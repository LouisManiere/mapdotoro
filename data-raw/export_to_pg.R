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

st_write(network_strahler, db_con, "network", driver = "PostgreSQL")
dbWriteTable(db_con, "continuity", continuity, overwrite = TRUE, row.names = FALSE)
dbWriteTable(db_con, "metrics", metrics, overwrite = TRUE, row.names = FALSE)
dbWriteTable(db_con, "landcover", landcover, overwrite = TRUE, row.names = FALSE)

dbDisconnect(con)
