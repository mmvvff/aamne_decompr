#!/bin/bash

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir -p sngl_btch && cd ~/0_scripts/sngl_btch &&
sudo rm -v *indexed*btch_[0-9][0-9]-[0-9][0-9].R
sudo wget -O 0_trnsfrm_indexed_sngl_btch_00-04.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_00-04.R
sudo wget -O 0_trnsfrm_indexed_sngl_btch_05-09.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_05-09.R
sudo wget -O 0_trnsfrm_indexed_sngl_btch_10-14.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_10-14.R
sudo wget -O 0_trnsfrm_indexed_sngl_btch_15-17.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_15-17.R
sudo wget -O 0_trnsfrm_indexed_sngl_btch_18-20.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_18-20.R

# run scripts in parallel: minimum requiered CPU with 6 cores
cd ~/0_scripts
[ -f 3_run_indexed_scripts.sh ] && sudo rm 3_run_indexed_scripts.sh
sudo wget -O 3_run_indexed_scripts.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/3_run_indexed_scripts.sh
sudo chmod +x 3_run_indexed_scripts.sh

cd ~
echo "Starting 3_run_indexed_scripts.sh"
~/0_scripts/3_run_indexed_scripts.sh
echo "scripts associated with 3_run_indexed_scripts.sh started in background"
