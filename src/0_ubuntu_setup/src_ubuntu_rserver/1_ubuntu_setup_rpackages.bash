# instalamos entorno de R
sudo apt update
sudo apt install -y software-properties-common ca-certificates apt-transport-https gnupg dirmngr

# Instalamos Librerias de R

# Dependencias
# tidyverse requirements
sudo add-apt-repository  -y ppa:c2d4u.team/c2d4u4.0+ && sudo apt update
sudo apt-get install -y libssl-dev libcurl4-openssl-dev unixodbc-dev libxml2-dev libmariadb-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev

sudo apt update -qq -y

# Librerias
sudo R -e 'install.packages("xml2", dependencies = T, INSTALL_opts = c("--no-lock"))'
cd ~/0_scripts
[ -f r_requirements.R ] && sudo rm r_requirements.R
sudo wget -O r_requirements.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_setup/src_ubuntu_rserver/r_requirements.R
sudo Rscript r_requirements.R
cd ~
sudo apt autoremove -y && sudo apt update -qq -y && sudo apt upgrade -qq -y
