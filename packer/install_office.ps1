$ErrorActionPreference = "Stop"

Write-Output "Scanning for the AUTOMATION drive (looking for nested Office cache)..."

# Look for the drive that contains our specific nested Office folder
$targetDrive = Get-PSDrive -PSProvider FileSystem | 
    Where-Object { Test-Path "$($_.Name):\packer_cache\office\configuration-Office365-x64.xml" } | 
    Select-Object -First 1

if (-not $targetDrive) {
    throw "Could not find configuration-Office365-x64.xml in \packer_cache\office\ on any drive!"
}

$driveLetter = "$($targetDrive.Name):"
# Define the exact nested paths based on your folder structure
$officeBaseDir = "$driveLetter\packer_cache\office"
$setupPath = "$officeBaseDir\setup.exe"
$configPath = "$officeBaseDir\configuration-Office365-x64.xml"

Write-Output "Correct Drive Found: $driveLetter"
Write-Output "Targeting: $setupPath"

# Change directory to the office folder so the ODT can see the 'Office' data folder
Set-Location -Path $officeBaseDir

Write-Output "Starting Office Installation..."
# We pass the absolute config path to avoid any ambiguity
$process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    throw "Office installation failed with Exit Code $($process.ExitCode)"
}

Write-Output "Office Installation Complete."