#!/bin/bash
######################################################################
#Author: Bhasker Kamshetty
#Description: This script installs lemp-server with certbot in Ubuntu
#Date: 8th March 2024
######################################################################

#Updates apt packges
echo "Updating apt packges"
apt-get update -y

#Installs Nginx Web Server
echo "Installing Nginx Web Server"
apt-get install nginx -y

#Enables Nginx Web Server on boot
echo "Enabling Nginx Web Server on Boot"
systemctl enable nginx

#Starts Nginx Web Server
echo "Starting Nginx Web Server"
systemctl start nginx

#Installs MariaDB Server
echo "Installing MySQL Server"
apt-get install mysql-server -y

#Enables MySQL Server on boot
echo "Enabling MySQL Server on Boot"
systemctl enable mysql

#Starts MySQL Server
echo "Starting MySQL Server"
systemctl start mysql

#Installs PHP
echo "Installing PHP"
apt-get install php8.3-{curl,fpm,gd,intl,mbstring,mysql,soap,xml,xmlrpc,zip} -y

#Installs certbot for nginx
echo "Installing certbot for nginx"
apt-get install certbot python3-certbot-nginx -y

#Restarts php8.1-fpm
echo "Restarting php8.3-fpm"
systemctl restart php8.3-fpm

#Restarts Nginx Web Server
echo "Restarting Nginx Web Server"
systemctl restart nginx

#Conclusion
echo "Done. Installing"
