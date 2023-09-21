#' Calculate Distance in Meters between Location and Nearest Stations
#'
#' @param stations Selection from \code{dwd_stations()}.
#' @param location Result of \code{address_to_lonlat}.
#' @param n_max Number of entries to be returned. Default ist set to 10.
#'
#' @return Data frame containing list of stations in neighbourhood of specified location. From nearest to longest.
#' @export
#'
#' @examples distance_between(stations = dwd_stations(), location = address_to_lonlat("Zugspitze, Deutschland"))
distance_between <- function(stations,
                             location,
                             n_max = 10L) {
  stopifnot(is.vector(location) && length(location) == 2L,
            is.numeric(n_max))
  ### currently messy ###
  # st_distance works out the great circle distance between points based on the ellipsoid.
  stations <-sf::st_as_sf(x = stations,
                          coords = c("geoLaenge", "geoBreite"),
                          crs = 4326)   # EPSG 4326
  location <- sf::st_as_sf(
    x = data.frame("geoLaenge" = rep(location[1L], nrow(stations)),
                   "geoBreite" = rep(location[2L], nrow(stations))),
    coords = c("geoLaenge", "geoBreite"),
    crs = 4326)
  stations$distance <- sf::st_distance(x = location,
                                       y = stations,
                                       by_element = TRUE)
  stations <- stations[order(stations$distance), ]
  if(n_max != 0L) stations <- stations[seq(n_max), ]
  stations
}
