#!/bin/bash

# sector definitions aggregates for sector-sector relations
cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir -p sngl_btch && cd ~/0_scripts/sngl_btch &&
sudo find . -maxdepth 1 -type f -name '*decompr*cousec*btch_[0-9][0-9]-[0-9][0-9].R' -delete -print
sudo wget -O 2_decompr_cousec_sngl_btch.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch.R

# run year batches in parallel: the dispatcher sizes them from the raw CSV years and the RAM
cd ~/0_scripts
[ -f 2_run_sngl_btch.sh ] && sudo rm 2_run_sngl_btch.sh
sudo wget -O 2_run_sngl_btch.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/2_run_sngl_btch.sh
sudo chmod +x 2_run_sngl_btch.sh

cd ~
echo "Starting 2_run_sngl_btch.sh"
~/0_scripts/2_run_sngl_btch.sh 2_decompr_cousec_sngl_btch.R
echo "scripts associated with 2_run_sngl_btch.sh started in background"
