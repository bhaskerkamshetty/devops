#!/bin/bash
############################################################
#Author: Bhasker Kamshetty
#Description: This script installs basic packages for Ubuntu.
#Date: 9th March 2024
############################################################

#Installs Network Tools
echo "Installing Network Tools"
apt-get install wget curl net-tools telnet iputils-ping mtr-tiny iproute2 iperf3 cockpit -y

#Installs Management & Session Persistence
echo "Installing Management & Session Persistence Tools"
apt-get install rsync nano vim zip unzip git micro tmux -y

#Installs System Monitoring & Diagnostics
echo "Installing System Monitoring & Diagnostics Tools"
apt-get install htop ncdu iotop -y

#Installs Security & System Hardening
echo "Installing Security & System Hardening Tools"
apt-get install fail2ban unattended-upgrades ufw iotop -y

#Conclusion
echo "Done. Installing"
