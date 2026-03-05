$ErrorActionPreference = "Stop"

Write-Output "Searching for the AUTOMATION drive..."

# We look for the unique XML filename that only exists in your office cache
$targetFile = Get-ChildItem -Path "?:\packer_cache\office\configuration-Office365-x64.xml" -File -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $targetFile) {
    throw "Could not find the Office configuration file on any mounted drive (D-Z)."
}

# Now we know exactly which drive and folder we are in
$officeDir = $targetFile.DirectoryName
$setupPath = Join-Path $officeDir "setup.exe"
$configPath = $targetFile.FullName

Write-Output "Found Office Cache at: $officeDir"

# Jump into that folder so setup.exe can see the 'Office' data folder
Set-Location -Path $officeDir

Write-Output "Starting Office Installation..."
Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait