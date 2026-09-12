<#
.SYNOPSIS
    Publish Acorn's Delight to GitHub: create the repository and push main + all tags.

.DESCRIPTION
    This script deliberately uses ONLY git and the GitHub REST API:

      * github.com serves git-over-HTTPS and api.github.com fine on most networks,
        but plain web/release downloads are often blocked, which is what the GitHub
        CLI installer needs. So this script never tries to install gh.

      * You supply a Personal Access Token (PAT) once. It is used to create the
        repository and to authenticate the push, and it is never written to disk
        (the git remote is reset to the clean URL afterwards).

    What it does:
      1. Verifies you are in the Acorn's Delight project root and that it is a git repo
      2. Reads and validates your token, and discovers your GitHub username
      3. Creates the repository (skips creation if it already exists)
      4. Pushes the main branch and every tag
      5. Writes the real repository URL into README.md and CHANGELOG.md
      6. Removes the token from the git remote configuration

    Safe to re-run.

    NOTE: this file is intentionally pure ASCII so Windows PowerShell 5.1 parses it
    correctly regardless of the encoding it is saved in.

.PARAMETER Token
    A GitHub Personal Access Token. If omitted you will be prompted for it
    (input is hidden). Classic tokens need the "repo" scope; fine-grained tokens
    need "Repository permissions -> Administration: Read and write" so the
    repository can be created (or create the repo yourself and only "Contents: Read and write").

.PARAMETER RepoName
    Repository name. Default: Acorns-Delight

.PARAMETER Visibility
    public or private. Default: public

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\init-github.ps1
    # then paste the token when prompted

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\init-github.ps1 -RepoName MyMod -Visibility private

.NOTES
    Token page: https://github.com/settings/tokens
#>

[CmdletBinding()]
param(
    [string]$Token,

    [string]$RepoName = "Acorns-Delight",

    [ValidateSet("public", "private")]
    [string]$Visibility = "public",

    [string]$Description = "Acorn's Delight - a small Farmer's Delight style Fabric mod for Minecraft 26.1. Acorns drop from oak leaves; turn them into Acorn Jam."
)

$ErrorActionPreference = "Stop"
$ApiBase = "https://api.github.com"

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

Write-Step "Checking that this is the Acorn's Delight project root"

if (-not (Test-Path ".\gradle.properties") -or -not (Test-Path ".\src\main\resources\fabric.mod.json")) {
    throw "Run this script from the Acorn's Delight project root (the folder containing gradle.properties and src), e.g.  powershell -ExecutionPolicy Bypass -File .\scripts\init-github.ps1 Current: $(Get-Location)"
}

if (-not (Select-String -Path ".\src\main\resources\fabric.mod.json" -Pattern 'acorn_delight' -Quiet)) {
    throw "This does not look like the Acorn's Delight project (acorn_delight missing from fabric.mod.json)."
}

if (-not (Test-Path ".\.git")) {
    throw "Not a git repository yet. Run these first: git init -b main ; git add -A ; git commit -m 'Release 1.0' ; git tag 1.0"
}

if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
    throw "git not found. Install Git for Windows first: https://git-scm.com/download/win"
}

$version = (Select-String -Path ".\gradle.properties" -Pattern '^version=(.+)$').Matches[0].Groups[1].Value.Trim()
$tags = @(git tag)
Write-Ok "Project root: $(Get-Location)"
Write-Ok "Mod version:  $version"
if ($tags.Count -gt 0) { Write-Ok "Local tags:   $($tags -join ', ')" }
else { Write-Note "No tags found. Releases should be tagged; you can add one with: git tag $version" }

if (-not (git log --oneline -1 2>$null)) {
    throw "The repository has no commits yet. Commit your work first."
}

# ------------------------------------------------------------------ 1. Token

Write-Step "Reading your GitHub token"

if (-not $Token) {
    Write-Host "    Create one at https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host "    (classic token with the 'repo' scope is simplest)" -ForegroundColor Yellow
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
    "User-Agent"           = "acorns-delight-init"
}

Write-Step "Checking the token against api.github.com"

try {
    $me = Invoke-RestMethod -Uri "$ApiBase/user" -Headers $headers -Method Get -TimeoutSec 30
}
catch {
    throw "Token rejected by GitHub: $($_.Exception.Message)`nCheck that the token is valid and not expired."
}

$ghUser = $me.login
Write-Ok "Authenticated as: $ghUser"

$repoUrl = "https://github.com/$ghUser/$RepoName"
$cleanRemote = "$repoUrl.git"
$authRemote = "https://$ghUser`:$Token@github.com/$ghUser/$RepoName.git"

# -------------------------------------------------------- 2. Create the repo

