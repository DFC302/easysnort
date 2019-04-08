#!/bin/bash

# This script will attempt to install and compile snort from source
# This script will enable active response
# This script will create the directories and files needed for snort
# to properly log and store files

# Please run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "\nPlease run as root!\n"
    exit 1
fi

# make sure system is up to date
apt-get update -y

# install necessary files
apt-get -y install flex bison build-essential libpcap-dev libnet1-dev libpcre3-dev libnetfilter-queue-dev iptables-dev libdnet libdnet-dev libdumbnet-dev zlib1g-dev

# check if files exist already
# if they dont, grab them
if [ ! -f "daq-2.0.6.tar.gz" ]; then
    wget https://snort.org/downloads/snort/daq-2.0.6.tar.gz
fi

if [ ! -f "snort-2.9.12.tar.gz" ]; then
    wget https://snort.org/downloads/snort/snort-2.9.12.tar.gz
fi

# untar both files
tar xvfz daq-2.0.6.tar.gz
tar xvfz snort-2.9.12.tar.gz

# remove tar files
rm daq-2.0.6.tar.gz
rm snort-2.9.12.tar.gz

# cd into directory, make daq
cd daq-2.0.6
./configure; make; make install

# cd back to home
cd ../

# cd into snort directory, make snort
cd snort-2.9.12
./configure --enable-active-response -disable-open-appid; make; make install

# cd back home
cd ../

# update shared library cache
ldconfig

# test snort
snort -V

# if directory does not exist
# create directory
if [ ! -d "/var/log/snort/" ]; then
    # create directory
    #cd /var/log/; mkdir snort
    mkdir /var/log/snort

fi

# Create alert file to log alerts for snort
touch /var/log/snort/alert

# if directory does not exists
# create directory
if [ ! -d "~/etc/snort/" ]; then
    # create snort folder    
    # create rule folder
    mkdir /root/etc/snort; mkdir /root/etc/snort/rules; touch snort.conf
fi

echo -e "\nFinished!\n"
