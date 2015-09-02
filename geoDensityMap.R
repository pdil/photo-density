

library(ggplot2)
library(ggmap)
library(grid)
library(gridExtra)

# import data from csv
# headers are id, date, file, lat, lon
geo.data <- read.csv("../data/geoDataTable.csv", header=TRUE)
# missing values were entered as -999
geo.data[] <- lapply(geo.data, function(x){replace(x, x==-999, NA)})

colorFunc <- colorRampPalette(c("black", "red", "orange", "yellow", "white"), space="rgb")
############
# TO DO LIST
# ==========
# define regions
# example: southwest = -115, 37.5 +/- width
# create list of all photos in that region
# > if (data$lon[i] <= && >= ... etc)
# convert milliseconds to month/year
# histogram (ggsubplot/geom_subplot())
#
# 1 Year = 31556952000 Milliseconds
# time is milliseconds since 1 Jan 1970
############
# lat/lon coords of "southwest region" bounding box
sw.top <- 50
sw.bottom <- 25
sw.left <- -130
sw.right <- -100

sw.data <- geo.data[geo.data$lon <= sw.right & geo.data$lon >= sw.left 
                    & geo.data$lat <= sw.top & geo.data$lat >= sw.bottom, ]

swmap <- get_map(location=c(lon=-115, lat=37.5), zoom=5, maptype="roadmap")

sw <- ggmap(swmap, darken=0.1) 
sw <- sw + geom_point(data=sw.data, alpha=0.4, aes(x=lon, y=lat), colour="blue", size=3)
sw <- sw + stat_density2d(data=sw.data, aes(fill=..level..), alpha=0.25, geom="polygon", bins=14)
sw <- sw + scale_fill_gradientn(colours=colorFunc(20), name="Density")
sw <- sw + xlab("Longitude") + ylab("Latitude") #+ labs(title="Southwestern US Photo Density")
sw <- sw + theme(legend.position=c(0.1, 0.2), legend.background=element_rect(colour="black"),
                 panel.border=element_rect(colour="black", fill=NA))

ggsave("/Users/paolo/Desktop/Data Analysis/GeoDensityMap/sw_us_density.png", sw)
print(sw)