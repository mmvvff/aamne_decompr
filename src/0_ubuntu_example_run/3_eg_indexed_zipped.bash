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
[ -f R_aamne_indexed.tar.gz ] && rm R_aamne_indexed.tar.gz

# Compress the project directory using tar and pigz (parallel gzip)
# The -9 flag sets maximum compression, and -p $cores specifies the number of cores to use
tar cf - ~/r_aamne_wwz/2_pipeline/R_aamne_indexed | pigz -9 -p $cores > R_aamne_indexed.tar.gz

# Check if the zipped file exists before echoing the completion message
if [ -f R_aamne_indexed.tar.gz ]; then
    echo "Compression completed using $cores cores"
else
    echo "Compression failed"
fi
