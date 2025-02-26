#!/bin/bash

# Dapatkan user yang sedang login
loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
USER_HOME="/Users/$loggedInUser"

# Fungsi untuk mengecek apakah aplikasi terinstal
is_installed() {
    [ -d "$1" ]
}

# Fungsi untuk menghapus aplikasi dengan path yang diberikan
remove_app() {
    local app_name="$1"
    shift
    echo "\n=== Menghapus $app_name ==="
    
    for path in "$@"; do
        expanded_path="${path//~/$USER_HOME}"
        if [ -e "$expanded_path" ]; then
            sudo rm -rf "$expanded_path"
            echo "Menghapus: $expanded_path"
        fi
    done
    echo "$app_name berhasil dihapus."
}

# Menghapus Slack
if is_installed "/Applications/Slack.app"; then
    echo "Slack ditemukan, menghapus..."
    pkill Slack
    remove_app "Slack" \
        "/Applications/Slack.app" \
        "/Users/$loggedInUser/Library/Application Support/Slack" \
        "/Users/$loggedInUser/Library/Caches/com.tinyspeck.slackmacgap" \
        "/Users/$loggedInUser/Library/Containers/com.tinyspeck.slackmacgap" \
        "/Users/$loggedInUser/Library/Preferences/com.tinyspeck.slackmacgap.plist" \
        "/Users/$loggedInUser/Library/Saved Application State/com.tinyspeck.slackmacgap.savedState" \
        "/Users/$loggedInUser/Library/Logs/Slack" \
        "/Users/$loggedInUser/Library/PreferencesByHost/com.tinyspeck.slackmacgap.*"
else
    echo "Slack tidak ditemukan, melewati langkah ini."
fi

# Menghapus Pulse Secure
if is_installed "/Library/Application Support/Pulse Secure/Pulse/Uninstall.app"; then
    echo "Pulse Secure ditemukan, menghapus..."
    
    # Matikan proses terkait
    sudo pkill -f "Pulse" 2>/dev/null
    sudo pkill -f "pulsesecure" 2>/dev/null
    sudo pkill -f "PulseTray" 2>/dev/null
    sudo launchctl remove net.pulsesecure.pulsetray 2>/dev/null
    sudo launchctl bootout system/net.pulsesecure.PulseSecureFirewall 2>/dev/null
    
    # Hapus kernel extension jika masih ada
    if kmutil showloaded | grep -q "net.pulsesecure.PulseSecureFirewall"; then
        echo "Menghapus kernel extension Pulse Secure..."
        sudo kmutil unload -b net.pulsesecure.PulseSecureFirewall 2>/dev/null
    fi
    
    # Jalankan script uninstall bawaan jika ada
    if [ -f "/Library/Application Support/Pulse Secure/Pulse/Uninstall.app/Contents/Resources/uninstall.sh" ]; then
        sudo chmod +x "/Library/Application Support/Pulse Secure/Pulse/Uninstall.app/Contents/Resources/uninstall.sh"
        sudo "/Library/Application Support/Pulse Secure/Pulse/Uninstall.app/Contents/Resources/uninstall.sh" 2>/dev/null
    fi
    
    # Hapus package receipt
    for pkg in $(pkgutil --pkgs | grep "net.pulsesecure" || true); do
        sudo pkgutil --forget "$pkg" 2>/dev/null
    done
    
    # Unload LaunchDaemons & LaunchAgents sebelum dihapus
    sudo launchctl unload -w "/Library/LaunchDaemons/net.pulsesecure.*" 2>/dev/null
    sudo launchctl unload -w "/Library/LaunchAgents/net.pulsesecure.*" 2>/dev/null
    
    remove_app "Pulse Secure" \
        "/Applications/Pulse Secure.app" \
        "/Library/Application Support/Pulse Secure" \
        "/Library/LaunchDaemons/net.pulsesecure.*" \
        "/Library/LaunchAgents/net.pulsesecure.*" \
        "/Library/Preferences/net.pulsesecure.*" \
        "/Users/Shared/Pulse" \
        "/Users/$loggedInUser/Library/PreferencesByHost/net.pulsesecure.*" \
        "/Users/$loggedInUser/Library/Application Support/Pulse Secure" \
        "/Users/$loggedInUser/Library/Logs/Pulse Secure"
else
    echo "Pulse Secure tidak ditemukan, melewati langkah ini."
fi

# Gunakan find untuk memastikan tidak ada file residual di direktori pengguna yang login
find "/Users/$loggedInUser/Library" -iname "*slack*" -exec sudo rm -rf {} +
find "/Users/$loggedInUser/Library" -iname "*pulsesecure*" -exec sudo rm -rf {} +

echo "\nProses selesai. Slack dan Pulse Secure telah diperiksa dan dihapus jika ditemukan."
