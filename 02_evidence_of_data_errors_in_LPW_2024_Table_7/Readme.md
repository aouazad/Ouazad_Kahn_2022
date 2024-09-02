# Evidence of Major Data Errors and Data Manipulation (Arbitrary Addition and Deletion) in LLPW (2024)

## Description

There are two parts that analyze the RFS Dataverse code of LLPW 2024. First, the code shows that there are large numbers of "NaN" values in the high cost dummy variable of the sample of LLPW 2024 **only for Table 7**, which is the table changing limits. This is likely the outcome of a coding error in LLPW, in an outer join of lines 55 and 56 of the file 02_generateRegressionSample.m of the LLPW RFS Dataverse.
> % add high-cost variable to main data set
> hmda_atlantic_05 = outerjoin(hmda_atlantic_05,conformingLimits,Keys={'as_of_year','state_code','county_co de'},MergeKeys=true,RightVariables="highcost",Type="left").

Second, this folder shows that the code has a hardcoded script that manipulates the data in 3 ways not performed by Ouazad and Kahn (2022). First, it excludes a selected set of ZIP codes that are part of the treatment group. ZIP codes excluded include areas in Southern Louisiana affected by Hurricane Katrina, and areas of Miami, Florida, affected by multiple hurricanes during the time period. Second, it hardcodes the duplication of observations from selected counties. Third, it hardcodes the removal of a specific lender. 

This is done on lines 140 to 143 of the script 02_generateRegressionSample.m,
> opts = detectImportOptions('excluded_ZIPs.xlsx');
> opts = setvartype(opts,'ZCTA5CE10','char');
> exclZips = readtable('excluded_ZIPs.xlsx',opts); joinedTableCombined(ismember(joinedTableCombined.ZCTA5CE10,exclZips.ZCTA5CE10),:) = [];
The code also excludes one specific lender, Ditech.
> joinedTableCombined(strcmp(joinedTableCombined.respondent_id, '41-1795868')&joinedTableCombined.as_of_year==2014,:) = [];

We then show that the RFS Dataverse archive for Ouazad and Kahn (2022) does not perform any of these arbitrary operations. 

The code downloads the RFS Dataverse of Ouazad and Kahn dated December 6th, 2021, posted at publication, and shows that these ZIP codes are:

1. **present in the estimation sample.**
2. **part of the treatment group.**

A report is generated and can be compiled in LaTeX.

## Steps


Step 1: Install 7-zip that is needed to decompress the RFS Dataverse files of LPW (2024). We provide a script install_packages_macos.sh for Macs.

Step 2: Run the scripts download_LPW_RFS_Dataverse.sh and download_OK_RFS_Dataverse.sh, which automatically download the *official* files.

The RFS Dataverse of LLPW was posted in August 2023. The RFS Dataverse of OK was posted in December 2021.

Step 3: Run the R scripts 01 and 02. Read the output.

Step 4: Compile the two LaTeX reports using pdflatex.

## Notes

This works great on a mac or on a linux machine. You may need to install the packages tidyverse and readxl on a fresh install.

