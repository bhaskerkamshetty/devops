#!/bin/bash
########################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs static website in lemp stack with vh & ssl in RHEL.
#Date: 7th March 2024
########################################################################################

read -p "Enter github username : " gituser
read -p "Enter github repo name : " gitrepo
read -p "Enter domain name : " domain

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
echo "Done, installed static website from git at https://$domain"
