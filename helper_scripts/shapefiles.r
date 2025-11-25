## shapefiles.r

# Load Shapefiles ---------------------------
belize_map <- st_read("shapefiles/Belize_Basemap.shp") %>%
    st_transform(4326)
protected_map <- st_read("shapefiles/ProtectedAreas_2024.shp") %>%
    st_transform(4326)
