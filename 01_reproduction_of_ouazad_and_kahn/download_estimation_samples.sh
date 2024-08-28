#!/bin/sh

set -e 

# Download the estimation samples made from the HMDA data
# This helps the user of the repo as the raw HMDA data is heavy and takes time to process

cd output

wget -O hmda_event_study_zip_level.Rds  https://www.dropbox.com/scl/fi/3nrel1ckpv62t8m2r5050/hmda_event_study_zip_level.Rds?rlkey=s31zpmehx9qq3rit5a9acxetk

wget -O est_sample_for_revision.Rds https://www.dropbox.com/scl/fi/adqzzzim4hg3ejludx2j4/est_sample_for_revision.rds?rlkey=b3pe6oxkmo24ssup6wnya9fea

cd ..

cd external_data

wget -O zillow_data_long_by_zip_1996_2019.rds https://www.dropbox.com/scl/fi/pa68cfz7s43a32v9y4a9x/zillow_data_long_by_zip_1996_2019.rds?rlkey=33vjiismj1t2ted0shrvyp70y
