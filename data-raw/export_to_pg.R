# install.packages("sf")
# install.packages("RPostgreSQL")

library(sf)
library(RPostgreSQL)
library(readr)


con <- DBI::dbConnect(RPostgres::Postgres(),
                      host   = "localhost",
                      dbname = "dbmapdo",
                      user      = Sys.getenv("DBMAPDO_LOCALHOST_USER"),
                      password  = Sys.getenv("DBMAPDO_LOCALHOST_PASS"),
                      port     = 5432)



network_strahler <- st_read("data-raw/network_strahler.gpkg")
continuity <- read.csv2("data-raw/continuity.csv")
metrics <- read.csv2("data-raw/metrics.csv")
landcover <- read.csv2("data-raw/landcover.csv")
network_metrics <- st_read("data-raw/network_landcover_continuity_metrics.gpkg")
network_axis <- st_read("data-raw/network_axis.gpkg")

st_write(network_strahler, con, "network", driver = "PostgreSQL")
dbWriteTable(con, "continuity", continuity, overwrite = TRUE, row.names = FALSE)
dbWriteTable(con, "metrics", metrics, overwrite = TRUE, row.names = FALSE)
dbWriteTable(con, "landcover", landcover, overwrite = TRUE, row.names = FALSE)
st_write(network_metrics, con, "network_metrics", driver = "PostgreSQL")
st_write(network_axis, con, "network_axis", driver = "PostgreSQL")

dbDisconnect(con)
