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

# Data version: aamne23 (default), aamne26 or icio2026; set AAMNE_VERSION before running to override
aamne_version="${AAMNE_VERSION:-aamne23}"
case "$aamne_version" in
  aamne23)  data_dir="oecd_aamne/aamne23";  url_file="url_aamne23.txt"; csv_members=('*.csv') ;;
  aamne26)  data_dir="oecd_aamne/aamne26";  url_file="url_aamne26.txt"; csv_members=('*.csv') ;;
  icio2026) data_dir="oecd_icio/icio2026";  url_file="url_icio26.txt";  csv_members=('*_SML.csv' '*_PROJECTED.csv') ;;
  *) echo "Unknown AAMNE_VERSION: $aamne_version"; exit 1 ;;
esac
# csv_members: yearly tables to extract (ICIO: current-price tables only, not the PYP tables)

# Create directory structure to download data
cd ~ && sudo mkdir -p 0_scripts "${project_name}"
# R runs via sudo (root owns the project); your shell writes the logs, so keep ~/0_scripts yours
sudo chown "$USER":"$USER" ~/0_scripts
cd ~/"${project_name}" && sudo mkdir 0_data 1_code 2_pipeline 3_output

# Data inputs: downloaded from the URL list (default), or read in place from AAMNE_DATA_SOURCES
# when AAMNE_DATA_FROM_SOURCES=TRUE (nothing is downloaded)
if [ "${AAMNE_DATA_FROM_SOURCES:-FALSE}" != "TRUE" ]; then

# Change to the data directory and create subdirectory for the data of the selected version
cd ./0_data && sudo mkdir -p ./"${data_dir}" && cd ./"${data_dir}"
# -p: create parent directories if they don't exist

# Remove existing URL file if it exists
[ -f "$url_file" ] && sudo rm "$url_file"
# [ -f file ]: checks if file exists and is a regular file

# Download the file containing URLs for the data of the selected version
sudo wget -O "$url_file" https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/"$url_file"
# -O: specify output file name

# Download the data files
file="$url_file"
cat "$file" | sudo xargs -n 1 sudo aria2c -c -x2 --summary-interval=0
# cat: read file contents
# xargs -n 1: execute aria2c for each line of input
# aria2c options:
#   -c: continue partially downloaded files
#   -x2: use 2 connections per download
#   --summary-interval=0: suppress download progress summary

# Change to the data directory of the selected version
cd ~/"${project_name}"/0_data/"${data_dir}"

# Unzip all .zip files in the current directory and its subdirectories
sudo find . -name '*.zip' -exec unzip -j -o {} "${csv_members[@]}" \;
# find: search for files
# -name '*.zip': match all .zip files
# -exec: execute the following command for each found file
# unzip -j -o {}: unzip the file without its folders (yearly CSVs land directly here), overwrite existing files without prompting

# Remove all .zip files after extraction
sudo find . -name '*.zip' -delete

fi

# Download sector classification CSVs into 0_data
# (required by the cousec and indexed scripts, which read them from 0_data/)
cd ~/"${project_name}"/0_data
sudo wget -O codes_sector_oecd_aamneV23_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_aamneV23_classification.csv
sudo wget -O codes_sector_oecd_icio2026_classification.csv https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/codes_sector_oecd_icio2026_classification.csv

#
cd ~
# For GCP users: Sync local data to Google Cloud Storage bucket
# gsutil -m rsync -r ~/"${project_name}"/0_data/"${data_dir}" gs://data_oecd/"${aamne_version}"/
# -m: perform operations in parallel for improved performance
# rsync: synchronize contents of directories
# -r: recursively copy subdirectories
