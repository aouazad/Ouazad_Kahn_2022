
rm(list=ls())
library(tidyverse)
library(readxl)
library(xtable)

# type ./download_LPW_RFS_Dataverse.sh in the terminal to download the data
# type ./download_OK_RFS_Dataverse.sh in the terminal to download the data

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# this CSV file is used for Table 5 of the LPW Comment
dflpw_2023_table_5 <- read_csv("downloads/Climate Risk Replication/regression_input_Table5.csv", guess_max = 500000)
# this table is downloaded in R in LPW's code as well

# this CSV file is used for Table 7 of the LPW Comment
dflpw_2023_table_7 <- read_csv("downloads/Climate Risk Replication/regression_input_Table7.csv", guess_max = 500000)
# this table is downloaded in R in LPW's code as well

# Load the OK (2022) sample
dfok_2022 <- read_rds("downloads/00_main_regressions/est_sample_classifier.rds")
# this is from the RFS Dataverse

# focus on the +- 10% window
dflpw5 <- dflpw_2023_table_5 %>%
    filter(action_taken %in% c(1,2,3,6)) # the filters used in the regressions

dflpw7 <- dflpw_2023_table_7 %>%
    filter(action_taken %in% c(1,2,3,6)) # the filters used in the approval and origination regressions

dfok <- dfok_2022 %>%
    filter(action.type %in% c(1,2,3,6)) # the filters used in the approval and origination regressions

# check the values of the high cost variable in the LPW (2023) sample
# no issue for table 5
table(dflpw5$high_cost, useNA = "always")
# issue for table 7
table(dflpw7$high_cost, useNA = "always")
# no issue for OK (2022)
table(dfok$highcost, useNA = "always")

table(dflpw7$state_code, dflpw7$high_cost,  useNA = "always")
table(dflpw7$action_taken, dflpw7$high_cost,  useNA = "always")

cutoffs = -0.10 + seq(0, 0.20, 0.005)

dflpw7_bin <- dflpw7 %>%
    filter(loan_to_limit_difference <= 0.05 &
            loan_to_limit_difference >= -0.05) %>%
    mutate(bin = cut(loan_to_limit_difference, cutoffs, 
                     include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarise(nans = sum(is.nan(high_cost)),
              loan_to_limit_difference = mean(loan_to_limit_difference, na.rm=TRUE)) %>%
    ungroup()

pdf("figures/nans_in_high_cost_dummy_bunching.pdf")
plot(dflpw7_bin$loan_to_limit_difference,
     dflpw7_bin$nans, breaks = 100,
     ylab = "Number of NaNs in high cost dummy",
     xlab = "Distance to conforming limit",
     main = "NaNs in the high cost dummy variable bunch at the conforming limit")
dev.off()


#################################################
# MAKE TYPESET TABLES FOR REPORT                #
#################################################

cw <- read_csv("crosswalk_state_FIPS_to_letter.csv") %>%
    select(st, stname) %>%
    rename(`State FIPS Code` = st,
           `State Name`= stname)

dflpw7 %>%
    group_by(state_code) %>%
    summarise(high_cost_0 = sum(high_cost == 0, na.rm = TRUE),
              high_cost_1 = sum(high_cost == 1, na.rm = TRUE),
              high_cost_nan = sum(is.nan(high_cost))) %>%
    rename(`0`= high_cost_0, `1`= high_cost_1, `NaN`= high_cost_nan,
            `State FIPS Code` = state_code) %>%
    left_join(cw, by = "State FIPS Code") %>%
    select(`State FIPS Code`, `State Name`, `NaN`, `0`,  `1`) %>%
    xtable(caption = "NaNs in high cost dummy by state",
            align = c("l", "l", "l", "c", "c", "c")) %>%
    print(include.rownames = FALSE, floating = FALSE) %>%
    write_lines("tables/nans_in_high_cost_dummy_by_state.tex")

dflpw7 %>%
    mutate(action_taken = as.character(action_taken)) %>%
    group_by(action_taken) %>%
    summarise(high_cost_0 = sum(high_cost == 0, na.rm = TRUE),
              high_cost_1 = sum(high_cost == 1, na.rm = TRUE),
              high_cost_nan = sum(is.nan(high_cost))) %>%
    rename(`0`= high_cost_0, `1`= high_cost_1, `NaN`= high_cost_nan,
            `Action Taken` = action_taken) %>%
    mutate(Description = case_when(
        `Action Taken` == 1 ~ "Loan originated",
        `Action Taken` == 2 ~ "Application approved but not accepted",
        `Action Taken` == 3 ~ "Application denied",
        `Action Taken` == 6 ~ "Loan purchased by the institution"
    )) %>%
    select(`Action Taken`, `Description`, `NaN`, `0`,  `1`) %>%
    xtable(caption = "NaNs in high cost dummy by action taken",
            align = c("l", "l", "l", "c", "c", "c")) %>%
    print(include.rownames = FALSE, floating = FALSE) %>%
    write_lines("tables/nans_in_high_cost_dummy_by_action_taken.tex")

# Compare counts in the LPW (2023) and OK (2022) samples

make_table <- function(df) {
    df %>%
    ungroup() %>%
    summarise(high_cost_0 = sum(high_cost == 0, na.rm = TRUE),
              high_cost_1 = sum(high_cost == 1, na.rm = TRUE),
              high_cost_nan = sum(is.nan(high_cost))) 
}

rbind(
    dfok %>% rename(high_cost = highcost) %>% 
        make_table() %>%
        mutate(Sample = "OK (2022)"),
    dflpw5 %>% make_table() %>%
        mutate(Sample = "LPW (2023) Table 5"),
    dflpw7 %>% make_table() %>%
        mutate(Sample = "LPW (2023) Table 7")) %>%
    rename(`0`= high_cost_0, `1`= high_cost_1, `NaN`= high_cost_nan) %>%
    select(Sample, `NaN`, `0`,  `1`) %>%
    xtable(caption = "Comparison of high cost dummy values in the LPW (2023) and OK (2022) samples",
            align = c("l", "l", "c", "c", "c")) %>%
    print(include.rownames = FALSE, floating = FALSE) %>%
    write_lines("tables/comparison_of_high_cost_dummy_values.tex")

stop()

# you can execute the code below to generate maps of the NaNs in the high cost dummy

#################################################
# MAKE MAP                                      #
#################################################

### Map of NaNs in Florida

require(sf)

for (chosen_fips in c("12", "37", "22")) {

    countypg <- st_read("census_shapefiles/US_county_2014.shp") %>%
        filter(STATEFP == chosen_fips) %>%
        mutate(county_fips = paste0(STATEFP, COUNTYFP))

    # do the map for Table 5, Table 7, and for the OK (2022) sample

    dflpw7_fl <- countypg %>%
        left_join(dflpw7 %>%
                  filter(state_code == as.numeric(chosen_fips)) %>%
                  mutate(county_fips = paste0(state_code, county_code)) %>%
                  group_by(county_fips) %>%
                  summarise(is_nan = ifelse(max(is.nan(high_cost))==1, "Yes", "No")),
                  by = "county_fips")

    p = ggplot(data = dflpw7_fl, aes(fill = is_nan)) +
        geom_sf() +
        labs(title = "NaNs in high cost dummy",
             fill = "Loans with 'NaN' for high_cost") +
        # make Yes in red and No in blue
        scale_fill_manual(values = c("No" = "blue", "Yes" = "red")) +
        theme_minimal() +
        theme(legend.position = "bottom")
    ggsave(paste0("figures/nans_in_high_cost_dummy_", chosen_fips, ".pdf"), plot = p,
           width = 6, height = 6)

}