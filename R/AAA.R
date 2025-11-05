#' @importFrom rJava .jinit .jpackage .jaddClassPath
#' @importFrom tools R_user_dir
.onLoad <- function(libname, pkgname) {

  # rJava setup
  rJava::.jinit()

  # Get JAR files from user data directory
  datadir <- tools::R_user_dir(pkgname, which = "data")
  jar_files <- .JARfiles(datadir)

  # Add JAR files from user data directory to classpath (if they exist)
  # Note: Installation is now optional and user-driven via install_jts()
  if (length(jar_files) > 0) {
    jar_paths <- file.path(datadir, jar_files)
    for (jar in jar_paths) {
      rJava::.jaddClassPath(jar)
    }
  }
}

.JARfiles <- function(dir) {
  if (!dir.exists(dir)) {
    return(character(0))
  }
  list.files(dir, pattern = "\\.jar$", full.names = FALSE)
}

#' @importFrom rJava .jnew
#' @importFrom utils packageVersion packageStartupMessage
#' @importFrom tools R_user_dir
.onAttach <- function(libname, pkgname) {
  ver <- JTSVersion()
  datadir <- tools::R_user_dir(pkgname, which = "data")
  jar_files <- .JARfiles(datadir)

  # Build the startup message
  pkg_ver <- tryCatch(packageVersion("rjts"), error = function(e) "unknown")
  base_msg <- paste0("rjts (", pkg_ver, ") -- R interface to the JTS Topology Suite")

  # Handle different states: JARs loaded, JARs not found, version not found
  if (length(jar_files) == 0) {
    # No JARs found - provide helpful message
    cpmsg <- paste0("\n\n  No JTS JAR files found. Run `install_jts()` to download libraries from GitHub.\n",
                    "  JAR files will be installed to:\n    ", datadir)
  } else if (inherits(ver, 'try-error') || ver == "<no-version>") {
    # JARs found but can't determine version - graceful fallback
    cpmsg <- paste0("\n  JAR files found:\n    ",
                    paste0(jar_files, collapse = "\n    "),
                    "\n  (unable to determine JTS version)")
  } else {
    # Success - JARs loaded and version determined
    cpmsg <- paste0("\n  JTS version: ", ver, "\n  JAR files:\n    ",
                    paste0(jar_files, collapse = "\n    "))
  }

  packageStartupMessage(paste0(base_msg, cpmsg))
}
