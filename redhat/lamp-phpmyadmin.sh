#!/bin/bash
######################################################################
#Author: Bhasker Kamshetty
#Description: This script installs phpMyAdmin with lamp stack on RHEL.
#Date: 11th March 2024
######################################################################

read -p "Enter domain name : " domain
read -p "Enter mysql user for phpMyAdmin : " uname
read -p "Enter password for mysql user $uname : " password

#Installs phpMyAdmin
echo "Installing phpMyAdmin"
dnf install phpmyadmin -y

#Creates MySQL User for phpMyAdmin
echo "Creating $uname MySQL admin user for phpMyAdmin"
echo "create user $uname@localhost identified by '$password';" >> temp.sql

#Grants privileges
echo "Granting all databased privileges for $uname"
echo "grant all privileges on *.* to $uname@localhost identified by '$password';" >> temp.sql

#Executes the above commands & deletes temp.sql
echo "Executing sql commands"
mysql < temp.sql
rm -rf temp.sql

#Removes alias ip/phpmyadmin
echo "Removing alias ip/phpmyadmin"
sed -i -e 's/Alias/#Alias/g' /etc/httpd/conf.d/phpMyAdmin.conf

#Adds these lines to the file /etc/httpd/conf.d/phpMyAdmin.conf
echo "Allows public access to phpmyadmin"
ex /etc/httpd/conf.d/phpMyAdmin.conf <<eof
15 insert
   Require all granted
.
xit
eof

#Adds these lines to the file /etc/httpd/conf/httpd.conf
echo "<VirtualHost *:80>" >> /etc/httpd/conf/httpd.conf
echo "	DocumentRoot /usr/share/phpMyAdmin/" >> /etc/httpd/conf/httpd.conf
echo "	ServerName $domain" >> /etc/httpd/conf/httpd.conf
echo "	CustomLog /var/log/httpd/$domain-access.log combined" >> /etc/httpd/conf/httpd.conf
echo "	ErrorLog /var/log/httpd/$domain-error.log" >> /etc/httpd/conf/httpd.conf
echo "</VirtualHost>" >> /etc/httpd/conf/httpd.conf

#Adds SSL certificate to the domain
echo "Adding SSL certificate to the $domain"
certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain

#Checks for any errors
apachectl -t

#Restarts Apache HTTP Web Server
echo "Restarting Apache HTTP Web Server"
systemctl restart httpd

#Conclusion
echo "Done, installed phpMyAdmin at https://$domain"
