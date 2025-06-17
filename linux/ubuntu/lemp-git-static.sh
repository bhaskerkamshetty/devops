#!/bin/bash
########################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs static website in lemp stack with vh & ssl in Ubuntu.
#Date: 9th March 2024
########################################################################################

read -p "Enter github username : " gituser
read -p "Enter github repo name : " gitrepo
read -p "Enter domain name : " domain

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
echo "Done, installed static website from git at https://$domain"
