#!/bin/bash

# CONSTANTS
TARGET=$1
FILETYPES=("doc" "docx" "xls" "xlsx" "pdf" "sql" "txt")
HUNTER_API=""
GREEN="\e[1;32m"
RED="\e[1;31m"
END="\e[0m"

banner () {

	echo "##################################"
	echo "            InfoHunter            "
	echo "##################################"
}

usage () {

	banner

	echo -e " Usage: ./infohunter.sh <target>\n"

	exit 0
}

hunt_robots() {
	# Search robots.txt
	echo "[*] Searching for robots.txt..."

	wget -q $TARGET/robots.txt -O $TARGET-robots.txt

	if [[ $? -eq 0 ]]; then

		echo -e "$GREEN[+] Robots.txt found! Printing it...$END\n"

		echo -e "$GREEN----------- ROBOTS.TXT -----------$END\n"

		cat $TARGET-robots.txt

		rm $TARGET-robots.txt

		echo -e "\n$GREEN-------------- FIN ---------------$END"

	else

		echo -e "$RED[-] Couldn't find robots.txt!$END"

	fi
}

hunt_emails(){
	# Finding emails
	echo -e "\n[*] Finding emails..."
	
	hasmails=$(curl -s -k "https://api.hunter.io/v2/domain-search?domain=$TARGET&api_key=$HUNTER_API"| jq '.["data"].emails[].value' | cut -d '"' -f 2)

	if [[ $hasmails != "" ]]; then
		
		echo -e "$GREEN[+] Emails found!$END\n"
		
		echo -e "$GREEN----------- EMAILS -----------$END\n"

		curl -s -k "https://api.hunter.io/v2/domain-search?domain=$TARGET&api_key=$HUNTER_API" | jq '.["data"].emails[].value' | cut -d '"' -f 2

		echo -e "\n$GREEN------------ FIN -------------$END"

	else

		echo -e "$RED[-] No emails found!$END"

	fi
}

hunt_leaks(){
	# Search leaks on pastebin
	echo -e "\n[*] Searching in pastebin..."
	
	pastes=$(lynx --dump "https://google.com.br/search?q=site:pastebin.com+\"$TARGET\"" | cut -d "?" -f2 | grep http | cut -d "=" -f 2 | grep -v google | sed 's/...$//' | wc -l)
	
	is_block=$(lynx --dump "https://google.com.br/search?q=site:pastebin.com+\"$TARGET\"" | grep -i "unusual traffic")

	if [[ $is_block != "" ]]; then
		#statements
		echo -e "$RED[-] Sorry, google has blocked your IP!$END"
		
		echo -e "\n[-] Change your address or try again later. Bye!"
		
		exit 1

	fi

	if [[ $pastes -gt 0 ]]; then

		echo -e "$GREEN----------- LEAKS -----------\n$END"

		echo -e "$GREEN[+] Pastes found! Printing it...$END\n"

		lynx --dump "https://google.com.br/search?q=site:pastebin.com+\"$TARGET\"" | cut -d "?" -f2 | grep http | cut -d "=" -f 2 | grep -v google | grep -v $TARGET | sed 's/...$//'

		echo -e "\n$GREEN------------- FIN --------------$END"

	else

			echo "$RED[-] No pastes found!$END"

	fi

}

hunt_files(){
	# counter
	counter=0
	
	# Search archives in domain
	echo -e "\n[*] Searching files..."
	
	# Verify dir existence
	rootdir=$(ls | grep ihunter_files)

	if [[ $? -ne 0 ]]; then
		mkdir ihunter_files 2> /dev/null
	fi

	targetdir=$(ls ihunter_files | grep $TARGET)

	if [[ $? -ne 0 ]]; then
		mkdir ihunter_files/$TARGET 2> /dev/null
	fi

	for type in "${FILETYPES[@]}"; do

		if [[ $(lynx --dump "https://google.com/search?q=site:$TARGET+filetype:$type" | grep "$type" | cut -d "=" -f2 | grep http | grep -v google | sed 's/...$//') ]]; then

			echo -e "$GREEN[+] $type file found!$END"
			wget -q -O ihunter_files/$TARGET/file_$counter.$type $(lynx --dump "https://google.com/search?q=site:$TARGET+filetype:$type" | grep "$type" | cut -d "=" -f2 | grep http | grep -v google | sed 's/...$//')
			((counter=counter+1))
		else
			echo -e "$RED[-] $type file not found.$END"
		fi
					
	done
}

hunt_meta(){

	# Analysing metadata of downloaded files
	echo -e "\n[*] Analysing files metadata..."
	
	for file in ihunter_files/$TARGET/*; do
	
		echo -e "\n[*] File $file:"
	
		exiftool $file
	
		echo
	
	done

}

main(){
	
	if [[ $# -eq 0 ]]; then
	
		usage
	
	else	
	
		banner
	
		echo -e "\n\nGathering information about $TARGET:"
	
		echo
	
		hunt_robots

		hunt_emails

		hunt_leaks

		hunt_files
	
		hunt_meta

	fi
}

main $1