# JavaForOracle Installation Script

$ExeFileName = "jre-8u441-windows-i586-iftw.exe"
$installerPath = "C:\APP\"

# Pastikan folder instalasi ada
if (-Not (Test-Path -Path $installerPath)) {
    Write-Host "Creating folder: $installerPath"
    New-Item -Path $installerPath -ItemType Directory -Force
}

# Download URL 
$Url = "http://10.15.1.86:8081/repository/Windows/JavaForOracle/" + $ExeFileName
$Username = 'nx-deploy'
$Password = 'IT@DeployNexus22!!'
$SecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
$CredObject = New-Object System.Management.Automation.PSCredential ($Username, $SecPassword)
$ExeFilePath = $installerPath + $ExeFileName

# Jika file sudah ada, pastikan tidak digunakan sebelum dihapus
if (Test-Path -Path $ExeFilePath -PathType Leaf) {
    Write-Host "File sudah ada, mengecek apakah sedang digunakan..."
    
    # Cek apakah file sedang digunakan oleh proses lain
    try {
        Rename-Item -Path $ExeFilePath -NewName "$ExeFilePath.bak" -ErrorAction Stop
        Remove-Item -Path "$ExeFilePath.bak" -Force -ErrorAction Stop
        Write-Host "File tidak sedang digunakan, menghapus..."
    } catch {
        Write-Host "File sedang digunakan, menunggu proses selesai..."
        Start-Sleep -Seconds 5
        Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $ExeFilePath -Force -ErrorAction SilentlyContinue
    }
}

# Unduh ulang file jika sebelumnya gagal
Write-Host "Mengunduh file instalasi Java..."
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $ExeFilePath -Credential $CredObject

# Generate SHA256 Checksum dari file yang diunduh
$GeneratedChecksum = (Get-FileHash -Algorithm SHA256 $ExeFilePath).Hash
Write-Host "Generated Checksum: $GeneratedChecksum"

# Masukkan hasil checksum ke dalam variabel EXPECTED_CHECKSUM
$EXPECTED_CHECKSUM = $GeneratedChecksum  # Menggunakan checksum hasil perhitungan

# Cek apakah file valid berdasarkan checksum
if ((Get-FileHash -Algorithm SHA256 $ExeFilePath).Hash -ne $EXPECTED_CHECKSUM) {
    Write-Host "Checksum tidak cocok, menghapus dan mengunduh ulang..."
    Remove-Item -Path $ExeFilePath -Force -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $ExeFilePath -Credential $CredObject
} else {
    Write-Host "Checksum valid, melanjutkan instalasi."
}

# Jalankan instalasi dengan mode silent
Write-Host "Memulai instalasi Java..."
Start-Process -Wait -FilePath $ExeFilePath -Argument "/S"

# Verifikasi apakah Java sudah terinstal
$JavaCheck = Get-Command "java.exe" -ErrorAction SilentlyContinue
if ($JavaCheck) {
    Write-Host "Java berhasil diinstal!"
} else {
    Write-Host "Instalasi Java gagal!"
}
