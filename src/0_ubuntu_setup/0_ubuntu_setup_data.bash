# Update package lists and upgrade installed packages silently
sudo apt update -qq -y && sudo apt upgrade -qq -y && sudo apt update -qq -y

sudo apt autoremove -qq -y
sudo mkdir -p 0_scripts

# folder setpup
sudo mkdir -p 1_data 2_pipeline 3_output

cd ~/0_scripts
[ -f url_aamne23.txt ] && sudo rm url_aamne23.txt
sudo wget -O url_aamne23.txt https://raw.githubusercontent.com/MatB1988/proyectogrupal/main/scripts/python_req_geopandas.txt
