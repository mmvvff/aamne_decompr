cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv


cd ~/0_scripts
sudo wget -O 1_prepdata_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/1_prepdata_prll.R
sudo wget -O 2_decompr_cousec_prll.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_prll.R
sudo wget -O 2_decompr_cousec_sngl_00-03.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_00-03.R
sudo wget -O 2_decompr_cousec_sngl_04-07.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_04-07.R
sudo wget -O 2_decompr_cousec_sngl_08-11.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_04-11.R
sudo wget -O 2_decompr_cousec_sngl_12-13.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_12-13.R

cd ~
# to avoid that the r scripts stops becuase it looses connection:
nohup Rscript ~/0_scripts/2_decompr_cousec_prll.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_sngl_00-03.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_sngl_04-07.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_sngl_08-11.R &
nohup Rscript ~/0_scripts/2_decompr_cousec_sngl_12-13.R &
