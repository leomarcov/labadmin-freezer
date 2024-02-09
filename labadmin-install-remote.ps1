#Requires -RunAsAdministrator
Param(
  [parameter(Mandatory=$true)]
  [String]$fileName,                  # Filename of installer file
  [String]$MD5,                       # MD5 to check integrity install file (if match not download)
  [URI]$URL,                          # URL from download (only download if file not exists and MD5 match)
  [Switch]$forceDownload,             # Force download and override install file
  [String]$destinationPath,	          # Optional folder to download instead of labadmin base download  
  [Switch]$removeInstaller,           # Remove install file after installation
  [String]$argumentList               # Optional argument list to silent installation for exe files (instead of default: /S /v"/qn", others typicall options: /S, /SILENT, /VERYSILENT, /SUPPRESSMSGBOXES)
)


#### CONFIG VARIABLES
$labadminDownloadsPath="${ENV:ALLUSERSPROFILE}\labadmin\downloads"
$defaultArguments='/S /v`"/qn`"'

if(!$argumentList) { $argumentList=$defaultArguments }
if(!$destinationPath) { $destinationPath=$labadminDownloadsPath}
$filePath="${destinationPath}\${fileName}"    

# CHECK EXTESION
if([System.IO.Path]::GetExtension($filePath) -eq ".exe") { $fileTypeEXE = $true }
elseif([System.IO.Path]::GetExtension($filePath) -eq ".msi") { $fileTypeMSI= $true }
else { Write-Error "File extension not supoerted (only .exe and .msi files)"; exit 1 }

# DOWNLOAD: call labadmin-download-file.ps1
$PSBoundParameters.Remove("removeInstaller") | Out-Null; $PSBoundParameters.Remove("argumentList") | Out-Null
& "${PSScriptRoot}\labadmin-download-file.ps1" @PSBoundParameters -ErrorAction Stop

# INSTALL
if($fileTypeEXE) { 
  Write-Output "Installing EXE in silent mode: $filePath $argumentList"
  Start-Process -FilePath $filePath -ArgumentList $argumentList -Verb runas -Wait
  Write-Output "Please, check manuallay if package is installed"
  Write-Output "`nIf fail, typical uninstall argumentList alternatives are:"
  Write-Output "  * /S /v`"/qn`""
  Write-Output "  * /S"
  Write-Output "  * /SILENT"
  Write-Output "  * /VERYSILENT"
  Write-Output "  * /SILENT /SUPPRESSMSGBOXES"
}  
elseif($fileTypeMSI) { 
  Write-Output "Installing MSI in silent mode: $filePath"
  Start-Process msiexec.exe -Wait -ArgumentList "/I `"${filePath}`" /norestart /QN"
}
$lec=$LASTEXITCODE

# REMOVE
if($removeInstaller) { 
    Write-Output "Removing install file: $filePath"
    Remove-Item -Force $filePath 
}
exit $lec
