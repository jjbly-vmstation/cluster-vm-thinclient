Write-Output "Downloading Office Deployment Tool..."
Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB369D707E/officedeploymenttool_17328-20162.exe" -OutFile "C:\Windows\Temp\odt.exe"

Write-Output "Extracting ODT..."
Start-Process -FilePath "C:\Windows\Temp\odt.exe" -ArgumentList "/extract:C:\Windows\Temp\odt /quiet" -Wait

Write-Output "Starting Office Installation (This may take 5-10 minutes)..."
Start-Process -FilePath "C:\Windows\Temp\odt\setup.exe" -ArgumentList "/configure C:\Windows\Temp\office_config.xml" -Wait

Write-Output "Office Installation Complete."