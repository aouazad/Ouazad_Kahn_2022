#!/bin/sh

set -e

wget https://www.dropbox.com/scl/fi/bsy3vho7dvvh23lwdg5zz/lacour_little_data_archive_initial_submission.zip?rlkey=tznr0xbeuelipjvalvio2hir0&st=idejl55x&dl=1 -P downloads/

cd downloads/

mv lacour_little_data_archive_initial_submission.zip?rlkey=tznr0xbeuelipjvalvio2hir0&st=idejl55x&dl=1 lacour_little_data_archive_initial_submission.zip
unzip lacour_little_data_archive_initial_submission.zip

cd ..


