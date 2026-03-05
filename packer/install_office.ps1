$ErrorActionPreference = "Stop"

# HARDCODED PATHS TO DRIVE E:
$driveRoot = "E:\"
$setupPath = "E:\setup.exe"
$configPath = "E:\configuration-Office365-x64.xml"

Write-Output "FORCING Office installation from drive E:..."

# Pre-execution check
if (-not (Test-Path $setupPath)) {
    throw "FATAL: setup.exe not found on E:. Verify drive mapping in VMware console."
}

# Change location so setup.exe sees the 'Office' data folder locally
Set-Location -Path $driveRoot

Write-Output "Executing: $setupPath /configure $configPath"

# Start the installation
$process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -NoNewWindow -PassThru

if ($process.ExitCode -ne 0) {
    Write-Output "Office installation failed with Exit Code $($process.ExitCode)"
    # Dump the Microsoft setup log if it exists
    if (Test-Path "C:\Windows\Temp\*-*.log") {
        Get-Content "C:\Windows\Temp\*-*.log" -Tail 20 | Write-Output
    }
    throw "Installation failed with code $($process.ExitCode)"
}

Write-Output "Office and Visio installation successfully completed on E:."