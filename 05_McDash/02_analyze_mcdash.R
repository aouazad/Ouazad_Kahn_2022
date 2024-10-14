
rm(list=ls())

library(tidyverse)
library(tidylog)

dfl <- read_rds("temp/mcdash_in_window.rds")

round_to_nearest_thousand <- function(x) {
  return (1000 * round(x/1000))
}

dfl$loanlimit_rounded <- round_to_nearest_thousand(dfl$conforming_loan_limit)

dfl <- dfl %>%
       mutate(below_limit = as.numeric(originalloanamount <= conforming_loan_limit),
              below_limit_rounded = as.numeric(originalloanamount <= loanlimit_rounded),
              diff_log_loan_amount = log(originalloanamount) - log(conforming_loan_limit))

# check that the Jumbo status is attributed before rounding

dfl <- dfl %>%
    mutate(at_limit = as.numeric(originalloanamount == round_to_nearest_thousand(conforming_loan_limit)))

table(dfl$isjumbo[dfl$at_limit == 1])

# now back to main sample

# Type I and Type II errors
# These numbers are in the Excel table
mean(dfl$below_limit_rounded[dfl$isjumbo == 1])
mean(dfl$below_limit[dfl$isjumbo == 1]) 

mean(dfl$isjumbo[dfl$below_limit == 1])
mean(dfl$isjumbo[dfl$below_limit_rounded == 1])

# By year

dferror = tibble()

for (chosen_year in c(2001:2017)) {

    es <- dfl %>%
        filter(abs(diff_log_loan_amount) <= 0.05) %>%
        filter(year == chosen_year)

    dferror <- rbind(dferror,
            tibble(
                year = chosen_year,
                Method = "OK, unrounded limit",
                type1error = mean(es$below_limit[es$isjumbo == 1]),
                type2error = mean(es$isjumbo[es$below_limit == 1]),
            ))

    dferror <- rbind(dferror,
            tibble(
                year = chosen_year,
                Method = "LLPW, rounded limit",
                type1error = mean(es$below_limit_rounded[es$isjumbo == 1]),
                type2error = mean(es$isjumbo[es$below_limit_rounded == 1])
            ))

}

# put two lines, Type I error for us and for LLPW
ggplot(data = dferror, aes(x = year, 
                           y = type1error, lty = Method)) +
    geom_line(col = "black") +
    labs(y = "McDash Jumbo Loans Below the Limit", 
         x = "Year",
         title = "McDash data: Type I error with Both Methods") +
    theme_minimal() +
    theme(legend.position = "bottom") +
    # fix the y axis to 0.00 to 0.25
    scale_y_continuous(limits = c(0.00, 0.25))
ggsave("figures/type1error.pdf", width = 12, height = 6)

# put two lines, Type II error for us and for LLPW
ggplot(data = dferror, aes(x = year, 
                           y = type2error, lty = Method)) +
    geom_line(col = "black") +
    labs(y = "Loans Below the Limit that are McDash Jumbo", 
         x = "Year",
         title = "McDash data: Type II error with Both Methods") +
    theme_minimal() +
    theme(legend.position = "bottom") +
    # fix the y axis to 0.00 to 0.25
    scale_y_continuous(limits = c(0.00, 0.25))
ggsave("figures/type2error.pdf", width = 12, height = 6)

# By window

dferror = tibble()

for (chosen_window in c(0.20,0.10,0.05,0.04,0.03,0.02)) {

    es <- dfl %>%
        filter(abs(diff_log_loan_amount) <= chosen_window)

    dferror <- rbind(dferror,
            tibble(
                window = chosen_window,
                Method = "OK, unrounded limit",
                type1error = mean(es$below_limit[es$isjumbo == 1]),
                type2error = mean(es$isjumbo[es$below_limit == 1]),
            ))

    dferror <- rbind(dferror,
            tibble(
                window = chosen_window,
                Method = "LLPW, rounded limit",
                type1error = mean(es$below_limit_rounded[es$isjumbo == 1]),
                type2error = mean(es$isjumbo[es$below_limit_rounded == 1])
            ))


}

# again, two lines, Type I and Type II error for us and for LLPW

ggplot(data = dferror, aes(x = window, 
                           y = type1error, lty = Method)) +
    geom_line(col = "black") +
    labs(y = "McDash Jumbo Loans Below the Limit", 
         x = "Window Around Conforming Loan Limit",
         title = "McDash data: Type I error with Both Methods") +
    theme_minimal() +
    theme(legend.position = "bottom") +
    # fix the y axis to 0.00 to 0.25
    scale_y_continuous(limits = c(0.00, 0.20))
ggsave("figures/type1error_bywindow.pdf", width = 12, height = 6)

ggplot(data = dferror, aes(x = window, 
                           y = type2error, lty = Method)) +
    geom_line(col = "black") +
    labs(y = "Loans Below the Limit that are McDash Jumbo", 
         x = "Window Around Conforming Loan Limit",
         title = "McDash data: Type II error with Both Methods") +
    theme_minimal() +
    theme(legend.position = "bottom") +
    # fix the y axis to 0.00 to 0.25
    scale_y_continuous(limits = c(0.00, 0.20))
ggsave("figures/type2error_bywindow.pdf", width = 12, height = 6)

