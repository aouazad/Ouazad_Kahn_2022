
rm(list = ls())

library(tidyverse)
library(tidylog)
library(sf)

countypg <- st_read("shapefiles/US_county_2014.shp") %>%
    st_transform(2163)

zippg <- st_read("shapefiles/US_zcta_2014.shp") %>%
    st_transform(2163)

if (!file.exists("temp/ZIP_county_inter.rds")) {

    inter <- st_intersection(countypg, zippg)

    write_rds(inter, "temp/ZIP_county_inter.rds")

} else {

    inter <- read_rds("temp/ZIP_county_inter.rds")

}

# match each ZIP to its corresponding county

inter <- inter %>%
    mutate(inter_area = as.numeric(st_area(.)))

cw <- inter %>%
    select(STATEFP,COUNTYFP,ZCTA5CE10,inter_area) %>%
    group_by(ZCTA5CE10) %>%
    filter(inter_area == max(inter_area,na.rm=TRUE)) %>%
    mutate(county_fips = paste0(STATEFP, COUNTYFP)) %>%
    rename(state = STATEFP) %>%
    select(ZCTA5CE10, state, county_fips) %>%
    rename(zip = ZCTA5CE10) %>%
    as_tibble() %>%
    select(-geometry)

write_rds(cw, "temp/ZIP_county_crosswalk.rds")


