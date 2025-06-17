#!/bin/bash
##############################################################
#Author: Bhasker Kamshetty
#Description: This script simplifies the usage of ex command
#Date: 13th February 2024
#Usage: ./ex.sh filename line-number operation content
#Takes 4 command line arguments
#Example: ./ex.sh a.txt 3 insert "Added at 3 line"
##############################################################

ex $1 <<eof
$2 $3
$4
.
xit
eof
