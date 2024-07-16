cd ~/0_scripts
sudo wget -O 1_prepdata_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_prepdata_prll.R
sudo wget -O 2_decompr_cousec_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_prll.R

cd ~
sudo Rscript ~/0_scripts/1_prepdata_prll.R
sudo Rscript ~/0_scripts/2_decompr_cousec_prll.R
