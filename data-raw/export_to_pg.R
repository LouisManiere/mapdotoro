# install.packages("sf")
# install.packages("RPostgreSQL")

library(sf)
library(RPostgreSQL)
library(readr)


con <- DBI::dbConnect(RPostgres::Postgres(),
                      host = Sys.getenv("DBMAPDO_HOST"),
                      port = Sys.getenv("DBMAPDO_PORT"),
                      dbname = Sys.getenv("DBMAPDO_NAME"),
                      user      = Sys.getenv("DBMAPDO_USER"),
                      password  = Sys.getenv("DBMAPDO_PASS"))



# network_strahler <- st_read("data-raw/network_strahler.gpkg")
# continuity <- read.csv2("data-raw/continuity.csv")
# metrics <- read.csv2("data-raw/metrics.csv")
# landcover <- read.csv2("data-raw/landcover.csv")
network_metrics <- st_read("data-raw/network_landcover_continuity_metrics.gpkg")
network_axis <- st_read("data-raw/network_axis.gpkg")
bassin_hydro <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "bassin_hydrographique")
region_hydro <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "region_hydrographique")
# secteur_hydro <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "secteur_hydrographique")
roe <- st_read(dsn = "data-raw/dbmapdo.gpkg", layer = "roe")



st_write(bassin_hydro, con, "bassin_hydrographique", driver = "PostgreSQL")
st_write(region_hydro, con, "region_hydrographique", driver = "PostgreSQL")
st_write(roe, con, "roe", driver = "PostgreSQL")

# st_write(network_strahler, con, "network", driver = "PostgreSQL")
# dbWriteTable(con, "continuity", continuity, overwrite = TRUE, row.names = FALSE)
# dbWriteTable(con, "metrics", metrics, overwrite = TRUE, row.names = FALSE)
# dbWriteTable(con, "landcover", landcover, overwrite = TRUE, row.names = FALSE)
st_write(network_metrics, con, "network_metrics", driver = "PostgreSQL")
st_write(network_axis, con, "network_axis", driver = "PostgreSQL")

dbDisconnect(con)
