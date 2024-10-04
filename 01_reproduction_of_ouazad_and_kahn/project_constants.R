
# project constants


datadir   <- "output/"
figuredir <- "figures/"
tabledir  <- "tables/"

atlantic_states <- c("23",
                     "33", "25", "44", "09",
                     "36", "34", "10", "24", 
                     "51", "37", "45", "13", 
                     "12", "01", "28", "22", "48")

library(tidyverse)
library(tidylog)
library(lfe)
library(data.table)
library(RColorBrewer)
library(stargazer)

truncatevar_upper <- function(x, ub) {
  x[x > ub] <- ub
  x
}

truncatevar_lower <- function(x, lb) {
  x[x < lb] <- lb
  x
}

winsorize <- function(x, probs = 0.05) {
  
  lb <- quantile(x, probs = probs, na.rm = T)
  ub <- quantile(x, probs = 1-probs, na.rm = T)
  
  x[x>ub] <- ub
  x[x<lb] <- lb
  
  x
  
}

get_window_size_string <- function(ws)
  gsub("\\.","_", format(ws, nsmall = 3))

normalize_coeff_array <- function(x)
  sapply(lapply(strsplit(x, ":"), 
              function(strarray) { sort(strarray) }), function(strarray) paste(strarray, collapse =":"))

slim_fixest <- function(regdf, depvar) {

  regdf$linear.predictors <- NULL
  regdf$working_residuals <- NULL
  regdf$family <- NULL
  regdf$fml <- NULL
  regdf$fml_all <- NULL
  regdf[["fml"]][[2]] = depvar

  regdf

}

format_pvalue <- function(p, digits = 3) {
  formatted <- sprintf(paste0("%.", digits, "f"), p)
  stars <- case_when(
    p < 0.01 ~ "***",
    p < 0.05 ~ "**",
    p < 0.1 ~ "*",
    TRUE ~ ""
  )
  paste0(formatted, stars)
}



# Define a custom sanitize function
my_sanitize <- function(str) {
  result <- str
  result <- gsub("&", "\\&", result)
  result <- gsub("<", "\\textless{}", result)
  result <- gsub(">", "\\textgreater{}", result)
  result <- gsub("%", "\\%", result)
  return(result)
}