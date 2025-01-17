#!/bin/bash

# for parallel processing
cd ~/0_scripts
[ -f 1_trnsfrm_indexed_prll.R ] && sudo rm 1_trnsfrm_indexed_prll.R
sudo wget -O 1_trnsfrm_indexed_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_transform_indexed_example/1_trnsfrm_indexed_prll.R

# add directory permission before execution
cd ~
sudo chmod u+rwx ~/r_aamne_wwz

[ -f 1_trnsfrm_indexed_prll.log ] && sudo rm 1_trnsfrm_indexed_prll.log
cd ~
# to avoid that the r scripts stops becuase it looses connection:
sudo nohup Rscript ~/0_scripts/1_trnsfrm_indexed_prll.R > ~/0_scripts/1_trnsfrm_indexed_prll.log 2>&1 &
