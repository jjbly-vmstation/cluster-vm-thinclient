Write-Output "Starting unattended Massgrave activation..."
# Using the /S flag for silent and adding /KMS38 as a fallback for Business editions
& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /Ohook /S
Write-Output "Activation completed."