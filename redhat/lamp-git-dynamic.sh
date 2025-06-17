#!/bin/bash
#####################################################################
#Author: Bhasker Kamshetty
#Description: This script installs dynamic website from git in RHEL.
#Date: 11th February 2024
#####################################################################

read -p "Enter github username : " gituser
read -p "Enter github repo name : " gitrepo
read -p "Enter database file name : " dbfile
read -p "Enter domain name : " domain
read -p "Enter mysql database name : " dbname
read -p "Enter mysql user name : " uname
read -p "Enter password for mysql user $uname : " password

#Installs Git
echo "Installing Git"
yum install git -y

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
echo "grant all privileges on $dbname.* to $uname@localhost identified by '$password';" >> temp.sql

#Executes the above commands, imports database & deletes temp.sql file
echo "Importing the database"
mysql < temp.sql
mysql $dbname < $domain/$dbfile
rm -rf temp.sql

#Conclusion
echo "Done. Created user $uname with full privileges on $dbname database."

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
echo "Done, installed dynamic website from git at https://$domain"
