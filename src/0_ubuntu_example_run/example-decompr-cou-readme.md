# Ubuntu Setup and Script Execution Guide

This guide provides instructions on how to set up R in Ubuntu and run scripts from the aamne_decompr project. It focuses on employing WWZ VA-trade measurement framework to the aAMNE database.

## Prerequisites

- Ubuntu operating system: Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1062-gcp x86_64)
- Internet connection
- Bash shell

## Setup

### 1. Setting up R in Ubuntu

To set up R in Ubuntu, you can run the following script directly (use `sudo` if necessary):

```bash
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/0_ubuntu_setup_rserver.bash | bash
```

This script will install R and necessary dependencies.

## Running Scripts

There are two methods to run the scripts:

### Method 1: Parallel Execution using R

This method uses R's `parallel` package to run scripts in parallel. Note that this might yield issues depending on your server configuration.

To run scripts in parallel (use `sudo` if necessary):

```bash
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/1_ubuntu_eg_decompr_cou_prll.bash | bash
```

### Method 2: Single Core Processing with Bash

This method runs individual scripts in parallel using bash. It's done in two steps:

#### Step 1: Run Individual Scripts

Execute the following command (use `sudo` if necessary):

```bash
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/1_ubuntu_eg_decompr_cou_sngl_1.bash | bash
```

These scripts will run in the background. You can check their individual execution as follows:
E.g.:
```
cd ~/0_scripts
nano 2_decompr_cou_sngl_btch_00-04_output.log
```

These scripts take ~120 minutes per year, so plan accordingly.

#### Step 2: Consolidate Findings

After confirming via log reports that the above scripts have finished, run the consolidation script:

```bash
sudo wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/1_ubuntu_eg_decompr_cou_sngl_2.bash | bash
```

## Downloading results

Once finished, you can download the entire project as a zip file while taking advantage of multi-core processing. The following code demonstrates how to accomplish this:

```
# Calculate the number of cores to use by subtracting 2 from the total available. This helps avoid overloading the system.
cores=$(($(nproc) - 2))

# You may print the number of cores being used for verification purposes.
echo "Using $cores cores"

# Use the calculated number of cores in a command.
# This example uses pigz, a parallel implementation of gzip, to compress the project directory.
cd ~ && sudo mkdir -p zipped && cd ~/zipped
[ -f R_aamne_decompr.tar.gz ] && sudo rm R_aamne_decompr.tar.gz
tar cf - ~/r_aamne_wwz/2_pipeline/R_aamne_decompr | pigz -9 -p $cores > R_aamne_decompr.tar.gz
```

## Important Notes

- Always verify the contents of scripts before running them, especially when using `wget` to download and execute in one command.
- Monitor the execution of background processes using log reports.
- Choose the execution method based on your server capabilities and project requirements.
