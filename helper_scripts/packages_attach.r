# packages_attach.r

## Check required packages ------------------------
options(repos = c(CRAN = "https://cran.rstudio.com/"))
required_packages <- c("tidyverse", "ggpubr", "auk", "hexbin", "sf", "ggspatial")
install_if_missing <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        install.packages(package)
    }
}
invisible(lapply(required_packages, install_if_missing))

## Attach packages ------------------------
library(tidyverse)
library(ggpubr)
library(auk) # Note: requires Cygwin installed on Windows computers
library(hexbin)
library(sf)
library(ggspatial)
