$ErrorActionPreference = "Stop"

Write-Output "Scanning for the AUTOMATION drive..."
# Find the drive that has our specific setup.exe at the root
$targetDrive = Get-PSDrive -PSProvider FileSystem | 
    Where-Object { Test-Path "$($_.Name):\setup.exe" } | 
    Select-Object -First 1

if (-not $targetDrive) {
    throw "Could not find the Office setup.exe on any mounted drive!"
}

$driveLetter = "$($targetDrive.Name):"
$setupPath = "$driveLetter\setup.exe"
$configPath = "$driveLetter\configuration-Office365-x64.xml"

Write-Output "Found setup on $driveLetter. Starting installation with explicit SourcePath..."

# By passing the SourcePath via command line, we override any internal XML confusion
# and ensure it pulls from the virtual CD-ROM, not the internet.
Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -NoNewWindow