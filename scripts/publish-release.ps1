<#
.SYNOPSIS
    Create (or refresh) a GitHub Release for Acorn's Delight and attach the built jar.

.DESCRIPTION
    Uses only git + the GitHub REST API, because some networks block GitHub's web
    and release-download domains while api.github.com keeps working.

    The release body is taken from the matching "## [<version>]" section of
    CHANGELOG.md, so the changelog stays the single source of truth.

    What it does:
      1. Verifies the project, the version and that build/libs/<name>-<version>.jar exists
      2. Requires that the matching git tag exists and is already pushed
         (run scripts/init-github.ps1 or `git push origin <tag>` first)
      3. Creates the release, or updates it if it already exists
      4. Uploads the jar as a release asset, replacing an asset of the same name

    Safe to re-run.

    NOTE: this file is intentionally pure ASCII so Windows PowerShell 5.1 parses it
    correctly regardless of the encoding it is saved in.

.PARAMETER Version
    Version to release, e.g. 1.1.0. Defaults to the `version` in gradle.properties.

.PARAMETER Token
    GitHub Personal Access Token with "repo" scope (classic) or
    "Contents: Read and write" (fine-grained). If omitted, the GITHUB_TOKEN
    environment variable is used, then you are prompted (hidden input).

.PARAMETER Draft
    Create the release as a draft instead of publishing it immediately.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\publish-release.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\publish-release.ps1 -Version 1.1.1

.NOTES
    Token page: https://github.com/settings/tokens
#>

[CmdletBinding()]
param(
    [string]$Version,
    [string]$Token,
    [switch]$Draft
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Write-Ok([string]$Text) {
    Write-Host "    [OK] $Text" -ForegroundColor Green
}

function Write-Note([string]$Text) {
    Write-Host "    [!] $Text" -ForegroundColor Yellow
}

# ------------------------------------------------------------- 0. Sanity check

Write-Step "Checking the project and the build output"

if (-not (Test-Path ".\gradle.properties") -or -not (Test-Path ".\src\main\resources\fabric.mod.json")) {
    throw "Run this script from the Acorn's Delight project root (the folder containing gradle.properties and src). Current: $(Get-Location)"
}

if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    throw "git not found in PATH."
}

if (-not $Version) {
    $Version = (Select-String -Path ".\gradle.properties" -Pattern '^version=(.+)$').Matches[0].Groups[1].Value.Trim()
}
if (-not $Version) { throw "Could not determine the version. Pass -Version explicitly." }

$archiveName = (Select-String -Path ".\gradle.properties" -Pattern '^archives_base_name=(.+)$').Matches[0].Groups[1].Value.Trim()
$jarPath = Join-Path (Get-Location) "build\libs\$archiveName-$Version.jar"

Write-Ok "Version: $Version"
Write-Ok "Jar:     build\libs\$archiveName-$Version.jar"

if (-not (Test-Path $jarPath)) {
    throw @"
Build output not found: build\libs\$archiveName-$Version.jar

Build it first (this also runs the in-game tests):
    .\gradlew.bat runGameTest build
"@
}
$jarInfo = Get-Item $jarPath
Write-Ok ("Jar size: {0:N0} bytes" -f $jarInfo.Length)

# --------------------------------------------------------- 1. Tag must exist

Write-Step "Checking that tag $Version exists and is pushed"

$localTag = git tag -l "$Version"
if (-not $localTag) {
    throw "Local tag '$Version' does not exist. Create and push it first: git tag $Version ; git push origin $Version"
}
$remoteTag = (git ls-remote --tags origin "refs/tags/$Version" 2>$null)
if (-not $remoteTag) {
    Write-Note "Tag $Version is not on the remote yet; pushing it."
    git push origin "$Version"
    if ($LASTEXITCODE -ne 0) { throw "Failed to push tag $Version." }
}
Write-Ok "Tag $Version is present locally and on origin"

# ---------------------------------------------------------------- 2. Token

$headers = $null
if (-not $Token) { $Token = $env:GITHUB_TOKEN }
if (-not $Token) {
    Write-Step "Reading your GitHub token"
    Write-Host "    Create one at https://github.com/settings/tokens (classic, 'repo' scope)" -ForegroundColor Yellow
    $secure = Read-Host "    Paste your GitHub token (input hidden)" -AsSecureString
    $Token = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}
$Token = $Token.Trim()
if (-not $Token) { throw "No token supplied." }

$headers = @{
    Authorization          = "Bearer $Token"
    Accept                 = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "acorns-delight-release"
}

Write-Step "Verifying the token"
try {
    $me = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -TimeoutSec 30
}
catch {
    throw "Token rejected by GitHub: $($_.Exception.Message)"
}
$ghUser = $me.login
Write-Ok "Authenticated as: $ghUser"

# Determine the repository from the git remote (owner/repo)
$remoteUrl = (git remote get-url origin)
if ($remoteUrl -match 'github\.com[:/]+([^/]+)/([^/]+?)(\.git)?$') {
    $owner = $Matches[1]
    $repo = $Matches[2]
}
else {
    throw "Could not parse the GitHub owner/repo from the origin remote: $remoteUrl"
}
Write-Ok "Repository: $owner/$repo"

# ------------------------------------------------- 3. Build the release body

# Release notes live in release-notes/<version>.md and are written in ENGLISH.
# Reason: GitHub renders them for an international audience, and a dedicated file per
# version is far easier to keep tidy than slicing a section out of CHANGELOG.md.
#
# CHANGELOG.md (Chinese) remains the canonical in-repo history; it is only used as a
# fallback when no release-notes file exists yet.
Write-Step "Building the release notes for $Version"

