#!/bin/bash

# sector definitions aggregates for sector-sector relations
cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv

# for parallel processing
cd ~/0_scripts
[ -f 1_prepdata_prll.R ] && sudo rm 1_prepdata_prll.R
sudo wget -O 1_prepdata_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_prepdata_prll.R
[ -f 2_decompr_cousec_prll.R ] && sudo rm 2_decompr_cousec_prll.R
sudo wget -O 2_decompr_cousec_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_prll.R

[ -f 2_decompr_cousec_prll_output.log ] && sudo rm 2_decompr_cousec_prll_output.log
cd ~
# to avoid that the r scripts stops becuase it looses connection:
nohup Rscript ~/0_scripts/2_decompr_cousec_prll.R > ~/0_scripts/2_decompr_cousec_prll_output.log 2>&1 &
