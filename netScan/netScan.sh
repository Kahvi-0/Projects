#!/bin/bash


if [[ $# -lt 1 ]]; then
	echo "Usage netScan.sh <target> <option>"
	echo ""
	echo "Target can be IP or subent"
	echo "Example: 10.10.10.0/24"
	echo -e "\n"
	echo "No flags runs a TCP full host and service discovery on all ports"
	echo -e "\n"
	echo "Flags:"
	echo "vuln       Run vulnerability scan using the NSE vuln script"
	echo "udp        Run a UDP port scan"
	echo "hd         Runs host discovery options"	
	echo ""
	exit 2
fi

if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]|\/[0-9]{1,2}+$ ]]; then
	echo "Starting"
else
	echo "First argument must be an IP address"
	exit 2

fi


if [[ $2 == vuln ]]; then

	sudo nmap -Pn -n -p- --script vuln -oA $1 -oN "vuln2.txt"
fi

if [[ $2 == udp ]]; then

	echo -e "[+] Scanning for top 1000 UDP ports for $1 \n\n\n"
	sudo nmap -Pn -sU -n -sV $1 -oN "UDPports.txt"
fi

if [[ $2 == hd ]]; then

	echo -e "[+] Using nmap to discover hosts $1 \n\n\n"
	sudo nmap -sn -O $1 -oN "hosts.txt"
fi




echo -e "[+] All scan for all TCP ports for $1 \n\n\n"
sudo nmap -Pn -sV -p- -T4 -A $1 -oN "TCPports.txt"
