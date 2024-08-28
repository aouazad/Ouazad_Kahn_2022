# Evidence of Data Manipulation

## Description

This code downloads the RFS Dataverse archive for LLPW (2024).

It shows that the code has a hardcoded script that manipulates the data in 3 ways not performed by Ouazad and Kahn (2022). First, it excludes a selected set of ZIP codes that are part of the treatment group. ZIP codes excluded include areas in Southern Louisiana affected by Hurricane Katrina, and areas of Miami, Florida, affected by multiple hurricanes during the time period.  Second, it hardcodes the duplication of observations from selected counties. Third, it hardcodes the removal 
of a specific lender. 

We then show that the RFS Dataverse archive for:

> Ouazad, A. and Kahn, M.E., 2022. Mortgage finance and climate change: Securitization dynamics in the aftermath of natural disasters. The Review of Financial Studies, 35(8), pp.3617-3665.

does not exclude any of the ZIP codes. 

The code downloads the RFS Dataverse of December 6th, 2021, posted right at publication, and shows that these ZIP codes are:

1. **present in the estimation sample.**
2. **part of the treatment group.**

A report is generated and can be compiled in LaTeX.

## Steps


Step 1: Install 7-zip that is needed to decompress the RFS Dataverse files of LPW (2024). We provide a script install_packages_macos.sh for Macs.

Step 2: Run the scripts download_LPW_RFS_Dataverse.sh and download_OK_RFS_Dataverse.sh, which automatically download the *official* files.

The RFS Dataverse of LLPW was posted in August 2023. The RFS Dataverse of OK was posted in December 2021.

Step 3: Run 01_evidence_of_excluded_ZIPs_in_LPW.R. Read the output.

Step 4: Compile the LaTeX report report_on_hardcoded_exclusion_of_ZIPs.tex by typing pdflatex

Step 5: Read the pdf file report_on_hardcoded_exclusion_of_ZIPs.pdf.

## Notes

This works great on a mac or on a linux machine. You may need to install the packages tidyverse and readxl on a fresh install.

