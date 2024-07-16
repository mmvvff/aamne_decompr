cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv


cd ~/0_scripts
sudo wget -O 1_prepdata_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_prepdata_prll.R
sudo wget -O 2_decompr_cousec_prll_0005.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl.R
sudo wget -O 2_decompr_cousec_prll_0611.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl.R
sudo wget -O 2_decompr_cousec_prll_1213.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl.R

cd ~
sudo Rscript ~/0_scripts/1_prepdata_prll.R
# to avoid that the r scripts stops becuase it looses connection:
nohup Rscript ~/0_scripts/2_decompr_cousec_prll_0005.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_prll_0611.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_prll_1213.R &
