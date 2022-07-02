# install JTS

#' Get Latest JTS GitHub Release Tags
#'
#' @param n integer. number of latest releases to return (default `n = 1`)
#' @param release_file character. URL of e.g. _releases.atom_ file; Default: `"https://github.com/locationtech/jts/releases.atom"`
#' @param pattern character. REGEX pattern (containing one capture group) that can parse URLs from `release_file`
#' @param ... additional arguments passed to `utils::download.file()` (e.g. `quiet`, `method`)
#' @return character. one or more URLs to recent releases
#' @noRd
#' @keywords internal
#' @importFrom utils download.file
.get_latest_JTS_release_tags <- function(n = 1,
                                         release_file = "https://github.com/locationtech/jts/releases.atom",
                                         pattern = ".*href=\"(.*/tag/.*)\"/>|.*",
                                         ...) {
  tf <- tempfile()
  utils::download.file(release_file, destfile = tf, ...)
  x <- trimws(gsub(pattern, "\\1", readLines(tf)))
  unlink(tf)
  x2 <- x[x != ""]
  if (n > length(x2)) return(x2)
  x2[seq_len(n)]
}

#' Get GitHub Download Path for JTS Core JAR file
#'
#' @param tagurls one or more URLs to recent releases
#'
#' @return character. one or more URLs to recent release JAR file
#' @noRd
#' @keywords internal
#' @aliases .get_JTS_core_GH_path .get_JTS_javadoc_GH_path .get_JTS_sources_GH_path .get_JTS_tesbuilder_GH_path
.get_JTS_GH_path <- function(tagurls, prefix = "", suffix = ".jar", dir_only = FALSE) {
  # e.g. https://github.com/locationtech/jts/releases/tag/1.19.0
  bn <- basename(tagurls)
  fn <- paste0(prefix, bn, suffix)
  dr <- gsub("/tag/", "/download/", tagurls)
  if (dir_only) return(dr)
  file.path(dr, fn)
}

#' @noRd
#' @keywords internal
.get_JTS_core_GH_path <- function(tagurls) {
  # e.g. https://github.com/locationtech/jts/releases/download/1.19.0/jts-core-1.19.0.jar
  .get_JTS_GH_path(tagurls = tagurls, prefix = c("jts-core-"
                                                 # ,"jts-io-common-"
                                                 ), suffix = ".jar")
}

#' @noRd
#' @keywords internal
.get_JTS_javadoc_GH_path <- function(tagurls) {
  # e.g. https://github.com/locationtech/jts/releases/download/1.19.0/jts-core-1.19.0-javadoc.jar
  .get_JTS_GH_path(tagurls = tagurls, prefix = c("jts-core-"
                                                 # , "jts-io-common-"
                                                 ), suffix = "-javadoc.jar")
}

#' @noRd
#' @keywords internal
.get_JTS_sources_GH_path <- function(tagurls) {
  # e.g. https://github.com/locationtech/jts/releases/download/1.19.0/jts-core-1.19.0-sources.jar
  .get_JTS_GH_path(tagurls = tagurls, prefix = c("jts-core-"
                                                 # ,"jts-io-common-"
                                                 ), suffix = "-sources.jar")
}

#' @noRd
#' @keywords internal
.get_JTS_testbuilder_GH_path <- function(tagurls) {
  # e.g. https://github.com/locationtech/jts/releases/download/1.19.0/JTSTestBuilder.jar
  file.path(.get_JTS_GH_path(tagurls = tagurls, dir_only = TRUE), "JTSTestBuilder.jar")
}

