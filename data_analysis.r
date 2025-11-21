# data_analysis.r

## Source code ------------------------
source("helper_scripts/data_prepare.r")

## Summarize species data ------------------------
edb_basic_species <- ebd_basic %>%
    filter(category == "species") %>%
    group_by(scientific_name, common_name) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count))
head(edb_basic_species, 10) # top 10 most common species observed
nrow(edb_basic_species) # number of unique species observed

## Summarize data availability ------------------------
length(unique(ebd_basic$checklist_id)) # number of approved checklists
length(unique(ebd_unvetted$checklist_id)) # number of unvetted checklists
nrow(ebd_basic) # number of approved observations
nrow(ebd_unvetted) # number of unvetted observations

## Summarize data sources ------------------------
edb_basic_source <- ebd_basic %>%
    group_by(observation_type) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count))
edb_basic_source # most common sources of observations

## Summarize data spatially ------------------------
edb_basic_district <- ebd_basic %>%
    group_by(state) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count))
edb_basic_district # most common districts of observations
edb_basic_locality <- ebd_basic %>%
    group_by(locality) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count))
edb_basic_locality # most common localities of observations

## Summarize data by effort ------------------------
mean(ebd_basic$duration_minutes, na.rm = TRUE) # mean duration (minutes)
mean(ebd_basic$effort_distance_km, na.rm = TRUE) # mean distance (km)
mean(ebd_basic$effort_area_ha, na.rm = TRUE) # mean area (ha)
mean(ebd_basic$number_observers, na.rm = TRUE) # mean number observers
