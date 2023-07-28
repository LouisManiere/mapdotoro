#' network_metrics_data
#'
#' Subset of network dataset clipped by swaths joined with metrics data.
#'
#' @format A data frame with 843 rows and 25 variables:
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
#'   \item{ floodplain_slope }{  numeric }
#'   \item{ floodplain_z0 }{  numeric }
#'   \item{ talweg_height_min }{  numeric }
#'   \item{ talweg_height_median }{  numeric }
#'   \item{ talweg_height_is_interpolated }{  integer }
#'   \item{ talweg_length }{  numeric }
#'   \item{ talweg_elevation_min }{  numeric }
#'   \item{ talweg_elevation_median }{  numeric }
#'   \item{ talweg_slope }{  numeric }
#'   \item{ valley_bottom_width }{  numeric }
#'   \item{ active_channel_width }{  numeric }
#'   \item{ valley_bottom_area }{  integer }
#'   \item{ natural_corridor_width }{  numeric }
#'   \item{ connected_corridor_width }{  numeric }
#'   \item{ geom }{  sfc_MULTILINESTRING,sfc }
#' }
#' @source Source
"network_metrics_data"
