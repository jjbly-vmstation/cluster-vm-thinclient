Write-Output "Starting unattended Massgrave activation..."
# The URL has been updated to the following:
& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID
Write-Output "Activation completed."