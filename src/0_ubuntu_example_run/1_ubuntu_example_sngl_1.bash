# sector definitions aggregates for sector-sector relations
cd ~/r_aamne_wwz/0_data
sudo wget -O codes_sector_oecd_aamneV18_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV18_classification.csv
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv

# for single batch processing
cd ~/0_scripts
sudo wget -O 2_decompr_cousec_sngl_btch_00-01.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_00-01.R
sudo wget -O 2_decompr_cousec_sngl_btch_02-03.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_02-03.R
sudo wget -O 2_decompr_cousec_sngl_btch_04-05.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_04-05.R
sudo wget -O 2_decompr_cousec_sngl_btch_06-07.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_06-07.R
sudo wget -O 2_decompr_cousec_sngl_btch_08-09.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_04-11.R
sudo wget -O 2_decompr_cousec_sngl_btch_10-11.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_04-11.R
sudo wget -O 2_decompr_cousec_sngl_btch_12-13.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_12-13.R
sudo wget -O 2_decompr_cousec_sngl_btch_end.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/cousec/2_decompr_cousec_sngl_btch_end.R
