% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/address_to_lonlat.R
\name{address_to_lonlat}
\alias{address_to_lonlat}
\title{Translates character string to long-lat coordinates}
\usage{
address_to_lonlat(address)
}
\arguments{
\item{address}{Any character string describing an address.}
}
\value{
Numeric vector of length two containing longitude and latitude coordinates.
}
\description{
The function is designed to translate any character string describing a location to the respective longitude and latitude coordinates (EPSG4326) by accessing the service endpoint "/search" of the \href{https://nominatim.org/release-docs/develop/api/Overview/}{Nominatim API} used by \href{https://www.openstreetmap.org/#map=21/52.97502/8.55864&layers=C}{Open Street Map}.
}
\examples{
address_to_lonlat("Brandenburger Tor, Berlin")
}
