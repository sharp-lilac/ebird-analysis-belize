# data_analysis.r

## Source code ------------------------
source("helper_scripts/data_prepare.r")
source("helper_scripts/theme.r")
source("helper_scripts/shapefiles.r")

## Summarize species data ------------------------
edb_basic_taxa <- ebd_basic %>%
    group_by(taxonomic_order, common_name) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count))
edb_basic_species <- ebd_basic %>%
    filter(category == "species") %>%
    group_by(scientific_name, common_name) %>%
    summarize(
        Count = n()
    ) %>%
    arrange(desc(Count)) # note: this does not include rock pigeon, which is classified as wild on eBird
head(edb_basic_species, 10) # top 10 most common species observed
tail(edb_basic_species, 30) # top 10 least common species observed
nrow(edb_basic_species) # number of unique species observed
nrow(filter(edb_basic_species, Count == 1)) # number of unique species observed once
nrow(filter(edb_basic_species, Count < 10)) # number of unique species observed less than 10 times

## Visualize species data ------------------------
df_rank_all <- edb_basic_species %>%
    ungroup() %>%
    mutate(
        Rank = row_number(),
        RelAbund = Count / sum(Count)
    )

fig_rank <- ggplot(df_rank_all, aes(x = Rank, y = RelAbund)) +
    geom_line(linewidth = 0.7, alpha = 0.5) +
    geom_point(size = 0.7, alpha = 0.5) +
    labs(x = "Species Rank", y = "Relative Abundance") +
    scale_y_log10(
        breaks = 10^(-9:0),
        labels = scales::comma,
        minor_breaks = rep(1:9, each = 5) * 10^rep(-9:0, times = 9),
    ) +
    scale_x_continuous(breaks = seq(0, max(df_rank_all$Rank, na.rm = TRUE), by = 50)) +
    theme_pubclean() +
    custom_theme
ggsave("outputs/fig_rank.png", fig_rank, height = 8, width = 12)
fig_rank_untransformed <- ggplot(df_rank_all, aes(x = Rank, y = RelAbund)) +
    geom_line(linewidth = 0.7, alpha = 0.5) +
    geom_point(size = 0.7, alpha = 0.5) +
    labs(x = "Species Rank", y = "Relative Abundance") +
    scale_x_continuous(breaks = seq(0, max(df_rank_all$Rank, na.rm = TRUE), by = 50)) +
    theme_pubclean() +
    custom_theme
ggsave("outputs/fig_rank_untransformed.png", fig_rank_untransformed, height = 8, width = 12)

## Summarize data availability ------------------------
length(unique(ebd_basic$checklist_id)) # number of approved checklists
length(unique(ebd_unvetted$checklist_id)) # number of unvetted checklists
nrow(ebd_basic) # number of approved observations
nrow(ebd_unvetted) # number of unvetted observations
length(unique(ebd_basic$observer_id)) # number of observers

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
top_edb_basic_locality <- head(edb_basic_locality, 10)$locality

# Regression of unique observers and unique checklists per year ------------------------
df_checklists_locality <- ebd_basic %>%
    filter(locality %in% top_edb_basic_locality) %>%
    filter(observation_type != "Historical" & observation_type != "Incidental") %>%
    mutate(Year = format(observation_date, "%Y")) %>%
    group_by(Year, locality) %>%
    summarize(
        Checklists = n_distinct(checklist_id),
        Observers = n_distinct(observer_id)
    ) %>%
    pivot_longer(cols = c(Checklists, Observers), names_to = "Metric", values_to = "Value")
plot_line <- ggplot(df_checklists_locality, aes(x = as.numeric(Year), y = Value, color = locality)) +
    geom_smooth(se = FALSE) +
    facet_wrap(~Metric) +
    scale_color_manual(values = palette) +
    labs(x = "Year", y = "Count", color = "Locality") +
    theme_pubclean() +
    custom_theme +
    theme(
        legend.position = "bottom",
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20),
        strip.text = element_text(size = 20)
    ) +
    guides(color = guide_legend(nrow = 5, byrow = TRUE))
ggsave("outputs/plot_line.png", plot_line, height = 10, width = 16)

## Summarize data by effort ------------------------
summary(ebd_basic$duration_minutes, na.rm = TRUE) # variation and central tendency duration (minutes)
summary(ebd_basic$effort_distance_km, na.rm = TRUE) # variation and central tendency distance (km)
summary(ebd_basic$effort_area_ha, na.rm = TRUE) # variation and central tendency area (ha)
summary(ebd_basic$number_observers, na.rm = TRUE) # variation and central tendency number observers

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

# Create observations hex density map (log transformed) ---------------------------
plot_map_log <- ggplot() +
    geom_hex(data = ebd_basic, aes(longitude, latitude), bins = 20) +
    geom_sf(data = belize_map, linewidth = 1, color = "black", fill = "#e9e9e9", alpha = 0.3) +
    scale_fill_gradientn(
        colours = palette_cont,
        name = "Observation Density",
        trans = "log10",
        breaks = scales::log_breaks(n = 6),
        labels = scales::comma
    ) +
    annotation_scale(location = "br", width_hint = 0.2, style = "ticks") +
    annotation_north_arrow(location = "tl", which_north = "true", style = north_arrow_fancy_orienteering) +
    theme_minimal() +
    custom_theme
ggsave("outputs/plot_map_log.png", plot_map_log, height = 12, width = 12)

# Create observations hex density map (log transformed, with protected areas) ---------------------------
plot_map_PAs <- ggplot() +
    geom_hex(data = ebd_basic, aes(longitude, latitude), bins = 20) +
    geom_sf(data = belize_map, linewidth = 1, color = "black", fill = "#e9e9e9", alpha = 0.3) +
    scale_fill_gradientn(
        colours = palette_cont,
        name = "Observation Density",
        trans = "log10",
        breaks = scales::log_breaks(n = 6),
        labels = scales::comma
    ) +
    geom_sf(data = protected_map, linewidth = 0.25, color = "black", fill = "grey", alpha = 0.3) +
    annotation_scale(location = "br", width_hint = 0.2, style = "ticks") +
    annotation_north_arrow(location = "tl", which_north = "true", style = north_arrow_fancy_orienteering) +
    theme_minimal() +
    custom_theme
ggsave("outputs/plot_map_PAs.png", plot_map_PAs, height = 12, width = 12)

# Calculate percentage of observations in protected areas ------------------------------
ebd_sf <- ebd_basic %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
protected_sf <- st_transform(protected_map, st_crs(ebd_sf)) %>%
    filter(st_is_valid(geometry))
ebd_with_PA <- st_join(ebd_sf, protected_sf, join = st_within)
total_obs <- nrow(ebd_with_PA)
inside_obs <- sum(!is.na(ebd_with_PA$NAME))
outside_obs <- total_obs - inside_obs
inside_obs / total_obs * 100 # percentage of observations inside PAs
outside_obs / total_obs * 100 # percentage of observations outside PAs

# Calculate percentage of observations done using PROALAS ------------------------------
proalas_projects <- c("PROALAS—General", "PROALAS — Belize", "PROALAS — Belize|PROALAS—General")
ebd_basic_proalas <- ebd_basic %>%
    filter(project_names %in% proalas_projects)
nrow(ebd_basic_proalas) / nrow(ebd_basic) * 100 # percentage of observations done using PROALAS
