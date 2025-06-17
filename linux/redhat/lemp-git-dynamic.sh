#!/bin/bash
#####################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs dynamic website with lemp stack from git in RHEL.
#Date: 7th March 2024
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
yum install git -y

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
chown nginx:nginx -R /var/www/$domain/
find /var/www/$domain -type d -exec chmod 755 {} \;
find /var/www/$domain -type f -exec chmod 644 {} \;
chcon -R -t httpd_sys_rw_content_t  /var/www/$domain

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
echo "Done, installed dynamic website from git at https://$domain"
