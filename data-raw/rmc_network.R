## code to prepare `rmc_network` dataset goes here

library(sf)
library(stringr)
library(glue)
library(dplyr)
library(tidyr)

### extract network axis from reference hydrological network ####
# get real BDTOPO 2021 network with DGO
# "liens_vers_cours_d_eau"  LIKE ANY (ARRAY[
#   'COURDEAU0000002000789104',
#   'COURDEAU0000002000790863',
#   'COURDEAU0000002000790852',
#   'COURDEAU0000002000796122',
#   'COURDEAU0000002000792287',
#   'COURDEAU0000002000792721',
#   'COURDEAU0000002000788975',
#   'COURDEAU0000002000794664',
#   'COURDEAU0000002000791856',
#   'COURDEAU0000002000794423%',
#   'COURDEAU0000002000794464',
#   'COURDEAU0000002000800539',
#   'COURDEAU0000002000794069',
#   'COURDEAU0000002000794279',
#   'COURDEAU0000002000794329',
#   'COURDEAU0000002000802959',
#   'COURDEAU0000002000802938',
#   'COURDEAU0000002000800998',
#   'COURDEAU0000002000800882',
#   'COURDEAU0000002000801685',
#   'COURDEAU0000002000806467',
#   'COURDEAU0000002000809358',
#   'COURDEAU0000002000812384',
#   'COURDEAU0000002000815160',
#   'COURDEAU0000002000804457',
#   'COURDEAU0000002000803225',
#   'COURDEAU0000002000803850',
#   'COURDEAU0000002000803776',
#   'COURDEAU0000002000803141',
#   'COURDEAU0000002000803060',
#   'COURDEAU0000002000803494'])
#####

### Old datRMC.rda data inputs ####
# load(file="data-raw/datRMC.rda")
# # reset crs
# st_crs(datRMC) = 4326
#
# # transform list col to num
# rmc_network <- datRMC %>%
#   mutate(xmin = as.numeric(xmin),
#          xmax = as.numeric(xmax),
#          ymin = as.numeric(ymin),
#          ymax = as.numeric(ymax)) %>%
#   filter(axis <=100)
#####

# workflow

#### merge all axis DGO => create swaths_refaxis_combine.gpkg ####
fichiers_swaths_refaxis <- list.files(path = "data-raw/", pattern = "SWATHS_REFAXIS.shp$", recursive = TRUE, full.names = TRUE)
liste_swaths_refaxis <- list() # empty list
# read all shapefile and store un list
for (swaths_refaxis in fichiers_swaths_refaxis) {
  sf_obj <- st_read(swaths_refaxis) %>%
    mutate(GID = as.integer(GID), M = as.integer(M)) %>% # integer is faster for processing
    filter(VALUE==2) %>% # Valid data (others are sliver polygons)
    group_by(GID) %>% # remove duplicate GID and M
    summarise(AXIS = first(na.omit(AXIS)), # actions on group_by aggregation
              VALUE = first(na.omit(VALUE)),
              M = first(na.omit(M)),
              geometry = st_union(geometry))
  liste_swaths_refaxis[[length(liste_swaths_refaxis) + 1]] <- sf_obj
}
# merge all shapefile in list
swaths_refaxis_combine <- do.call(rbind, liste_swaths_refaxis)

## check duplicate GID and M in DGO #
# for (axis in unique(swaths_refaxis_combine$AXIS)){
#   dgo_axe <- swaths_refaxis_combine %>%
#     filter(AXIS==axis) %>%
#     filter(VALUE==2)
#   if (any(duplicated(dgo_axe$M))==TRUE){
#     duplicate <- glue::glue("L'axe {axis} a des doublons")
#     message(duplicate)
#   }
# }

## get duplicate rows with same GID id for AXIS 15
# swaths_refaxis_combine %>%
#   filter(AXIS==15) %>%
#   group_by(GID) %>%
#   filter(n()>1) %>%
#   ungroup()

# st_write(swaths_refaxis_combine, "data-raw/swaths_refaxis_combine.gpkg", "swaths_refaxis_combine", append = FALSE)
#####

# read swaths
swaths_refaxis_combine <- st_read("data-raw/swaths_refaxis_combine.gpkg") %>%
  st_transform(2154)

