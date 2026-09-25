#!/bin/bash

# prepare decompr inputs (run once; cou and cousec both read its output)
cd ~/0_scripts
[ -f 1_prepdata_sngl.R ] && sudo rm 1_prepdata_sngl.R
sudo wget -O 1_prepdata_sngl.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_prepdata_sngl.R

[ -f 1_prepdata_sngl_output.log ] && sudo rm 1_prepdata_sngl_output.log
# run from the project root: scripts resolve AAMNE_PROJECT_DIR (default ".") against it
cd ~/r_aamne_wwz
# to avoid that the r script stops because it loses connection:
sudo nohup Rscript ~/0_scripts/1_prepdata_sngl.R > ~/0_scripts/1_prepdata_sngl_output.log 2>&1 &
