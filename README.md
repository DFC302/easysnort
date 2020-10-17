# easysnort

![Snort success](https://github.com/DFC302/easysnort/blob/master/images/snort.png)

Bash script to easily install snort from scratch.

# Installation

--Using GIT--

git clone https://github.com/DFC302/easysnort.git \
cd easysnort/ \
Change SNORT_VER and DAQ_VER variables to appropriate versions on snorts website here: https://www.snort.org/downloads
chmod 755 install_snort.sh \
run as root.

--Zip install--

Click on clone or download \
Click download as ZIP \
Save file \
Go to Downloads Folder and click extract here or unzip easysnort-master.zip \
cd easysnort-master \
chmod 755 install_snort.sh \
./install_snort.sh (as root)

Log files are kept in /var/log/snort

Rule files are kept in /etc/snort/rules

# Author
Written and Coded By Matthew Greer