Write-Step "Creating repository $ghUser/$RepoName ($Visibility)"

$exists = $false
try {
    $null = Invoke-RestMethod -Uri "$ApiBase/repos/$ghUser/$RepoName" -Headers $headers -Method Get -TimeoutSec 30
    $exists = $true
}
catch { }

if ($exists) {
    Write-Note "Repository already exists; will push to it."
}
else {
    $body = @{
        name        = $RepoName
        description = $Description
        private     = ($Visibility -eq "private")
        has_issues  = $true
        has_wiki    = $false
    } | ConvertTo-Json

    try {
        $null = Invoke-RestMethod -Uri "$ApiBase/user/repos" -Headers $headers -Method Post `
            -Body $body -ContentType "application/json" -TimeoutSec 60
        Write-Ok "Repository created"
    }
    catch {
        throw @"
Failed to create the repository: $($_.Exception.Message)

If your token cannot create repositories, create it by hand instead:
  1. Open $repoUrl in a browser and create an empty PUBLIC repository named $RepoName
     (do NOT let GitHub add a README, .gitignore or licence)
  2. Re-run this script; it will detect the existing repository and just push.
"@
    }
}

# ---------------------------------------------------------- 3. Configure remote

Write-Step "Configuring the git remote"

if ((git remote) -contains "origin") {
    git remote set-url origin $cleanRemote
    Write-Ok "origin updated to $cleanRemote"
}
else {
    git remote add origin $cleanRemote
    Write-Ok "origin set to $cleanRemote"
}

# ------------------------------------------------------------------ 4. Push

Write-Step "Pushing the main branch and all tags"

# The token is supplied per-command on the URL rather than stored in .git/config,
# so it never ends up on disk in plain text.
$pushed = $false
try {
    git push $authRemote "refs/heads/main:refs/heads/main"
    if ($LASTEXITCODE -ne 0) { throw "git push exited with $LASTEXITCODE" }
    Write-Ok "main pushed"

    git push $authRemote --tags
    if ($LASTEXITCODE -ne 0) { Write-Note "Tag push failed; retry later with the same command." }
    else { Write-Ok "Tags pushed" }

    $pushed = $true
}
finally {
    # Make sure the token cannot linger in the process command line or config
    git remote set-url origin $cleanRemote 2>$null
}

if (-not $pushed) { throw "Push failed. Check your network and token permissions." }

# ------------------------------------------------- 5. Fill in the URL in the docs

Write-Step "Writing the repository URL into README.md and CHANGELOG.md"

$patched = $false
foreach ($file in @("README.md", "CHANGELOG.md")) {
    if (-not (Test-Path $file)) { continue }
    $text = Get-Content $file -Raw
    if ($text.Contains("https://github.com/OWNER/REPO")) {
        $text = $text.Replace("https://github.com/OWNER/REPO", $repoUrl)
        # UTF-8 without BOM keeps the docs byte-identical to the source files
        [System.IO.File]::WriteAllText((Resolve-Path $file).Path, $text, (New-Object System.Text.UTF8Encoding($false)))
        Write-Ok "$file updated"
        $patched = $true
    }
}

if ($patched) {
    # Documentation-only commit. The published tag is intentionally NOT moved:
    # once a tag is pushed it should stay where it is.
    git add README.md CHANGELOG.md
    git commit -m "docs: fill in the GitHub repository URL" | Out-Null
    git push $authRemote "refs/heads/main:refs/heads/main"
    git remote set-url origin $cleanRemote 2>$null
    Write-Ok "Committed and pushed (tag $version left untouched)"
}

# -------------------------------------------------------------------- Done

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Done! Repository: $repoUrl" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Releasing a new version later (example: 1.1):" -ForegroundColor Cyan
Write-Host "  1. Set version=1.1 in gradle.properties"
Write-Host "  2. Describe the changes in CHANGELOG.md"
Write-Host "  3. Verify:  .\gradlew.bat runGameTest build"
Write-Host "  4. Commit and tag with the same name:"
Write-Host "       git add -A"
Write-Host "       git commit -m ""Release 1.1: support Minecraft 26.2"""
Write-Host "       git tag 1.1"
Write-Host "       git push origin main"
Write-Host "       git push origin 1.1"
Write-Host ""
Write-Host "Versioning: X.0 for big changes (new mechanics/gameplay), X.Y for small ones (compat fixes/optimisations)." -ForegroundColor Cyan
Write-Host ""
Write-Host "Security note: the token was only used for this push and was not saved." -ForegroundColor DarkGray
Write-Host "You can revoke it any time at https://github.com/settings/tokens" -ForegroundColor DarkGray
