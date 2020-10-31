#!/bin/bash
helpscreen () {

        echo ''
        echo 'Usage web.sh <http(s)://target> <port> <bust level>'
        echo ''
        echo '-----------------------------------------------------------'
        echo 'Flags:'
        echo '	Directory bust level:   '
        echo '				-1: light'
        echo '				-2: heavy'
        echo '				-3: really heavy'
        echo ''
        echo '-----------------------------------------------------------'
        echo ''
        echo 'Used With Burp:'
        echo '  1. Routing through Burp:'
        echo '      Proxy -> Options -> Proxy Listeners -> Add'
        echo '        Binding: port: 8081  Loopback only'
        echo '        Request handling: Redirect to host: <target IP> <target port>'
        echo ''
        echo '  2. Retrieve the generated final list of discovered web resources and import to Burp'
        echo '     Find target under sitemap.  '
        echo '     Right click -> Scan -> Open scan launcher'        
        echo '     Paste the list of discovered resources into the URLs to scan box.'
        echo ''
        echo ''
        exit 2
        }
        
#Syntax checks

if ! [[ $1 =~ ^'http' ]]; then
	echo "no http"
	helpscreen
fi

if ! [ "$#" = 3 ]; then
	echo "need 3"
	helpscreen
fi

/usr/bin/echo "what is the project name?"
read project

echo -e "\n\n[+] preparing project directories and files\n\n"
/usr/bin/mkdir $project
/usr/bin/mkdir $project/directories
/usr/bin/mkdir $project/vulnScan
/usr/bin/mkdir -p $project/directories/screenshots/100
/usr/bin/mkdir -p $project/directories/screenshots/200
/usr/bin/mkdir -p $project/directories/screenshots/300
/usr/bin/mkdir -p $project/directories/screenshots/400
/usr/bin/mkdir -p $project/directories/screenshots/500
/usr/bin/mkdir -p $project/tools
/usr/bin/mkdir -p $project/tools/aquatone
/usr/bin/mkdir -p $project/logs
/usr/bin/touch $project/overview.html

# Downloading tools
git -C $project/directories/  clone https://github.com/maurosoria/dirsearch.git
git -C $project/directories/ clone https://github.com/Tuhinshubhra/CMSeeK
pip3 install -r $project/directories/CMSeeK/requirements.txt
wget https://raw.githubusercontent.com/Kahvi-0/Tools-and-Concepts/master/Toolbox/Web/wordlists/common_extensions.txt
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O $project/tools/aquatone/aquatone.zip && unzip $project/tools/aquatone/aquatone.zip -d $project/tools/aquatone/

clear -x

echo "Bitter Sweet Enumerator"


#fix 
echo "<h1>CMS details</h1>" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(Detected CMS.*)" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(........Version.*)" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(^.*vulnerabilities.*)" >> $project/overview.html

echo "<PRE>" >> $project/overview.html
whatweb -v -color=never $1:$2 >> $project/overview.html
echo "</PRE>" >> $project/overview.html


## Add specific scanners for discovered CMS

## Add results of those scanners to direcotry list / certain output to the file

## Scrape robots.txt for directories 


echo -e "\n\n[+] dirsearchings\n\n"
#light busting
if [ $3 == -1 ]; then
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -e extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt  | sort -u >  $project/directories/FinalList.txt
fi

#heavy busting
if [ $3 == -2 ]; then
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -e extensions.txt -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
echo -e "\n\n[+] directory-list-2.3-medium.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs2.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt $project/directories/dirs2.txt | sort -u >  $project/directories/FinalList.txt
fi

#really heavy busting
if [ $3 == -3 ]; then
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -e extensions.txt -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
echo -e "\n\n[+] directory-list-2.3-medium.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs2.txt
echo -e "\n\n[+] directory-list-lowercase-2.3-medium.txt\n\n"
python3 $project/directories/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs3.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt $project/directories/dirs2.txt $project/directories/dirs3.txt | sort -u >  $project/directories/FinalList.txt
fi


echo -e "\n\n[+] Sorting results\n\n"
#sort results into seperate files by status
cat $project/directories/FinalList.txt | grep ^"1" | grep -oP "((?=http).*)" > $project/directories/100status.txt
cat $project/directories/FinalList.txt | grep ^"2" | grep -oP "((?=http).*)" > $project/directories/200status.txt
cat $project/directories/FinalList.txt | grep ^"3" | grep -v "REDIRECTS TO: " | grep -oP "((?=http).*)" > $project/directories/300status.txt
cat $project/directories/FinalList.txt | grep ^"4" | grep -oP "((?=http).*)" > $project/directories/400status.txt
cat $project/directories/FinalList.txt | grep ^"5" | grep -oP "((?=http).*)" > $project/directories/500status.txt

#Screenshots from aquatone
echo -e "\n\n[+] Grabbing screenshots using aquatone\n\n"
cat $project/directories/*status.txt | $project/tools/aquatone/aquatone -silent -ports $2 -out $project


# Vulnerability scan section. Expand on later
#echo -e "\n\n[+] Running some vulnerability scanners\n\n"
#nikto -h $1 > $project/vulnScan/nikto.txt || echo "\nError with nikto\n" 
#cat $project/vulnScan/nikto.txt >> $project/overview.html



clear -x
echo ''
echo "Web enumeration completed for $1"
echo "Output file found in $project/overview.html"
echo "List of all discovered directories found here: $project/directories/FinalList.txt"

# Option to open all result pages 

sensible-browser $project/overview.html $project/aquatone_report.html#/pages/single $project/directories/FinalList.txt 

#clean up section
echo -e "\n\n[+] Cleaning up\n\n"
rm -f $project/directories/dirs.txt
rm -f $project/directories/dir2.txt
rm -rf $project/directories/webscreenshot
rm -rf $project/directories/dirsearch
rm ./common_extensions.txt
