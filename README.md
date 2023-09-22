DWD Intro
================
Friedemann Brockmeyer

<!-- README.md is generated from README.Rmd. Please edit that file -->

## Disclaimer

I am a Statistician with a passion for sensor data and open data
projects. While I have designed and assembled my own weather station (on
the basis of the *Raspberry Pi 3*), I also dealt with open data
availability of weather data in Germany. A few initial efforts are shown
below.

Note, this site is not intended to share my code - mostly written in
*python*, *mySQL*, and *R* - to operate my weather station, and to save
my data on a self-hosted server. At least for the moment.

## The Data

As of September 22, 2023, the weather and climate data for Germany can
be found at the [open data
server](https://opendata.dwd.de/climate_environment/CDC/) provided by
[“Deutscher Wetterdienst”](https://www.dwd.de/EN/Home/home_node.html),
commonly abbreviated as “*DWD*”.

To access relevant data conveniently, we wrapped simple functions in a
tiny package called `{dwdaccess}`. The usage will be demonstrated by
telling a little story originated from a trivial conversation I had with
a friend at a lake on a hot summer day in August 2023.

Note, beyond the scope of this project there exist other packages to
handle data from DWD like [“rdwd”](https://bookdown.org/brry/rdwd/).

## Installation

One can install the development version of `{dwdaccess}` from
[GitHub](https://github.com/FBrockmeyer/dwdaccess) with:

``` r
# install.packages("devtools") # uncomment this if necessary 
devtools::install_github("FBrockmeyer/dwdaccess")
library(dwdaccess)
```

The development of a full and competitive package available via CRAN is
not planned yet.

## Example: A *tropical night*

The lake we met at was the famous
[Wannsee](https://www.openstreetmap.org/search?query=Wannsee#map=12/52.4341/13.1992).
To retrieve the latitude and longitude coordinates of any location we
wrote a function `address_to_lonlat()` which translates any location
described by a character string like *Wannsee Berlin* to a numeric
vector of longitude and latitude. To do so, the function relies on an
API service from [Open Street Map](https://www.openstreetmap.org/). This
allows a visualisation of any location in *RStudio* and can be
particularly interesting for the development of a *shiny app*:

``` r
{
  library(leaflet)
  library(leaflegend)
}

kladow <- address_to_lonlat("Kladow Berlin")

leaflet() |>
  addTiles() |>
  flyTo(lng = kladow["longitude"],
        lat = kladow["latitude"], 
        zoom = 11) |>
  addMiniMap(width = 150, height = 150)
```

<div class="leaflet html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-6681e2aaf04dff6a3a8e" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-6681e2aaf04dff6a3a8e">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMiniMap","args":[null,null,"bottomright",150,150,19,19,-5,false,false,false,false,false,false,{"color":"#ff7800","weight":1,"clickable":false},{"color":"#000000","weight":1,"clickable":false,"opacity":0,"fillOpacity":0},{"hideText":"Hide MiniMap","showText":"Show MiniMap"},[]]}],"flyTo":[{"latitude":52.4602925,"longitude":13.1400517},11,[]]},"evals":[],"jsHooks":[]}</script>

Besides the location of interest, we need the locations of all weather
stations operated and affiliated by DWD to identify relevant stations
close by. The function `dwd_stations()` returns a list of weather
stations. The list is on-line available, click
[here](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/daily/kl/recent/KL_Tageswerte_Beschreibung_Stationen.txt).
Finally, with `distance_between()` we are able to calculate the distance
between the inserted location, *Kladow*, a village situated on the lake,
and the nearest weather stations in meters:

``` r
distance_between(stations = dwd_stations(),
                 location = address_to_lonlat(address = "Kladow Berlin")
                 # everything followed by the closing parenthesis is for styling purposes only
                 ) |> head() |> kable() 
```

|     | Stations_id | von_datum | bis_datum | Stationshoehe | Stationsname      | geometry                |        distance |
|:----|:------------|:----------|:----------|--------------:|:------------------|:------------------------|----------------:|
| 113 | 00435       | 19640101  | 20061231  |            45 | Berlin-Zehlendorf | POINT (13.2327 52.4289) |  7184.398 \[m\] |
| 563 | 02621       | 19560101  | 19691231  |            42 | Kleinmachnow      | POINT (13.2134 52.4045) |  7950.801 \[m\] |
| 849 | 03988       | 18930101  | 20191231  |            81 | Potsdam           | POINT (13.0622 52.3822) | 10162.401 \[m\] |
| 848 | 03987       | 18930101  | 20230921  |            81 | Potsdam           | POINT (13.0622 52.3812) | 10257.607 \[m\] |
| 95  | 00402       | 18760101  | 19621231  |            55 | Berlin-Dahlem     | POINT (13.2997 52.4564) | 10825.689 \[m\] |
| 96  | 00403       | 19500101  | 20230921  |            51 | Berlin-Dahlem     | POINT (13.3017 52.4537) | 10977.383 \[m\] |

Note, throughout this introduction the commands `kable()` and, later,
`t() |> kable()` are used to style the output. `kable()` is exported
from package
[`{knitr}`](https://bookdown.org/yihui/rmarkdown-cookbook/kable.html).
The wrapper `zip_urls()` scraps the information found under the urls of
the following form:
<https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/recent/>,
i.e.,

``` r
recent_temp <- zip_urls(
  link = "https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/recent/") 

historical_temp <- zip_urls(
  link = "https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/historical/")
```

and is mainly designed to collect all available urls to *.zip*-files. A
link for each station/id. The function is not restricted to observations
on a hourly basis. It works with [other time intervals between
measurements](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/)
as well.

Lets store the station ids of the five closest weather stations (A) and
check if data, i.e. links to *.zip*-files, is indeed available (B):

``` r
# (A)
nearest5stations <- distance_between(stations = dwd_stations(),
                                     location = address_to_lonlat(address = "Kladow Berlin")
                                     )$Stations_id[1:5]

# (B)
recent_temp[recent_temp$id %in% nearest5stations, ] |> kable()
```

|     | url                                                                                                                                        | id    |
|:----|:-------------------------------------------------------------------------------------------------------------------------------------------|:------|
| 296 | <https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/recent/stundenwerte_TU_03987_akt.zip> | 03987 |

``` r
historical_temp[historical_temp$id %in% nearest5stations, ] |> kable()
```

|     | url                                                                                                                                                               | id    |
|:----|:------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------|
| 379 | <https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/historical/stundenwerte_TU_03987_18930101_20221231_hist.zip> | 03987 |

It looks like the station with `id` $03987$ is the only of the five
closest stations providing data. Does the data for recent and historical
records come from the same station?

``` r
recent_temp[recent_temp$id %in% nearest5stations, ]$id == historical_temp[historical_temp$id %in% nearest5stations, ]$id
```

    ## [1] TRUE

Yes. Which station name corresponds to the `id`?

``` r
dwd_stations()[
  which(dwd_stations()$Stations_id == recent_temp[recent_temp$id %in% nearest5stations, ]$id), ]
```

    ##     Stations_id von_datum bis_datum Stationshoehe geoBreite geoLaenge
    ## 848       03987  18930101  20230920            81   52.3812   13.0622
    ##     Stationsname
    ## 848      Potsdam

The weather station on the grounds of the university it is, click
[here](https://www.openstreetmap.org/search?whereami=1&query=52.38124%2C13.06212#map=19/52.38124/13.06212)
to see the location. As we have now identified potential data, we
continue with the download of recent (air) temperature (and humidity)
data on an hourly basis. Additionally, we download all historical data
that is available.

Note. A thorough documentation can be found
[here](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/).
A complete list of the available variables can be obtained from
[here](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/).
Note, we assume that the download function `download_data()` can also be
used for other subfolders than *air_temperature* and *precipitation*.

The following code demonstrates the utilisation of `download_data()` to
access data from a certain weather station. The function can also be
used to download data from several stations at once. For this, the input
data frame `job` needs to contain several station ids. After the
download process is complete, we use several `{data.table}` functions to
rename and modify the data in the fastest possible manner. You can
ignore the surrounding if-clause and its purposes.

``` r
# Code in clause runs only once per R session. This is intended 
if(exists("hasRun") == FALSE) {
  
  # Download weather data 
  recent_data <- download_data(job = recent_temp[recent_temp$id %in% nearest5stations, ],
                          cleanup = TRUE)
  historical_data <- download_data(job = historical_temp[historical_temp$id %in% nearest5stations, ],
                              cleanup = TRUE)
  # Modify and rename 
  {
    library(data.table)
  }
  # Merge data sets
  # Note. {data.table} is the fast. 
  data <- data.table::merge.data.table(x = data.table::setDT(recent_data),
                                       y = data.table::setDT(historical_data), 
                                       all = TRUE)
  # Clean-up environment 
  rm(recent_data, historical_data)
  
  # Renaming
  data <- setNames(data, 
                   c("id", "datetime", "quality9", "temperature", "humidity", "eor"))
  
  # Change character variable containing date information to POSIXct (datetime)
  data[, datetime := as.POSIXct(x = as.character(datetime), 
                            format = "%Y%m%d%H", 
                            origin = Sys.timezone())]
  # Pad id with zeros; nchar == 5
  data[, id := sprintf("%05s", id)]
  # Replace missing values with R-like NA's in the fastest possible manner data.table provides
  for(col in names(data)) data.table::set(data, i = which(data[[col]] == -999.000), j = col, value = NA)
  
  hasRun <- TRUE 
}
```

    ## The directory /Users/cara/Desktop/dwdaccess/temp_folder has been deleted.The directory /Users/cara/Desktop/dwdaccess/temp_folder has been deleted.

The data is now downloaded, merged and prepared in a very R-like
fashion. The time has come to do simple explanatory analysis. How many
observations and variables did we get?

``` r
dim(data) 
```

    ## [1] 1145842       6

More than a million observations, and six variables, distributed over

``` r
difftime(max(data$datetime, na.rm = TRUE), min(data$datetime, na.rm = TRUE), 
                                         tz = Sys.timezone(), units = "days") |>kable()
```

| x             |
|:--------------|
| 47743.87 days |

roughly $\approx130.71$ years. That is the number of days $477743.87$
divided by $365.25$. Loosely speaking, as we deal with hourly
observations, the deviation from the maximal number:
$47743.87*24 = 114852.88$ is negligible and certainly the result of
carelessness in computation. More relevant is the share of observations
with non-missing (air) temperature values:

``` r
sum(complete.cases(data$temperature)) / nrow(data)
```

    ## [1] 0.9999799

This figure is impressively high. Quite a “dense” data set!

Coming back to the trivial conversation. We spoke about the extreme heat
during these days in the middle of August 2023. One mentioned: “We have
a **tropical night**.”. *Meteorologists* define those as **nights where
the lowest (air) temperature between 6 pm and 6 am does not fall under
20°C** (add source). By the way, (air) temperature is commonly measured
at a height of two meters above sea level, see, e.g. the [DWD
documentation](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/DESCRIPTION_obsgermany_climate_hourly_air_temperature_en.pdf).
We would now like to know whether he was correct in stating that.

To increase comprehensibility, we switch to `{dplyr}` syntax. Although
slower in big data applications, it is more widely used in applied
science than `{data.table}`. First, we calculate a few more variables
`year`, `month`, and `date` to simplify filtering (1). Second, we store
the data under the name `example` to reduce length of code in subsequent
`code chunks` (2). We, then, *subset* the data to get the relevant
month: August 2023 (3). Essentially, we calculate an indicator variable
[`tn20GT`](https://en.wikipedia.org/wiki/Tropical_night) which is `TRUE`
if a certain night meets the definition and `FALSE` otherwise (4).

``` r
library(dplyr); library(lubridate)
# (1) + (2)
example <- data |>
  mutate(year = lubridate::year(datetime),
         month = lubridate::month(datetime), 
         date = lubridate::date(datetime)) 
# (3)
example |>
  filter(year == 2023 & 
           datetime >= as.POSIXct("2023073118", format = "%Y%m%d%H", origin = Sys.timezone()) & 
           datetime <= as.POSIXct("2023083106", format = "%Y%m%d%H", origin = Sys.timezone())
         ) |>
# (4)
  # shifted time ranges 
  mutate(shifted_start = lubridate::as_date(datetime - lubridate::hours(18))) |>
  summarise(tn20GT = all(temperature >= 20), .by = shifted_start) |>
  count(tn20GT) |> kable()
```

| tn20GT |   n |
|:-------|----:|
| FALSE  |  30 |
| TRUE   |   1 |

For each day, to decide whether or not a night was tropical the routine
considers the previous night instead of the upcoming one. This is a
matter of definition. As a consequence, $6$ hours of July 31, 2023 need
to be taken into account. Similarly, the filtering ends on
`as.POSIXct("2023083106", format = "%Y%m%d%H", origin = Sys.timezone())`,
such that the (air) temperatures on the last evening of August 2023 are
ignored as those only influence the calculation w.r.t. September 1,
2023. Which night was tropical?

``` r
example |>
  filter(year == 2023 & 
           # read "2023073118" as 6 p.m. on July 30, 2023 
           datetime >= as.POSIXct("2023073118", format = "%Y%m%d%H", origin = Sys.timezone()) & 
           datetime <= as.POSIXct("2023083106", format = "%Y%m%d%H", origin = Sys.timezone())
         ) |>
  mutate(shifted_start = lubridate::as_date(datetime - lubridate::hours(18))) |>
  summarise(tn20GT = all(temperature >= 20), .by = shifted_start) |>
  filter(tn20GT == 1) |> kable()
```

| shifted_start | tn20GT |
|:--------------|:-------|
| 2023-08-19    | TRUE   |

Note `shifted_start` is an auxiliary variable and slightly misleading in
terms of interpretation. Due to the shift, we need to add one day to the
date under `shifted_start`:

``` r
example |>
  filter(year == 2023 & 
           datetime >= as.POSIXct("2023081918", format = "%Y%m%d%H", origin = Sys.timezone()) & 
           datetime <= as.POSIXct("2023082006", format = "%Y%m%d%H", origin = Sys.timezone())
         ) |> kable()
```

| id    | datetime            | quality9 | temperature | humidity | eor | year | month | date       |
|:------|:--------------------|---------:|------------:|---------:|:----|-----:|------:|:-----------|
| 03987 | 2023-08-19 18:00:00 |        1 |        26.9 |       68 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-19 19:00:00 |        1 |        26.5 |       63 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-19 20:00:00 |        1 |        25.6 |       68 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-19 21:00:00 |        1 |        24.7 |       72 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-19 22:00:00 |        1 |        24.5 |       71 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-19 23:00:00 |        1 |        24.4 |       73 | eor | 2023 |     8 | 2023-08-19 |
| 03987 | 2023-08-20 00:00:00 |        1 |        23.6 |       74 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 01:00:00 |        1 |        23.1 |       82 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 02:00:00 |        1 |        22.7 |       84 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 03:00:00 |        1 |        22.0 |       88 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 04:00:00 |        1 |        21.3 |       92 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 05:00:00 |        1 |        21.0 |       91 | eor | 2023 |     8 | 2023-08-20 |
| 03987 | 2023-08-20 06:00:00 |        1 |        20.9 |       80 | eor | 2023 |     8 | 2023-08-20 |

**The night previous to the day August 20, 2023 was tropical.** The guy
was right. We have had a *tropical night* on this date.

The [German version](https://de.wikipedia.org/wiki/Tropennacht) of the
Wikipedia article “*Tropical night*” is interesting. Among other things,
it is explained that the [weather station of the Meteorological
Institute (LMU) in
Munich](https://www.meteorologie.lmu.de/ueber_uns/kontakt/index.html)
recorded a yearly average of $1.7$ *tropical nights* between 1982 and
2002. Worrisome, between 2003 and 2018 this number increased to $5.25$.
Unequal periods of time, $20$ and $15$ years as well as the selection of
the starting years appear questionable and need to be investigated.
Scientifically unsound at first glance. However, the following code
calculates those numbers for the weather station located in *Potsdam*:

``` r
example |>
  filter(year %in% 1982:2002) |>
  mutate(shifted_start = lubridate::as_date(datetime - lubridate::hours(18))) |>
  summarise(tn20GT = all(temperature >= 20), .by = c(shifted_start, year)) |>
  select(year, tn20GT) |>
  summarise(tn20GT_total = sum(tn20GT), .by = year) |> t() |> kable()
```

|              |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |
|:-------------|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| year         | 1982 | 1983 | 1984 | 1985 | 1986 | 1987 | 1988 | 1989 | 1990 | 1991 | 1992 | 1993 | 1994 | 1995 | 1996 | 1997 | 1998 | 1999 | 2000 | 2001 | 2002 |
| tn20GT_total |    0 |    1 |    0 |    0 |    0 |    1 |    1 |    0 |    0 |    0 |    1 |    0 |    4 |    1 |    0 |    0 |    1 |    0 |    1 |    1 |    1 |

In total $13$ *tropical nights* are recorded, resulting in an average of
$\approx0.62$ *tropical nights* per year between 1982 and 2002. 1994 is
striking with four occurrences. For the time period 2003-2018 the result
look as follows:

``` r
example |>
  filter(year %in% 2003:2018) |>
  mutate(shifted_start = lubridate::as_date(datetime - lubridate::hours(18))) |>
  summarise(tn20GT = all(temperature >= 20), .by = c(shifted_start, year)) |>
  select(year, tn20GT) |>
  summarise(tn20GT_total = sum(tn20GT), .by = year) |> t() |> kable()
```

|              |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |
|:-------------|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| year         | 2003 | 2004 | 2005 | 2006 | 2007 | 2008 | 2009 | 2010 | 2011 | 2012 | 2013 | 2014 | 2015 | 2016 | 2017 | 2018 |
| tn20GT_total |    2 |    0 |    1 |    3 |    2 |    0 |    0 |    5 |    0 |    1 |    5 |    1 |    6 |    2 |    0 |    8 |

In total $36$ *tropical nights*, resulting in an average of $2.25$
*tropical nights* per year.
