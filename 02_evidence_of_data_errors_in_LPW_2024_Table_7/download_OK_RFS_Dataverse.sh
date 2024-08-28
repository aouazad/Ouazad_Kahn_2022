#!/bin/sh

set -e

wget https://dataverse.harvard.edu/api/access/datafile/5426357 -O downloads/00_main_regressions.zip

cd downloads

unzip 00_main_regressions.zip

