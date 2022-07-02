
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rjts

<!-- badges: start -->
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

This is an example showing how to read Well-known Text (WKT), perform
various basic geometric operations, returning the WKT result.

``` r
library(rjts)
#> rjts (0.1.0.9000) -- R interface to the JTS Topology Suite
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

## TODO: WKBWriter example

# Geometry objects/results also have a toString() method that returns WKT
x$getBoundary()$toString()
#> [1] "MULTILINESTRING ((40 40, 20 45, 45 30, 40 40), (20 35, 10 30, 10 10, 30 5, 45 20, 20 35), (30 20, 20 15, 20 25, 30 20))"
x$convexHull()$toString()
#> [1] "POLYGON ((30 5, 10 10, 10 30, 20 45, 40 40, 45 30, 45 20, 30 5))"
```
