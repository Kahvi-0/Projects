#!/bin/bash

# TO add SubDomainizer, hakrawler, Sub0ver, sublister, dnsdumpster.com, massDNS, altDNS
# Add passive and active 
# Add and use all.txt

#Prep

#Note amass and assetfinder use APIkeys

#Change amass config location
amassConfig="~/.config/amass/config.ini"
url=$1

if [ ! -d "$url" ]; then
	mkdir $url
fi

if [ ! -d "$url/recon" ]; then
	mkdir $url/recon
	mkdir $url/logs
fi

#Phase 1

echo "Nomnomnomming subdomains with assetfinder...."
go get -u github.com/tomnomnom/assetfinder

~/go/bin/assetfinder $url >> $url/recon/assets.txt

cat $url/recon/assets.txt | grep $url >> $url/recon/final.txt

rm $url/recon/assets.txt


echo "Buzzing subdomains with Amass...."

amass enum -passive -d $url -log $url/logs/amass.log -config $amassConfig >> $url/recon/f.txt

#amass enum -active -brute -d $url -p 80,443,81,8443,8080 -log $url/logs/amass.log -config $amassConfig >> $url/recon/f.txt

sort -u $url/recon/f.txt >> $url/recon/final.txt
rm $url/recon/f.txt




#active
#https://medium.com/@hakluke/haklukes-guide-to-amass-how-to-use-amass-more-effectively-for-bug-bounties-7c37570b83f7
#amass ASN, might want to leave manual 

#amass intel -org "Tesla" -config ./config.ini 
# Menu item to add ASN to future commands
#Take returned ASN and remove the extra words 
#amass intel -active -asn <ASN> -whois -d <domain.com>-config ./config.ini 

#amass SSL domain grabbing
#use amass db -show -d <url.com> to obtain cidr and ASN

#amass intel -active -cider <net>/cdr

#Phase 2


echo "Probing for alive domains with httprobe...."
go get -u github.com/tomnomnom/httprobe
cat $url/recon/final.txt | sort -u | ~/go/bin/httprobe -p http:81 -p https:8443 -p https:8080 |  sed 's/https\?:\/\///' | tee -a $url/recon/a.txt

sort -u $url/recon/a.txt > $url/recon/alive.txt

rm $url/recon/a.txt


echo "Looking for sites we can subjack...."

if [ ! -d "$url/recon/potential_takeover" ]; then
	mkdir $url/recon/potential_takeover
	touch $url/recon/potential_takeover/PT.txt
fi

go get github.com/haccer/subjack
~/go/bin/subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeover/PT.txt


echo "Looking waaaaaaaaayback...."

go get github.com/tomnomnom/waybackurls
cat $url/recon/final.txt | ~/go/bin/waybackurls >> $url/recon/waybackoutput.txt
sort -u $url/recon/waybackoutput.txt > $url/recon/waybacksorted.txt
rm $url/recon/waybackoutput.txt


echo "Pulling params...."

cat $url/recon/waybacksorted.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/waybackparams.txt

for line in $(cat $url/recon/waybackparams.txt);do echo $line'=';done

# Maybe edit to pull from my list of file extensions

echo "Pulling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat $url/recon/waybacksorted.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/recon/waybackJS1.txt
		sort -u $url/recon/waybackJS1.txt >> $url/recon/waybackJS.txt
	fi
	if [[ "$ext" == "html" ]]; then
		echo $line >> $url/recon/waybackJSP1.txt
		sort -u $url/recon/waybackJSP1.txt >> $url/recon/waybackJSP.txt
	fi
	if [[ "$ext" == "json" ]]; then
		echo $line >> $url/recon/waybackJSON1.txt
		sort -u $url/recon/waybackJSON1.txt >> $url/recon/waybackJSON.txt
	fi
	if [[ "$ext" == "php" ]]; then
		echo $line >> $url/recon/waybackPHP1.txt
		sort -u $url/recon/waybackPHP1.txt >> $url/recon/waybackPHP.txt
	fi
	if [[ "$ext" == "aspx" ]]; then
		echo $line >> $url/recon/waybackASPX1.txt
		sort -u $url/recon/waybackASPX1.txt >> $url/recon/waybackASPX.txt
	fi

done

rm $url/recon/waybackJS1.txt
$url/recon/waybackJSP1.txt
rm $url/recon/waybackJSON1.txt
$url/recon/waybackPHP1.txt
$url/recon/waybackASPX1.txt

# Check live subdomains
# Find a way to potentually take over 
# Nice output of subdomains
# Amass Maltego output

amass track -d $url
