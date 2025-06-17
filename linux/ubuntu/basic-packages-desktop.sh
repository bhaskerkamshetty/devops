#!/bin/bash
#####################################################################
#Author: Bhasker Kamshetty
#Description: This script installs basic packages for Ubuntu Desktop
#Date: 20th February 2024
#####################################################################

echo "Adding Repositories"
add-apt-repository universe
apt-add-repository ppa:cubic-wizard/release
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6494C6D6997C215E
add-apt-repository ppa:obsproject/obs-studio
add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
add-apt-repository ppa:nilarimogard/webupd8
add-apt-repository ppa:tsbarnes/indicator-keylock

echo "Installing Sublime Text"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
apt-get install sublime-text -y

echo "Installing Gdebi"
apt-get install gdebi -y

echo "Installing Flatpak"
apt-get install flatpak gnome-software-plugin-flatpak -y

echo "Installing Ubuntu Restricted Extras"
apt-get install ubuntu-restricted-extras -y

echo "Installing Preload"
apt-get install preload -y

echo "Installing Cubic"
apt-get install cubic -y

echo "Installing Gnome Tweaks"
apt-get install gnome-tweak-tool tlp tlp-rdw net-tools -y

echo "Installing Indicator Keylock"
apt install indicator-keylock -y

echo "Installing Timeshift"
apt-get install timeshift -y

echo "Installing GParted"
apt-get install gparted -y

echo "Installing Remmina"
apt-get install remmina -y

echo "Installing 7Zip"
apt-get install p7zip-full -y

echo "Installing Audacity"
apt-get install audacity -y

echo "Installing BleachBit"
apt-get install bleachbit -y

echo "Installing Inkscape"
apt-get install inkscape -y

echo "Installing OBS Studio"
apt-get install ffmpeg obs-studio -y

echo "Installing qBittorrent"
apt-get install qbittorrent -y

echo "Installing VLC Media Player"
apt-get install vlc -y

echo "Installing Shotwell"
apt-get install shotwell -y

echo "Installing Samba File Sharing"
apt-get install samba samba-common-bin -y

echo "Installing WOEUSB"
apt-get install woeusb -y

echo "Installing GIMP Image Editor"
flatpak install https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

echo "Removing Bloatware"
apt-get remove --purge deja-dup* -y
apt-get remove --purge aisleriot* -y
apt-get remove --purge gnome-sudoku* -y
apt-get remove --purge gnome-mahjongg* -y
apt-get remove --purge gnome-mines* -y
apt-get remove --purge evince* -y
apt-get remove --purge eog* -y
apt-get remove --purge libreoffice* -y
apt-get remove --purge rhythmbox* -y
apt-get remove --purge totem* -y
apt-get remove --purge transmission* -y
apt-get remove --purge yelp* -y
rm /usr/share/applications/bleachbit-root.desktop
rm /usr/share/applications/display-im6.q16.desktop

echo "Clearing APT Cache"
apt-get autoremove -y
apt-get autoclean -y
apt-get clean -y

echo "Installing java"
mkdir /usr/java/
mv java.tar.gz /usr/java/
cd /usr/java/
tar -xvf java.tar.gz
rm java.tar.gz
subl /etc/profile
: <<'MODIFY'
JAVA_HOME=/usr/java/jdk1.8.0_281
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export PATH
MODIFY
. /etc/profile
update-alternatives --install "/usr/bin/java" "java" "/usr/java/jdk1.8.0_281/bin/java" 1
update-alternatives --install "/usr/bin/javac" "javac" "/usr/java/jdk1.8.0_281/bin/javac" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/java/jdk1.8.0_281/bin/javaws" 1
update-alternatives --set java /usr/java/jdk1.8.0_281/bin/java
update-alternatives --set javac /usr/java/jdk1.8.0_281/bin/javac
update-alternatives --set javaws /usr/java/jdk1.8.0_281/bin/javaws
