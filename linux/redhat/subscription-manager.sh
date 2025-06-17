#!/bin/bash
############################################################
#Author: Bhasker Kamshetty
#Description: This script adds subscription to RHEL.
#Date: 6th February 2024
############################################################

#Removes Existing Subscriptions
echo "Removing Existing Subscriptions"
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean

#Registers System to Entitlement Server
echo "Registering System to Entitlement Server"
subscription-manager register
subscription-manager refresh
subscription-manager attach --auto

#Conclusion
echo "Done."
