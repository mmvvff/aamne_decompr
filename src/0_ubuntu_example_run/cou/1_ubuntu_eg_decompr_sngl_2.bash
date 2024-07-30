#!/bin/bash

# collect processed data
# download scripts
cd ~/0_scripts/sngl_btch &&
[ -f 2_decompr_cousec_sngl_btch_end.R ] && sudo rm 2_decompr_cousec_sngl_btch_end.R
sudo wget -O 2_decompr_cousec_sngl_btch_end.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/bash_prll/2_decompr_cousec_sngl_btch_end.R

[ -f 2_decompr_cousec_sngl_btch_end_output.log ] && sudo rm 2_decompr_cousec_sngl_btch_end_output.log
cd ~
echo "Starting 2_decompr_cousec_sngl_btch_end.R"
nohup Rscript ~/0_scripts/sngl_btch/2_decompr_cousec_sngl_btch_end.R > ~/0_scripts/2_decompr_cousec_sngl_btch_end_output.log 2>&1 &
echo "2_decompr_cousec_sngl_btch_end.R started in background"
