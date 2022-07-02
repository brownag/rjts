#' Create Well-known Text Reader
#'
#' Creates a new reference to the JTS `WKTReader` class.
#'
#' @param ... Optional: A custom `GeometryFactory`
#'
#' @return an object of class `jobjRef` to new instance of `org.locationtech.jts.io.WKTReader`
#'
#' @export
WKTReader <- function(...) {
  rJava::.jnew("org.locationtech.jts.io.WKTReader", ...)
}

#' Create Well-known Text Writer
#'
#' Creates a new reference to the JTS `WKTWriter` class.
#'
#' @return an object of class `jobjRef` to new instance of `org.locationtech.jts.io.WKTWriter`
#'
#' @export
WKTWriter <- function() {
  rJava::.jnew("org.locationtech.jts.io.WKTWriter")
}
