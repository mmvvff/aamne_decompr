# Change to home directory
cd ~

# Update system and install necessary tools
sudo apt update
sudo apt install -y software-properties-common ca-certificates apt-transport-https gnupg dirmngr

# Install R environment and dependencies

# Add repository for R packages
sudo add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+ && sudo apt update

# Install system dependencies for R packages (including tidyverse requirements)
sudo apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    unixodbc-dev \
    libxml2-dev \
    libmariadb-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Update package list after installing dependencies
sudo apt update -qq -y

# Install R packages

# Install xml2 package
sudo R -e 'install.packages("xml2", dependencies = T, INSTALL_opts = c("--no-lock"))'

# Change to scripts directory
cd ~/0_scripts

# Remove existing R requirements file if it exists
[ -f r_requirements.R ] && sudo rm r_requirements.R

# Download latest R requirements file
sudo wget -O r_requirements.R https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_setup/src_ubuntu_rserver/r_requirements.R

# Install R packages from the requirements file
sudo Rscript r_requirements.R

# Return to home directory
cd ~

# Clean up and update system
sudo apt autoremove -y && sudo apt update -qq -y && sudo apt upgrade -qq -y
