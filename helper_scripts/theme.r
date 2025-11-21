# theme.r

## Define color palettes ------------------------
palette <- c("#007bb8", "#E6A93A", "#7BB800") # discrete
palette_cont <- c("#f3fafd", "#a3d1e1", "#e6e64c", "#ddb263", "red") # continuous

## Define ggplot theme ------------------------
custom_theme <- theme(
    axis.title = element_text(size = 26),
    axis.text = element_text(size = 18),
    axis.ticks = element_line(color = "black", size = 1.2),
    axis.ticks.length = unit(0.4, "cm"),
    panel.grid.major.y = element_line(color = "black", linewidth = 0.5, linetype = "dashed"),
    panel.grid.minor.y = element_line(color = "grey85", linewidth = 0.3)
)
