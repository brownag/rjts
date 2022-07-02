
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rjts

<!-- badges: start -->

[![R-CMD-check Build
Status](https://github.com/brownag/rjts/workflows/R-CMD-check/badge.svg)](https://github.com/brownag/rjts/actions)
[![rjts
Manual](https://img.shields.io/badge/docs-HTML-informational)](https://humus.rocks/rjts/)
<!-- badges: end -->

The goal of {rjts} is to provide a basic {rJava} wrapper around JTS
Topology Suite \<<https://www.osgeo.org/projects/jts/>\>.

See the Javadoc \<<https://locationtech.github.io/jts/javadoc/>\> to see
the tools that are provided via JTS.

## Installation

You can install the development version of {rjts} thusly:

``` r
# install.packages("remotes")
remotes::install_github("brownag/rjts")
```

## Example

This is an example showing how to read and write Well-Known Text (WKT)
and Well-Known Binary. You can perform various basic geometric
operations by accessing
[`Geometry`](https://locationtech.github.io/jts/javadoc/org/locationtech/jts/geom/Geometry.html)
class methods exposed in the `read()` result object. Use `$` to access
methods.

``` r
library(rjts)
#> rjts (0.1.0.9001) -- R interface to the JTS Topology Suite
#> Added JTS version 1.19.0 to Java classpath

wr <- WKTReader()

# read a MULTIPOLYGON from character vector
x <- wr$read("MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)),
                           ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),
                           (30 20, 20 15, 20 25, 30 20)))")
x$getGeometryType()
#> [1] "MultiPolygon"

# use the WKTWriter to return Well-known text
ww <- WKTWriter()
ww$writeFormatted(x$convexHull())
#> [1] "POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))"

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

wbr <- WKBReader()
wbr$read(y)
#> [1] "Java-Object{POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))}"

# Geometry objects/results also have a toString() method that returns WKT
x$getBoundary()$toString()
#> [1] "MULTILINESTRING ((40 40, 20 45, 45 30, 40 40), (20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20))"
x$convexHull()$toString()
#> [1] "POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))"
```
