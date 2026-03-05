$ErrorActionPreference = "Stop"

Write-Output "Locating the Automation CD Drive..."
# Identify the drive letter for the CD-ROM containing our setup
$driveLetter = Get-Volume | 
    Where-Object DriveType -eq 'CD-ROM' | 
    Select-Object -ExpandProperty DriveLetter | 
    Select-Object -First 1

if (-not $driveLetter) {
    throw "Could not find any mounted CD-ROM drive."
}

$setupPath = "$($driveLetter):\setup.exe"
# Ensure this filename matches exactly what is in your tree
$configPath = "$($driveLetter):\configuration-Office365-x64.xml"

if (Test-Path $setupPath) {
    Write-Output "Found Office Setup on drive $($driveLetter):. Starting installation..."
    # Start the installation using the local configuration
    $process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        throw "Office installation failed with exit code $($process.ExitCode)"
    }
} else {
    throw "setup.exe not found on drive $($driveLetter):"
}

Write-Output "Office Installation Complete."