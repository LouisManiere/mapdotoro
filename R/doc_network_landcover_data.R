#' network_landcover_data
#'
#' Subset of network dataset clipped by swaths joined with landcover data.
#'
#' @format A data frame with 7587 rows and 14 variables:
#' \describe{
#'   \item{ num }{  integer }
#'   \item{ ID }{  character }
#'   \item{ AXIS }{  numeric }
#'   \item{ popup }{  character }
#'   \item{ TOPONYME }{  character }
#'   \item{ hasData }{  character }
#'   \item{ GID }{  integer }
#'   \item{ VALUE }{  integer }
#'   \item{ M }{  integer }
#'   \item{ X }{  integer }
#'   \item{ landcover }{  character }
#'   \item{ landcover_area }{  integer }
#'   \item{ landcover_width }{  numeric }
#'   \item{ geom }{  sfc_MULTILINESTRING,sfc }
#' }
#' @source Source
"network_landcover_data"
