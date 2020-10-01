# easysnort
#Introduction--
Snort is a packet sniffer that monitors network traffic in real time, scrutinizing each packet closely to detect a dangerous payload or suspicious anomalies. Snort is based on libpcap (for library packet capture), a tool that is widely used in TCP/IP traffic sniffers and analyzers

![Snort success](https://github.com/DFC302/easysnort/blob/master/images/snort.png)

Bash script to easily install snort from scratch.

# Installation

--Using GIT--

git clone https://github.com/DFC302/easysnort.git \
cd easysnort/ \
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
