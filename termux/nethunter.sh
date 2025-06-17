#!/bin/bash
#####################################################################
#Author: Bhasker Kamshetty
#Description: This script installs basic packages for Termux
#Date: 8th October 2024
#####################################################################

pkg install root-repo
pkg install x11-repo
pkg update -y
pkg upgrade -y
pkg install wget unzip zip git nano vim -y
termux-change-repo
termux-setup-storage
wget -O nethunter https://offs.ec/2MceZWr
chmod +x nethunter
./nethunter
nethunter
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y kali-linux-default
