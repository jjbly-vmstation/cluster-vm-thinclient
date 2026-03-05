$ErrorActionPreference = "Stop"

Write-Output "Downloading Office Deployment Tool..."
# Using the permanent link to ensure we always get the latest version and avoid 404s
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/p/?LinkID=626065" -OutFile "C:\Windows\Temp\odt.exe"

Write-Output "Extracting ODT..."
Start-Process -FilePath "C:\Windows\Temp\odt.exe" -ArgumentList "/extract:C:\Windows\Temp\odt /quiet" -Wait

Write-Output "Starting Office Installation (This may take 5-10 minutes)..."
Start-Process -FilePath "C:\Windows\Temp\odt\setup.exe" -ArgumentList "/configure C:\Windows\Temp\office_config.xml" -Wait

Write-Output "Office Installation Complete."