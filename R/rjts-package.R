#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' Get JTS Version
#'
#' Convenience method for accessing the version number for the currently-loaded JTS library.
#'
#' When the JTS core library is loaded by rJava, either `.onAttach()` or after `install_jts()`, the _org.locationtech.jts.JTSVersion_ class static fields are read to determine the current version. This value is stored in the package option `rjts.JTS_VERSION`.
#'
#' @return character. Semantic version number of loaded JTS library.
#' @export
JTSVersion <- function() {
  ver <- try(rJava::.jnew("org.locationtech.jts.JTSVersion")$toString())
  if (inherits(ver, 'try-error')) {
    ver <- "<no-version>"
  } else {
    options(rjts.JTS_VERSION = ver)
  }
  ver
}
