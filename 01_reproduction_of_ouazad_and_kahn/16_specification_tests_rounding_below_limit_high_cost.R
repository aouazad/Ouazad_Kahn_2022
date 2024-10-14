
rm(list=ls())

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(tidyverse)
library(tidylog)
library(fixest)
library(broom)
library(fixest)
library(broom)

source("project_constants.R")

est_sample <- read_rds("output/est_sample_for_revision.Rds")

########################################################################################################
# LENDING STANDARDS REGRESSION                                                                         #
########################################################################################################

figure_dir <- "figures"
outputdir <- "output"
depvar_array <- c("originated", "securitized", "approved")

round_to_nearest_thousand <- function(x) {
  return (1000 * round(x/1000))
}

est_sample$effective_loanlimit <- round_to_nearest_thousand(est_sample$effective_loanlimit)

for (chosen_window in c(0.20, 0.10, 0.05, 0.04, 0.03, 0.02, 0.01)) {

for (depvar in depvar_array) {
        
        est_sample_filtered <- est_sample %>% 
                        filter(time %in% -4:4) %>%
                        mutate(below_limit = as.numeric(log_loan_amount < log(effective_loanlimit/1000))) %>%
                        filter(abs(diff_log_loan_amount) <= chosen_window)

        if (depvar == "securitized")
            est_sample_filtered <- est_sample_filtered %>%
                filter(action.type %in% c(1,6))
        if (depvar %in% c("approved", "originated"))
            est_sample_filtered <- est_sample_filtered %>%
                filter(action.type %in% c(1,2,3)) # all applications
        
        regf <- as.formula(sprintf(paste0("%s ~ %s + %s + %s + %s + %s + %s + %s + %s", # covariates
                                          "+ below_limit + below_limit:treated + below_limit:highcost + below_limit:treated:highcost ",
                                          "| as.factor(highcost) + as.factor(year) + as.factor(ZCTA5CE10) + as.factor(name_event)" # fixed effects
                                          ), 
                                   depvar,
                                   paste(sprintf("below_limit:time_m%d:treated",
                                                 (abs(range(est_sample_filtered$time)[1]):2)),
                                         collapse = " + "),
                                   paste(sprintf("below_limit:time_%d:treated",
                                                 0:range(est_sample_filtered$time)[2]),
                                         collapse = " + "),
                                   paste(sprintf("time_m%d:treated",
                                                 (abs(range(est_sample_filtered$time)[1]):2)),
                                         collapse = " + "),
                                   paste(sprintf("time_%d:treated",
                                                 0:abs(range(est_sample_filtered$time)[2])),
                                         collapse = " + "),
                                   paste(sprintf("below_limit:year_%d",
                                                 (abs(range(est_sample_filtered$year)[1]):2012)),
                                         collapse = " + "),
                                   paste(sprintf("below_limit:year_%d",
                                                 2014:range(est_sample_filtered$year)[2]),
                                         collapse = " + "),
                                   paste(sprintf("below_limit:highcost:year_%d",
                                                 (abs(range(est_sample_filtered$year)[1]):2012)),
                                         collapse = " + "),
                                   paste(sprintf("below_limit:highcost:year_%d",
                                                 2014:range(est_sample_filtered$year)[2]),
                                         collapse = " + ")))
        
        print(regf)
        
        results <- feols(regf, 
                         data = est_sample_filtered,
                         cluster = ~ ZCTA5CE10 + year,                  # double-clustering
                         ssc = ssc(adj = FALSE, cluster.adj = FALSE),   # no impact on SEs
                         lean = TRUE, mem.clean = TRUE)  
        
        print(sprintf(' ****************** Results for %s', depvar))
        print(summary(results))
        print(results$N)

        tidy_results <- results %>% tidy()

        jumbodf <- tidy_results %>%
                filter(substr(term, 1, nchar("treated:time_")) == "treated:time_") %>%
                mutate(term = gsub("treated:time_", "", term, fixed = TRUE),
                       term = gsub("m", "-", term),
                       term = as.numeric(term))
        
        conformingdf <- tidy_results %>%
                filter(grepl("below_limit:treated", term, fixed = TRUE),
                       substr(term, 1, nchar("below_limit:treated:")) == "below_limit:treated:") %>%
          mutate(term = gsub("below_limit:treated:time_", "", term, fixed = TRUE),
                 term = gsub("m", "-", term),
                 term = as.numeric(term))

        if (chosen_window == 0.05) {

        pdf(paste0("figures/impact_on_jumbo_conforming_market_", 
                  depvar, "_rounding_below_limit_high_cost.pdf"))   
        plotCI(y = jumbodf$estimate,
               x = jumbodf$term,
               uiw = 1.96*jumbodf$std.error,
               ylim = range(c(jumbodf$estimate + 1.96 * jumbodf$std.error, 
                              conformingdf$estimate + 1.96 * conformingdf$std.error,
                              jumbodf$estimate - 1.96 * jumbodf$std.error, 
                              conformingdf$estimate - 1.96 * conformingdf$std.error)),
               xlab = "Years Since Hurricane Exposure",
               ylab = paste0("Impact on Probability ", str_to_title(depvar)))
        lines(y = rep(0, 10),
              x = -4 + 9 * (0:9)/9,
              lty = 2,
              col = "red")
        dev.off()
        
        pdf(paste0("figures/impact_on_conforming_market_", 
                   depvar, "_rounding_below_limit_high_cost.pdf"))   
        plotCI(y = conformingdf$estimate,
               x = conformingdf$term,
               uiw = 1.96*conformingdf$std.error)
        lines(y = rep(0, 10),
              x = -4 + 9 * (0:9)/9,
              lty = 2,
              col = "red")
        dev.off()
        }

        write_rds(slim_fixest(results, depvar),  # this speeds up the process
                  sprintf("output/results_%s_%s_rounding_below_limit_high_cost.rds", depvar, 
                          gsub(".", "_", sprintf("%02.2f", chosen_window),
                                         fixed = TRUE)
                 ))
    
}

}

