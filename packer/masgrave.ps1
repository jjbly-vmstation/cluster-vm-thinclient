# masgrave.ps1
# Example: Invoke Massgrave HWID activation for Windows 11
Write-Output "Starting Masgrave activation..."
irm https://massgrave.dev/get | iex
Write-Output "Activation completed."