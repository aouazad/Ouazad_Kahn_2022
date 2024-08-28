#!/bin/bash

set -e

brew install 7-zip

Rscript -e 'install.packages("readxl", repos="https://cloud.r-project.org")'
Rscript -e 'install.packages("xtable", repos="https://cloud.r-project.org")'
Rscript -e 'install.packages("sf", repos="https://cloud.r-project.org")'
