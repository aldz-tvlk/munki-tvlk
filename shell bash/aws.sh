#!/bin/bash

# Mendapatkan user yang sedang login
loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

# Validasi user
if [ -z "$loggedInUser" ] || [ ! -d "/Users/$loggedInUser" ]; then
    echo "Invalid user or home directory not found."
    exit 1
fi

# Path folder .aws
awsPath="/Users/$loggedInUser/.aws"

# Mengecek apakah folder .aws ada
if [ -d "$awsPath" ]; then
    echo "Folder .aws ditemukan di $awsPath"
    
    # Mengubah permission menjadi read & write untuk user (tanpa permission "Custom")
    chmod -R 700 "$awsPath"

    # Mengubah owner ke user yang sedang login
    chown -R "$loggedInUser":staff "$awsPath"

    echo "Permission untuk .aws telah diubah menjadi read & write (tanpa 'Custom') untuk $loggedInUser."
else
    echo "Folder .aws tidak ditemukan untuk user $loggedInUser."
fi