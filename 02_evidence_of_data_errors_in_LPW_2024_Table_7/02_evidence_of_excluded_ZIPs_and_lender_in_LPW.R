# This scripts presents evidence that in the replication code of LLPW (2024)
# a *hardcoded* list of ZIP codes was excluded from the analysis
# These ZIP codes are important: they are part of the treatment group.
#
# The code of LPW falsely claims that this exclusion comes from Ouazad and Kahn (2022)
# The next script shows that these ZIP codes are present in OK's (2022)
#  *posted RFS dataverse archive* dated December 6th 2021.

rm(list=ls())
library(tidyverse)
library(readxl)
library(xtable)

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load the ZIP codes excluded by LPW

# Load the CSV files for each of the tables

# Show the code that excludes these ZIP codes
code <- readLines("downloads/Climate Risk Replication/generateRegressionSample.m")
# note that 02_generateRegressionSample.m is not a correct MATLAB file name
# so it needs to be renamed generateRegressionSample.m to be functional
print(" ** the code that excludes these ZIP codes")
# This is on lines  140 to 143
print(code[140:143])

# the code claims that this is per Ouazad and Kahn (2022). 
# This is false. Ouazad and Kahn (2022) do not exclude these ZIP codes.
# See evidence below using the RFS Dataverse archive.

print(" ** the code that duplicates counties")
# This is on lines  129 to 131
print(code[129:131])

print(" ** the code that excludes an arbitrary lender")
# This is on line 134 
print(code[134])

# Load the ZIP codes excluded by LPW
excluded_ZIPs_df <- readxl::read_xlsx("downloads/Climate Risk Replication/excluded_ZIPs.xlsx")
excluded_ZIPs <- excluded_ZIPs_df$ZCTA5CE10

# this CSV file is used for Table 5 of the LPW Comment
dflpw_2023_table_5 <- read_csv("downloads/Climate Risk Replication/regression_input_Table5.csv", guess_max = 500000)
# this CSV file is used for Table 7 of the LPW Comment
dflpw_2023_table_7 <- read_csv("downloads/Climate Risk Replication/regression_input_Table7.csv", guess_max = 500000)

# Check that these ZIP codes are absent from their sample

table(dflpw_2023_table_5$ZCTA5CE10 %in% excluded_ZIPs)
table(dflpw_2023_table_7$ZCTA5CE10 %in% excluded_ZIPs)

# I have no idea why they are excluding these ZIP codes. 
#  They are present in the OK (2022) sample
#  and there is no reason to exclude them.

# Load the OK (2022) sample

dfok_2022 <- read_rds("downloads/00_main_regressions/est_sample_classifier.rds")

# Check that these ZIP codes are present in the OK (2022) sample

table(excluded_ZIPs %in% dfok_2022$ZCTA5CE10)

# they matter because:
# 1. they are in the treatment group
# 2. they are more likely to be in the conforming segment, backed by the GSEs

# Show that these ZIP codes are in the treatment group

dfok_2022 %>%
  filter(ZCTA5CE10 %in% excluded_ZIPs) %>%
  select(ZCTA5CE10, treated, state, name_event) %>%
  distinct() %>%
  rename(`5-digit ZIPs Excluded by LPW` = ZCTA5CE10,
         `Treated in OK (2022)` = treated,
         `State FIPS` = state,
         `Hurricane in OK (2022)` = name_event) %>%
  mutate(`Treated in OK (2022)` = 
                ifelse(`Treated in OK (2022)` == 1, 
                        "Yes", "No"),
         `Hurricane in OK (2022)` = gsub("_", " ", 
                                        `Hurricane in OK (2022)`, fixed = TRUE)) %>%
  xtable(caption = "Lists of ZIP codes excluded manually by LLPW on lines 140-143 of 02\\_generateRegressionSample.m",
         align = c("l", "c", "c", "c", "c")) %>%
  print(type = "latex", include.rownames = FALSE,
        floating = FALSE) %>%
  write_lines("tables/excluded_ZIPs_in_treatment_group.tex")

rbind(
summary(dfok_2022$diff_log_loan_amount[dfok_2022$ZCTA5CE10 %in% excluded_ZIPs]) %>%
    as.numeric(),
summary(dfok_2022$diff_log_loan_amount[!(dfok_2022$ZCTA5CE10 %in% excluded_ZIPs)]) %>%
    as.numeric()
) %>% as_tibble() %>%
 # set the column names
    setNames(c("Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")) %>%
    # add the row names
    rownames_to_column("Sample") %>%
    mutate(Sample = ifelse(Sample == "1", 
                              "Excluded ZIPs", "Rest of the sample")) %>%
    # print the table
  xtable(caption = "Summary statistics of log(loan amount) - Conforming Limit for the ZIPs wrongly excluded by LLPW and the rest of the sample",
         # align the columns as lcccccc
         align = c("l", "l", "c", "c", "c", "c", "c", "c")
         ) %>%
  print(type = "latex", include.rownames = FALSE, floating = FALSE) %>%
  write_lines("tables/summary_diff_log_loan_amount_excluded_ZIPs.tex")

pdf("figures/density_diff_log_loan_amount_excluded_ZIPs.pdf")
plot(density(dfok_2022$diff_log_loan_amount[dfok_2022$ZCTA5CE10 %in% excluded_ZIPs]), col = "red", lwd = 2, main = "Density of diff_log_loan_amount for the ZIPs wrongly excluded by LPW", xlab = "diff_log_loan_amount")
# add a vertical dashed line at x=0
abline(v=0, col="black", lty=2)
dev.off()



