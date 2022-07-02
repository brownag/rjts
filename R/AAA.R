#' @importFrom rJava .jinit .jpackage
.onLoad <- function(libname, pkgname) {

  # rJava setup
  rJava::.jinit()

  # we load everything in inst/java
  rJava::.jpackage(pkgname, lib.loc = libname)

}

#' @importFrom rJava .jnew
#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
  options(rjts.JTS_VERSION = rJava::.jnew("org.locationtech.jts.JTSVersion")$toString())
  packageStartupMessage(paste0("rjts (", packageVersion("rjts"), ") -- R interface to the JTS Topology Suite\n",
                               "Added JTS version ", getOption("rjts.JTS_VERSION", "<no-version>"), " to Java classpath"))

}
