#!/bin/bash

# Variabel
PKG_NAME="/tmp/TV3/TeamViewer_Host-idc62u2a44.pkg"
CHOICES_XML="/tmp/TV3/choices.xml"
ASSIGNMENT_ID="0001CoABChCxbmXARXAR7p5fZQpCBNg6EigIACAAAgAJANJqaz57ia10GKjpC0kB3omWzx-Mym3PJTpFjHe-3_GNGkDMre9ddjkyTDCSMzvdKjVMmvIaTPnV_wMsS0j6Ar7e2Njh3vcdB-o-oUsUAeDR3LlAExPZ3qbjSvZ-2R1hzDEzIAEQneyzsAs="
TVURL="http://10.15.1.86:8081/repository/Mac/TeamviewerHost/TV3.zip"
ZIP_PATH="/tmp/TV3.zip"
EXTRACT_PATH="/tmp/TV3"
LOG_FILE="/tmp/teamviewer_install.log"
USER="nx-deploy"
PASS="IT@DeployNexus22!!"

# === Fungsi untuk logging ===
log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") $1" | sudo tee -a "$LOG_FILE"
}

# === Mulai Download ===
log "🔄 Mengunduh TeamViewer Host dari $TVURL..."
curl --verbose --silent --fail -g -u "${USER}:${PASS}" -o "$ZIP_PATH" "$TVURL"

if [ $? -ne 0 ]; then
    log "❌ Gagal mengunduh TeamViewer Host. Periksa URL atau koneksi."
    exit 1
fi

# Ekstraksi ZIP
log "📦 Mengekstrak TeamViewer Host..."
mkdir -p "$EXTRACT_PATH"
unzip -q "$ZIP_PATH" -d/tmp/

if [ $? -ne 0 ]; then
    log "❌ Gagal mengekstrak TeamViewer Host."
    exit 1
fi

# Hapus ZIP setelah ekstraksi
#rm -f "$ZIP_PATH"
log "✅ Ekstraksi selesai."

# Pastikan file .pkg ada sebelum instalasi
if [ ! -f "$PKG_NAME" ]; then
    log "❌ Paket $PKG_NAME tidak ditemukan di $EXTRACT_PATH."
    exit 1
fi

# === Process Post Install ===
log "📋 Menampilkan pilihan instalasi..."
installer -showChoicesAfterApplyingChangesXML "$CHOICES_XML" -pkg "$PKG_NAME" -target / > /dev/null 2>&1

log "🚀 Memulai instalasi TeamViewer..."
sudo installer -applyChoiceChangesXML "$CHOICES_XML" -pkg "$PKG_NAME" -target / > /dev/null 2>&1

if [ $? -ne 0 ]; then
    log "❌ Instalasi TeamViewer gagal."
    exit 1
fi

# Pastikan layanan berjalan (retry max 5x)
log "🔄 Memastikan layanan TeamViewer berjalan..."
    sudo launchctl kickstart -k system/com.teamviewer.teamviewer_service > /dev/null 2>&1

log "✅ Layanan TeamViewer berhasil berjalan."

sleep 10  # Beri waktu agar layanan dapat berjalan

log "🔗 Menghubungkan TeamViewer dengan assignment ID..."
sudo /Applications/TeamViewerHost.app/Contents/Helpers/TeamViewer_Assignment -assignment_id "$ASSIGNMENT_ID" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log "✅ TeamViewer Host telah berhasil diinstal dan diassign."
else
    log "⚠️ Gagal menghubungkan TeamViewer."
    exit 1
fi
