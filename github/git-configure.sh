#!/bin/bash
##############################################################################
#Author: Bhasker Kamshetty
#Description: This script configures git
#Date: 19th February 2024
#Usage: ./git-configure.sh "Full Name" emailid
#Takes 2 command line arguments
#Example: ./git-configure.sh "FirstName LastName" "yourname@email.com"
##############################################################################

#Configures Git
git config --global user.name "$1"
git config --global user.email "$2"
git config --global init.defaultBranch main
git config --global core.editor code
cat ~/.gitconfig
