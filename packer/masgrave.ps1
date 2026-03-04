# masgrave.ps1
Write-Output "Starting unattended Massgrave activation..."
# The /HWID flag bypasses the menu and automatically activates Windows
iex "& { $(irm https://massgrave.dev/get) } /HWID"
Write-Output "Activation completed."