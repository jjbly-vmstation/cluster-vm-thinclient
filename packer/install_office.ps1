$ErrorActionPreference = "Stop"

Write-Output "Searching for the AUTOMATION drive..."

# Compatibility-friendly search for the nested config file
$targetFile = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $path = "$($_.Name):\packer_cache\office\configuration-Office365-x64.xml"
    if (Test-Path $path) { Get-Item $path }
} | Select-Object -First 1

if (-not $targetFile) {
    throw "Could not find configuration-Office365-x64.xml in \packer_cache\office\ on any drive (D-Z)."
}

# Define the paths based on where we found the file
$officeDir = $targetFile.DirectoryName
$setupPath = Join-Path $officeDir "setup.exe"
$configPath = $targetFile.FullName

Write-Output "Found Office Cache at: $officeDir"

# Move focus to the CD folder so setup.exe sees the 'Office' data folder
Set-Location -Path $officeDir

Write-Output "Starting Office Installation..."
# Using explicit call to setup.exe with configuration
$process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    throw "Office installation failed with Exit Code $($process.ExitCode)"
}

Write-Output "Office Installation Complete."