#!/bin/bash

# for parallel processing
cd ~/0_scripts
[ -f 2_decompr_cou_prll.R ] && sudo rm 2_decompr_cou_prll.R
sudo wget -O 2_decompr_cou_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cou/2_decompr_cou_prll.R

[ -f 2_decompr_cou_prll_output.log ] && sudo rm 2_decompr_cou_prll_output.log
# run from the project root: scripts resolve AAMNE_PROJECT_DIR (default ".") against it
cd ~/r_aamne_wwz
# to avoid that the r script stops because it loses connection:
nohup Rscript ~/0_scripts/2_decompr_cou_prll.R > ~/0_scripts/2_decompr_cou_prll_output.log 2>&1 &
