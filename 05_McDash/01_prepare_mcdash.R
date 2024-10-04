rm(list=ls())

library(tidyverse)
library(tidylog)
library(sf)

# set directory to folder of script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# heavy file, prepare a focused data set
if (!file.exists("temp/mcdash_master_redux.rds")) {

    df <- read_csv("/media/amine/Walras/Project_data/mcdash_master.csv", guess_max = 100000)

    dfredux <- df %>%
        filter(year >= 2000) %>%
        select(loanid,state,zip,originalloanamount,isjumbo,jumboatoriginationflag,year,closingmonth)

    write_rds(dfredux, "temp/mcdash_master_redux.rds")

} else {

    dfredux <- read_rds("temp/mcdash_master_redux.rds")

}

# match to a ZIP-county crosswalk

cw <- read_rds("temp/ZIP_county_crosswalk.rds")

dfredux <- dfredux %>%
    left_join(cw %>% select(-state), by = "zip") 

# then match to conforming loan limits

limitsdf <- read_rds("../01_reproduction_of_ouazad_and_kahn/output/conforming_loan_limits_1980_2017.rds") %>%
        distinct(county_fips, year, conforming_loan_limit)

dfredux <- dfredux %>%
    left_join(limitsdf, by = c("county_fips", "year"))

# keep observations in the +- 20% window

dfl <- dfredux %>%
    mutate(loan_to_limit = originalloanamount / conforming_loan_limit) %>%
    filter(loan_to_limit >= 0.8 & loan_to_limit <= 1.2)

# save the data

write_rds(dfl, "temp/mcdash_in_window.rds")
