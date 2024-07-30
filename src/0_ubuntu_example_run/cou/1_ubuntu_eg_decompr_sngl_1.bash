#!/bin/bash

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir sngl_btch && cd ~/0_scripts/sngl_btch &&
sudo rm -v *decompr*cou*btch_[0-9][0-9]-[0-9][0-9].R
sudo wget -O 2_decompr_cou_sngl_btch_00-04.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/bash_prll/2_decompr_cou_sngl_btch_00-04.R
sudo wget -O 2_decompr_cou_sngl_btch_05-09.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/bash_prll/2_decompr_cou_sngl_btch_05-09.R
sudo wget -O 2_decompr_cou_sngl_btch_10-14.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/bash_prll/2_decompr_cou_sngl_btch_10-14.R
sudo wget -O 2_decompr_cou_sngl_btch_15-17.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/bash_prll/2_decompr_cou_sngl_btch_15-17.R
sudo wget -O 2_decompr_cou_sngl_btch_18-20.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/bash_prll/2_decompr_cou_sngl_btch_18-20.R

# run scripts in parallel: minimum requiered CPU with 6 cores
cd ~/0_scripts
[ -f 2_run_decompr_cou_scripts.sh ] && sudo rm 2_run_decompr_cou_scripts.sh
sudo wget -O 2_run_decompr_cou_scripts.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/2_run_decompr_cou_scripts.sh
sudo chmod +x 2_run_decompr_cou_scripts.sh

cd ~
echo "Starting 2_run_decompr_cou_scripts.sh"
~/0_scripts/2_run_decompr_cou_scripts.sh
echo "scripts associated with 2_run_decompr_cou_scripts.sh started in background"