### merge all continuity, metrics, landcover => write continuity_combine.csv, metrics_combine.csv, landcover_combine.csv ####
merge_csv_in_subfolders <- function(folder, pattern_file, pattern_subfolders){
  # Get a list of subfolders starting with "AX"
  subfolders <- list.dirs(path = folder, recursive = FALSE, full.names = FALSE)
  subfolders <- subfolders[str_detect(subfolders, paste("^", pattern_subfolders, sep=""))]

  if (length(subfolders) == 0) {
    stop("No subfolders starting with 'AX' found in the specified folder.")
  }
  data_frame_list <- list()
  for (subfolder in subfolders) {
    folder_path <- file.path(folder, subfolder) # path to subfolder
    file_list <- list.files(path = folder_path, pattern = paste(pattern_file,"$", sep = ""), full.names = TRUE) # get all csv pattern in subfolder

    if (length(file_list) > 0) { # more than 1 file found
      # Read each CSV file and add a new column "AXIS" with the folder name (AXIS number)
      data_frames <- lapply(file_list, function(file) {
        df <- read.csv2(file)
        df$AXIS <- as.integer(str_extract(subfolder, "\\d+"))
        return(df)
      })
      data_frame_list <- c(data_frame_list, data_frames)
    }
    else {
      print(glue("No {pattern_file} files found in {subfolder}"))
    }
  }

  if (length(data_frame_list) == 0) {
    stop("No CSV files found in the subfolders.")
  }

  result_df <- do.call(rbind, data_frame_list)

}

## check duplicate in metrics data
# for (axis in unique(metrics_combine$AXIS)){
#   data_axe <- metrics_combine %>%
#     filter(AXIS==axis)
#   if (any(duplicated(data_axe$measure))==TRUE){
#     duplicate <- glue::glue("L'axe {axis} a des doublons")
#     message(duplicate)
#   }
# }

continuity_combine <- merge_csv_in_subfolders(folder = "data-raw/", pattern_file = "continuity.csv", pattern_subfolders = "AX")
metrics_combine <- merge_csv_in_subfolders(folder = "data-raw/", pattern_file = "metrics.csv", pattern_subfolders = "AX")
landcover_combine <- merge_csv_in_subfolders(folder = "data-raw/", pattern_file = "landcover.csv", pattern_subfolders = "AX")

write.csv2(continuity_combine, "data-raw/continuity.csv")
write.csv2(metrics_combine, "data-raw/metrics.csv")
write.csv2(landcover_combine, "data-raw/landcover.csv")
#####

# read metrics
continuity_combine <- read.csv2("data-raw/continuity.csv")
metrics_combine <- read.csv2("data-raw/metrics.csv")
landcover_combine <- read.csv2("data-raw/landcover.csv")

### load old simplify network => write old_datsf.gpkg ####
load(file="data-raw/datsf.rda")
# old style crs, rewrite with WKT, not proj4string
# see : str(attr(datsf$geometry,"crs")) or attr(datsf$geometry,"crs")[[1]]
st_crs(datsf) <- 4326
old_datsf <- datsf[1:nrow(datsf),] %>% # subset all data... to fix Error: attr classes has wrong size: please file an issue (see : https://github.com/r-spatial/sf/issues/400)
  st_cast ( "MULTILINESTRING") %>% # set geometry type not set correctly
  st_transform(2154) # reproject

st_write(old_datsf, "data-raw/old_datsf.gpkg", "old_datsf", append = FALSE)
#####

# read old simplify network
datsf <- st_read("data-raw/old_datsf.gpkg")

### load reference hydrological network and get attribut from old network => write network_with_attibut.gpkg ####

network <- st_read("./data-raw/ref_hydro_network.gpkg", geometry_column = "geom")
st_geometry(network) <- "geometry"

# regroup line by axis
network_axis <- network %>%
  select(liens_vers_cours_d_eau, cpx_toponyme_de_cours_d_eau, geometry) %>%
  group_by(liens_vers_cours_d_eau) %>%
  summarise(TOPONYME = first(na.omit(cpx_toponyme_de_cours_d_eau)),
            geometry = st_union(geometry))

# get the initial simplify network (datasf) attributs
network_with_attribut <-  network_axis %>%
 left_join(as.data.frame(datsf), by = join_by(TOPONYME == TOPONYME)) %>%
  select(num, ID, AXIS, popup, TOPONYME, hasData, geometry.x)
