#!/bin/bash

# Calculate the number of cores to use (total available minus 2) to avoid system overload
cores=$(($(nproc) - 2))

# Create a directory for the zipped files if it doesn't exist
cd ~ && sudo mkdir -p ~/zipped

# Change to the home directory and ensure proper permissions for the source directory
sudo chmod u+rwx ~/zipped

# Move to the zipped directory
cd ~/zipped

# Remove any existing compressed file with the same name
[ -f R_aamne_indexed.tar.gz ] && sudo rm R_aamne_indexed.tar.gz

# Compress the project directory using tar and pigz (parallel gzip)
# The -9 flag sets maximum compression, and -p $cores specifies the number of cores to use
sudo bash -c "tar cf - ~/r_aamne_wwz/2_pipeline/R_aamne_indexed | pigz -9 -p $cores > R_aamne_indexed.tar.gz"

# Check if the compressed file exists and has content
if [ -s R_aamne_indexed.tar.gz ]; then
    echo "Compression completed successfully using $cores cores"
else
    echo "Compression failed"
    exit 1
fi
