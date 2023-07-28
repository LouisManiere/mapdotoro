#' network_continuity_data
#'
#' Subset of network dataset clipped by swaths joined with continuity data.
#'
#' @format A data frame with 5058 rows and 16 variables:
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
#'   \item{ continuity }{  character }
#'   \item{ continuity_area }{  integer }
#'   \item{ continuity_width }{  numeric }
#'   \item{ continuity_weighted_area }{  integer }
#'   \item{ continuity_weighted_width }{  numeric }
#'   \item{ geom }{  sfc_MULTILINESTRING,sfc }
#' }
#' @source Source
"network_continuity_data"
