#!/bin/bash

# Array of script names
scripts=(
    "2_decompr_cousec_sngl_btch_00-04.R"
    "2_decompr_cousec_sngl_btch_05-09.R"
    "2_decompr_cousec_sngl_btch_10-14.R"
    "2_decompr_cousec_sngl_btch_15-17.R"
    "2_decompr_cousec_sngl_btch_19-20.R"
)

# Loop through the scripts and run them
for script in "${scripts[@]}"; do
    echo "Starting $script"
    sudo nohup Rscript ~/0_scripts/sngl_btch/$script > ~/0_scripts/${script%.R}_output.log 2>&1 &
done

echo "All scripts have been started in the background."
