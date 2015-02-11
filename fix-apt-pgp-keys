#!/bin/bash

echo "This script will add missing keys for apt repositories"
echo "If you are still missing some keys after running this script"
echo "re-run the script with the hex key signature: $0 1234567890ABCDEF"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $1
