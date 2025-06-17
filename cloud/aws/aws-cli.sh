#!binbash
############################################################
#Author Bhasker Kamshetty
#Description This script Installs & configures aws cli
#Date 19th February 2024
############################################################

#Downloads aws cli binary
curl httpsawscli.amazonaws.comawscli-exe-linux-x86_64.zip -o awscliv2.zip

#Unzips aws cli binary
unzip -q awscliv2.zip

#Installs aws cli
sudo .awsinstall

#Deletes awscliv2.zip & aws
rm -rf awscliv2.zip aws

#Configures aws cli
usrlocalbinaws configure