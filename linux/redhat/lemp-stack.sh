#!/bin/bash
#####################################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs websites / web apps / wordpress with virtual host & ssl in RHEL.
#Date: 13th March 2024
#####################################################################################################
webserver="nginx"
webroot="/var/www"
confile="/etc/nginx/nginx.conf"
pkgname="nginx"
reqpkgs="git wget unzip"
dbpkgs="mariadb mariadb-server"
sslpkgs="certbot python3-certbot-nginx"
phppkgs="php-common php-fpm php-gd php-intl php-mysqlnd php-mbstring php-pecl-zip php-soap php-xml"
InstallCheck ()
{
	if rpm -q $reqpkgs $dbpkgs $pkgname $phppkgs $sslpkgs; then
        	Actions
	else
		Install
	fi
}
Install ()
{
	echo "Installing LEMP Stack"
	echo "Adding EPEL Repositories"
		dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
		dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm  -y
		/usr/bin/crb enable
	echo "Installing $reqpkgs"
		yum install $reqpkgs -y
  	echo "Installing Nginx Web Server"
		dnf module list $pkgname
		dnf module enable $pkgname:1.22 -y
  		dnf install $pkgname -y
	echo "Enabling & starting $webserver web server"
		systemctl enable $pkgname && systemctl start $pkgname
	echo "Installing $dbpkgs"
		yum install $dbpkgs -y
	echo "Enabling & starting mariadb"
		systemctl enable mariadb && systemctl start mariadb
	echo "Installing PHP"
		yum install $phppkgs -y
	echo "Installing $sslpkgs for $webserver"
		dnf install $sslpkgs -y
 	echo "Enabling & starting certbot renew timer"
	 	systemctl enable certbot-renew.timer && systemctl start certbot-renew.timer
	echo "Changing php-fpm user group and listeners to $webserver"
		sed -i -e 's/apache/nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.owner/listen.owner/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.group/listen.group/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/nobody/nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/listen.acl_users = nginx,nginx/listen.acl_users = nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.acl_groups =/listen.acl_groups = nginx/g' /etc/php-fpm.d/www.conf
  		chown -R $webserver:$webserver /var/lib/php/session
 	echo "Restarting php-fpm & $webserver server"
		systemctl restart php-fpm && systemctl restart $pkgname
}
UnInstall ()
{
	echo "Uninstalling LEMP Stack"
	yum remove $reqpkgs $dbpkgs $pkgname $phppkgs $sslpkgs -y
}
ChangeOwnerPermissions ()
{
	chown $webserver:$webserver -R /var/www/$domain/
	find /var/www/$domain -type d -exec chmod 755 {} \;
	find /var/www/$domain -type f -exec chmod 644 {} \;
	chcon -R -t httpd_sys_rw_content_t  /var/www/$domain
}
CreateDB ()
{
	echo "create database $dbname;" >> temp.sql
	echo "create user $uname@localhost identified by '$password';" >> temp.sql
	echo "grant all privileges on $dbname.* to $uname@localhost identified by '$password';" >> temp.sql
	mysql < temp.sql
	rm -rf temp.sql
}
CreateVH ()
{
       	echo "" >> temp.conf
        echo "    server {" >> temp.conf
        echo "        server_name  $domain;" >> temp.conf
        echo "        root         /var/www/$domain/;" >> temp.conf
        echo "        include      /etc/nginx/default.d/*.conf;" >> temp.conf
        echo "        access_log   /var/log/nginx/$domain-access.log;" >> temp.conf
        echo "        error_log    /var/log/nginx/$domain-error.log;" >> temp.conf
        echo "    }" >> temp.conf
        echo -e "ex $confile <<eof\n55 insert" >> temp.sh
        cat temp.conf >> temp.sh
        echo -e ".\nxit\neof" >> temp.sh
        chmod 700 temp.sh && sh temp.sh && rm -rf temp.*
}
CreateSSL ()
{
	certbot --$webserver --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain
 	$pkgname -t
  	systemctl restart $pkgname
}
CustomStatic ()
{
	read -p "Enter domain name : " domain
	read -p "Enter url of the zip file : " url
	read -p "Enter directory name of the content : " dir
	echo "Moving to $webroot & downloading content from $url"
		cd $webroot && wget $url
	echo "Extracting zip file, deleting zip file"
		unzip -q *.zip && rm -rf *.zip && mv -v $dir $domain
	echo "Changing ownership of $webroot/$domain"
		ChangeOwnerPermissions
	echo "Creating VirtualHost & SSL"
		CreateVH
		CreateSSL
	echo "Done, installed custom static website at https://$domain"
}
GitStatic ()
{
	read -p "Enter github username : " gituser
	read -p "Enter github repo name : " gitrepo
	read -p "Enter domain name : " domain
	echo "Moving to $webroot & cloning git repo from github.com/$gituser/$gitrepo"	
		cd $webroot && git clone git@github.com:$gituser/$gitrepo.git
	echo "Renaming $gitrepo to $domain"
		mv -v $gitrepo $domain
	echo "Changing ownership of $webroot/$domain"
		ChangeOwnerPermissions
	echo "Creating VirtualHost & SSL"
		CreateVH
		CreateSSL
	echo "Done, installed static website from git at https://$domain"
}
GitDynamic ()
{
	read -p "Enter github username : " gituser
	read -p "Enter github repo name : " gitrepo
	read -p "Enter database file name : " dbfile
	read -p "Enter domain name : " domain
	read -p "Enter mysql database name : " dbname
	read -p "Enter mysql user name : " uname
	read -p "Enter password for mysql user $uname : " password
	echo "Moving to $webroot & cloning git repo from github.com/$gituser/$gitrepo"
		cd $webroot && git clone git@github.com:$gituser/$gitrepo.git
	echo "Renaming $gitrepo to $domain"
		mv -v $gitrepo $domain
	echo "Creating database $dbname with all permissions to $uname & importing sql file"
		CreateDB
 		mysql $dbname < $domain/$dbfile
	echo "Changing ownership of $webroot/$domain"
		ChangeOwnerPermissions
	echo "Creating VirtualHost & SSL"
		CreateVH
		CreateSSL
	echo "Done, installed dynamic website from git at https://$domain"
}
Wordpress ()
{
	read -p "Enter domain name : " domain
	read -p "Enter mysql database name : " dbname
	read -p "Enter mysql user name : " uname
	read -p "Enter password for mysql user $uname : " password
	echo "Moving to $webroot & downloading latest wordpress"
		cd $webroot && wget https://wordpress.org/latest.zip
	echo "Extracting zip file, deleting zip file & renaming wordpress to $domain"
		unzip -q latest.zip && rm -rf latest.zip && mv -v wordpress $domain
	echo "Creating database $dbname with all permissions to $uname"
		CreateDB
	echo "Changing ownership of $webroot/$domain"
		ChangeOwnerPermissions
		setsebool -P httpd_can_network_connect 1
	echo "Creating VirtualHost & SSL"
		CreateVH
		CreateSSL
	echo "Done, installed wordpress at https://$domain"
}
Actions ()
{
	clear
	echo -e "Options for LAMP-Stack\n1. Custom Static Content\n2. Git Static Content\n3. Git Dynamic Content\n4. Wordpress\n5. UnInstall Stack"
	read -p "Select type of content to install : " contype
	case $contype in
		"1")
			CustomStatic
		;;
		"2")
            		GitStatic
	    	;;
		"3")
			GitDynamic
		;;
		"4")
			Wordpress
		;;
  		"5")
    			UnInstall Stack
       		;;	 
  		*)
			echo "Invalid option !"
		;;
	esac
}
InstallCheck
