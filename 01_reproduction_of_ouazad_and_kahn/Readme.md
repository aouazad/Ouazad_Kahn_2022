
# Replication of Ouazad and Kahn (2022) 

The first step is to download the data.

The folder limits/ has the conforming loan limits.

The folder hmda/ stores the raw HMDA files. If you want to build the sample from raw HMDA data, use the script download_raw_hmda.sh and execute the files in sequence of their number.

The folder external_data/ has data providing additional variables. 

The folder output/ stores intermediary files, such as the estimation sample.

The folder tables/ and the folder figures/ store the code's output, automatically generated in 06_main_regression.R.


> 00_1_prepare_limits_by_county.R 
 
Build a dataset of conforming loan limits for each year.

> 00_2_make_baseline_hmda_file.R

This takes each raw HMDA file and makes an Rds file.

**you can avoid 00_1_ and 00_2_ by using the script download_formatted_hmda.sh which will download the output of 00_2_ from the cloud**.

> 01_1_make_hmda_individual_files.R

Standardizes the variable names in the different waves of HMDA to prepare it to be matched with conforming loan limits.

> 02_1_make_hmda_individual_with_loan_limit.R

Matches each HMDA file with the conforming loan limits 

> 02_2_make_panel_within_window.R

Build the longitudinal HMDA sample.

> 04_make_hmda_event_study_data_set.R

Build the event study data. For each hurricane, consider the set of mortgage applications in the treated group. Add the set of never treated, which form the control group.

> 05_make_estimation_sample.R

Builds the estimation sample by matching the output of 04 with the external data (such as the lender crosswalk) and **verifies** the data.

> 06_main_regression.R

Performs the main regression following Ouazad and Kahn (2022) specification (1) and outputs the LaTeX tables in tables/. 

impact_conforming_market.tex for windows +-20%, +-10%, +-5% around the conforming loan limit.

impact_conforming_market_narrower.tex for windows +-4%, +-3%, +-2% around the conforming loan limit.



To execute this, you need to have the following packages on your system: tidyverse (2.0.0), fixest (0.11.2), broom (1.0.5), foreign (0.8.86), data.table (1.15.0), gam (1.22.3), lfe (3.0.0), gplots (3.1.3.1). These are available on CRAN and can be installed in R using install.packages. 

