#Requires -RunAsAdministrator

$install_path=$ENV:ProgramFiles+"\labadmin\labadmin-freezer\"



# Create folder and close permissions to admin
if(!(Test-Path $install_path)) { New-Item -ItemType Directory -Force -Path $install_path | Out-Null }

# Download files
$url="https://raw.githubusercontent.com/leomarcov/labadmin-freezer/main/"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url_files="config-usbstorage.ps1 manage-restorepoints.ps1 profiles-cleaner.ps1"
foreach($f in $url_files.split(" ")) { Invoke-WebRequest -Uri ("${url}/${f}") -OutFile ($install_path+"\$f") }

