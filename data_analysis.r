# data_analysis.r

## Source code ------------------------
source("helper_scripts/data_prepare.r")
source("helper_scripts/theme.r")
source("helper_scripts/shapefiles.r")

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

## Visualize data by date ------------------------
min_year <- as.integer(format(min(ebd_basic$observation_date, na.rm = TRUE), "%Y"))
max_year <- as.integer(format(max(ebd_basic$observation_date, na.rm = TRUE), "%Y"))
start_year <- floor(min_year / 25) * 25
end_year <- ceiling((max_year + 1) / 25) * 25
start_date <- as.Date(paste0(start_year, "-01-01"))
end_date <- as.Date(paste0(end_year, "-01-01"))
plot_date <- ggplot(ebd_basic %>% select(checklist_id, observation_date) %>% distinct(), aes(x = observation_date)) +
    geom_histogram(binwidth = 365 * 5, color = "black", fill = palette[1]) +
    scale_x_date(breaks = seq(start_date, end_date, by = "25 years"), date_labels = "%Y") +
    scale_y_log10(
        breaks = 10^(0:7),
        labels = scales::comma,
        minor_breaks = rep(1:9, each = 5) * 10^rep(0:7, times = 9),
    ) +
    labs(x = "Observation Date", y = "Number of Checklists") +
    theme_pubclean() +
    custom_theme
ggsave("outputs/plot_date.png", plot_date, height = 6, width = 12)

# Create observations hex density map ---------------------------
plot_map <- ggplot() +
    geom_hex(data = ebd_basic, aes(longitude, latitude), bins = 20) +
    geom_sf(data = belize_map, linewidth = 1, color = "black", fill = "#e9e9e9", alpha = 0.3) +
    scale_fill_gradientn(
        colours = palette_cont,
        name = "Observation Density",
        labels = scales::comma
    ) +
    annotation_scale(location = "br", width_hint = 0.2, style = "ticks") +
    annotation_north_arrow(location = "tl", which_north = "true", style = north_arrow_fancy_orienteering) +
    theme_minimal() +
    custom_theme
ggsave("outputs/plot_map.png", plot_map, height = 12, width = 12)
