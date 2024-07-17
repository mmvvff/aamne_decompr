# Change to home directory
cd ~

# Update and upgrade system packages
sudo apt update -qq -y && sudo apt upgrade -qq -y && sudo apt update -qq -y
# -qq: run quietly (suppress output)
# -y: automatically answer yes to prompts
# Double update ensures we have the latest package information

# Install aria2 download manager
sudo apt install aria2

# Remove unnecessary packages and dependencies
sudo apt autoremove -qq -y

# Set the variable
project_name="r_aamne_wwz"

# Create directory structure to download data
cd ~ && sudo mkdir -p 0_scripts "${project_name}"
cd ~/"${project_name}" && sudo mkdir 0_data 1_code 2_pipeline 3_output

# Change to the data directory and create subdirectory for AAMNE 2023 data
cd ./0_data && sudo mkdir -p ./oecd_aamne/aamne23 && cd ./oecd_aamne/aamne23
# -p: create parent directories if they don't exist

# Remove existing URL file if it exists
[ -f url_aamne23.txt ] && sudo rm url_aamne23.txt
# [ -f file ]: checks if file exists and is a regular file

# Download the file containing URLs for AAMNE 2023 data
sudo wget -O url_aamne23.txt https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/url_aamne23.txt
# -O: specify output file name

# Download AAMNE 2023 data files
file="url_aamne23.txt"
cat "$file" | sudo xargs -n 1 sudo aria2c -c -x2 --summary-interval=0
# cat: read file contents
# xargs -n 1: execute aria2c for each line of input
# aria2c options:
#   -c: continue partially downloaded files
#   -x2: use 2 connections per download
#   --summary-interval=0: suppress download progress summary

# Change to the AAMNE 2023 data directory
cd ~/0_data/oecd_aamne/aamne23

# Unzip all .zip files in the current directory and its subdirectories
sudo find . -name '*.zip' -exec unzip -o {} \;
# find: search for files
# -name '*.zip': match all .zip files
# -exec: execute the following command for each found file
# unzip -o {}: unzip the file, overwrite existing files without prompting

# Remove all .zip files after extraction
sudo find . -name '*.zip' -delete

#
cd ~
# For GCP users: Sync local data to Google Cloud Storage bucket
gsutil -m rsync -r ~/0_data/oecd_aamne/aamne23 gs://data_oecd/aamne23/
# -m: perform operations in parallel for improved performance
# rsync: synchronize contents of directories
# -r: recursively copy subdirectories
