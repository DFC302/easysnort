#!/bin/bash

# global variables
SNORT_VER="2.9.16"
DAQ_VER="2.0.7"
LOG=~/easysnort.log

# if user is not root, prompt user, exit script
function isRoot() {
	if [[ $EUID -ne 0 ]] ; then
		echo -e "Please run as root!\n"
		exit 1
	fi

}

# Create basis for log file. Rewrite log file each time.
function createLogFile() {
	touch ${LOG} ;
	OS=$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release) ;

	echo -e "Process started at $(date)\n" > ${LOG} ;
	echo -e "Operating System: ${OS}" >> ${LOG} ;
	echo -e "Snort Version Number: ${SNORT_VER}" >> ${LOG} ;
	echo -e "Daq Version Number: ${DAQ_VER}" >> ${LOG} ;
	echo -e "Snort Configuration File: /etc/snort/" >> ${LOG} ;
	echo -e "Alert File: /var/log/snort" >> ${LOG} ;
	echo -e "Log File: ${LOG}" >> ${LOG} ;
	echo -e "\n" >> ${LOG}

}

# Install dependencies needed to build Snort.
# If any dependeencies do not install, send STDERR to log file
# Dont exit script, some may fail, but are not always needed.
# If Snort fails to install, log file can provide insight on why.
function installDependencies() {
	# update the system
	echo -e "Updating System: $(date)\n" >> ${LOG} ;
	apt update -y ;


	# install dependencies
	echo "Installing dependencies: $(date)" >> ${LOG} ;
	echo "The following dependencies failed to install:" >> ${LOG} ;
	apt-get install -y flex 2>> ${LOG} ;
	apt-get install -y bison 2>> ${LOG} ;
	apt-get install -y build-essential 2>> ${LOG} ; 
	apt-get install -y libpcap-dev 2>> ${LOG} ;
	apt-get install -y libnet1-dev 2>> ${LOG} ;
	apt-get install -y libpcre3-dev 2>> ${LOG} ;
	apt-get install -y libnetfilter-queue-dev 2>> ${LOG} ; 
	apt-get install -y iptables-dev 2>> ${LOG} ;
	apt-get install -y golang-github-coreos-go-iptables-dev 2>> ${LOG} ;
	apt-get install -y libdnet 2>> ${LOG} ;
	apt-get install -y libdnet-dev 2>> ${LOG} ;
	apt-get install -y libdumbnet-dev 2>> ${LOG} ;
	apt-get install -y zlib1g-dev 2>> ${LOG} ;
	apt-get install -y libdaq-dev 2>> ${LOG} ;

	echo -e "\nDepenedencies installed: $(date)\n" >> ${LOG}
}

function grabFiles() {
	# check if files exist already
	# if they do not, download them
	if [ ! -f "daq-${DAQ_VER}.tar.gz" ]; then
		echo "Daq file version ${DAQ_VER} not found!" >> ${LOG} ;
		echo -e "Attempting to download daq file now: $(date)\n" >> ${LOG} ;
	    	wget -q "https://snort.org/downloads/snort/daq-${DAQ_VER}.tar.gz" 2>> ${LOG} ;
		
		if [ $? -ne 0 ] ; then
	    	    echo -e "EasySnort failed due to daq file version number ${DAQ_VER} not found on server!" >> ${LOG} ; \
	     	    echo -e "Check for updated daq file version on snort.org and update version number." >> ${LOG} ; \
	     	    echo "Failed at: $(date)" >> ${LOG} ;
		    exit 1
		fi
	fi

	if [ ! -f "snort-${SNORT_VER}.tar.gz" ]; then
		echo "Snort file version ${SNORT_VER} not found!" >> ${LOG} ;
		echo -e "Attempting to download snort file now: $(date)\n" >> ${LOG} ;
	    	wget -q "https://snort.org/downloads/snort/snort-${SNORT_VER}.tar.gz" 2>> ${LOG} ;
		
		if [ $? -ne 0 ] ; then
	    	    echo -e "EasySnort failed due to snort file version number ${SNORT_VER} not found on server!" >> ${LOG} ; \
	    	    echo -e "Check for updated snort file version on snort.org and update version number." >> ${LOG} ; \
	    	    echo "Failed at: $(date)" >> ${LOG} ; 
		    exit 1
		fi
	fi

	# untar both files
	tar xvfz daq-${DAQ_VER}.tar.gz ;
	tar xvfz snort-${SNORT_VER}.tar.gz ;

	# remove tar files
	rm daq-${DAQ_VER}.tar.gz
	rm snort-${SNORT_VER}.tar.gz
}

