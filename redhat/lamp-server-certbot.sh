#!/bin/bash
######################################################################
#Author: Bhasker Kamshetty
#Description: This script installs lamp-server with certbot in RHEL.
#Date: 7th February 2024
######################################################################

#Installs required packages
echo "Installing required packages"
yum install git wget unzip -y

#Installs Apache HTTP Web Server
echo "Installing Apache HTTP Web Server"
yum install httpd -y

#Enables Apache HTTP Web Server on boot
echo "Enabling Apache HTTP Web Server on Boot"
systemctl enable httpd

#Starts Apache HTTP Web Server
echo "Starting Apache HTTP Web Server"
systemctl start httpd

#Installs MariaDB Server
echo "Installing MariaDB Server"
yum install mariadb mariadb-server -y

#Enables MariaDB Server on boot
echo "Enabling MariaDB Server on Boot"
systemctl enable mariadb

#Starts MariaDB Server
echo "Starting MariaDB Server"
systemctl start mariadb

#Installs PHP
echo "Installing PHP"
yum install php-{curl,fpm,gd,intl,mbstring,mysqli,soap,xml,zip} -y

#Restarts Apache HTTP Web Server
echo "Restarting Apache HTTP Web Server"
systemctl restart httpd

#Adds EPEL repositories
echo "Adding required repositories"
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm  -y
/usr/bin/crb enable

#Installs certbot for apache
echo "Installing certbot for apache"
dnf install certbot python3-certbot-apache -y

#Restarts Apache HTTP Web Server
echo "Restarting Apache HTTP Web Server"
systemctl restart httpd

#Conclusion
echo "Done. Installing"
