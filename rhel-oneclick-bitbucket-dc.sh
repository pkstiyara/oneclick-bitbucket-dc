!/bin/bash

# Define color escape codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Welcome message in green
echo -e "${GREEN}Welcome to Bitbucket DC Setup Wizard!${NC}"
echo ""

# Description in cyan
echo -e "${CYAN}Description: Streamline the setup process for Bitbucket Data Center with ease. Just run this script, follow the prompts, and watch your Bitbucket instance come to life.${NC}"
echo ""

# Get started message in yellow
echo -e "${YELLOW}Get started today and deploy your Bitbucket Data Center instance effortlessly!${NC}"
echo ""

# Additional notes
echo "Please provide your Bitbucket Instance details."
echo ""

# End of script
echo "End of script"

# Install dependencies
echo -e "${CYAN}Installing dependencies...${NC}"
sudo yum update -y
sudo yum install -y wget vim 

# Function to check if Fontconfig is installed
check_fontconfig() {
    if rpm -q fontconfig &> /dev/null; then
        echo -e "${CYAN}Fontconfig is already installed.${NC}"
    else
        echo -e "${YELLOW}Fontconfig is not installed. Installing Fontconfig...${NC}"
        install_fontconfig
    fi
}

# Function to install Fontconfig
install_fontconfig() {
    sudo yum install fontconfig -y
}

# Install Fontconfig if not already installed
check_fontconfig



# Function to check if Java is installed
check_java() {
    if java -version &> /dev/null; then
        echo -e "${CYAN}Java is already installed.${NC}"
    else
        echo -e "${YELLOW}Java is not installed. Installing Java...${NC}"
        install_java
    fi
}

# Function to install Java
install_java() {
    cd /opt/
    sudo wget https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz
    sudo tar -xvzf openjdk-17.0.1_linux-x64_bin.tar.gz
    echo -e '\nexport JAVA_HOME=/opt/jdk-17.0.1\nexport PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile
    source /etc/profile
}

# Install Java if not already installed
check_java

# Bitbucket Installation Directory 

cd /mnt

# Take the latest insataller version of Bitbucket 

wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-8.9.11-x64.bin

sudo chmod +x atlassian-bitbucket-8.9.11-x64.bin


# sh -x atlassian-Bitbucket-8.5.7-x64.bin << EOF
# o
# 1
# i
# n
# EOF

# stop the Firewalld Service 

systemctl stop firewalld.service