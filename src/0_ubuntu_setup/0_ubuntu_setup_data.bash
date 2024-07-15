# Update and upgrade system packages
sudo apt update -qq -y && sudo apt upgrade -qq -y && sudo apt update -qq -y
# -qq: run quietly (suppress output)
# -y: automatically answer yes to prompts
# Double update ensures we have the latest package information

# Install aria2 download manager
sudo apt install aria2

# Remove unnecessary packages and dependencies
sudo apt autoremove -qq -y

# Create directory structure
sudo mkdir -p 0_scripts 1_data 2_pipeline 3_output
# -p: create parent directories if they don't exist

# Change to the data directory
cd ~/1_data

# Create subdirectory for AAMNE 2023 data
sudo mkdir -p data_aamne23

# Remove existing URL file if it exists
[ -f url_aamne23.txt ] && sudo rm url_aamne23.txt
# [ -f file ]: checks if file exists and is a regular file

# Download the file containing URLs for AAMNE 2023 data
sudo wget -O url_aamne23.txt https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/url_aamne23.txt
# -O: specify output file name

# Download AAMNE 2023 data files
file="url_aamne23.txt"
cat "$file" | xargs -n 1 aria2c -c -x2 --summary-interval=0
# cat: read file contents
# xargs -n 1: execute aria2c for each line of input
# aria2c: download manager
#   -c: continue partially downloaded files
#   -x2: use 2 connections per download
#   --summary-interval=0: suppress download progress summary
