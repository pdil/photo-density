

library(ggmap)

# import data from csv
# headers are id, date, file, lat, lon
geo_data <- read.csv("data/geoDataTable.csv", header = TRUE)
# missing values were entered as -999
geo_data[] <- lapply(geo_data, function(x) {replace(x, x == -999, NA)})

colorFunc <- colorRampPalette(c("black", "red", "orange", "yellow", "white"), space = "rgb")

# lat/lon coords of "southwest region" bounding box
sw_top <- 50
sw_bottom <- 25
sw_left <- -130
sw_right <- -100

# select only images with locations in selected region
sw_data <- geo_data[geo_data$lon <= sw_right & geo_data$lon >= sw_left 
                    & geo_data$lat <= sw_top & geo_data$lat >= sw_bottom, ]

# create map image
swmap <- get_map(location = c(lon = -115, lat = 37.5), zoom = 5, maptype = "roadmap")

# use ggmap to create map with points, 2D density, and legend
sw <- ggmap(swmap, darken = 0.1) 
sw <- sw + geom_point(data = sw_data, alpha=0.4, aes(x = lon, y = lat), colour = "blue", size = 3)
sw <- sw + stat_density2d(data = sw_data, aes(fill = ..level..), alpha = 0.25, geom = "polygon", bins = 14)
sw <- sw + scale_fill_gradientn(colours = colorFunc(20), name = "Density")
sw <- sw + xlab("Longitude") + ylab("Latitude")
sw <- sw + theme(legend.position = c(0.1, 0.2), legend.background = element_rect(colour = "black"),
                 panel.border = element_rect(colour = "black", fill = NA))

# save image
ggsave("sw_us_density.png", sw)
print(sw)