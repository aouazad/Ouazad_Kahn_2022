
rm(list=ls())

library(ggplot2)
library(dplyr)
library(tidyverse)
library(tidylog)
library(stringr)

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

list_specs <- c(
   "Below Limit, Below Limit x Treated, Treated, Below Limit x Time x Treated," = "_OLS",
   "Adding ZIP and Year f.e." = "_2wfe",
   "Adding ZIP and Year f.e. and Disaster, GitHub Sep 2024" = "",
   "Adding Agency fixed effects" = "_agency_dummies",
   "Adding High Cost fixed effects" = "_highcost",
   "Adding Agency and High Cost fixed effects" = "_agency_and_highcost",
   "Adding High Cost x year fixed effects" = "_highcost_year",
   "Adding Agency, High Cost, and High Cost x Year fixed effects" = "_agency_highcost_year",
   "Adding Below Limit x High Cost x Year" = "_belowlimit_highcost_year"
)

windows <- c(0.20, 0.10, 0.05, 0.04, 0.03, 0.02)

depvar <- c("approved", "originated", "securitized")

get_file_name <-function (spec, wnd, dv)
        sprintf("output/results_%s_%s%s.rds", dv, 
                gsub(".", "_", sprintf("%02.2f", wnd), fixed = TRUE), spec)

data <- c()

for (spec_k in seq_len(length(list_specs))) {

    spec_name <- names(list_specs)[spec_k]
    spec_code <- list_specs[spec_k]
    print(spec_name)

    for (dv in depvar) {

        for (wnd in windows) {

            fn <- get_file_name(spec_code, wnd, dv)
            print(get_file_name(spec_code, wnd, dv))

            df <- read_rds(get_file_name(spec_code, wnd, dv))

            for (t in 1:4) {

                pattern <- sprintf("(?=.*below_limit)(?=.*time_%d)(?=.*treated)", t)

                this_coefficient <- df$coefficients[
                    grepl(pattern, names(df$coefficients), perl = TRUE)
                ]
                this_se <- df$se[
                    grepl(pattern, names(df$se), perl = TRUE)
                ]

                data <- rbind(data, 
                    tibble(spec_code   = spec_code,
                           spec_name   = str_wrap(spec_name, width = 20),
                           window = wnd, 
                           depvar = dv, 
                           time   = t,
                           coeff  = this_coefficient,
                           se     = this_se)
                )
            }

        }

    }

}

# Calculate confidence intervals 
data$lower_ci <- data$coeff - 1.96*data$se
data$upper_ci <- data$coeff + 1.96*data$se

# Create the plot


for (chosen_time in c(1,2,3,4))
        for (wnd in c(0.05,0.03))
                for (chosen_depvar in c("approved", "originated", "securitized")) {
                        p <- ggplot(data %>% filter(time == chosen_time, window == wnd, depvar == chosen_depvar) , 
                                aes(y = spec_name, x = coeff)) +
                          geom_point(position = position_dodge(width = 0.5)) +
                          geom_errorbarh(aes(xmin = lower_ci, xmax = upper_ci), 
                                         height = 0.2, position = position_dodge(width = 0.5), lty = 2) +
                          geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
                          scale_y_discrete(limits = rev(unique(data$spec_name))) +
                          labs(x = "Coefficient Estimate", y = "Model Specification") +
                          theme_minimal() +
                          theme(legend.position = "bottom") +
                          scale_x_continuous(
                            breaks = c(0, 0.02, 0.05, 0.07, 0.10, 0.15, 0.20),
                            labels = scales::percent_format(accuracy = 1)
                          )
                        ggsave(paste0("output/coefficients_", chosen_depvar, "_time", chosen_time, 
                                        "_window", gsub(".", "_", sprintf("%02.2f", wnd), fixed=TRUE), ".png"), plot = p)
                }

