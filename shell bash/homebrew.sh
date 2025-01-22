#!/bin/bash

loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

# Validate the user
if [ -z "$loggedInUser" ] || [ ! -d "/Users/$loggedInUser" ]; then
    echo "Invalid user or home directory not found."
    exit 1
fi

zshrcPath="/Users/$loggedInUser/.zshrc"

# Detect the chip type (Apple Silicon or Intel)
if sysctl -n machdep.cpu.brand_string | grep -q "Apple"; then
    homebrewPath="export PATH=\$PATH:/opt/homebrew/bin"
else
    homebrewPath="export PATH=\$PATH:/usr/local/bin"
fi

# Ensure the .zshrc file exists
if [ ! -f "$zshrcPath" ]; then
    touch "$zshrcPath"
    chown "$loggedInUser":staff "$zshrcPath"  # Set ownership to the logged-in user
    chmod 600 "$zshrcPath"                   # Set permission for the file
    echo ".zshrc file created with proper permissions."
else
    # Check if the logged-in user owns the file
    fileOwner=$(stat -f "%Su" "$zshrcPath")
    if [ "$fileOwner" != "$loggedInUser" ]; then
        chown "$loggedInUser":staff "$zshrcPath"  # Fix ownership
        chmod 600 "$zshrcPath"                   # Ensure proper permissions
        echo "Fixed ownership and permissions for $zshrcPath."
    else
        echo "$zshrcPath already has correct ownership."
    fi
fi

# Add the path if it doesn't already exist
if ! grep -Fxq "$homebrewPath" "$zshrcPath"; then
    echo -e "\n$homebrewPath" >> "$zshrcPath"
    echo "Path $homebrewPath has been successfully added to $zshrcPath."
else
    echo "Path $homebrewPath already exists in $zshrcPath."
fi
