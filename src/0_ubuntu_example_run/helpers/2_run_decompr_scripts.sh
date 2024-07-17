#!/bin/bash

# Array of script names
scripts=(
    "2_decompr_cousec_sngl_btch_00-01.R"
    "2_decompr_cousec_sngl_btch_02-03.R"
    "2_decompr_cousec_sngl_btch_04-05.R"
    "2_decompr_cousec_sngl_btch_06-07.R"
    "2_decompr_cousec_sngl_btch_08-09.R"
    "2_decompr_cousec_sngl_btch_10-11.R"
    "2_decompr_cousec_sngl_btch_12-13.R"
)

# Loop through the scripts and run them
for script in "${scripts[@]}"; do
    echo "Starting $script"
    nohup Rscript ~/0_scripts/sngl_btch/$script > ~/0_scripts/${script%.R}_output.log 2>&1 &
done

echo "All scripts have been started in the background."
