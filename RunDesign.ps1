$originalPath = Get-Location

# Getting the parent (Roles) folder of the script's folder (which is the project folder. This should work regardless 
## where we execute the script from.
# Also browsing there since genRpd doesn't seem to work when executed from the project folder.
cd (Split-Path -Parent (Split-Path -Parent $PSCommandPath))

if (Test-Path Hastlayer.rpd) {
    Remove-Item .\Hastlayer.rpd
}

.\genRpd.ps1 -inputSof $PSScriptRoot\Project\output_files\Project.sof -outputRpd .\Hastlayer.rpd

cd ..\Driver\Bin
.\RSU.exe -write ..\..\Roles\Hastlayer.rpd
.\RSU.exe -reconfig

cd $originalPath