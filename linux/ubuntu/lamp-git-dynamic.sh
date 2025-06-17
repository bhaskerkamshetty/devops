#!/bin/bash
#####################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs dynamic website with lemp stack from git in Ubuntu.
#Date: 8th October 2024
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

#Moves to apache web root
echo "Moving to apache web root /var/www/"
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
echo "Creating virtual host for $domain at /etc/apache2/sites-available/$domain"
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/$domain
echo "        DocumentRoot /var/www/$domain" >> /etc/apache2/sites-available/$domain
echo "        ServerName $domain" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "        ErrorLog /var/log/apache2/$domain-error.log" >> /etc/apache2/sites-available/$domain
echo "        CustomLog /var/log/apache2/$domain-access.log combined" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "        <Directory /var/www/$domain/>" >> /etc/apache2/sites-available/$domain
echo "            Require all granted" >> /etc/apache2/sites-available/$domain
echo "            Options FollowSymlinks MultiViews" >> /etc/apache2/sites-available/$domain
echo "            AllowOverride All" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "           <IfModule mod_dav.c>" >> /etc/apache2/sites-available/$domain
echo "               Dav off" >> /etc/apache2/sites-available/$domain
echo "           </IfModule>" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "        SetEnv HOME /var/www/$domain" >> /etc/apache2/sites-available/$domain
echo "        SetEnv HTTP_HOME /var/www/$domain" >> /etc/apache2/sites-available/$domain
echo "        Satisfy Any" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "       </Directory>" >> /etc/apache2/sites-available/$domain
echo "" >> /etc/apache2/sites-available/$domain
echo "</VirtualHost>" >> /etc/apache2/sites-available/$domain

#Creates symlink to the virtual host in sites enabled
echo "Creating symlink to the virtual host $domain"
a2ensite $domain.conf
a2enmod rewrite headers env dir mime setenvif ssl

#Adds SSL certificate to the domain
echo "Adding SSL certificate to the $domain"
certbot --apache --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain

#Checks for any errors
apache -t

#Restarts php8.3-fpm
echo "Restarting php8.3-fpm"
systemctl restart php8.3-fpm

#Restarts Apache Web Server
echo "Restarting apache Web Server"
systemctl restart apache

#Conclusion
echo "Done, installed dynamic website from git at https://$domain"
