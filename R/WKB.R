
#' Create Well-known Binary Reader
#'
#' Creates a new reference to the JTS `WKBReader` class.
#'
#' @return an object of class `jobjRef` to new instance of `org.locationtech.jts.io.WKBReader`
#'
#' @export
WKBReader <- function() {
  rJava::.jnew("org.locationtech.jts.io.WKBReader")
}

#' Create Well-known Binary Writer
#'
#' Creates a new reference to the JTS `WKBWriter` class.
#'
#' @return an object of class `jobjRef` to new instance of `org.locationtech.jts.io.WKBWriter`
#'
#' @export
WKBWriter <- function() {
  rJava::.jnew("org.locationtech.jts.io.WKBWriter")
}
