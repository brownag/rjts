% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/install.R
\name{uninstall_jts}
\alias{uninstall_jts}
\title{Remove JAR files from package \code{"/inst/"} folder}
\usage{
uninstall_jts(
  libname = dirname(find.package(pkgname)),
  pkgname = "rjts",
  pattern = "\\\\.jar$"
)
}
\arguments{
\item{libname}{Library name; default: \code{dirname(find.package(pkgname))}}

\item{pkgname}{Package name; default: \code{"rjts"}}

\item{pattern}{Passed to \code{file.path()} REGEX pattern to match}
}
\value{
logical. result of recursive \code{all(file.remove(...))},  invisibly
}
\description{
Remove JAR files from package \code{"/inst/"} folder
}
\examples{
\dontrun{
uninstall_jts()
}
}
