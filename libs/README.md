# Vendored compile-only dependencies

## `RoughlyEnoughItems-26.1.819.jar`

REI 26.1 is distributed **only** through Modrinth / CurseForge — neither
`maven.shedaniel.me` (stuck on the 12.0.x line) nor Maven Central carries a 26.1
build — so the jar is vendored here purely so that `AcornsDelightReiPlugin` can
be compiled against `me.shedaniel.rei.api.client.plugins.REIClientPlugin`.

Source: <https://modrinth.com/mod/rei/version/26.1.819+fabric>
(Licence: MIT — see the `LICENSE` entry inside the jar.)

It is declared as a `compileOnly files(...)` dependency, which means:

* it is **never** packaged into the built mod jar and never redistributed by this
  project, and
* at runtime the plugin class is loaded only if the user has actually installed
  REI, via the optional `rei_client` entrypoint in `fabric.mod.json`.

If REI ever publishes to a Maven repository, replace the
`compileOnly files("libs/...")` line in `build.gradle` with a normal
`compileOnly "..."` coordinate and delete this directory.
