#!/bin/bash
########################################################################
#Author: Bhasker Kamshetty
#Description: This script installs node-js-server with certbot in RHEL.
#Date: 13th February 2024
########################################################################

#Installs node-js server
dnf module install nodejs:22/common
dnf install nodejs npm -y
