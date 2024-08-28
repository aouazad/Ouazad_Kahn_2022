
# prepare HMDA data for analysis

library(tidyverse)

# set the working directory to the folder of the script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

output_dir <- 'hmda/'
data_dir <- 'hmda/'

widths.pre1990 <- c(28, 8, 4, 6, 5, 2, 3, 1, 2,  
                    1, 4, 9,  
                    1, 4, 9, 
                    1, 4, 9, 
                    1, 4, 9, 
                    1, 4, 9, 
                    1);

varnames.pre1990 <- c(  "respondent.name",
                        "respondent.id",
                        "msa",
                        "census_tract",
                        "state_county",
                        "state",
                        "county",
                        "agency",
                        "census_validity_flag",
                        "va_fha_fmha_loans_validity_flag",
                        "va_fha_fmha_loans_number",
                        "va_fha_fmha_loans_totalamount",
                        "conventional_loans_validity_flag",
                        "conventional_loans_number",
                        "conventional_loans_totalamount",
                        "home_improvement_validity_flag",
                        "home_improvement_number",
                        "home_improvement_amount",
                        "multifamily_validity_flag",
                        "multifamily_number",
                        "multifamily_amount",
                        "non_occupant_validity_flag",
                        "non_occupant_number",
                        "non_occupant_amount",
                        "record_quality_flag");

widths.2000.2004 <- c(4, 10, 1,1,1,1, 5, 1, 4, 2, 3, 7, 1, 1,
	1,1,4,1,1,1,1,1,7);
	
varnames.2000.2004 <- c("date",
		"respondent.id",
		"agency",
		"loan.type",
		"loan.purpose",
		"occupancy",
		"loan.amount",
		"action.type",
		"msa",
		"state",
		"county",
		"census.tract",
		"applicant.race",
		"coapplicant.race",
		"applicant.sex",
		"coapplicant.sex",
		"applicant.income",
		"purchaser.type",
		"denial.reason.1",
		"denial.reason.2",
		"denial.reason.3",
		"edit.status",
		"sequence.number");
		
widths.post.2004 <- c( 4, 10, 1, 1, 1, 1, 5,
	1, 5, 2, 3, 7, 1, 1, 4, 1, 1, 1, 1,
	rep(1,15), 5, 1, 1, 7);

varnames.post.2004 <- c("date",
		"respondent.id",
		"agency",
		"loan.type",
		"loan.purpose",
		"occupancy",
		"loan.amount",
		"action.type",
		"msa",
		"state",
		"county",
		"census.tract",
		"applicant.sex",
		"coapplicant.sex",
		"applicant.income",
		"purchaser.type",
		sprintf("denial.reason.%d", c(1,2,3)),
		"edit.status",
		"property.type",
		"preapprovals",
		"applicant.ethnicity",
		"coapplicant.ethnicity",
		sprintf("applicant.race.%d", 1:5),
		sprintf("coapplicant.race.%d", 1:5),
		"rate.spread",
		"hoepa.status",
		"lien.status",
		"sequence.number" );

stopifnot(length(widths.2000.2004) == length(varnames.2000.2004));
stopifnot(length(widths.post.2004) == length(varnames.post.2004));

filenames <- c(    '1995' = 'HMS.U1995.LARS',
                   '1996' = 'HMS.U1996.LARS', 
                   '1997' = 'HMS.U1997.LARS', 
                   '1998' = 'HMS.F1998.LARS', 
                   '1999' = 'HMS.F1999.LARS', 
                   '2000' = 'HMS.U2000.LARS', 
                   '2001' = 'HMS.F2001.LARS',                 
                   '2002' = 'HMS.F2002.LARS',  
                   '2003' = 'HMS.F2003.LARS',
                   '2004' = 'u2004lar.public.dat',
                   '2005' = 'LARS.FINAL.2005.DAT',
                   '2006' = 'LARS.FINAL.2006.DAT',
                   '2007' = 'lars.ultimate.2007.dat',
                   "2008" = "lars.final.2008.dat",
                   "2009" = "2009_Final_PUBLIC_LAR.dat",
                   "2010" = "Lars.ultimate.2010.dat",
                   "2011" = "Lars.final.2011.dat")

#for (year in 1990:2011) {
for (year in 2004:2011) {
  
    if (year < 1990) {
      
      format.widths <- widths.pre1990
      varnames <- varnames.pre1990
      
    } else if (year >= 1990 & year < 2004) {
      
      format.widths <- widths.2000.2004
      varnames <- varnames.2000.2004
      
    } else if (year >= 2004) {
      
      format.widths <- widths.post.2004
      varnames <- varnames.post.2004
      
    }
    
    hmda.annual <- read_fwf(sprintf("%s/%s", data_dir,
                year, filenames[as.character(year)]),
                col_positions = fwf_widths(format.widths, varnames))
    
    hmda.annual$county.fips <- with(hmda.annual, 
                    as.numeric(state) * 1000 + as.numeric(county))
    
    stopifnot(nrow(hmda.annual) > 10) # check we haven't eliminated every observation
    
    write_rds(hmda.annual, 
              path = sprintf("%s/hmda_%d.Rds", output_dir, year))

}

varnames.2012.2014 <- c(
  "date",
  "respondent.id",
  "agency",
  "loan.type",
  "property.type",
  "loan.purpose",
  "occupancy",
  "loan.amount",
  "preapprovals",
  "action.type",
  "msa",
  "state",
  "county",
  "census.tract",
  "applicant.ethnicity",
  "coapplicant.ethnicity",
  sprintf("applicant.race.%d", 1:5),
  sprintf("coapplicant.race.%d", 1:5),
  "applicant.sex",
  "coapplicant.sex",
  "applicant.income",
  "purchaser.type",
  sprintf("denial.reason.%d", c(1,2,3)),
  "rate.spread",
  "hoepa.status",
  "lien.status",
  "edit.status",
  "sequence.number",
  "population",
  "minority.pop.pct",
  "ffiec.median.family.income",
  "tract.to.msa.income",
  "nbr.owner.occupied.units",
  "nbr.1.to.4.family.units",
  "application.date.indicator"
)

for (year in 2012:2016) {

    hmda.annual <- read_csv(file = sprintf("%s/%dHMDALAR - National.csv", 
                                           data_dir, year, year), 
                            col_names = varnames.2012.2014);
    
    hmda.annual$county.fips <- with(hmda.annual, 
                  as.numeric(state) * 1000 + as.numeric(county))
    
    stopifnot(nrow(hmda.annual) > 10)
    
    write_rds(hmda.annual, path = sprintf("%s/hmda_%d.Rds", 
                                          output_dir, year));

}






