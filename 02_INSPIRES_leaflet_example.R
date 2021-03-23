library(shiny)
library(leaflet)
#library(raster)
library(rgdal)

## Leaflet examples from https://nceas.github.io/oss-lessons/publishing-maps-to-the-web-in-r/publishing-maps-to-the-web-in-r.html
## Accessed 2021-03-02

## Try with Track 2 sites
track2_sites <- read.csv("data\\Track2_site_coordinates.csv", header = T)
bnds <- readOGR(dsn = "data", layer = "S_USA_Experimental_Area_Boundaries_Inspires")
nacp <- readOGR(dsn = "data", layer = "NACP_Forest_Biophysical_Georeference_points_field_surveys_2009")
neon <- readOGR(dsn = "data", layer= "NEON_Terrestrial_Sampling_Boundaries_Northeast")
landisCnty <- readOGR(dsn = "data", layer = "US_Counties_Being_Intialized_for_Landis_at_UVM")
dart2nd <- readOGR(dsn = "data", layer = "Darmouth_2nd_College_Grant")
nulhegan1 <- readOGR(dsn = "data", layer = "Nulhegan_Basin_Simple_Boundary")
corinth1 <- readOGR(dsn = "data", layer = "Corinth_VT_Simple_Boundary")


## Simple map example
map <- leaflet() %>%
  # Base groups
  addTiles() %>%

  # Overlay groups
  addPolygons(data = landisCnty, color = "orange", opacity = 0.5,
              popup = ~as.character(StudyArea), group = "Landis-II Simulation Area") %>%
  addPolygons(data = neon, color = "purple", opacity = 0.5,
              popup = ~as.character(siteName), group = "NEON Sites") %>%
  addPolygons(data = bnds, popup = ~as.character(NAME), group = "US Exp. Forests") %>%
  addPolygons(data = dart2nd, color = "green", opacity = 0.5,
              popup = "Dartmouth 2nd College Grant", group = "Partner Forests") %>%  
  addPolygons(data = nulhegan1, color = "green", opacity = 0.5,
              popup = "Nulhegan Basin", group = "Partner Forests") %>% 
  addPolygons(data = corinth1, color = "green", opacity = 0.5,
              popup = "Corinth ? Forest", group = "Partner Forests") %>%  
  addMarkers(data = track2_sites, ~Long, ~Lat, popup = ~as.character(Name), group = "Sites") %>%
  addCircles(data = nacp, stroke = F, popup = ~as.character(Label), 
             group = "Plots") %>%
  # Layers control
  addLayersControl(
    #baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
    overlayGroups = c("Sites", "Plots", "US Exp. Forests", "Partner Forests",
                      "NEON Sites", "Landis-II Simulation Area"),
    options = layersControlOptions(collapsed = FALSE)
  )
map





## Other examples
## Create a leaflet map of just point markers
leaflet(track2_sites) %>%
  addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~as.character(Name))

## Try creating a leaflet map that layers polygons as well
leaflet() %>%
  addTiles() %>%
  addMarkers(data = track2_sites, ~Long, ~Lat, popup = ~as.character(Name)) %>%
  addPolygons(data = bnds) %>%
  addMarkers(data = nacp, popup = ~as.character(Label))

## Colored circles example
# Create a palette that maps factor levels to colors
pal <- colorFactor(c("navy", "red"), domain = c("ship", "pirate"))

leaflet(df) %>% addTiles() %>%
  addCircleMarkers(
    radius = ~ifelse(type == "ship", 6, 10),
    color = ~pal(type),
    stroke = FALSE, fillOpacity = 0.5
  )

## Simple map example
map <- leaflet() %>%
  # Base groups
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  # Overlay groups
  addCircles(~long, ~lat, ~10^mag/5, stroke = F, group = "Quakes") %>%
  addPolygons(data = outline, lng = ~long, lat = ~lat,
              fill = F, weight = 2, color = "#FFFFCC", group = "Outline") %>%
  # Layers control
  addLayersControl(
    baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
    overlayGroups = c("Quakes", "Outline"),
    options = layersControlOptions(collapsed = FALSE)
  )
map