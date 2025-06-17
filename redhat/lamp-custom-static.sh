#!/bin/bash
########################################################################
#Author: Bhasker Kamshetty
#Description: This script installs static website with vh & ssl in RHEL.
#Date: 11th February 2024
########################################################################

read -p "Enter domain name : " domain
read -p "Enter url of the zip file : " url
read -p "Enter directory name of the content : " dir

#Installs required packages for this script
echo "Installing wget zip unzip packages"
yum install wget zip unzip -y

#Moves to apache web root
echo "Moving to apache web root /var/www/"
cd /var/www/

#Downloads the zip file
echo "Downloading the zip file from $url"
wget $url

#Unzips the zip file & deletes the zip file
echo "Extracting the zip file & deleting the zip file"
unzip -q *.zip
rm -rf /var/www/*.zip

#Renames content directory to domain name
echo "Renaming content directory to $domain"
mv $dir $domain

#Change ownership of the domain webroot
echo "Changing ownership of the $domain webroot"
chown apache:apache -R /var/www/$domain/
find /var/www/$domain -type d -exec chmod 755 {} \;
find /var/www/$domain -type f -exec chmod 644 {} \;
chcon -R -t httpd_sys_rw_content_t  /var/www/$domain

#Adds these lines to the file /etc/httpd/conf/httpd.conf
echo "<VirtualHost *:80>" >> /etc/httpd/conf/httpd.conf
echo "	DocumentRoot /var/www/$domain/" >> /etc/httpd/conf/httpd.conf
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
echo "Done, installed static website from custom url at https://$domain"
