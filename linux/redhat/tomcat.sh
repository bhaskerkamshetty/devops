#!/bin/bash
#####################################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs apache tomcat in RHEL.
#Date: 13th March 2024
#####################################################################################################

read -p "Enter the url of tomcat zip file" url

#Installs wget
echo "Installing wget"
yum install wget -y

#Installs Java JDK
echo "Installing Java JDK"
yum install java -y

#Moves to /opt/
echo "Moving to /opt/"
cd /opt/

#Downloads zip file to /opt/
echo "Downloading zip file to /opt/"
wget $url

#Extracts zip file
echo "Extracts zip file"
unzip -q *.zip


