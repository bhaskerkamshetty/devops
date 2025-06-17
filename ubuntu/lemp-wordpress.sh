#!/bin/bash
##################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs wordpress in lemp stack with vh & ssl in Ubuntu.
#Date: 9th March 2024
##################################################################################

read -p "Enter domain name : " domain
read -p "Enter mysql database name : " dbname
read -p "Enter mysql user name : " uname
read -p "Enter password for mysql user $uname : " password

#Installs required packages for this script
echo "Installing wget zip unzip packages"
apt-get install wget zip unzip -y

#Moves to nginx web root
echo "Moving to nginx web root /var/www/"
cd /var/www/

#Downloads wordpress zip file
echo "Downloading wordpress zip file"
wget https://wordpress.org/latest.zip

#Unzips wordpress zip file
echo "Extracting wordpress zip file"
unzip -q latest.zip

#Renames wordpress directory to domain name
echo "Renaming wordpress directory to $domain"
mv wordpress $domain

#Creates Database
echo "Creating $dbname database"
echo "create database $dbname;" >> temp.sql

#Creates MySQL Username
echo "Creating $uname MySQL user"
echo "create user $uname@localhost identified by '$password';" >> temp.sql

#Grants privileges
echo "Granting privileges for $uname on $dbname"
echo "grant all on $dbname.* to $uname@localhost" >> temp.sql

#Executes the above commands, deletes temp.sql & wordpress zip file
echo "Executing sql commands"
mysql < temp.sql
rm -rf temp.sql latest.zip

#Conclusion
echo "Done. Created user $uname with full privileges on $dbname database."

#Change ownership of the domain webroot
echo "Changing ownership of the $domain webroot"
chown www-data:www-data -R /var/www/$domain/
find /var/www/$domain -type d -exec chmod 755 {} \;
find /var/www/$domain -type f -exec chmod 644 {} \;

#Creates virtual host for the domain
echo "Creating virtual host for $domain at /etc/nginx/sites-available/$domain"
echo "server {" >> /etc/nginx/sites-available/$domain
echo "        listen 80;" >> /etc/nginx/sites-available/$domain
echo "        listen [::]:80;" >> /etc/nginx/sites-available/$domain
echo "        server_name $domain;" >> /etc/nginx/sites-available/$domain
echo "        root /var/www/$domain;" >> /etc/nginx/sites-available/$domain
echo "        index index.php index.html index.htm;" >> /etc/nginx/sites-available/$domain
echo "        access_log   /var/log/nginx/$domain-access.log;" >> /etc/nginx/sites-available/$domain
echo "        error_log   /var/log/nginx/$domain-error.log;" >> /etc/nginx/sites-available/$domain
echo "        location ~ \.php$ {" >> /etc/nginx/sites-available/$domain
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/$domain
echo "                fastcgi_pass unix:/run/php/php8.1-fpm.sock;" >> /etc/nginx/sites-available/$domain
echo "        }" >> /etc/nginx/sites-available/$domain
echo "}" >> /etc/nginx/sites-available/$domain

#Creates symlink to the virtual host in sites enabled
echo "Creating symlink to the virtual host $domain"
ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain

#Adds SSL certificate to the domain
echo "Adding SSL certificate to the $domain"
certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain

#Checks for any errors
nginx -t

#Restarts php8.1-fpm
echo "Restarting php8.1-fpm"
systemctl restart php8.1-fpm

#Restarts Nginx Web Server
echo "Restarting Nginx Web Server"
systemctl restart nginx

#Conclusion
echo "Done, installed wordpress at https://$domain"
