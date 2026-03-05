$ErrorActionPreference = "Stop"

Write-Output "Searching for the AUTOMATION drive..."

# 1. Find the drive that has the ODT setup.exe
$targetDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { 
    Test-Path "$($_.Name):\setup.exe" 
} | Select-Object -ExpandProperty Name -First 1

if (-not $targetDrive) {
    throw "Could not find setup.exe on any drive. Check your Packer cd_files config."
}

# 2. Set variables to the ODT-specific filename
$setupPath = "$($targetDrive):\setup.exe"
$configPath = "$($targetDrive):\configuration-Office365-x64.xml"

# 3. CRITICAL: Change location to the drive root so setup.exe sees the 'Office' folder
Set-Location -Path "$($targetDrive):\"

Write-Output "Starting Offline Installation from drive $($targetDrive): using configuration-Office365-x64.xml..."

# 4. Run the install
$process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    # If it fails, dump the last bit of the log so we see the Microsoft error
    Get-Content "C:\Windows\Temp\*-*.log" -Tail 20 | Write-Output
    throw "Office installation failed with Exit Code $($process.ExitCode)"
}

Write-Output "Office and Visio installation complete."