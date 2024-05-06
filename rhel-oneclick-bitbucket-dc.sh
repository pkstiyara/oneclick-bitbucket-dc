#!/bin/bash

# Install dependencies
echo -e "${CYAN}Installing dependencies...${NC}"
sudo yum update -y
sudo yum install git -y
sudo yum install -y wget vim 
sudo yum install fontconfig -y

systemctl stop firewalld.service

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


################ Only for azure to mount the existing disk for data #############################
# Partition the disk with default input
echo -e "n\n3\n\n\nw" | fdisk /dev/sda
# Refresh partition table
partprobe
# Format partition as ext4
mkfs.ext4 /dev/sda3 || { echo "Error: Formatting partition failed."; exit 1; }
# Create a directory to mount the partition
mkdir /data || { echo "Error: Creating directory failed."; exit 1; }
# Mount the partition
mount /dev/sda3 /data || { echo "Error: Mounting partition failed."; exit 1; }
# Verify mount
df -h /data &> /dev/null || { echo "Error: Mount point not found in df output."; exit 1; }
echo "Partition mounted successfully."
#################################################################################################

# Bitbucket Installation Directory 

cd /data
mkdir bitbucket_mesh_home
mkdir bitbucket_home

#################### Downloading and install Bitbucket #############################

wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-8.19.2.tar.gz

tar -xvzf  atlassian-bitbucket-8.19.2.tar.gz

# Get the mesh package
wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-mesh-2.5.2.tar.gz

tar -xvzf  atlassian-bitbucket-mesh-2.5.2.tar.gz

# Edit set-bitbucket-home.sh
echo 'Editing set-bitbucket-home.sh...'
sed -i '0,/BITBUCKET_HOME=/s|BITBUCKET_HOME=|BITBUCKET_HOME=/data/bitbucket_home|' atlassian-bitbucket-8.19.2/bin/set-bitbucket-home.sh

# Edit set-bitbucket-mesh-home.sh
echo 'Editing set-mesh-home.sh...'
sed -i '0,/MESH_HOME=/s|MESH_HOME=|MESH_HOME=/data/bitbucket_mesh_home|' atlassian-bitbucket-mesh-2.5.2/bin/set-mesh-home.sh

# Create a jira user with an empty full name
adduser jira --comment "" || { echo "Error: User creation failed."; exit 1; }

# Grant all permissions of the /data folder to the jira user
chown -R jira:jira /data || { echo "Error: Granting permissions failed."; exit 1; }


# Now switch to jira user from root user and start the mesh and then Bitbucket server
su -s /bin/bash jira -c 'sh -x /data/atlassian-bitbucket-mesh-2.5.2/bin/start-mesh.sh'
su -s /bin/bash jira -c 'sh -x /data/atlassian-bitbucket-8.19.2/bin/start-bitbucket.sh'

