#!/bin/bash

# This is a helper script to install all kinds of tools and utilities on a new machine
red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
reset=`tput sgr0`
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get started
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${red}This script must be ran while connected to the internet!${reset}"
    exit
fi

# Install basic tools
sudo apt-get update
sudo apt-get install -y vim git openssh-server gcc curl

# Install barrier
sudo snap install barrier

# Terminal tools
sudo apt-get install -y terminator tmux

# More security
sudo ufw enable
sudo apt-get install -y gufw

# Less burden - UI tweaks
sudo apt-get install -y gnome-tweak-tool 

# Install fish
sudo apt-get install -y fish
if ! grep -Fxq "exec fish" ~/.bashrc 
then
	echo 'exec fish' >> ~/.bashrc
fi

# Disable the dock
gnome-extensions disable ubuntu-dock@ubuntu.com

# Remove the report issue prompt - we never have issues
sudo apt remove -y apport apport-gtk

# Install chrome if it is not already installed
if ! command -v google-chrome &> /dev/null
then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb
else
	echo "${green}Chrome is already installed!${reset}"
fi

# Install slack
sudo apt-get install -y slack

# Install VS Lame
sudo snap install --classic code

# Install gitkraken
if ! command -v gitkraken &> /dev/null
then
	wget -c https://release.gitkraken.com/linux/gitkraken-amd64.deb
	sudo apt install ./gitkraken-amd64.deb
	rm gitkraken-amd64.deb
else
	echo "${magenta}Gitkraken is already installed!${reset}"
fi

# Install python dev dependencies
sudo apt install -y python3-distutils python3.8-venv python3-pip python3-setuptools python3-pkg-resources

# Install poetry for python
curl -sSL https://install.python-poetry.org | python3 -
set -U fish_user_paths ~/.local/bin/ $fish_user_paths

# Install Jetbrains Stack - do this last because it has to be interactive :/
read -p "${green}Do you want to install jetbrains (y/n)${reset}" -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "${green}Click the download link (I know this sucks, blame jetbrains)${reset}"
	read -n 1

	google-chrome https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux & 

	echo "${red}Press any key when the download is complete...${reset}"
	read -n 1

	cd ~/Downloads
	pattern="*jetbrains-toolbox*"
	installer=( $pattern )
	sudo tar -xzf "${installer[0]}" -C /opt

	echo "${green}Opening up the jetbrains toolbox, click back here once you click install on all things${reset}"
	cd /opt/
	bin=( $pattern )
	"${bin[0]}"/jetbrains-toolbox &
	read -n 1
fi

# Perform cleanup and exit
sudo apt -y autoremove
echo "${green}Done!${reset}"