$body = ""
$notesPath = ".\release-notes\$Version.md"

if (Test-Path $notesPath) {
    $body = ([System.IO.File]::ReadAllText((Resolve-Path $notesPath).Path,
        (New-Object System.Text.UTF8Encoding($false)))).Trim()
    Write-Ok "Using release-notes\$Version.md ($($body.Length) chars)"
}
else {
    Write-Note "release-notes\$Version.md not found; falling back to CHANGELOG.md."

    if (Test-Path ".\CHANGELOG.md") {
        $changelog = [System.IO.File]::ReadAllText((Resolve-Path ".\CHANGELOG.md").Path, (New-Object System.Text.UTF8Encoding($false)))
        $lines = $changelog -split "`r?`n"
        $collect = $false
        $buffer = New-Object System.Collections.Generic.List[string]
        foreach ($line in $lines) {
            if ($line -match "^##\s+\[?$([regex]::Escape($Version))\]?") { $collect = $true; continue }
            elseif ($collect -and $line -match "^##\s") { break }
            if ($collect) { $buffer.Add($line) }
        }
        if ($buffer.Count -gt 0) {
            $body = ($buffer -join "`n").Trim()
            Write-Ok "Pulled $($buffer.Count) lines from the CHANGELOG"
        }
    }
}

if (-not $body) { $body = "Acorn's Delight $Version" }

# Keep the notes ASCII-only so they survive every encoding path unharmed.
$nonAscii = ([regex]::Matches($body, '[^\x00-\x7F]')).Count
if ($nonAscii -gt 0) {
    Write-Note "Release notes contain $nonAscii non-ASCII characters. They will be sent as UTF-8;"
    Write-Note "prefer English (ASCII) notes in release-notes/<version>.md to avoid any doubt."
}

# ---------------------------------------------------- 4. Create the release

Write-Step "Creating or updating the release $Version"

$name = "Acorn's Delight $Version"
$existing = $null
try {
    $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/tags/$Version" -Headers $headers -TimeoutSec 30
}
catch { }

# Serialise the payload to UTF-8 BYTES ourselves.
#
# This is the important part. Windows PowerShell 5.1's ConvertTo-Json escapes non-ASCII
# characters as \uXXXX, and Invoke-RestMethod encodes a *string* body as ISO-8859-1, so
# those \uXXXX sequences get flattened to '?' on GitHub. Passing raw UTF-8 bytes with an
# explicit charset keeps every character intact.
$jsonText = [ordered]@{
    tag_name   = $Version
    name       = $name
    body       = $body
    draft      = [bool]$Draft
    prerelease = $false
} | ConvertTo-Json -Depth 5 -Compress

$payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonText)

if ($existing) {
    Write-Note "Release already exists (id $($existing.id)); updating it."
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/$($existing.id)" `
        -Headers $headers -Method Patch -Body $payloadBytes `
        -ContentType "application/json; charset=utf-8" -TimeoutSec 60
    Write-Ok "Release updated"
}
else {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases" `
        -Headers $headers -Method Post -Body $payloadBytes `
        -ContentType "application/json; charset=utf-8" -TimeoutSec 60
    Write-Ok "Release created"
}
$releaseUrl = $release.html_url

# ------------------------------------------------------ 5. Upload the asset

Write-Step "Uploading $($jarInfo.Name) as a release asset"

$assets = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/$($release.id)/assets" -Headers $headers -TimeoutSec 30

# GitHub rejects an upload whose name already exists, so remove any previous copy first.
foreach ($a in @($assets)) {
    if ($a -and $a.name -eq $jarInfo.Name) {
        Write-Note "Removing the previous '$($a.name)' asset (id $($a.id))"
        Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases/assets/$($a.id)" `
            -Headers $headers -Method Delete -TimeoutSec 60 | Out-Null
    }
}

$uploadUrl = "https://uploads.github.com/repos/$owner/$repo/releases/$($release.id)/assets?name=$([uri]::EscapeDataString($jarInfo.Name))"

Add-Type -AssemblyName System.Net.Http
$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromMinutes(10)
$client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $Token)
$client.DefaultRequestHeaders.UserAgent.ParseAdd("acorns-delight-release")
$client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github+json")

$stream = $null
try {
    $stream = [System.IO.File]::OpenRead($jarInfo.FullName)
    $content = New-Object System.Net.Http.StreamContent($stream)
    $content.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue("application/java-archive")

    $response = $client.PostAsync($uploadUrl, $content).GetAwaiter().GetResult()
    $text = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()

    if (-not $response.IsSuccessStatusCode) {
        throw "Upload failed ($([int]$response.StatusCode)): $text"
    }

    $asset = $text | ConvertFrom-Json
    Write-Ok "Uploaded: $($asset.name) ($('{0:N0}' -f $asset.size) bytes)"
    Write-Ok "Download: $($asset.browser_download_url)"
}
finally {
    if ($stream) { $stream.Dispose() }
    $client.Dispose()
}

# -------------------------------------------------------------------- Done

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Released Acorn's Delight $Version" -ForegroundColor Green
Write-Host " Release : $releaseUrl" -ForegroundColor Green
Write-Host " Download: $releaseUrl/download/$Version/$($jarInfo.Name)" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Security note: the token was only used for these API calls and was not saved." -ForegroundColor DarkGray
Write-Host "Revoke it any time at https://github.com/settings/tokens" -ForegroundColor DarkGray
