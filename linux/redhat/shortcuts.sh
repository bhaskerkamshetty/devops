#!/bin/bash
############################################################
#Author: Bhasker Kamshetty
#Description: This is a command shortcut scripts for RHEL.
#Date: 9th February 2024
############################################################
TaskHostname ()
{
	read -p "Enter New Hostname : " hn
 	hostnamectl set-hostname $hn
	exec bash
}
TaskTimezone ()
{
	read -p "Enter New Timezone : " tz
	timedatectl set-timezone $tz
}
TaskUsers ()
{
	echo "1. USER - ADD"
	echo "2. USER - LOCK"
 	echo "3. USER - UNLOCK"
	echo "4. USER - RENAME"
 	echo "5. USER - DELETE"
  	read -p "Select your option: " seluser
   	case $seluser in
    		"1")
			read -p "Enter Username: " username
   			useradd $username
			passwd $username
   		;;
     		"2")
			read -p "Enter Username: " username
   			usermod -L $username
      		;;
		"3")
  			read -p "Enter Username: " username
     			usermod -U $username
		;;
  		"4")
    			read -p "Enter Old Username: " oldusername
       			read -p "Enter New Username: " newusername
	  		usermod $oldusername -l $newusername
     			groupmod -n $newusername $oldusername
			mv /home/$oldusername /home/$newusername
   			usermod $newusername -d /home/$newusername
      		;;
		"5")
  			read -p "Enter Username: " username
     			userdel -f -r $username
		;;
  		*)
    			echo "Not a valid option"
       		;;
	 esac
}
TaskSSH ()
{
	read -p "Enter IP Address: " ip
	read -p "Enter OpenSSH Key Path: " key
	read -p "Enter Username: " username
	ssh -i $key $username@$ip
}
TaskRSYNC ()
{
	echo "1. RSYNC Local - Local"
	echo "2. RSYNC Local - Remote"
	echo "3. RSYNC Remote - Local"
 	read -p "Select your option: " selrsync
  	case $selrsync in
   	"1")
    		read -p "Enter Source File / Directory Names: " locpath
      		read -p "Enter Remote File / Directory Names: " rempath
		rsync -r -d $locpath $rempath
  	;;
   	"2")
    		read -p "Enter Local File / Directory Names: " locpath
      		read -p "Enter Remote Username: " remuser
		read -p "Enter Remote Host IP: " remip
  		read -p "Enter Remote Path: " rempath
    		rsync -d -r $locpath $remuser@$remip:$rempath
      	;;
       "3")
       		read -p "Enter Remote Username: " remuser
	 	read -p "Enter Remote Host IP: " remip
   		read -p "Enter Remote Path: " rempath
     		read -p "Enter Local Directory Path: " locpath
       		rsync -d -r $remuser@$remip:$rempath $locpath
	;;
 	*)
  		echo "Not a valid option"
    esac
}
TaskSCP ()
{
	echo "1. SCP Local - Remote"
 	echo "2. SCP Remote - Local"
  	echo "3. SCP Remote - Remote"
   	read -p "Select your option: " selscp
    	case $selscp in
     	"1")
        	read -p "Enter Local File / Directory Names: " locpath
        	read -p "Enter Remote Username: " remuser
        	read -p "Enter Remote Host IP: " remip
        	read -p "Enter Remote Path: " rempath
        	scp -d -r $locpath $remuser@$remip:$rempath
        ;;
        "2")
        	read -p "Enter Remote Username: " remuser
      		read -p "Enter Remote Host IP: " remip
        	read -p "Enter Remote Path: " rempath
        	read -p "Enter Local Directory Path: " locpath
        	scp -d -r $remuser@$remip:$rempath $locpath
        ;;
        "3")
        	read -p "Enter Source Username: " souruser
        	read -p "Enter Source Host IP: " sourip
        	read -p "Enter Source Path: " sourpath
        	read -p "Enter Destination Username: " destuser
        	read -p "Enter Destination Host IP: " destip
        	read -p "Enter Destination Path: " destpath
        	scp -d -r $souruser@$sourip:$sourpath $destuser@$destip:$destpath
        ;;
        *)
        	echo "Not a valid option"
	;;
        esac
}
echo "1. Change Hostname"
echo "2. Change Timezone"
echo "3. Users"
echo "4. SSH"
echo "5. RSYNC"
echo "6. SCP"
read -p "Select option: " selopt
case $selopt in
        "1")
		TaskHostname
        ;;
        "2")
		TaskTimezone
        ;;
        "3")
		TaskUsers
        ;;
	"4")
		TaskSSH
	;;
        "5")
		TaskRSYNC
        ;;        
	"6")
 		TaskSCP
        *)
	        echo "Not a valid option"
        ;;
esac
