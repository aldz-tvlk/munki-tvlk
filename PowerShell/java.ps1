#JavaForOracle

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

# Start the installation process in the background (no user interaction)
Start-Process -Wait -FilePath $ExeFilePath -Argument "/S"
