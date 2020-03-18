#!/bin/bash
echo -e "\nUpdate system"
apt-get install sudo -y
sudo apt-get update
sudo apt-get upgrade
sudo apt autoremove -y
sudo apt install -y curl

# Ask for the user password
# Script only works if sudo caches the password for a few minutes
sudo true

echo -e "\Installing docker latest version"
wget -qO- https://get.docker.com/ | sh
echo -e "[Done]"

echo -e "\nInstalling git"
apt install git -y
git --version
echo -e "[Done]"

echo -e "\nInstall docker-compose"
COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`

echo -e "\nInstalling docker-compose version : ${COMPOSE_VERSION}"
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
echo -e "[Done]"

echo -e "\nInstall docker-cleanup command"
cd /tmp
git clone https://gist.github.com/76b450a0c986e576e98b.git
cd 76b450a0c986e576e98b
sudo mv docker-cleanup /usr/local/bin/docker-cleanup
sudo chmod +x /usr/local/bin/docker-cleanup
docker-cleanup -n
echo -e "[Done]"
