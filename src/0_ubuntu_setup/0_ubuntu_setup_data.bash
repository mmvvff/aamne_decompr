# Update and upgrade system packages
# -qq: run quietly (suppress output)
# -y: automatically answer yes to prompts
sudo apt update -qq -y && sudo apt upgrade -qq -y && sudo apt update -qq -y

# Remove unnecessary packages and dependencies
sudo apt autoremove -qq -y

# Create directory structure
sudo mkdir -p 0_scripts
sudo mkdir -p 1_data 2_pipeline 3_output

# Change to the data directory
cd ~/1_data

# Create subdirectory for AAMNE 2023 data
sudo mkdir -p data_aamne23

# Remove existing URL file if it exists
[ -f url_aamne23.txt ] && sudo rm url_aamne23.txt

# Download the file containing URLs for AAMNE 2023 data
sudo wget -O url_aamne23.txt https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/data_urls/url_aamne23.txt

# Download AAMNE 2023 data files
file="url_aamne23.txt"
cat "$file" | xargs -n 1 wget -c \
    --tries=3 \              # Retry 3 times if download fails
    --retry-connrefused \    # Retry even if connection is initially refused
    --waitretry=5 \          # Wait 5 seconds between retries
    --timeout=60             # Set 60 second timeout for each attempt
