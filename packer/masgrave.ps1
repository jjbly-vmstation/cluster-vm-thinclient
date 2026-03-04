Write-Output "Starting unattended Massgrave activation..."
& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID
Write-Output "Activation completed."