#!/bin/bash

set -e 

wget https://dataverse.harvard.edu/api/access/datafile/7280167 -O "downloads/Climate Risk Replication.7z.001"
wget https://dataverse.harvard.edu/api/access/datafile/7280165 -O "downloads/Climate Risk Replication.7z.002"
wget https://dataverse.harvard.edu/api/access/datafile/7280168 -O "downloads/Climate Risk Replication.7z.003"
wget https://dataverse.harvard.edu/api/access/datafile/7280170 -O "downloads/Climate Risk Replication.7z.004"
wget https://dataverse.harvard.edu/api/access/datafile/7280169 -O "downloads/Climate Risk Replication.7z.005"
wget https://dataverse.harvard.edu/api/access/datafile/7280166 -O "downloads/Climate Risk Replication.7z.006"

cd downloads

7zz x "Climate Risk Replication.7z.001"

cd ..
