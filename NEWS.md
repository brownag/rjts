# rjts 0.2.0

## Major Changes

* JAR files are now downloaded and stored in a user-specific data directory using `tools::R_user_dir("rjts", which = "data")` instead of the package `inst/java` directory. This keeps the git repository clean and avoids bundling large JAR files.

   * Users no longer need to clone the repository and re-install the package. Simply run `install_jts()` after installing the package to download JAR files, which are then automatically loaded on subsequent package loads.

* Added explicit dependency on R >= 4.0 to support `tools::R_user_dir()`.

## Minor Changes

* Improved user messaging in `install_jts()` to show where JAR files are stored
* Updated `.onLoad()` and `.onAttach()` to load JARs from user data directory via `rJava::.jaddClassPath()`
* Simplified `uninstall_jts()` function signature

---

# rjts 0.1.1

## Major Changes

* Added JAR file installer function `install_jts()` to download JTS from GitHub releases
* Removed bundled JAR files from repository
* Added WKB (Well-Known Binary) support functions

## Minor Changes

* Added GitHub URLs to DESCRIPTION
* Updated documentation and README

---

# rjts 0.1.0

## Initial Release

* Basic rJava wrapper for the JTS Topology Suite
* Support for reading/writing WKT (Well-Known Text) with `WKTReader()` and `WKTWriter()`
* Access to core JTS Geometry class methods
* GH Actions CI/CD integration with pkgdown documentation
