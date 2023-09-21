#' @title Translates character string to long-lat coordinates
#' @description The function is designed to translate any character string describing a location to the respective longitude and latitude coordinates (EPSG4326) by accessing the service endpoint "/search" of the \href{https://nominatim.org/release-docs/develop/api/Overview/}{Nominatim API} used by \href{https://www.openstreetmap.org/#map=21/52.97502/8.55864&layers=C}{Open Street Map}.
#'
#' @param address Any character string describing an address.
#' @return Numeric vector of length two containing longitude and latitude coordinates.
#' @export
#' @examples address_to_lonlat("Brandenburger Tor, Berlin")
address_to_lonlat <- function(address) {
  # first attempt. under development
  stopifnot(is.character(address), length(address) == 1L)

  address <- gsub(pattern = " ",
                  replacement = "+",
                  x = gsub(pattern = "\\.|\\,|\\:|\\;|\\(|\\)|\\+|\\=",
                           replacement = "",
                           x = address))
  # API changes on August 03, 2023,
  # see https://github.com/osm-search/Nominatim/issues/3134
  url <- "https://nominatim.openstreetmap.org/search?q="
  urlenc <- utils::URLencode(paste(url, address, "&format=json&limit=1"))
  as.numeric(unlist(rjson::fromJSON(file = urlenc)[[1L]][c("lon", "lat")]))
}
