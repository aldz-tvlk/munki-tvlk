#!/bin/bash

# Dapatkan user yang sedang login
loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

# Path ke folder Logs
LOG_PATH="/Users/$loggedInUser/Library/Logs"

# Cek apakah folder Logs ada
if [ ! -d "$LOG_PATH" ]; then
  echo "Folder $LOG_PATH tidak ditemukan. Mohon pastikan folder ada terlebih dahulu."
  exit 1
fi

# Ambil pemilik folder Logs
currentOwner=$(stat -f "%Su" "$LOG_PATH")

# Jika pemilik folder bukan user yang sedang login, ubah pemiliknya
if [ "$currentOwner" != "$loggedInUser" ]; then
  echo "Folder $LOG_PATH tidak dimiliki oleh user $loggedInUser. Mengubah kepemilikan..."
  sudo chown -R "$loggedInUser" "$LOG_PATH"
fi

# Cek apakah user memiliki izin read & write
if [ ! -w "$LOG_PATH" ] || [ ! -r "$LOG_PATH" ]; then
  echo "User $loggedInUser tidak memiliki izin read & write. Memperbaiki izin..."
  sudo chmod -R u+rw "$LOG_PATH"
else
  echo "User $loggedInUser sudah memiliki izin read & write pada $LOG_PATH."
fi

echo "Proses selesai."