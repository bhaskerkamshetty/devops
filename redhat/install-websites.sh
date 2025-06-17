#!/bin/bash
#####################################################################################################
#Author: Bhasker Kamshetty
#Description: This script installs websites / web apps / wordpress with virtual host & ssl in RHEL.
#Date: 9th March 2024
#####################################################################################################
InstallCheck ()
{
	$Stack-Stack
        if rpm -q $pkgs; then
		clear
                Stack-Actions
	else
		Install
	fi
}
lamp-Stack ()
{
	pkgs="git wget unzip httpd mariadb mariadb-server php-common php-fpm php-gd php-intl php-mbstring php-mysqlnd php-soap php-xml php-pecl-zip epel-release.noarch certbot python3-certbot-httpd"
 	pkgname="httpd"
	webserver="apache"
	webroot="/var/www"
	confile="/etc/httpd/conf/httpd.conf"
}
lemp-Stack ()
{
	pkgs="git wget unzip nginx mariadb mariadb-server php-common php-fpm php-gd php-intl php-mbstring php-mysqlnd php-soap php-xml php-pecl-zip epel-release.noarch certbot python3-certbot-nginx"
        pkgname="nginx"
        webserver="nginx"
	webroot="/var/www"
	confile="/etc/nginx/nginx.conf"
}
Install ()
{
	$Stack-Stack
	echo -e "Installing $Stack stack\nInstalling required packages"
	yum install git wget unzip -y
	if [ $Stack == "lamp" ]; then
		echo "Installing Apache Web Server"
		yum install $pkgname -y
	elif [ $Stack == "lemp" ]; then
  		echo "Installing Nginx Web Server"
		dnf module list $pkgname
		dnf module enable $pkgname:1.22 -y
  		dnf install $pkgname -y
  	else
   		echo "Something went wrong."
 	fi
	echo "Enabling & Starting $webserver server"
	systemctl enable $pkgname && systemctl start $pkgname
	echo "Installing MariaDB Server"
	yum install mariadb{,-server} -y
	echo "Enabling & Starting MariaDB Server"
	systemctl enable mariadb && systemctl start mariadb
	echo "Installing PHP"
	yum install php-{common,fpm,gd,intl,mbstring,mysqlnd,soap,xml,pecl-zip} -y
	echo "Adding EPEL repositories"
	dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
	dnf install https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm  -y
	/usr/bin/crb enable
	echo "Installing certbot for $webserver"
	dnf install certbot python3-certbot-$webserver -y
 	echo "Enabling & Starting Certbot Renew Timer"
 	systemctl enable certbot-renew.timer && systemctl start certbot-renew.timer
 	if [ $Stack == "lemp" ]; then
		echo "Changing php-fpm user group and listeners to $webserver"
		sed -i -e 's/apache/nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.owner/listen.owner/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.group/listen.group/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/nobody/nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/listen.acl_users = nginx,nginx/listen.acl_users = nginx/g' /etc/php-fpm.d/www.conf
		sed -i -e 's/;listen.acl_groups =/listen.acl_groups = nginx/g' /etc/php-fpm.d/www.conf
  		systemctl restart php-fpm
	fi
	chown -R $webserver:$webserver /var/lib/php/session
 	echo "Restarting $webserver server"
	systemctl restart $pkgname
}
ChangeOwnerPerms ()
{
	$Stack-Stack
	chown $webserver:$webserver -R /var/www/$domain/
	find /var/www/$domain -type d -exec chmod 755 {} \;
	find /var/www/$domain -type f -exec chmod 644 {} \;
	chcon -R -t httpd_sys_rw_content_t  /var/www/$domain
}
CreateDB ()
{
	$Stack-Stack
	echo "create database $dbname;" >> temp.sql
	echo "create user $uname@localhost identified by '$password';" >> temp.sql
	echo "grant all privileges on $dbname.* to $uname@localhost identified by '$password';" >> temp.sql
	mysql < temp.sql
	rm -rf temp.sql
}
CreateVHSSL ()
{
	$Stack-Stack
	if [ $Stack == "lamp" ]; then
		echo "<VirtualHost *:80>" >> $confile
		echo "DocumentRoot /var/www/$domain/" >> $confile
		echo "ServerName $domain" >> $confile
		echo "CustomLog /var/log/httpd/$domain-access.log combined" >> $confile
		echo "ErrorLog /var/log/httpd/$domain-error.log" >> $confile
		echo "</VirtualHost>" >> $confile
  	elif [ $Stack == "lemp" ]; then
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
	else
  		echo "Something went wrong!"
  	fi
	certbot --$webserver --agree-tos --redirect --hsts --staple-ocsp --email info@$domain -d $domain
}
CustomStatic ()
{
	$Stack-Stack
	read -p "Enter domain name : " domain
	read -p "Enter url of the zip file : " url
	read -p "Enter directory name of the content : " dir
	echo "Moving to $webroot & downloading content from $url"
	cd $webroot && wget $url
	echo "Extracting zip file, deleting zip file & renaming $dir to $domain"
	unzip -q *.zip && rm -rf *.zip && mv $dir $domain
	echo "Changing ownership of $webroot/$domain"
	ChangeOwnerPerms
	echo "Creating VirtualHost & SSL"
	CreateVHSSL
	echo "Done, installed custom static website at https://$domain"
}
GitStatic ()
{
	$Stack-Stack
	read -p "Enter github username : " gituser
	read -p "Enter github repo name : " gitrepo
	read -p "Enter domain name : " domain
	echo "Moving to $webroot & cloning git repo from github.com/$gituser/$gitrepo"	
	cd $webroot && git clone git@github.com:$gituser/$gitrepo.git
	echo "Renaming $gitrepo to $domain"
	mv $gitrepo $domain
	echo "Changing ownership of $webroot/$domain"
	ChangeOwnerPerms
	echo "Creating VirtualHost & SSL"
	CreateVHSSL
	echo "Done, installed static website from git at https://$domain"
}
GitDynamic ()
{
	$Stack-Stack
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
	mv $gitrepo $domain
	echo "Creating database $dbname with all permissions to $uname & importing sql file"
	CreateDB
 	mysql $dbname < $domain/$dbfile
	echo "Changing ownership of $webroot/$domain"
	ChangeOwnerPerms
	echo "Creating VirtualHost & SSL"
	CreateVHSSL
	echo "Done, installed dynamic website from git at https://$domain"
}
Wordpress ()
{
	$Stack-Stack
	read -p "Enter domain name : " domain
	read -p "Enter mysql database name : " dbname
	read -p "Enter mysql user name : " uname
	read -p "Enter password for mysql user $uname : " password
	echo "Moving to $webroot & downloading latest wordpress"
	cd $webroot && wget https://wordpress.org/latest.zip
	echo "Extracting zip file, deleting zip file & renaming wordpress to $domain"
	unzip -q latest.zip && rm -rf latest.zip && mv wordpress $domain
	echo "Creating database $dbname with all permissions to $uname"
	CreateDB
	echo "Changing ownership of $webroot/$domain"
	ChangeOwnerPerms
	setsebool -P httpd_can_network_connect 1
	echo "Creating VirtualHost & SSL"
	CreateVHSSL
	echo "Done, installed wordpress at https://$domain"
}
Stack-Actions ()
{
	echo -e "Options for $Stack stack\n1. Custom Static Content\n2. Git Static Content\n3. Git Dynamic Content\n4. Wordpress\n5. phpMyAdmin"
	read -p "Select content type : " contype
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
  		*)
			echo "Invalid option !"
		;;
	esac
}
read -p "Enter stack name : " Stack
if [[ $Stack == "lamp" || $Stack == "lemp" ]]; then
	InstallCheck
else
	echo "Stack $Stack doesn't exists!"
fi