function installSnort() {
	echo -e "\nBeginning installation of daq now: $(date)\n" >> ${LOG} ;

	# make daq file
	cd daq-${DAQ_VER} ;

	# Incase aclocal or automake fail
	apt-get install automake-1.15 -y;
	#touch aclocal.m4 configure ; touch Makefile.am ; Makefile.in

	./configure ; make ; make install 2>> ${LOG} || echo "Daq failed to compile! $(date)" >> ${LOG} || exit 1

	echo -e "\nDaq was successfully configured: $(date)" >> ${LOG} ;

	# move snort file and make snort
	cd ../ ;
	mv snort-${SNORT_VER} /etc/ ;

	cd /etc/snort-${SNORT_VER} ;
	
	echo -e "\nBeginning installation of snort now: $(date)\n" >> ${LOG} ;

	./configure --enable-active-response -disable-open-appid ; make ; make install 2>> ${LOG} || echo "Snort failed to compile! $(date)" >> ${LOG} || exit 1 ;
	
	echo -e "Snort was successfully configured: $(date)\n" >> ${LOG} ;

	# update shared library cache
	echo "Updating snort shared library cache: $(date)" >> ${LOG} ;
	
	sudo ldconfig -v 2>> ${LOG} || echo "Snort shared library cache failed to update!" >> ${LOG}

	echo "Shared library cache updated: $(date)" >> ${LOG} ;

	# Create log directory for snort, if directory does not exist.
	if [ ! -d "/var/log/snort/" ]; then
		echo "Snort log directory not found!" >> ${LOG} ;
		echo "Creating directory now: $(date)" >> ${LOG} ;
	    # create directory
	    mkdir /var/log/snort ;

	    # create log file
	    if [ ! -f /var/log/snort/alert ] ; then
	    	# create file
	    	echo "Snort alert file not found!" >> ${LOG} ;
			echo "Creating alert file now: $(date)" >> ${LOG} ;
	    	touch /var/log/snort/alert
	    fi

	fi

	if [ ! -d /etc/snort/ ]; then
		echo "Snort directory not found!" >> ${LOG} ;
		echo "Creating directory now: $(date)" >> ${LOG} ;
	    # create snort folder    
	    # create rule folder
	    mkdir /etc/snort ; mkdir /etc/snort/rules
	fi

}

function defaults() {
	echo -e "\nDownloading snort default rules now: $(date)\n" >> ${LOG} ;
	
	# Download default rule sets
	cd /etc/snort/rules/; 
	apt-get install snort-rules-default -y 2>> ${LOG} ;

	# Download default configuration file
	echo "Downloading default configuration file now: $(date)" >> ${LOG} ;
	
	if wget https://raw.githubusercontent.com/DFC302/easysnort/master/snort.conf 2>> ${LOG} || \
		echo "Default snort configuration file could not be downloaded at this time!" >> ${LOG} ; 
		echo "The file can also be downloaded manually from snort.org." >> ${LOG} ; then
			:
	else
		mv snort.conf /etc/snort/

	fi
}

function testInstall() {
	# test snort
	if snort -V ; then
		echo -e "Installation successful!\n"

		echo -e "Snort configuration file can be found in /etc/snort/\n"
		echo -e "Alert file can be found in /var/log/snort/\n"

		echo -e "\nInstallation successful.\n" >> ${LOG};
		echo "Process ended at $(date)" >> ${LOG}
	else 
		echo -e "Installation failed!\n"
		echo -e "\nInstallation failed!" >> ${LOG} ;
		echo "Reason: Unknown" >> ${LOG} ;
		echo "Process ended at $(date)" >>  ${LOG} ;
		exit 1
	fi 
}

function main() {
	STARTTIME=`date +%s`
	isRoot
	createLogFile
	installDependencies
	grabFiles
	installSnort
	defaults
	testInstall
	ENDTIME=`date +%s`
	RUNTIME=$((ENDTIME-STARTTIME))
	echo -e "\nRUNTIME: $RUNTIME (seconds)" >> ${LOG}
}

main
