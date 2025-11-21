# data_prepare.r

## Source code ------------------------
source("helper_scripts/packages_attach.r")

## Load data ------------------------
data_dir <- file.path("data")
files <- list.files(data_dir, pattern = "^ebd_.*\\.txt$", full.names = TRUE)
files <- sort(files)
f_in_basic <- files[1]
f_in_sampling <- files[2]
f_in_unvetted <- files[3]

## Prepare eBird data ------------------------
read_ebd_basic <- read_ebd(f_in_basic, rollup = FALSE)
read_ebd_unvetted <- read_ebd(f_in_unvetted, rollup = FALSE)
selection_columns <- c(
    "checklist_id", "observation_date", "latitude", "longitude", "state",
    "locality", "taxonomic_order", "category", "common_name",
    "scientific_name", "subspecies_common_name", "subspecies_scientific_name",
    "breeding_category", "behavior_code", "age_sex", "time_observations_started",
    "observer_id", "observation_type", "duration_minutes", "effort_distance_km",
    "effort_area_ha", "number_observers", "all_species_reported", "approved"
)
ebd_basic <- read_ebd_basic %>%
    select(selection_columns)
ebd_unvetted <- read_ebd_unvetted %>%
    select(selection_columns)
