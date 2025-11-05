
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {rjts}

<!-- badges: start -->

[![rjts
Manual](https://img.shields.io/badge/docs-HTML-informational)](https://humus.rocks/rjts/)
[![R-CMD-check](https://github.com/brownag/rjts/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/brownag/rjts/actions/workflows/R-CMD-check.yml)
<!-- badges: end -->

The goal of {rjts} is to provide a basic {rJava} wrapper for the JTS
Topology Suite \<<https://www.osgeo.org/projects/jts/>\>.

Check out the Javadoc \<<https://locationtech.github.io/jts/javadoc/>\>
to see the tools that are provided via JTS.

## Installation

You can install the development version of {rjts} with {remotes}

``` r
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("brownag/rjts")
```

Requires R \>= 4.0 and {rJava}.

Once the package is installed, you will need to download the required
JAR files using `install_jts()`:

``` r
library(rjts)
#> rjts (#.#.#) -- R interface to the JTS Topology Suite
#>
#>   Unable to load JTS JAR files! JARs should be downloaded to:
#>     ~/.local/share/R/rjts/
#>
#>   Run `install_jts()` to download libraries from GitHub <https://github.com/locationtech/jts/releases>.

install_jts()
#> Install complete! JAR files are now available at: ~/.local/share/R/rjts/
```

After running `install_jts()`, the JAR files will be automatically
loaded when you load the package:

``` r
library(rjts)

#> rjts (#.#.#) -- R interface to the JTS Topology Suite
#> Added JTS version #.#.# to Java classpath
#>   JAR files:
#>      jts-core-#.#.#.jar
#>      JTSTestBuilder.jar
```

JAR files are stored in a user-specific data directory as determined by
`tools::R_user_dir("rjts", which = "data")`, which respects
`R_USER_DATA_DIR`, `XDG_DATA_HOME`, and platform defaults. This approach
avoids the need to bundle JAR files in the package and keeps the git
repository clean.

## Example

This is an example showing how to read and write Well-Known Text (WKT)
and Well-Known Binary (WKB).

You can perform various basic geometric operations by accessing
[`Geometry`](https://locationtech.github.io/jts/javadoc/org/locationtech/jts/geom/Geometry.html)
class methods exposed in the `read()` result object. Use `$` to access
methods.

``` r
library(rjts)
#> rjts (0.2.0) -- R interface to the JTS Topology Suite
#>   JTS version: 1.20.0
#>   JAR files:
#>     jts-core-1.20.0.jar
#>     JTSTestBuilder.jar

wr <- WKTReader()

# read a MULTIPOLYGON from character vector
x <- wr$read("MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)),
                           ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),
                           (30 20, 20 15, 20 25, 30 20)))")
x$getGeometryType()
#> [1] "MultiPolygon"

# use the WKTWriter to return Well-Known Text
ww <- WKTWriter()
ww$writeFormatted(x$convexHull())
#> [1] "POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))"

# use the WKBWriter to return Well-Known Binary
wb <- WKBWriter()
y <- wb$write(x$convexHull())

class(y)
#> [1] "raw"
y
#>   [1] 00 00 00 00 03 00 00 00 01 00 00 00 08 40 3e 00 00 00 00 00 00 40 14 00 00
#>  [26] 00 00 00 00 40 24 00 00 00 00 00 00 40 24 00 00 00 00 00 00 40 24 00 00 00
#>  [51] 00 00 00 40 3e 00 00 00 00 00 00 40 34 00 00 00 00 00 00 40 46 80 00 00 00
#>  [76] 00 00 40 44 00 00 00 00 00 00 40 44 00 00 00 00 00 00 40 46 80 00 00 00 00
#> [101] 00 40 3e 00 00 00 00 00 00 40 46 80 00 00 00 00 00 40 34 00 00 00 00 00 00
#> [126] 40 3e 00 00 00 00 00 00 40 14 00 00 00 00 00 00

# use the WKBReader to convert Well-Known Binary to a JTS Geometry object
wbr <- WKBReader()
wbr$read(y)
#> [1] "Java-Object{POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))}"

# Geometry objects/results also have a toString() method that returns WKT
x$getBoundary()$toString()
#> [1] "MULTILINESTRING ((40 40, 20 45, 45 30, 40 40), (20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20))"
x$convexHull()$toString()
#> [1] "POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))"
```
