library(rgeos)
library(maptools)
gpclibPermit()
library(ggplot2)
library(scales)
library(plyr)
library(reshape2)

# Install Directory -- WILL NEED TO BE MODIFIED PER DEPLOYMENT
install_dir = "~/Code/NepalMaps"
setwd(install_dir)

# MAP setup
np_dist <- readShapeSpatial("baselayers/NPL_adm/NPL_adm3.shp")
np_distf <- fortify(np_dist, region="NAME_3")

choropleth <- function(data, x, y, fortifiedpolygons, extra) {
  # force upper case for better matching
  data[,x] <- as.character(toupper(data[,x]))
  fortifiedpolygons$id <- as.character(toupper(fortifiedpolygons$id))
  # basic contract, data$x and fortifiedpolygons$id has to include the same things
  stopifnot(all(data[,x] %in% levels(factor(fortifiedpolygons$id))))
  
  ggplot() + 
    geom_map(data = data, aes_string(map_id=x, fill=y), map=fortifiedpolygons) + 
    expand_limits(x=fortifiedpolygons$long, y=fortifiedpolygons$lat) + 
    scale_fill_gradient(low="white", high=muted("blue")) +
    extra() +
    theme(axis.title=element_blank(), axis.text=element_blank(),
          axis.ticks = element_blank(), panel.grid=element_blank(), panel.background=element_rect(fill='#888888'))
}

# district over lay
#districts <- ddply(np_distf, .(id), summarize, clat = mean(lat), clong = mean(long))
districts <- read.csv("baselayers/districts.csv")
districtoverlay <- function() {
  geom_text(data=districts, aes(x=clong, y=clat, label=id), size=4)
}

# np choropleth
npchoropleth <- function (data, x, y) { choropleth(data, x, y, np_distf, districtoverlay) }