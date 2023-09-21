#' Donwload list of all DWD stations
#'
#' @note Link and list contain German words.
#'
#' @param url_txt Default exists. Do not touch. The .txt-file can be found under \href{https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/daily/kl/recent/KL_Tageswerte_Beschreibung_Stationen.txt}{DWD station list}.
#'
#' @return A data frame.
#' @export
#'
#' @examples dwd_stations()
dwd_stations <- function(
    url_txt = "https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/daily/kl/recent/KL_Tageswerte_Beschreibung_Stationen.txt") {
  # retrieve
  tbl <- utils::read.table(url_txt,
                           header = FALSE,
                           fill = TRUE,
                           fileEncoding = "Latin1")
  # clean
  tbl[ , c(8, 9)] <- list(NULL)
  colnames(tbl) <- as.character(tbl[1, ])
  tbl <- tbl[-c(1, 2), ]
  tbl[tbl == ""] <- NA
  tbl <- stats::na.omit(tbl)
  tbl[, c("Stationshoehe", "geoBreite", "geoLaenge")] <-
    lapply(tbl[, c("Stationshoehe", "geoBreite", "geoLaenge")], as.numeric)
  # return
  tbl
}
