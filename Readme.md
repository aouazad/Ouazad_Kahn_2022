# Ouazad and Kahn (2022) and the LLPW (2024) Comment

> Ouazad, A. and Kahn, M.E., 2022. Mortgage finance and climate change: Securitization dynamics in the aftermath of natural disasters. The Review of Financial Studies, 35(8), pp.3617-3665.

This repository provides three folders. 

> 01_reproduction_of_ouazad_and_kahn

This runs the fixed effect regression identical to Ouazad and Kahn (2022) specification 1, using the conforming loan limits from FHFA.

Shell scripts download the data automatically from the cloud, R codes prepare the data, and run the regression.

This produces tables.tex, which can be compiled with pdflatex. 



The second and third folders analyze the data of LLPW (2024) and find evidence of failed joins, and arbitrary data deletion and padding. The folders download data automatically from the RFS Dataverse.

> 02_evidence_of_data_errors_in_LLPW_2024

This downloads the RFS Dataverse of August 2023 for LLPW (2024) and shows that:

1. the LLPW code produces an estimation sample with **large amounts of 'NaN' values for the high_cost variable,** which should be a county-specific dummy variable for high-cost counties. This is an issue because the join between mortgage applications and conforming loan limits relies on this variable, as does the regression. This affects **only Table 7 of the LLPW comment**, which is the table that tests robustness. This is done in 01_errors_in_coding_of_high_cost_dummy.R
2. the LLPW code **arbitrarily** excludes 20 ZIPs and 1 lender (Ditech) in the file 02_generateRegressionSample.m. These ZIPs and this lender are present in Ouazad and Kahn (2022), which never performs an arbitrary exclusion of data. The code verifies this by downloading the Ouazad and Kahn (2022) Dataverse automatically and checking this is the case.

> 03_flaws_in_the_independent_replication_table_8

This relies on an archive provided by AP, shared with us in April 2023. The RFS Dataverse of LLPW (2024) does not include the code for Table 8, so we rely on this archive. The folder automatically downloads the AP (2023) archive and performs integrity checks. The code shows that the time dummies are not mutually exclusive and that the hurricane treatment years are miscoded.

Each folder generates a pdf in tables.pdf.

The root folder generates tables.pdf with all tables from the three folders.



