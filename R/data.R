#' Lookup Table for ULAN Entities
#'
#' This table is used by the local method for \link{ulanr_match} to find match
#' possibilities for names in the Getty's Union List of Artist Names database.
#'
#' @format A data frame with 559178 rows and 7 variables:
#' \describe{
#'   \item{\code{id}}{integer. Artist ID.}
#'   \item{\code{alt_name}}{character. Alternative name, stripped of puncutation
#'   and capitals to ease matching.}
#'   \item{\code{pref_name}}{character. ULAN preferred name}
#'   \item{\code{birth_year}}{integer. Artist birth year, if assigned.}
#'   \item{\code{death_year}}{integer. Artist death year, if assigned}
#'   \item{\code{gender}}{character. Artist gender, if assigned.}
#'  \item{\code{nationality}}{character. Artist nationality, if assigned.}
#' }
#'
#' @source http://vocab.getty.edu/
"query_table"
