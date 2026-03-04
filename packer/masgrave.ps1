Write-Output "Starting unattended Massgrave activation..."
# Permanent URL for the activation script
irm https://get.activated.win | iex
Write-Output "Activation completed."