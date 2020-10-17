# easysnort
#Introduction--
Snort is a packet sniffer that monitors network traffic in real time, scrutinizing each packet closely to detect a dangerous payload or suspicious anomalies. Snort is based on libpcap (for library packet capture), a tool that is widely used in TCP/IP traffic sniffers and analyzers

![Snort success](https://github.com/DFC302/easysnort/blob/master/images/snort.png)

Bash script to easily install snort from scratch.

# Installation
```
git clone https://github.com/DFC302/easysnort.git
cd easysnort/
```
Change SNORT_VER and DAQ_VER variables to appropriate versions on snorts website here: https://www.snort.org/downloads
```
chmod 755 install_snort.sh
```
run as root.

Log files are kept in /var/log/snort

Rule files are kept in /etc/snort/rules

# Author
Written and Coded By Matthew Greer
