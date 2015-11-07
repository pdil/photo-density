# photo-density
Plot density of photo locations.


#### Example
<img src="http://pdil.github.io/images/sw_us_density.png" width="70%">

The code to create this image is presented here (note: this code assumes a dataset has already been created - see Java code for how to do this).

##### 0. Create photo geodata file
The ```Java Extractor``` folder contains the ```.java``` file which handles the creation of the data set of photo locations that are plotted on a map. A sample of the data set is as follows:

id | year | month | day | file | lat | lon
:--: | :----: | :-----: | :---: | :----: | :---: | :---:
 1 | 2013 | Sep   |  29 | IMG_1407.jpg | 35.0679083 | -106.63624
 2 | 2013 | Oct   |  11 | IMG_1700.jpg | 35.067775  | -106.63557
... | ... | ...   | ... | ...          | ...        | ...
1498 | 2015 |	Apr |	  7 |	IMG_5410.jpg | 35.08214167 | -106.6247944

The Java code uses the ```metadata-extractor``` library file available here: https://github.com/drewnoakes/metadata-extractor

##### 1. Install and load ```ggmap```
```R
install.packages("ggmap")
library(ggmap)
```
```ggmap``` contains the required functions for easily creating map plots from Google Maps images.

##### 2. Import and prepare data
Import the file containing photo locations:
```R
# import data from csv
# headers are id, date, file, lat, lon
geo_data <- read.csv("data/geoDataTable.csv", header = TRUE)
```
Missing values in the data set were automatically entered as -999 by the Java code, so we replace them the R-friendly ```NA``` here.
```R
# missing values were entered as -999
geo_data[] <- lapply(geo_data, function(x) {replace(x, x == -999, NA)})
```
The images we are interested in are located in the Southwestern United States, so we create our bounding box using the longitude and latitude of this region. The longtidue and latitude will essentially map to the x-y coordinates of our plot.
```R
# lat/lon coords of "southwest region" bounding box
sw_top <- 50
sw_bottom <- 25
sw_left <- -130
sw_right <- -100
```
Now that we have defined the region we can extract only the images that are in this region to be plotted.
```R
# select only images with locations in selected region
sw_data <- geo_data[geo_data$lon <= sw_right & geo_data$lon >= sw_left 
                    & geo_data$lat <= sw_top & geo_data$lat >= sw_bottom, ]
```
##### 3. Plot map with 2D density
The ```get_map()``` function in ```ggmap``` allows us to obtain a Google Maps image of the region we define:
```R
# create map image
swmap <- get_map(location = c(lon = -115, lat = 37.5), zoom = 5, maptype = "roadmap")
```
Finally, we can plot the image locations on this map using ```ggmap```. This package follows the grammar of grpahics used in ```ggplot2``` so the same logic and functions apply here.
```R
# use ggmap to create map with points, 2D density, and legend
sw <- ggmap(swmap, darken = 0.1) 
sw <- sw + geom_point(data = sw_data, alpha=0.4, aes(x = lon, y = lat), colour = "blue", size = 3)
sw <- sw + stat_density2d(data = sw_data, aes(fill = ..level..), alpha = 0.25, geom = "polygon", bins = 14)
sw <- sw + scale_fill_gradientn(colours = colorFunc(20), name = "Density")
sw <- sw + xlab("Longitude") + ylab("Latitude")
sw <- sw + theme(legend.position = c(0.1, 0.2), legend.background = element_rect(colour = "black"),
                 panel.border = element_rect(colour = "black", fill = NA))
```

Save and view the completed map!
```R
# save image
ggsave("sw_us_density.png", sw)
print(sw)
```
