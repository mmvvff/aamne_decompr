#!/bin/bash

# for single batch processing
# download scripts
cd ~/0_scripts && sudo mkdir -p sngl_btch && cd ~/0_scripts/sngl_btch &&
sudo rm -v *indexed*btch_[0-9][0-9]-[0-9][0-9].R
sudo wget -O 0_trnsfrm_indexed_sngl_btch.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch.R

# add directory permission before execution
cd ~
sudo chmod u+rwx ~/r_aamne_wwz

# run year batches in parallel: the dispatcher sizes them from the raw CSV years and the RAM
cd ~/0_scripts
[ -f 2_run_sngl_btch.sh ] && sudo rm 2_run_sngl_btch.sh
sudo wget -O 2_run_sngl_btch.sh https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/helpers/2_run_sngl_btch.sh
sudo chmod +x 2_run_sngl_btch.sh

cd ~
echo "Starting 2_run_sngl_btch.sh"
~/0_scripts/2_run_sngl_btch.sh 0_trnsfrm_indexed_sngl_btch.R
echo "scripts associated with 2_run_sngl_btch.sh started in background"
