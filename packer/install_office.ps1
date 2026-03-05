$ErrorActionPreference = "Stop"

Write-Output "Searching for the AUTOMATION drive..."

# Search for the config file at the root of any drive (Packer flattens cd_files)
$targetFile = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $path = "$($_.Name):\configuration-Office365-x64.xml"
    if (Test-Path $path) { Get-Item $path }
} | Select-Object -First 1

if (-not $targetFile) {
    throw "Could not find configuration-Office365-x64.xml on any drive root. Check if cd_files in HCL is correct."
}

$driveRoot = $targetFile.DirectoryName
$setupPath = Join-Path $driveRoot "setup.exe"
$configPath = $targetFile.FullName

# IMPORTANT: Move to the drive root so setup.exe finds the 'Office' folder locally
Set-Location -Path $driveRoot

Write-Output "Starting Local Office/Visio Installation from $driveRoot..."
# The /configure flag combined with SourcePath="." in XML ensures it stays offline
$process = Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -PassThru

if ($process.ExitCode -ne 0) {
    throw "Office installation failed with Exit Code $($process.ExitCode)"
}

Write-Output "Office Installation Complete using local source files."