st_geometry(network_with_attribut) <- "geometry"

st_write(network_with_attribut, "data-raw/network_with_attribut.gpkg", "network", append = FALSE)
#####

network_with_attribut <- st_read("data-raw/network_with_attribut.gpkg")

### clip network axis with attribut by Swaths => write network_clip.gpkg ####

# for each axis line, clip line by DGO filtered by axis and add DGO attribut on line
network_clip <- st_sf(st_sfc(crs = 2154)) # create an empty sf dataset
# clip by axis
for (axis in unique(network_with_attribut$AXIS)){
  dgo_axe <- swaths_refaxis_combine %>%
    filter(AXIS == axis) # get swaths by axis
  network_axe <- network_with_attribut %>%
    filter(AXIS == axis) # get ref_hydro_format lines by axis
  network_clip_axis <- network_axe %>%
    st_intersection(dgo_axe) %>%  # clip by axis (keep only lines inside swaths)
    select(-AXIS.1)
  network_clip <- rbind(network_clip, network_clip_axis) # fill the output dataset by axis
}

# check for duplicate in M field
# for (axis in unique(network_clip$AXIS)){
#   net_axe <- network_clip %>%
#     filter(AXIS==axis)
#   if (any(duplicated(net_axe$M))==TRUE){
#     duplicate <- glue::glue("L'axe {axis} a des doublons")
#     message(duplicate)
#   }
# }

# st_write(network_clip, "data-raw/network.gpkg", "network_clip", append = FALSE)
####

# read network clipped
network_clip <- st_read("data-raw/network.gpkg")

# strahler order done by hand
# read network with strahler order
network_strahler <- st_read("data-raw/network_strahler.gpkg")

# write final scv file to copy without subset
write.csv2(continuity_combine, "data-raw/continuity.csv")
write.csv2(metrics_combine, "data-raw/metrics.csv")
write.csv2(landcover_combine, "data-raw/landcover.csv")

### combine network to metrics and landcover ####

# create unique id to network
network_strahler_id <- network_strahler %>%
  mutate(id_net = row_number())

### LANDCOVER PREPARATION
# join with landcover
network_landcover_join <- network_strahler_id %>%
  left_join(landcover_combine, by = c("M"="measure", "AXIS"="AXIS"))

# remove geom and pivot landcover to have all the area by landcover type
landcover_pivot <- network_landcover_join %>%
  st_drop_geometry() %>%
  select(id_net, landcover, landcover_area) %>%
  pivot_wider(names_from = landcover, values_from = landcover_area) %>%
  rename_with(~str_replace_all(., " ", "_"), everything())

### CONTINUITY PREPARATION
network_continuity_join <- network_strahler_id %>%
  left_join(continuity_combine, by = c("M"="measure", "AXIS"="AXIS"))

# remove geom and pivot continuity to have all the area by continuity type
continuity_pivot <- network_continuity_join %>%
  st_drop_geometry() %>%
  select(id_net, continuity, continuity_area) %>%
  pivot_wider(names_from = continuity, values_from = continuity_area) %>%
  rename_with(~str_replace_all(., " ", "_"), everything()) %>%
  rename_with(~str_replace_all(., "-", "_"), everything())

# add pivot landuse and metrics to network
network_landcover_continuity_metrics <- network_strahler_id %>%
  left_join(landcover_pivot, by = c("id_net"="id_net")) %>%
  left_join(continuity_pivot, by = c("id_net"="id_net")) %>%
  left_join(metrics_combine, by= c("M"="measure", "AXIS"="AXIS"))

# write final network dataset
st_write(network_landcover_continuity_metrics, "data-raw/network_landcover_continuity_metrics.gpkg", "network_landcover_continuity_metrics", append = FALSE)

# read final network dataset
network_landcover_metrics <- st_read("data-raw/network_landcover_continuity_metrics.gpkg")

### USE BELOW TO SAVE TO DATA FOLDER WITH DOC ####

# put the data to data folder
usethis::use_data(network_data, overwrite = TRUE)
# add data documentation R in R folder
checkhelper::use_data_doc(name = "network_data")
# regenerate all the package documentation to create the md data doc from the R data doc, store in man folder
attachment::att_amend_desc()