#' Install JTS Topology Suite from Latest GitHub Release
#'
#' Downloads JTS JAR files to `inst/java` using `utils::download.file(..., mode="wb")`
#'
#' @param path Package folder to install into; Default: `find.package("rjts")`
#' @param url Optional: custom URL or path to JAR file
#' @param javadoc Download Javadoc JAR? Default: `FALSE`
#' @param sources Download sources JAR? Default: `FALSE`
#' @param testbuilder Download JTS Test Builder JAR? Default: `TRUE`
#' @param overwrite Overwrite existing JAR file (if present)? Default `FALSE`
#' @param ... additional arguments passed to `utils::download.file()` (e.g. `quiet`, `method`)
#'
#' @return Downloads and installs JAR files to `file.path(find.package("rjts"), "inst", "java")`, then calls `rJava::.jpackage()` to load the JAR files into Java classpath.
#' @export
#' @importFrom rJava .jaddClassPath
#' @examples
#' \dontrun{
#' install_jts()
#' }
install_jts <- function(
           path = find.package("rjts"),
           url = NULL,
           javadoc = FALSE,
           sources = FALSE,
           testbuilder = TRUE,
           overwrite = FALSE,
           ...) {

  # short circuit for local file
  if (!is.null(url) && file.exists(url)) {
    return(invisible(file.copy(url, def, overwrite = overwrite)))
  }

  # use custom URL to either a release or a path to jar or find latest release
  if (!is.null(url) && !all(endsWith(url, ".jar"))) {
    pth <- .get_JTS_core_GH_path(url)
  } else if (!is.null(url) && all(endsWith(url, ".jar"))) {
    pth <- url
  } else {
    tag <- .get_latest_JTS_release_tags(n = 1, ...)
    pth <- .get_JTS_core_GH_path(tag)
  }

  defdir <- file.path(path, "inst", "java")
  extdir <- file.path(path, "inst", "extdata")
  if (!dir.exists(defdir)) {
    dir.create(defdir, recursive = TRUE)
  }
  if (!dir.exists(extdir)) {
    dir.create(extdir, recursive = TRUE)
  }
  def <- file.path(defdir, basename(pth))

  res <- try(download.file(pth, destfile = def, overwrite = overwrite, ...))

  if (inherits(res, 'try-error')) {
    what <- ifelse(is.null(url),
                   paste0(" latest version of JTS core (", basename(pth),
                          "); you can manually specify the URL/path to a JAR file via `url` argument"),
                   paste0("(", pth, ")"))
    res <- try(stop("Failed to install ", what, call. = FALSE))
    message(res[1])
  }

  # Assume if JAR files specified explicitly don't need any add'l remote paths
  if (!is.null(url) && all(endsWith(url, ".jar"))) {
    return(res)
  }

  if (javadoc) {
    pth <- .get_JTS_javadoc_GH_path(tag)
    def <- file.path(extdir, basename(pth))
    res <- try(download.file(pth, destfile = def, overwrite = overwrite, mode = "wb", ...))
    if (inherits(res, 'try-error')) {
      res <- try(stop("Failed to install latest version of JTS javadoc (", basename(pth),
                      "); you can manually specify the URL/path to a JAR file via `url` argument", call. = FALSE))
      message(res[1])
    }
  }

  if (sources) {
    pth <- .get_JTS_sources_GH_path(tag)
    def <- file.path(extdir, basename(pth))
    res <- try(download.file(pth, destfile = def, overwrite = overwrite, mode = "wb", ...))
    if (inherits(res, 'try-error')) {
      res <- try(stop("Failed to install latest version of JTS sources (", basename(pth),
                      "); you can manually specify the URL/path to a JAR file via `url` argument", call. = FALSE))
      message(res[1])
    }
  }

  if (testbuilder) {
    pth <- .get_JTS_testbuilder_GH_path(tag)
    def <- file.path(defdir, basename(pth))
    res <- try(download.file(pth, destfile = def, overwrite = overwrite, mode = "wb", ...))
    if (inherits(res, 'try-error')) {
      res <- try(stop("Failed to install latest version of JTS Test Builder (", basename(pth),
                      "); you can manually specify the URL/path to a JAR file via `url` argument", call. = FALSE))
      message(res[1])
    }
  }

  if (!inherits(res, 'try-error')) {
    "Install complete. You will now need to re-install the R package with the new `inst/java` folder."
  }

  invisible(res)
}

#' Remove JAR files from package `"/inst/"` folder
#'
#' @param libname Library name; default: `dirname(find.package(pkgname))`
#' @param pkgname Package name; default: `"rjts"`
#' @param pattern Passed to `file.path()` REGEX pattern to match
#'
#' @return result of recursive `file.remove()`,  invisbly
#' @export
#'
#' @examples
#' \dontrun{
#' uninstall_jts()
#' }
uninstall_jts <- function(libname = dirname(find.package(pkgname)), pkgname = "rjts", pattern = "\\.jar$") {
  invisible(file.remove(list.files(file.path(libname, pkgname, "inst"), pattern = pattern, recursive = TRUE, full.names = TRUE)))
}
