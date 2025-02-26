#JRE

$ExeFileName = "jre-8u441-windows-i586-iftw.exe"
$installerPath = "C:\APP\"


# Ensure the target user folder exists or create it if necessary
if (-Not (Test-Path -Path $installerPath)) {
    Write-Host "Creating user folder: $installerPath"
    New-Item -Path $installerPath -ItemType Directory -Force
}

# Download url 
$Url = "http://10.15.1.86:8081/repository/Windows/JavaForOracle/" + $ExeFileName
$Username = 'nx-deploy'
$Password = 'IT@DeployNexus22!!'
$SecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
$CredObject = New-Object System.Management.Automation.PSCredential ($Username, $SecPassword)
$ExeFilePath = $installerPath + $ExeFileName

# Download file
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $ExeFilePath -Credential $credObject

#install
Start-Process -Wait -FilePath $ExeFilePath -ArgumentList "/s" -NoNewWindow

# Ambil username pengguna yang sedang login
$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName
$userName = $loggedInUser.Split('\')[-1]

# Cari lokasi profil pengguna berdasarkan username
$profilePath = (Get-WmiObject Win32_UserProfile | Where-Object { $_.LocalPath -match $userName }).LocalPath

# Path ke file exception list Java
$exceptionFile = "$profilePath\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"

# Daftar URL yang akan ditambahkan ke exception list
$exceptions = @(
"https://ora.eci.traveloka.com",
"https://id05oebs.tvlk-pay.cloud",
"https://id04oebs.tvlk-pay.cloud",
"https://id05oebs.mfc.traveloka.com",
"https://id04oebsstaging.tvlk-pay.cloud",
"https://id05oebsstaging.tvlk-pay.cloud",
"https://ora.eci.staging-traveloka.com",
"https://ora.eci.development-traveloka.com"
)

# Pastikan folder ada, jika tidak buat baru
$directoryPath = Split-Path -Path $exceptionFile
if (!(Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath -Force
}

# Buat file jika belum ada
if (!(Test-Path $exceptionFile)) {
    New-Item -ItemType File -Path $exceptionFile -Force
}

# Tambahkan setiap URL jika belum ada di dalam file
foreach ($url in $exceptions) {
    if (!(Select-String -Path $exceptionFile -Pattern $url -SimpleMatch -Quiet)) {
        Add-Content -Path $exceptionFile -Value $url
    } else {
        Write-Output "⚠️ Exception already exists: $url"
    }
}

Get-Content "$profilePath\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"