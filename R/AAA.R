#' @importFrom rJava .jinit .jpackage
.onLoad <- function(libname, pkgname) {

  # rJava setup
  rJava::.jinit()

  if (length(.JARfiles(libname, pkgname)) == 0) {
    # NOTE: this should probably not be done on CRAN
    #       is there a better way to make sure the JAR is present?
    if (interactive()) {
      res <- try(install_jts(quiet = TRUE))
      if (inherits(res, 'try-error')){
        message(res[1])
      }
    }
  }

  # we load everything in inst/java
  rJava::.jpackage(pkgname, lib.loc = libname)
}

.JARfiles <- function(libname, pkgname) {
  list.files(file.path(libname, pkgname, "inst/java"), pattern = "\\.jar")
}

#' @importFrom rJava .jnew
#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
  ver <- JTSVersion()
  cpmsg <- ifelse(inherits(ver, 'try-error') || ver == "<no-version>",
                  "\n\n  Unable to load JTS JAR files! Perhaps the package was installed with an empty 'inst/java' directory?
                   \n   - Run `install_jts()` to download libraries from GitHub <https://github.com/locationtech/jts/releases>
                   \n   - Then, re-install the package. It may be convenient to use a local instance of the GitHub repository to install from.",
                  paste0("\nAdded JTS version ", ver, " to Java classpath\n",
                         paste0(c("  JAR files:", .JARfiles(libname, pkgname)), collapse = "\n\t")))
  packageStartupMessage(paste0("rjts (", packageVersion("rjts"), ") -- R interface to the JTS Topology Suite", cpmsg))
}
