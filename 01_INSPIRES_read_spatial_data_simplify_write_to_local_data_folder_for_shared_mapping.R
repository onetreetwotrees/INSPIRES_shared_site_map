library(shiny)
library(leaflet)
library(raster)
library(sp)
library(rgdal)
library(dplyr)

## Leaflet examples from https://nceas.github.io/oss-lessons/publishing-maps-to-the-web-in-r/publishing-maps-to-the-web-in-r.html
## Accessed 2021-03-02

## Try with Track 2 sites
track2_sites <- read.csv("data\\Track2_site_coordinates.csv", header = T)

## Read in Experimental Forest boundaries shapefiles
## Downloaded 2020-06-16
bnds0 <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\data_download\\S_USA.Experimental_Area_Boundaries", 
                 layer = "S_USA.Experimental_Area_Boundaries")
## Subset to Experimental Forests in Inspires domain
subInds <- c(grep("Bartlett", bnds0$NAME),grep("Hubbard", bnds0$NAME), 
             grep("Howland", bnds0$NAME), grep("Penobscot", bnds0$NAME))
bnds <- bnds0[subInds,]

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('S_USA_Experimental_Area_Boundaries_Inspires', dir("data"))) == 0) {
writeOGR(bnds, dsn = "data", layer = "S_USA_Experimental_Area_Boundaries_Inspires", 
         driver = "ESRI Shapefile")
}


## Read in NACP forest biophysical plot geo-markers
## Original download https://daac.ornl.gov/NACP/guides/NACP_Forest_Biophysical.html on 2020-10-30
nacp <- read.csv("C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\data_download\\NACP_FOREST_BIOPHYSICAL_1046\\data\\Georeference_points_field_surveys_2009.csv",
                 skip = 3)
## Remove row with units description
nacp <- nacp[-1,]
coords <- nacp %>% dplyr::select(Longitude, Latitude) %>% mutate(Longitude = as.numeric(Longitude),
                                                                 Latitude = as.numeric(Latitude))
nacpSp <- SpatialPointsDataFrame(coords, data = nacp, proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
crs(nacpSp)

## Create a label field for leaflet map
nacpSp@data$Label <- with(nacpSp@data, paste("NACP",Site,Plot_ID, sep = "-"))

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('NACP_Forest_Biophysical_Georeference_points_field_surveys_2009', dir("data"))) == 0) {
  writeOGR(nacpSp, dsn = "data", layer = "NACP_Forest_Biophysical_Georeference_points_field_surveys_2009", 
           driver = "ESRI Shapefile")
}


################################################################################
## Read LANDIS-II Simulation Landscape Footprints - Boundaries being initialized
cnty_Ches_Worc <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                          layer = "Ches-Worc_countiest")
cnty_Benn_Berk <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                          layer = "Benn-Berk_counties")
cnty_N_NH <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                     layer = "N-NH_counties")
cnty_N_VT <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                     layer = "N-VT_counties")
cnty_Stra_York <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                          layer = "Stra-York")
cnty_ME_Peno_Hanc_Wash <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\gis",
                          layer = "ME_Peno-Hanc-Wash")

cnty_Ches_Worc$StudyArea <- "NH-MA_UVM_O_Box"
cnty_Benn_Berk$StudyArea <- "VT-MA_UVM_H_Higgins"
cnty_N_NH$StudyArea <- "N-NH_UVM_J_Foster"
cnty_N_VT$StudyArea <- "N-VT_UVM_J_Santoro"
cnty_Stra_York$StudyArea <- "Stra_York_UVM_J_Foster"
cnty_ME_Peno_Hanc_Wash$StudyArea <- "Peno_Hanc_Wash_UVM_J_Foster"


## Merge counties into one spatial file
landisCnty <- bind(cnty_Ches_Worc, cnty_Benn_Berk, cnty_N_NH, cnty_N_VT,
                   cnty_Stra_York, cnty_ME_Peno_Hanc_Wash) 

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('US_Counties_Being_Intialized_for_Landis_at_UVM', dir("data"))) == 0) {
  writeOGR(landisCnty, dsn = "data", layer = "US_Counties_Being_Intialized_for_Landis_at_UVM", 
           driver = "ESRI Shapefile")
}

################################################################################
## Read NEON Terrestrial Sampling Boundaries and Clip out Inspires sites
neon <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\code\\Rcode\\NEON_tutorials\\data\\Field_Sampling_Boundaries",
                layer = "terrestrialSamplingBoundaries")
neon <- subset(neon, neon$domainName == "Northeast")
## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('NEON_Terrestrial_Sampling_Boundaries_Northeast', dir("data"))) == 0) {
  writeOGR(neon, dsn = "data", layer = "NEON_Terrestrial_Sampling_Boundaries_Northeast", 
           driver = "ESRI Shapefile")
}

################################################################################
## Read 2nd College Grant Boundary
dart2nd <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\NE_Kingdom\\data_shared",
                layer = "bnd83")
crs(dart2nd)
## Transform to a Geographic, Lat-Long coordinate system
dart2nd <- spTransform(dart2nd, crs(neon))

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('Darmouth_2nd_College_Grant', dir("data"))) == 0) {
  writeOGR(dart2nd, dsn = "data", layer = "Darmouth_2nd_College_Grant", 
           driver = "ESRI Shapefile")
}

################################################################################
## Read Nulhegan Basin Boundary, dissolve into a simpler single polygon for map
nulhegan <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\data_shared\\Nulhegan",
                   layer = "all_management_zones_as_feature")
crs(nulhegan)

nulhegan$all <- 1
# Now the dissolve
#nulhegan1 <- gUnaryUnion(nulhegan, id = nulhegan@data$all)
nulhegan1 <- aggregate(nulhegan, by = "all")
## Transform to a Geographic, Lat-Long coordinate system
nulhegan1 <- spTransform(nulhegan1, crs(neon))

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('Nulhegan_Basin_Simple_Boundary', dir("data"))) == 0) {
  writeOGR(nulhegan1, dsn = "data", layer = "Nulhegan_Basin_Simple_Boundary", 
           driver = "ESRI Shapefile")
}

################################################################################
## Read Corinth Boundary, dissolve into a simpler single polygon for map
corinth <- readOGR(dsn = "C:\\Users\\janer\\Dropbox\\Projects\\Inspires\\data_shared\\GIS",
                    layer = "188-std83VTm")
crs(nulhegan)

corinth$all <- 1
# Now the dissolve
corinth1 <- aggregate(corinth, by = "all")
## Transform to a Geographic, Lat-Long coordinate system
corinth1 <- spTransform(corinth1, crs(neon))

## Write simplified spatial data to shapefile in project data folder (if it is not already there)
if (length(grep('Corinth_VT_Simple_Boundary', dir("data"))) == 0) {
  writeOGR(corinth1, dsn = "data", layer = "Corinth_VT_Simple_Boundary", 
           driver = "ESRI Shapefile")
}



## Create a leaflet map of just point markers
leaflet(track2_sites) %>%
  addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~as.character(Name))

## Try creating a leaflet map that layers polygons as well
leaflet() %>%
  addTiles() %>%
  addMarkers(data = track2_sites, ~Long, ~Lat, popup = ~as.character(Name)) %>%
  addPolygons(data = bnds) %>%
  addMarkers(data = nacpSp, popup = ~as.character(Label))
