
rm(list=ls())

library(tidyverse)
library(tidylog)

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# this CSV file is used for Table 5 of the LPW Comment
dflpw_2023_table_5 <- read_csv("downloads/Climate Risk Replication/regression_input_Table5.csv", guess_max = 500000)
# this table is downloaded in R in LPW's code as well

# Load the OK (2022) sample
dfok_2022 <- read_rds("downloads/00_main_regressions/est_sample_classifier.rds")
# this is from the RFS Dataverse

sample_ok <- dfok_2022 %>%
    filter(abs(diff_log_loan_amount) <= 0.10)  %>%
    select(highcost, year,
            agency, action.type,
            diff_log_loan_amount,
            state, treated
            )

sample_dflpw <- dflpw_2023_table_5 %>%
    filter(abs(loan_to_limit_difference) <= 0.10) %>%
    select(high_cost, as_of_year,
            agency_code, action_taken,
            loan_to_limit_difference,
            state_code, # state is full of NAs
            Treatment,
            purchaser_type
            ) %>%
    rename(highcost = high_cost,
            year = as_of_year,
            agency = agency_code,
            action.type = action_taken,
            diff_log_loan_amount = loan_to_limit_difference,
            state = state_code,
            treated = Treatment
            )

# stack the two samples for t tests
df <- bind_rows(
    sample_dflpw %>% mutate(sample = "LPW"),
    sample_ok %>% mutate(sample = "OK")
) %>%
    mutate(lpw = sample == "LPW")

############################## MISSING TREATED OBSERVATIONS ##############################

bystatetreatment <- df %>%
    mutate(state = as.numeric(state)) %>%
    filter(treated == 1) %>%
    group_by(state, lpw) %>%
    summarise(n = n()) %>%
    spread(lpw, n) %>%
    select(state, `TRUE`, `FALSE`)  %>%
    rename(`State FIPS Code` = state,
           `LLPW Sample` = `TRUE`,
           `OK Sample` = `FALSE`) %>%
    mutate(`Missing Observations in Treated LLPW Sample` = `LLPW Sample` - `OK Sample`)

bystatetreatment %>%
    dplyr::select(`State FIPS Code`, `Missing Observations in Treated LLPW Sample`, `LLPW Sample`, `OK Sample`)

# pretty table
cw <- read_csv("crosswalk_state_FIPS_to_letter.csv") %>%
    select(stname, st) %>%
    mutate(st = as.numeric(st))

bystatetreatment %>%
    left_join(cw, by = c("State FIPS Code" = "st")) %>%
    rename(`State Name` = stname) %>%
    select(`State Name`, 
           `State FIPS Code`, 
           `Missing Observations in Treated LLPW Sample`, `LLPW Sample`, `OK Sample`) %>%
    mutate(`State FIPS Code` = sprintf("%02.0f", `State FIPS Code`)) %>%
    arrange(`Missing Observations in Treated LLPW Sample`) %>%
    xtable::xtable(caption = "Comparison of the Number of Observations in LLPW 2024 by State and Treatment Group") %>%
    print(include.rownames = FALSE,
          format.args = list(big.mark = ","), floating = FALSE, type = "html") %>%
    write_lines("tables/missing_treated_obs_by_state.html")


############################## BUNCHING OF MISSING TREATED OBSERVATIONS ##############################

cutoffs = -0.10 + seq(0, 0.20, 0.005)

bybinlpw_vs_ok <- df %>%
    mutate(state = as.numeric(state)) %>%
    filter(treated == 1) %>%
    mutate(diff_log_loan_amount_bin = 
            cut(diff_log_loan_amount, cutoffs)) 

cwbin <- bybinlpw_vs_ok %>%
    group_by(diff_log_loan_amount_bin) %>%
    summarise(diff_log_loan_amount = mean(diff_log_loan_amount, na.rm=TRUE))

graphdf <- bybinlpw_vs_ok %>%
    group_by(diff_log_loan_amount_bin, lpw) %>%
    summarise(n = n()) %>%
    spread(lpw, n) %>%
    select(diff_log_loan_amount_bin, `TRUE`, `FALSE`)  %>%
    left_join(cwbin, by = "diff_log_loan_amount_bin") %>%   
    rename(`Bin` = diff_log_loan_amount_bin,
           `LLPW Sample` = `TRUE`,
           `OK Sample` = `FALSE`) %>%
    mutate(`Missing Observations in Treated LLPW Sample` = `LLPW Sample` - `OK Sample`)

pdf("figures/missing_observations_bunching.pdf")
plot(graphdf$diff_log_loan_amount, 
     graphdf$`Missing Observations in Treated LLPW Sample`,
     ylab = "Number of Missing Observations in Treated LLPW Sample",
     xlab = "Distance to Conforming Limit")
# add vertical line at 0
abline(v = 0, col = "red", lty = 2)
dev.off()

