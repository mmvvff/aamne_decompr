# Ubuntu Setup and Script Execution Guide

This guide offers instructions for setting up R in Ubuntu and executing scripts from the aamne_decompr project. It focuses on the process of transforming matrices into indexed dataframes to facilitate calculations of international trade in gross terms. The guide covers this transformation for the intermediate transactions and final demand matrices, as well as the aggregate production vectors of the Global Multi-region Input-Output table aAMNE. By following these instructions, users can effectively prepare their data for further analysis of international trade patterns and economic relationships within the aAMNE framework.

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

This approach employs R's `parallel` package to run scripts simultaneously. However, be aware that this method might face challenges based on your specific server setup. Each year processed requires a minimum of 20GB of RAM. On macOS systems, if physical available RAM is insufficient, the operating system typically compensates by using hard disk space as virtual RAM. Given these memory requirements, parallel execution is  not advised for most users. The high RAM demand can lead to performance issues or system instability.

To run scripts in parallel (use `sudo` if necessary):

```bash
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/2_ubuntu_eg_indexed_prll.bash | bash
```

### Method 2: Single Core Batch Processing with Bash

This method runs individual scripts in parallel using bash. Execute the following command (use `sudo` if necessary):

```bash
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/2_ubuntu_eg_indexed_sngl_btch.bash | bash
```

These scripts will run in the background. You can check their individual execution as follows:
E.g.:
```
cd ~/0_scripts
nano 0_trnsfrm_indexed_sngl_btch_00-04_output.log
```

These scripts take ~60 minutes per year, so plan accordingly.


## Downloading results

Once finished, you can download the entire project as a zip file. To zip the folder while taking advantage of multi-core processing do the following:

```
wget -O - https://raw.githubusercontent.com/mmvvff/aamne_decompr/main/src/0_ubuntu_example_run/3_eg_indexed_zipped.bash | bash
```


## Important Notes

- Always verify the contents of scripts before running them, especially when using `wget` to download and execute in one command.
- Monitor the execution of background processes using log reports.
- Choose the execution method based on your server capabilities and project requirements.
