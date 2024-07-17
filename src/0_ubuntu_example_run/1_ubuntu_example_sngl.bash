#!/bin/bash

# sector definitions aggregates for sector-sector relations
cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir sngl_btch && cd ~/0_scripts/sngl_btch &&
sudo wget -O 2_decompr_cousec_sngl_btch_00-01.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_00-01.R
sudo wget -O 2_decompr_cousec_sngl_btch_02-03.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_02-03.R
sudo wget -O 2_decompr_cousec_sngl_btch_04-05.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_04-05.R
sudo wget -O 2_decompr_cousec_sngl_btch_06-07.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_06-07.R
sudo wget -O 2_decompr_cousec_sngl_btch_08-09.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_08-09.R
sudo wget -O 2_decompr_cousec_sngl_btch_10-11.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_10-11.R
sudo wget -O 2_decompr_cousec_sngl_btch_12-13.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_12-13.R
sudo wget -O 2_decompr_cousec_sngl_btch_end.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_end.R

# run scripts in parallel: minimum requiered CPU with 8 cores
cd ~/0_scripts
sudo wget -O 2_run_decompr_scripts.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/2_run_decompr_scripts.sh
sudo chmod +x 2_run_decompr_scripts.sh

cd ~
echo "Starting 2_run_decompr_scripts.sh"
if ~/0_scripts/2_run_decompr_scripts.sh; then
    echo "2_run_decompr_scripts.sh completed successfully"
    echo "Starting 2_decompr_cousec_sngl_btch_end.R"
    nohup Rscript ~/0_scripts/sngl_btch/2_decompr_cousec_sngl_btch_end.R > ~/0_scripts/sngl_btch/2_decompr_cousec_sngl_btch_end_output.log 2>&1 &
    echo "2_decompr_cousec_sngl_btch_end.R started in background"
else
    echo "2_run_decompr_scripts.sh failed, not starting 2_decompr_cousec_sngl_btch_end.R"
fi
