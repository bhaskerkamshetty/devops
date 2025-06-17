#!/bin/bash
####################################################################
#Author: Bhasker Kamshetty
#Description: This script installs ansible-core with windows module
#Date: 27th February 2024
####################################################################

#Installs Ansible-Core
echo "Installing Ansible-Core"
yum install ansible-core -y

#Installs pip3
echo "Installing pip3"
dnf install python3-pip -y

#Installs pywinrm
echo "Installing pywinrm"
pip3 install "pywinrm>=0.3.0"

#Installs windows module for ansible
echo "Installing windows module for ansible"
ansible-galaxy collection install ansible.windows
