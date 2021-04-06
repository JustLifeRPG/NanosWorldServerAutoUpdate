#!/bin/bash
serverpath=/home/nanosworld
download_filename='NanosWorldServer'
server_filename='NanosWorldServer'
version_filename='version'
cmd_startserver="sudo service nanosworld start"
cmd_stopserver="sudo service nanosworld stop"


current_version="unknown"
echo "Nanos World Server - Auto Update Script"
echo "Version 0.0.1 by MarkusSR1984"
echo "-----------------------------------------------------"
echo "Checking for new Version..."

latest_version=$(curl -Ls -m 30 -o /dev/null -w %{url_effective} https://github.com/nanos-world/nanos-world-server/releases/latest);

# make sure the connection was successful
if [ $? -ne 0 ]; then
    echo "Error checking for latest version. Script exiting."
    exit 20
fi;

if [ -f "$serverpath/$version_filename" ]; then
    current_version=$(cat $serverpath/$version_filename)
fi

latest_version=$(echo "$latest_version" | awk -F "/" '{print $NF}' )

download_url=https://github.com/nanos-world/nanos-world-server/releases/download/$(echo $latest_version)/$(echo $download_filename)
latest_download_path=/tmp/$(echo $download_filename)_$(echo $latest_version)

# see if the latest version is installed (do the versions match?)
if [ $current_version == $latest_version ] ; then
    echo "NanosWorldServer is up to date."
    echo "Installed Version: $current_version"
    echo
    echo "Exiting."
else
    echo "NanosWorldServer update available."
    echo "Installed Version: $current_version"
    echo "Latesst Version:   $latest_version"
    echo
    echo "Attempting to download update."
    # download with a 5 minute timeout period
    curl -Ls -o $latest_download_path -m 300 $download_url
    
    # see if download was successful
    if [ $? -ne 0 ]; then
        #failed
        echo
        echo "Download failed, cleaning up parital download and exiting."
        rm $latest_download_path
        exit 30
    fi
    # success, install
    echo
    echo "Download success."
    echo "Stopping NanosWorldServer"
    eval $cmd_stopserver
    echo "Installing..."
    rm $serverpath/$server_filename
    mv $latest_download_path $serverpath/$server_filename
    chmod +x $serverpath/$server_filename
    echo $latest_version > $serverpath/$version_filename
    echo "Starting NanosWorldServer"
    eval $cmd_startserver
    echo "Update success."
fi