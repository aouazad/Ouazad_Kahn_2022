#!/bin/sh

set -e

# Download the ``formatted'' HMDA data

# This is a set of Rds files created by 01_1_make_hmda_individual_files.R

# We provide them here because it is time-consuming to create them from the raw HMDA data

cd hmda/

wget https://www.dropbox.com/scl/fo/honcs3m4k27pbrs10ygv7/AFPuWevocNL88xRSAz3-GyE?rlkey=z258glym9i0dg9nqmllp6fx3e

# these files need to be placed in hmda/ if your wget doesn't do so

