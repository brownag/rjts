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
#' Downloads JTS JAR files to user data directory using `utils::download.file(..., mode="wb")`.
#'
#' JAR files are stored in a platform-specific user data directory as determined by
#' `tools::R_user_dir("rjts", which = "data")`, which respects `R_USER_DATA_DIR`,
#' `XDG_DATA_HOME`, and platform defaults. This avoids the need to bundle JAR files
#' in the package or re-install the package after downloading JARs.
#'
#' @param url Optional: custom URL or path to JAR file
#' @param javadoc Download "Javadoc" JAR? Default: `FALSE`
#' @param sources Download "sources" JAR? Default: `FALSE`
#' @param testbuilder Download JTS Test Builder JAR? Default: `TRUE`
#' @param overwrite Overwrite existing JAR file (if present)? Default `FALSE`
#' @param ... additional arguments passed to `utils::download.file()` (e.g. `quiet`, `method`)
#'
#' @return Downloads and installs JAR files to user data directory (invisibly returns result).
#'   After running this function, the JAR files will be automatically loaded when the package is attached.
#' @export
#' @importFrom tools R_user_dir
#' @examples
#' \dontrun{
#' install_jts()
#' }
install_jts <- function(url = NULL,
                        javadoc = FALSE,
                        sources = FALSE,
                        testbuilder = TRUE,
                        overwrite = FALSE,
                        ...) {

  # Get user data directory for JARs
  defdir <- tools::R_user_dir("rjts", which = "data")
  if (!dir.exists(defdir)) {
    dir.create(defdir, recursive = TRUE)
  }

  # short circuit for local file
  if (!is.null(url) && file.exists(url)) {
    def <- file.path(defdir, basename(url))
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

  def <- file.path(defdir, basename(pth))

  res <- try(download.file(pth, destfile = def, overwrite = overwrite, mode = "wb", ...))

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
    return(invisible(res))
  }

  if (javadoc) {
    pth <- .get_JTS_javadoc_GH_path(tag)
    def <- file.path(defdir, basename(pth))
    res <- try(download.file(pth, destfile = def, overwrite = overwrite, mode = "wb", ...))
    if (inherits(res, 'try-error')) {
      res <- try(stop("Failed to install latest version of JTS javadoc (", basename(pth),
                      "); you can manually specify the URL/path to a JAR file via `url` argument", call. = FALSE))
      message(res[1])
    }
  }

  if (sources) {
    pth <- .get_JTS_sources_GH_path(tag)
    def <- file.path(defdir, basename(pth))
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
    message("Install complete! JAR files are now available at: ", defdir)
  }

  invisible(res)
}

#' Remove JAR files from user data directory
#'
#' @param pattern Passed to `list.files()` REGEX pattern to match JAR files
#'
#' @return logical. result of recursive `all(file.remove(...))`,  invisibly
#' @export
#' @importFrom tools R_user_dir
#'
#' @examples
#' \dontrun{
#' uninstall_jts()
#' }
uninstall_jts <- function(pattern = "\\.jar$") {
  datadir <- tools::R_user_dir("rjts", which = "data")
  if (!dir.exists(datadir)) {
    return(invisible(TRUE))
  }
  invisible(all(file.remove(
    list.files(
      datadir,
      pattern = pattern,
      recursive = TRUE,
      full.names = TRUE
    )
  )))
}
