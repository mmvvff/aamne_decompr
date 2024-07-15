# Update package lists and upgrade installed packages silently
sudo apt update -qq -y && sudo apt upgrade -qq -y && sudo apt update -qq -y

sudo apt autoremove -qq -y
sudo mkdir -p 0_scripts

# folder setpup
sudo mkdir -p 1_data 2_pipeline 3_output
