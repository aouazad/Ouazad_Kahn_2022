
rm(list=ls())

library(tidyverse)
library(tidylog)
library(car) # for linear hypothesis test
library(fixest)

source("project_constants.R") # utilities for the project

# make a table of linear tests of post treatment effects

# for each window

windows <- c(0.20, 0.10, 0.05, 0.04, 0.03, 0.02)

# for each dependent variable

depvar <- c("approved", "originated", "securitized")

# for each specification

list_specs <- c(
   "Below Limit, Below Limit x Treated, Treated, Below Limit x Time x Treated" = "_OLS",
   "Adding ZIP and Year f.e." = "_2wfe",
   "Adding ZIP and Year f.e. and Disaster, GitHub Sep 2024" = "",
   "Adding Agency fixed effects" = "_agency_dummies",
   "Adding High Cost fixed effects" = "_highcost",
   "Adding Agency and High Cost fixed effects" = "_agency_and_highcost",
   "Adding High Cost x year fixed effects" = "_highcost_year",
   "Adding Agency, High Cost, and High Cost x Year fixed effects" = "_agency_highcost_year",
   "Adding Below Limit x High Cost x Year" = "_belowlimit_highcost_year"
)

get_file_name <-function (spec, wnd, dv)
        sprintf("output/results_%s_%s%s.rds", dv, 
                gsub(".", "_", sprintf("%02.2f", wnd), fixed = TRUE), spec)

##################################################
# For each dependent variable

for (chosen_depvar in depvar) {

tbldf <- c()

emptyrow <- tibble(Specification  = "", 
                   `$\\pm$ 20\\%` = "", 
                   `$\\pm$ 10\\%` = "", 
                   `$\\pm$  5\\%`  = "", 
                   `$\\pm$  4\\%`  = "", 
                   `$\\pm$  3\\%`  = "", 
                   `$\\pm$  2\\%`  = "")

for (spec_k in seq_len(length(list_specs))) {

    spec_name <- names(list_specs)[spec_k]
    spec_code <- list_specs[spec_k]
    print(spec_name)

    dfrow <- tibble(Specification = c(str_wrap(spec_name, width = 20), ""))

    for (chosen_window in windows) {

        print(chosen_window)

        fn <- get_file_name(spec_code, chosen_window, chosen_depvar)
        print(fn)

        reg <- read_rds(fn)
    
        pvalue <- linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$`Pr(>Chisq)`[2] %>%
                   format_pvalue(digits = 3)

        teststat <- sprintf("%3.2f", linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$Chisq[2])

        dfrow <- cbind(dfrow, tibble(window = c(teststat,pvalue)))

        names(dfrow)[names(dfrow)=="window"] <- sprintf("$\\pm$ %2.0f\\%%", 100*chosen_window)

    }

    tbldf <- rbind(tbldf, 
                   dfrow,
                   emptyrow)    

}

require(xtable)

tbldf %>%
    xtable(align = c("l", "p{5cm}", "c","c","c","c","c","c")) %>%
    print(include.rownames=FALSE, sanitize.text.function = my_sanitize, floating = FALSE, type="html") %>%
    write_lines(paste0("tables/linear_tests_", chosen_depvar, ".html"))

}
