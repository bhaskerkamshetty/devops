#!/bin/bash
############################################################
#Author: Bhasker Kamshetty
#Description: This script installs basic packages for RHEL.
#Date: 6th February 2024
############################################################

echo "Installing Nano Text Editor"
yum install nano -y

echo "Installing Wget Tool"
yum install wget -y

echo "Installing Zip/Unzip Tool"
yum install zip unzip -y

echo "Installing Network Tools"
yum install net-tools -y

echo "Installing Telnet"
yum install telnet -y

echo "Installing Git"
yum install git -y

echo "Installing gcc & g++"
yum install gcc g++ -y
