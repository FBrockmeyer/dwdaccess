#' Return urls of zip files if station data is available
#'
#' @param link API link, e.g. \href{https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/recent/}{here}
#'
#' @return A data frame containing station ids, basenames, and zip urls.
#' @export
#'
#' @examples zip_urls(link = "https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/recent/")
zip_urls <- function(link) {
  df <-
    rvest::read_html(link) |>
    rvest::html_nodes("a") |>
    rvest::html_attr("href") |>
    as.data.frame() |>
    dplyr::rename(basename = 1) |>
    # TODO: likely "akt.zip" is not universal enough
    dplyr::filter(grepl("hist.zip$|akt.zip$", basename)) |>
    dplyr::mutate(url = paste0(link, basename),
                  # TODO: probably "\\d{5}(?=_)" has shortcomings
                  id = stringr::str_extract(basename, "\\d{5}(?=_)"),
                  basename = NULL)

  if(grepl("precipitation", link) & !grepl("historical", link)) {
    upload_date <-
      rvest::read_html(link) |>
      rvest::html_nodes(xpath = "/html/body/pre/a/following-sibling::text()[3]") |>
      xml2::xml_text(trim = TRUE) |>
      stringr::str_extract(pattern = "\\d{2}-\\w{3}-\\d{4}\\s\\d{2}\\:\\d{2}") |>
      as.POSIXct(tz = Sys.timezone(), format = "%d-%b-%Y %H:%M")

    df <- cbind(df, upload_date)

    if(grepl("recent", link)) {
      df[as.Date(df$upload_date) %in% seq(Sys.Date()-3, by = "day", length.out = 4), ] } else df

  } else df

}




