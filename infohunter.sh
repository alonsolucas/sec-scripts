#!/bin/bash

TARGET=$1
FILETYPES=("doc" "docx" "xls" "xlsx" "pdf" "sql" "txt")

usage () {
	echo "##################################"
	echo "            InfoHunter            "
	echo "##################################"
	echo -e " Usage: ./infohunter.sh <target>\n"
	exit 0
}


if [[ $# -eq 0 ]]; then
	#statements
	usage
else
	echo "##################################"
	echo "            InfoHunter            "
	echo "##################################"
	echo -e "\n\nGathering information about $TARGET:"
	echo

	# Search robots.txt
	echo "[*] Searching for robots.txt..."
	wget -q $TARGET/robots.txt -O $TARGET-robots.txt
	if [[ $? -eq 0 ]]; then
		#statements
		echo -e "[+] Robots.txt found! Printing it...\n"
		cat $TARGET-robots.txt
		rm $TARGET-robots.txt
	else
		echo "[-] Couldn't find robots.txt!"
	fi

	# Finding emails
	echo -e "\n[*] Finding emails with hunter.io..."
	hasmails=$(curl --silent -m2 -k "https://api.hunter.io/v2/domain-search?domain=$1&api_key=a1ab2c7a810a1162854c2069e7f6b0288f4ce643"| grep value | cut -d '"' -f 4 | wc -l)
	if [[ hasmails -gt 0 ]]; then
		#statements
		curl --silent -m2 -k "https://api.hunter.io/v2/domain-search?domain=$1&api_key=a1ab2c7a810a1162854c2069e7f6b0288f4ce643"| grep value | cut -d '"' -f 4
	else
		echo "[-] No emails found!"
	fi
	
	# Search leaks on pastebin
	echo -e "\n[*] Searching in pastebin..."
	pastes=$(lynx --dump "https://google.com.br/search?q=site:pastebin.com+\"$TARGET\"" | cut -d "?" -f2 | grep http | cut -d "=" -f 2 | grep -v google | sed 's/...$//' | wc -l)

	if [[ $pastes -gt 0 ]]; then
		#statements
		echo -e "[+] Pastes found! Printing it...\n"
		lynx --dump "https://google.com.br/search?q=site:pastebin.com+\"$TARGET\"" | cut -d "?" -f2 | grep http | cut -d "=" -f 2 | grep -v google | grep -v $TARGET | sed 's/...$//'
		else
			echo "[*] Finding emails..."

			echo "[-] No pastes found!"
	fi

	# Search archives in domain
	echo -e "\n[*] Searching files..."
	
	# Verify dir existence
	rootdir=$(ls | grep ihunter_files)

	if [[ $? -ne 0 ]]; then
		#statements
		mkdir ihunter_files 2> /dev/null
	fi

	targetdir=$(ls ihunter_files | grep $TARGET)

	if [[ $? -ne 0 ]]; then
		#statements
		mkdir ihunter_files/$TARGET 2> /dev/null
	fi

	counter=0
	
	for type in "${FILETYPES[@]}"; do
		#statements

		if [[ $(lynx --dump "https://google.com/search?q=site:$TARGET+filetype:$type" | grep "$type" | cut -d "=" -f2 | grep http | grep -v google | sed 's/...$//') ]]; then
			#statements
			echo "[+] $type file found!"
			wget -q -O ihunter_files/$TARGET/file_$counter.$type $(lynx --dump "https://google.com/search?q=site:$TARGET+filetype:$type" | grep "$type" | cut -d "=" -f2 | grep http | grep -v google | sed 's/...$//')
			((counter=counter+1))
		else
			echo "[-] $type file not found."
		fi
					
	done

	# Analysing metadata of downloaded files
	echo -e "\n[*] Analysing files metadata..."
	for file in ihunter_files/$TARGET/*; do
		#statements
		echo -e "\n[*] File $file:"
		exiftool $file
		echo
	done

fi

