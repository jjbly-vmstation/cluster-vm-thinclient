$ErrorActionPreference = "Stop"
Write-Output "Starting unattended Massgrave activation..."
& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /Ohook /S
if ($LASTEXITCODE -ne 0) { throw "Activation failed with exit code $LASTEXITCODE" }
Write-Output "Activation completed."