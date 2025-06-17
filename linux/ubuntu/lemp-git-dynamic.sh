#!/bin/bash
#####################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs dynamic website with lemp stack from git in Ubuntu.
#Date: 9th March 2024
#####################################################################################

read -p "Enter github username : " gituser
read -p "Enter github repo name : " gitrepo
read -p "Enter database file name : " dbfile
read -p "Enter domain name : " domain
read -p "Enter mysql database name : " dbname
read -p "Enter mysql user name : " uname
read -p "Enter password for mysql user $uname : " password

#Installs Git
echo "Installing Git"
apt-get install git -y

#Moves to nginx web root
echo "Moving to nginx web root /var/www/"
cd /var/www/

#Clones git repo
git clone git@github.com:$gituser/$gitrepo.git

#Renames git repo with to domain name
echo "Renaming $gitrepo to $domain"
mv $gitrepo $domain

#Creates Database
echo "Creating $dbname database"
echo "create database $dbname;" >> temp.sql

#Creates MySQL Username
echo "Creating $uname MySQL user"
echo "create user $uname@localhost identified by '$password';" >> temp.sql

#Grants privileges
echo "Granting privileges for $uname on $dbname"
echo "grant all on $dbname.* to $uname@localhost" >> temp.sql

#Executes the above commands, imports database & deletes temp.sql file
echo "Importing the database"
mysql < temp.sql
mysql $dbname < $domain/$dbfile
rm -rf temp.sql

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
echo "Done, installed dynamic website from git at https://$domain"
