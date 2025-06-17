#!/bin/bash
#####################################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs websites / web apps / wordpress with virtual host & ssl in RHEL.
#Date: 12th March 2024
#####################################################################################################
webserver="apache"
webroot="/var/www"
confile="/etc/httpd/conf/httpd.conf"
pkgname="httpd"
reqpkgs="git wget unzip"
dbpkgs="mariadb mariadb-server"
sslpkgs="certbot python3-certbot-apache"
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
	echo "Installing LAMP Stack"
	echo "Adding EPEL Repositories"
		dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
		dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm  -y
		/usr/bin/crb enable
	echo "Installing $reqpkgs"
		yum install $reqpkgs -y
	echo "Installing $webserver web server"
		yum install $pkgname -y
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
		chown -R $webserver:$webserver /var/lib/php/session
 	echo "Restarting $webserver server"
		systemctl restart $pkgname
}
UnInstall ()
{
	echo "Uninstalling LAMP Stack"
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
	echo "<VirtualHost *:80>" >> $confile
	echo "	DocumentRoot /var/www/$domain/" >> $confile
	echo "	ServerName $domain" >> $confile
	echo "	CustomLog /var/log/httpd/$domain-access.log combined" >> $confile
	echo "	ErrorLog /var/log/httpd/$domain-error.log" >> $confile
	echo "</VirtualHost>" >> $confile
}
CreateSSL ()
{
	certbot --$webserver --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain
 	apachectl -t
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
phpMyAdmin ()
{
 	read -p "Enter domain name : " domain
	read -p "Enter mysql user for phpMyAdmin : " uname
	read -p "Enter password for mysql user $uname : " password
	echo "Installing phpMyAdmin"
		dnf install phpmyadmin -y
	echo "Creating $uname MySQL admin user for phpMyAdmin"
		echo "create user $uname@localhost identified by '$password';" >> temp.sql
	echo "Granting all databased privileges for $uname"
		echo "grant all privileges on *.* to $uname@localhost identified by '$password';" >> temp.sql
	echo "Executing sql commands"
  		mysql < temp.sql && rm -rf temp.sql
     	echo "Removing alias ip/phpmyadmin"
		sed -i -e 's/Alias/#Alias/g' /etc/httpd/conf.d/phpMyAdmin.conf
     	echo "Changing ownership to $webserver for /usr/share/phpMyAdmin/"  	
   		chown $webserver:$webserver -R /usr/share/phpMyAdmin/
		find /usr/share/phpMyAdmin/ -type d -exec chmod 755 {} \;
		find /usr/share/phpMyAdmin/ -type f -exec chmod 644 {} \;
		chcon -R -t httpd_sys_rw_content_t  /usr/share/phpMyAdmin/
 	echo "Allows public access to phpmyadmin"
		echo -e "ex /etc/httpd/conf.d/phpMyAdmin.conf <<eof\n15 insert" >> temp.sh
		echo "   Require all granted" >> temp.sh
		echo -e ".\nxit\neof" >> temp.sh
		chmod 700 temp.sh && sh temp.sh && rm -rf temp.sh
		echo "Creating VirtualHost & SSL"
 		CreateVH
		sed -i -e "s|/var/www/$domain/|/usr/share/phpMyAdmin/|g" $confile	
		CreateSSL
	echo "Done, installed phpMyAdmin at https://$domain"
}
Actions ()
{
	clear
	echo -e "Options for LAMP-Stack\n1. Custom Static Content\n2. Git Static Content\n3. Git Dynamic Content\n4. Wordpress\n5. phpMyAdmin\n6. UnInstall Stack"
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
    			phpMyAdmin
       		;;
  		"6")
    			UnInstall Stack
       		;;	 
  		*)
			echo "Invalid option !"
		;;
	esac
}
InstallCheck
