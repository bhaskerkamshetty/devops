#!/bin/bash
##################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs wordpress in lemp stack with vh & ssl in RHEL.
#Date: 6th March 2024
##################################################################################

read -p "Enter domain name : " domain
read -p "Enter mysql database name : " dbname
read -p "Enter mysql user name : " uname
read -p "Enter password for mysql user $uname : " password

#Installs required packages for this script
echo "Installing wget zip unzip packages"
yum install wget zip unzip -y

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
echo "grant all privileges on $dbname.* to $uname@localhost identified by '$password';" >> temp.sql

#Executes the above commands, deletes temp.sql & wordpress zip file
echo "Executing sql commands"
mysql < temp.sql
rm -rf temp.sql latest.zip

#Conclusion
echo "Done. Created user $uname with full privileges on $dbname database."

#Change ownership of the domain webroot
echo "Changing ownership of the $domain webroot"
chown nginx:nginx -R /var/www/$domain/
find /var/www/$domain -type d -exec chmod 755 {} \;
find /var/www/$domain -type f -exec chmod 644 {} \;
chcon -R -t httpd_sys_rw_content_t  /var/www/$domain
setsebool -P httpd_can_network_connect 1

#Adds these lines to the file /etc/nginx/nginx.conf
ex /etc/nginx/nginx.conf <<eof
55 insert

    server {
        server_name  $domain;
        root         /var/www/$domain/;
        include      /etc/nginx/default.d/*.conf;
        access_log   /var/log/nginx/$domain-access.log;
        error_log    /var/log/nginx/$domain-error.log;
    }
.
xit
eof

#Adds SSL certificate to the domain
echo "Adding SSL certificate to the $domain"
certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain

#Checks for any errors
nginx -t

#Restarts Nginx Web Server
echo "Restarting Nginx Web Server"
systemctl restart nginx

#Conclusion
echo "Done, installed wordpress at https://$domain"
