#!/usr/bin/env bash

# Each section would generate a plain-text file containing only the version number. 
# for the PHP script to parse the information.

# Set the web server document root here (don't forget the trailing slash)
webdoc_root="/var/www/example.com/html/"


# Get the iOS version
curl -sf "https://itunes.apple.com/lookup?id=423121946" \
	| json_pp | awk -F':' '/"version"/ { print $2 }' \
	| sed 's/^\ "//' | sed 's/",//' > ${webdoc_root}convo_ios.txt


# Get the Android version
curl -sf "https://play.google.com/store/apps/details?id=com.convorelay.convomobile&hl=en_US" \
	| grep -E 'Additional Information.*Current Version' | sed 's/^.*Current Version//' | sed 's/Requires Android.*$//' \
	| sed 's/^.*class="IQ1z0d"><span class="htlgb">//' | sed 's/<.*$//' > ${webdoc_root}convo_android.txt


# Get the macOS version
curl -sf -o Convo_macOS.zip "https://d3uqp1raf0m8tp.cloudfront.net/assets/downloads/Convo_macOS.zip"
if [ -f Convo_macOS.zip ]
then
	unzip -l Convo_macOS.zip | awk '/Convo-/ { print $4 }' | sed 's/Convo-//' \
		| sed 's/.sparkle_guided.pkg//' > ${webdoc_root}convo_macos.txt
	rm Convo_macOS.zip
fi


# Get the Windows version
curl -sf -o Convo_Windows.exe "https://d3uqp1raf0m8tp.cloudfront.net/assets/downloads/Convo_Windows.exe"
if [ -f Convo_Windows.exe ]
then
	exiftool -a Convo_Windows.exe | awk -F':' '/File Version [^Number]/ { print $2 }' \
		| sed 's/^\ //' > ${webdoc_root}convo_windows.txt
	rm Convo_Windows.exe
fi
