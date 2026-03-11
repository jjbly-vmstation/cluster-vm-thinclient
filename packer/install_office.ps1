# install_office.ps1 - Downloads Office ODT and installs Microsoft 365 Apps
$ErrorActionPreference = "Stop"
$WorkDir = "C:\Windows\Temp\OfficeInstall"

Write-Host "Creating working directory..."
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

# Download ODT
Write-Host "Downloading Office Deployment Tool..."
$ODTUrl = "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19628-20192.exe"
$ODTExe = "$WorkDir\odt.exe"
Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTExe -UseBasicParsing

# Extract ODT
Write-Host "Extracting ODT..."
Start-Process -FilePath $ODTExe -ArgumentList "/quiet /extract:$WorkDir" -Wait

# Write Office config XML - Microsoft 365 Apps for Enterprise, no Teams, no OneDrive
Write-Host "Writing Office config..."
$ConfigXML = @"
<Configuration ID="homelab-m365">
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <Updates Enabled="FALSE" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Logging Level="Standard" Path="C:\Windows\Temp\OfficeInstall" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="SharedComputerLicensing" Value="0" />
</Configuration>
"@
$ConfigXML | Out-File "$WorkDir\office_config.xml" -Encoding UTF8

# Run Office install
Write-Host "Installing Office (this will take a while)..."
$SetupExe = "$WorkDir\setup.exe"
$Result = Start-Process -FilePath $SetupExe -ArgumentList "/configure $WorkDir\office_config.xml" -Wait -PassThru

if ($Result.ExitCode -ne 0) {
    throw "Office installation failed with exit code: $($Result.ExitCode). Check C:\Windows\Temp\OfficeInstall for logs."
}

Write-Host "Office installation completed successfully."

# Cleanup
Write-Host "Cleaning up..."
Remove-Item -Path $WorkDir -Recurse -Force -ErrorAction SilentlyContinue