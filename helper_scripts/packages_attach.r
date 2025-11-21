# packages_attach.r

## Check required packages ------------------------
options(repos = c(CRAN = "https://cran.rstudio.com/"))
required_packages <- c("dplyr", "auk")
install_if_missing <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        install.packages(package)
    }
}
invisible(lapply(required_packages, install_if_missing))

## Attach packages ------------------------
library(dplyr)
library(auk) # Note: requires Cygwin installed on Windows computers
