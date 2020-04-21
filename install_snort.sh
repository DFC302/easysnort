#!/bin/bash

# Tested on Ubuntu 16.04 and 18.04 server editions.

# This script will attempt to install and compile snort from source
# This script will enable active response
# This script will create the directories and files needed for snort
# to properly log and store files

function isRoot() {
	# Please run as root
	if [[ $EUID -ne 0 ]]; then
    	echo -e "\nPlease run as root!\n"
    	exit 1
	fi
}

function checkDependencies() {
	# update the system
	apt-get update -y ;

	# install dependencies
	apt install -y flex ;
	apt install -y bison ;
	apt install -y build-essential ; 
	apt install -y libpcap-dev ;
	apt install -y libnet1-dev ;
	apt install -y libpcre3-dev ;
	apt install -y libnetfilter-queue-dev ; 
	apt install -y iptables-dev ;
	apt install -y libdnet ;
	apt install -y libdnet-dev ;
	apt install -y libdumbnet-dev ;
	apt install -y zlib1g-dev ;

	# Move into tmp directory
	cd /tmp/

	# check if files exist already
	# if they dont, grab them
	if [ ! -f "daq-2.0.6.tar.gz" ]; then
	    wget https://snort.org/downloads/snort/daq-2.0.6.tar.gz
	fi

	if [ ! -f "snort-2.9.13.tar.gz" ]; then
	    wget https://snort.org/downloads/snort/snort-2.9.15.1.tar.gz
	fi

	# untar both files
	tar xvfz daq-2.0.6.tar.gz
	tar xvfz snort-2.9.15.1.tar.gz

	# remove tar files
	rm daq-2.0.6.tar.gz
	rm snort-2.9.15.1.tar.gz
}

function installSnort() {
	# cd into directory, make daq
	cd daq-2.0.6
	./configure; make; make install

	# Place snort in /etc/ directory
	cd /etc/ ; mv /tmp/snort-2.9.15.1 /etc/

	# cd into snort directory, make snort
	cd snort-2.9.15.1
	./configure --enable-active-response -disable-open-appid; make; make install

	# update shared library cache
	ldconfig

	# if directory does not exist
	# create directory
	if [ ! -d "/var/log/snort/" ]; then
	    # create directory
	    #cd /var/log/; mkdir snort
	    mkdir /var/log/snort

	fi
}

function createDir() {
	# if directory does not exist
	# create directory
	if [ ! -d "/var/log/snort/" ]; then
	    # create directory
	    #cd /var/log/; mkdir snort
	    mkdir /var/log/snort

	fi

	# Create alert file to log alerts for snort
	touch /var/log/snort/alert

	# cd back to /etc/ directory
	cd /etc/

	# if directory does not exists
	# create directory
	if [ ! -d /etc/snort/ ]; then
	    # create snort folder    
	    # create rule folder
	    mkdir /etc/snort; mkdir /etc/snort/rules
	fi

}

function defaults() {
	# Download default rule sets
	cd /etc/snort/rules/; apt install snort-rules-default -y

	# Download default configuration file
	wget https://raw.githubusercontent.com/DFC302/easysnort/master/snort.conf

	mv snort.conf /etc/snort/
}

function testInstall() {
	# clear the screen
	#clear

	# test snort
	if snort -V ; then
		echo -e "Installation successful!\n"

		echo -e "Snort configuration file can be found in /etc/snort/\n"
		echo -e "Alert file can be found in /var/log/snort/\n"
	else 
		echo -e "Installation failed!\n"
		exit 1
	fi 
}

function main() {
	isRoot
	checkDependencies
	installSnort
	createDir
	defaults
	testInstall
}

main
