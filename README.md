
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {rjts}

<!-- badges: start -->

[![R-CMD-check Build
Status](https://github.com/brownag/rjts/workflows/R-CMD-check/badge.svg)](https://github.com/brownag/rjts/actions)
[![rjts
Manual](https://img.shields.io/badge/docs-HTML-informational)](https://humus.rocks/rjts/)
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

Once the package is installed, you will need to install the required JAR
files.

``` r
library(rjts)
#> rjts (#.#.#) -- R interface to the JTS Topology Suite
#> 
#>   Unable to load JTS JAR files! Perhaps the package was installed with an empty 'inst/java' directory?
#>    - Run `install_jts()` to download libraries from GitHub <https://github.com/locationtech/jts/releases>. Then, re-install the package. 
#>    - It may be convenient to use a local instance of the GitHub repository to install from. See instructions at <https://humus.rocks/rjts/>
```

You can download and install JAR libraries from GitHub
\<<https://github.com/locationtech/jts/releases>\> with `install_jts()`.
You will need to run this installation command in a *local* instance of
the package repository that you can then install the package from
(again).

For instance, you can do:

``` sh
git clone http://github.com/brownag/rjts.git
Rscript -e "rjts::install_jts('rjts')"
Rscript -e "remotes::install_local('rjts', force = TRUE)"
```

This clones the Git repository, runs `install_jts()` (requires {rjts} be
installed from GitHub as above), then runs `remotes::install_local()` to
*re-install* from the local instance of the package (where `"inst/java"`
has been populated with relevant JAR files).

``` r
library(rjts)

#> rjts (#.#.#) -- R interface to the JTS Topology Suite
#> Added JTS version #.#.# to Java classpath
#>   JAR files:
#>      jts-core-#.#.#.jar
#>      JTSTestBuilder.jar
```

## Example

This is an example showing how to read and write Well-Known Text (WKT)
and Well-Known Binary (WKB).

You can perform various basic geometric operations by accessing
[`Geometry`](https://locationtech.github.io/jts/javadoc/org/locationtech/jts/geom/Geometry.html)
class methods exposed in the `read()` result object. Use `$` to access
methods.

``` r
library(rjts)
#> rjts (0.1.1) -- R interface to the JTS Topology Suite
#> Added JTS version 1.19.0 to Java classpath
#>   JAR files:
#>  jts-core-1.19.0.jar
#>  JTSTestBuilder.jar

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
