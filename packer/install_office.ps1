$ErrorActionPreference = "Stop"

# Force TLS 1.2 to ensure secure connections to Microsoft's servers don't drop
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$url = "https://go.microsoft.com/fwlink/p/?LinkID=626065"
$odtPath = "C:\Windows\Temp\odt.exe"
$extractDir = "C:\Windows\Temp\odt"

Write-Output "Downloading Office Deployment Tool..."
# WebClient is generally more reliable and synchronous in headless provisioning
(New-Object System.Net.WebClient).DownloadFile($url, $odtPath)

# Remove the "Mark of the Web" so Windows doesn't block the executable
Unblock-File -Path $odtPath

Write-Output "Creating extraction directory..."
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

Write-Output "Extracting ODT..."
Start-Process -FilePath $odtPath -ArgumentList "/extract:$extractDir /quiet" -Wait

Write-Output "Starting Office Installation (This may take 5-10 minutes)..."
Start-Process -FilePath "$extractDir\setup.exe" -ArgumentList "/configure C:\Windows\Temp\office_config.xml" -Wait

Write-Output "Office Installation Complete."