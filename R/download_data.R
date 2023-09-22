#' Wrapper to download data
#'
#' @param job Possible truncated result of \code{zip_urls()} containing urls and base names of station ids which should be downloaded.
#' @param cleanup Should the download folder be deleted after the process of unzipping, reading, and merging is completed?
#'
#' @return A data frame.
#' @export
#'
#' @examples
download_data <- function(job,
                          cleanup = TRUE) {
  stopifnot(is.data.frame(job) & "url" %in% names(job))
  path <- file.path(getwd(), "temp_folder")
  dir.create(path)

  lapply(job$url,
         \(x) utils::download.file(x, destfile = file.path(path, basename(x)), quiet = TRUE))

  lapply(list.files(path = path, pattern = "\\.zip$", full.names = TRUE),
         \(x) utils::unzip(x, exdir = path))

  fls <- list.files(path = path, pattern = "\\.txt$", full.names = TRUE)

  lsjob <- lapply(fls[!grepl("Metadaten", fls)],
                  \(x) utils::read.table(x, fill = TRUE, header = TRUE, sep = ";"))

  x <- do.call("rbind", lsjob)

  if(cleanup) {
    if(file.exists(path)) {
      unlink(path, recursive = TRUE, force = TRUE)
      cat(paste("Disk clean-up: The directory", path, "has been deleted."))
    }
  }
  x
}
