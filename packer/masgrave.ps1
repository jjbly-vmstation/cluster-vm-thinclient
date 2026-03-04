Write-Output "Starting unattended activation..."
# The new permanent URL for the activation script
irm https://get.activated.win | iex
Write-Output "Activation process triggered."