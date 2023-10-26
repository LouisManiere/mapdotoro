# install.packages("sf")
# install.packages("RPostgreSQL")

library(sf)
library(dplyr)
library(RPostgreSQL)
library(readr)


con <- DBI::dbConnect(RPostgres::Postgres(),
                      host = Sys.getenv("DBMAPDO_HOST"),
                      port = Sys.getenv("DBMAPDO_PORT"),
                      dbname = Sys.getenv("DBMAPDO_MODELNAME"), # Sys.getenv("DBMAPDO_NAME")
                      user      = Sys.getenv("DBMAPDO_USER"),
                      password  = Sys.getenv("DBMAPDO_PASS"))

# con <- DBI::dbConnect(RPostgres::Postgres(),
#                       host = Sys.getenv("DBMAPDO_DEV_HOST"),
#                       port = Sys.getenv("DBMAPDO_DEV_PORT"),
#                       dbname = Sys.getenv("DBMAPDO_DEV_NAME"),
#                       user      = Sys.getenv("DBMAPDO_DEV_USER"),
#                       password  = Sys.getenv("DBMAPDO_DEV_PASS"))

bassin_hydro <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "bassin_hydrographique") %>%
  select(-ProjCoordO)
region_hydro <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "region_hydrographique")
roe <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "roe")
network_metrics <- st_read("data-raw/network_landcover_continuity_metrics.gpkg")
network_axis <- st_read("data-raw/network_axis.gpkg")

st_write(bassin_hydro, con, "bassin_hydrographique", driver = "PostgreSQL")
st_write(region_hydro, con, "region_hydrographique", driver = "PostgreSQL")
st_write(roe, con, "roe", driver = "PostgreSQL")

st_write(network_metrics, con, "network_metrics", driver = "PostgreSQL")
st_write(network_axis, con, "network_axis", driver = "PostgreSQL")

dbDisconnect(con)
