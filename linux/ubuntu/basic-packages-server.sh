#!/bin/bash
############################################################
#Author: Bhasker Kamshetty
#Description: This script installs basic packages for Ubuntu.
#Date: 9th March 2024
############################################################

#Installs Nano Text Editor
echo "Installing Nano Text Editor"
apt-get install nano -y

#Installs Wget Tool
echo "Installing Wget Tool"
apt-get install wget -y

#Installs Zip/Unzip Tool
echo "Installing Zip/Unzip Tool"
apt-get install zip unzip -y

#Installs Network Tools
echo "Installing Network Tools"
apt-get install net-tools -y

#Installs Telnet
echo "Installing Telnet"
apt-get install telnet -y

#Installs Git
echo "Installing Git"
apt-get install git -y

#Installs Cockpit
echo "Installing Cockpit"
apt-get install cockpit -y

#Conclusion
echo "Done. Installing"