require(car)

specs <- expand_grid(
        depvar =  c("approved", "originated", "securitized"),
        window = c(0.20, 0.10, 0.05)
)

listregs <- lapply(seq_len(nrow(specs)), 
        function(k) {
        read_rds(sprintf("output/results_%s_%s_rounding_below_limit_high_cost.rds", 
                                   specs$depvar[k], 
                                   gsub(".", "_", 
                                        sprintf("%02.2f", specs$window[k]),
                                        fixed = TRUE)
                                   ))
    }) 
    
pvalues <- sapply(listregs, 
        function(reg) {
        linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$`Pr(>Chisq)`[2] %>%
        format_pvalue(digits = 3)
    })

teststats <- sapply(listregs, 
        function(reg) {
        linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$Chisq[2]
    })

listregs %>% etable(keep = c("%below_limit:treated:time_0", 
                           "%below_limit:treated:time_1", 
                           "%below_limit:treated:time_2", 
                           "%below_limit:treated:time_3", 
                           "%below_limit:treated:time_4", 
                           "%below_limit:time_m4:treated", 
                           "%below_limit:treated:time_m3", 
                           "%below_limit:treated:time_m2"), 
                           tex = TRUE,
                  dict = c("below_limit" = "Below Conforming Limit",
                           "treated" = "Treated",
                           "time_0"  = "Time +0",
                           "time_1"  = "Time +1",
                           "time_2"  = "Time +2",
                           "time_3"  = "Time +3",
                           "time_4"  = "Time +4",
                           "time_m2"  = "Time -2",
                           "time_m3"  = "Time -3",
                           "time_m4"  = "Time -4",
                           "as.factor(ZCTA5CE10)" = "5-digit Zip Code",
                           "ZCTA5CE10" = "5-digit Zip Code",
                           "as.factor(year)" = "Year",
                           "as.factor(name_event)" = "Disaster"),
                 headers = list(c("20\\%", "10\\%", "5\\%",
                               "20\\%", "10\\%", "5\\%",
                               "20\\%", "10\\%", "5\\%")),
                extralines = list("Post Hurricane joint test" = teststats, 
                                  "Post Hurricane p-value" = pvalues)) %>%
        write_lines("tables/impact_conforming_market_rounding_below_limit_high_cost.tex")

specs <- expand_grid(
        depvar =  c("approved", "originated", "securitized"),
        window = c(0.04, 0.03, 0.02)
)

listregs <- lapply(seq_len(nrow(specs)), 
        function(k) {
        read_rds(sprintf("output/results_%s_%s_rounding_below_limit_high_cost.rds", 
                                   specs$depvar[k], 
                                   gsub(".", "_", 
                                        sprintf("%02.2f", specs$window[k]),
                                        fixed = TRUE)
                                   ))
    }) 
    
pvalues <- sapply(listregs, 
        function(reg) {
        linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$`Pr(>Chisq)`[2] %>%
        format_pvalue(digits = 3)
    })

teststats <- sapply(listregs, 
        function(reg) {
        linearHypothesis(reg, c("below_limit:treated:time_1=0",
                                    "below_limit:treated:time_2=0",
                                    "below_limit:treated:time_3=0",
                                    "below_limit:treated:time_4=0"),
                        test = "Chisq")$Chisq[2]
    })
    
listregs %>% etable(keep = c("%below_limit:treated:time_0", 
                           "%below_limit:treated:time_1", 
                           "%below_limit:treated:time_2", 
                           "%below_limit:treated:time_3", 
                           "%below_limit:treated:time_4", 
                           "%below_limit:time_m4:treated", 
                           "%below_limit:treated:time_m3", 
                           "%below_limit:treated:time_m2"), 
                           tex = TRUE,
                  dict = c("below_limit" = "Below Conforming Limit",
                           "treated" = "Treated",
                           "time_0"  = "Time +0",
                           "time_1"  = "Time +1",
                           "time_2"  = "Time +2",
                           "time_3"  = "Time +3",
                           "time_4"  = "Time +4",
                           "time_m2"  = "Time -2",
                           "time_m3"  = "Time -3",
                           "time_m4"  = "Time -4",
                           "as.factor(ZCTA5CE10)" = "5-digit Zip Code",
                           "ZCTA5CE10" = "5-digit Zip Code",
                           "as.factor(year)" = "Year",
                           "as.factor(name_event)" = "Disaster"),
                 headers = list(c("4\\%", "3\\%", "2\\%",
                               "4\\%", "3\\%", "2\\%",
                               "4\\%", "3\\%", "2\\%")),
                extralines = list("Post Hurricane joint test" = teststats, 
                                  "Post Hurricane p-value" = pvalues)) %>%
        write_lines("tables/impact_conforming_market_narrower_rounding_below_limit_high_cost.tex")



