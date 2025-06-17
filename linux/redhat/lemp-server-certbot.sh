#!/bin/bash
######################################################################
#Author: Bhasker Kamshetty
#Description: This script installs lemp-server with certbot in RHEL.
#Date: 6th March 2024
######################################################################

#Checks Nginx Web Server Modules
echo "Checks Nginx Web Server Modules"
dnf module list nginx

#Installs required packages
echo "Installing required packages"
yum install git wget unzip -y

#Enables Nginx Web Server Module 1.22
echo "Enables Nginx Web Server Module 1.22"
dnf module enable nginx:1.22 -y

#Installs Nginx Web Server
echo "Installing Nginx Web Server"
dnf install nginx -y

#Enables Nginx Web Server on boot
echo "Enabling Nginx Web Server on Boot"
systemctl enable nginx

#Starts Nginx Web Server
echo "Starting Nginx Web Server"
systemctl start nginx

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

#Restarts Nginx Web Server
echo "Restarting Nginx Web Server"
systemctl restart nginx

#Adds EPEL repositories
echo "Adding required repositories"
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm  -y
/usr/bin/crb enable

#Installs certbot for nginx
echo "Installing certbot for nginx"
dnf install certbot python3-certbot-nginx -y

#Changes php-fpm user group and listeners to nginx
echo "Changing php-fpm user group and listeners to nginx"
sed -i -e 's/apache/nginx/g' /etc/php-fpm.d/www.conf
sed -i -e 's/;listen.owner/listen.owner/g' /etc/php-fpm.d/www.conf
sed -i -e 's/;listen.group/listen.group/g' /etc/php-fpm.d/www.conf
sed -i -e 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf
sed -i -e 's/nobody/nginx/g' /etc/php-fpm.d/www.conf
sed -i -e 's/listen.acl_users = nginx,nginx/listen.acl_users = nginx/g' /etc/php-fpm.d/www.conf
sed -i -e 's/;listen.acl_groups =/listen.acl_groups = nginx/g' /etc/php-fpm.d/www.conf

#Restarts Nginx Web Server
echo "Restarting Nginx Web Server"
systemctl restart php-fpm
systemctl restart nginx

#Conclusion
echo "Done. Installing"
