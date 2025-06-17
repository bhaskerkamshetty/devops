#!/bin/bash
######################################################################
#Author: Bhasker Kamshetty
#Description: This script installs lamp-server with certbot in Ubuntu
#Date: 8th October 2024
######################################################################

#Updates apt packges
echo "Updating apt packges"
apt-get update -y

#Installs Apache Web Server
echo "Installing Apache Web Server"
apt-get install apache2 -y

#Enables Apache Web Server on boot
echo "Enabling Apache Web Server on Boot"
systemctl enable apache2

#Starts Apache Web Server
echo "Starting Apache Web Server"
systemctl start apache2

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
apt-get install certbot python3-certbot-apache -y

#Restarts php8.1-fpm
echo "Restarting php8.3-fpm"
a2enconf php8.3-fpm
systemctl restart php8.3-fpm

#Restarts Apache Web Server
echo "Restarting Apache Web Server"
systemctl restart apache2

#Conclusion
echo "Done. Installing"
