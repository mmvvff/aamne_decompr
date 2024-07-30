#!/bin/bash

# sector definitions aggregates for sector-sector relations
cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir sngl_btch && cd ~/0_scripts/sngl_btch &&
[ -f *decompr*cousec*btch_[0-9][0-9]-[0-9][0-9].R ] && sudo rm -v *decompr*cousec*btch_[0-9][0-9]-[0-9][0-9].R
sudo wget -O 2_decompr_cousec_sngl_btch_00-04.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_00-04.R
sudo wget -O 2_decompr_cousec_sngl_btch_05-09.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_05-09.R
sudo wget -O 2_decompr_cousec_sngl_btch_10-14.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_10-14.R
sudo wget -O 2_decompr_cousec_sngl_btch_15-17.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_15-17.R
sudo wget -O 2_decompr_cousec_sngl_btch_18-20.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_18-20.R

# run scripts in parallel: minimum requiered CPU with 6 cores
cd ~/0_scripts
[ -f 2_run_decompr_cousec_scripts.sh ] && sudo rm 2_run_decompr_cousec_scripts.sh
sudo wget -O 2_run_decompr_cousec_scripts.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/2_run_decompr_cousec_scripts.sh
sudo chmod +x 2_run_decompr_cousec_scripts.sh

cd ~
echo "Starting 2_run_decompr_cousec_scripts.sh"
~/0_scripts/2_run_decompr_cousec_scripts.sh
echo "scripts associated with 2_run_decompr_cousec_scripts.sh started in background"
