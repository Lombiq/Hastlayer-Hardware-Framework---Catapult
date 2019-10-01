if (Test-Path Hastlayer.rpd) {
    Remove-Item .\Hastlayer.rpd
}

# genRpd doesn't seem to work when executed from the Hastlayer folder, so need to browse there.
cd ..
.\genRpd.ps1 -inputSof $PSScriptRoot\Project\output_files\Project.sof -outputRpd .\Hastlayer.rpd

cd ..\Driver\Bin
.\RSU.exe -write ..\..\Roles\Hastlayer.rpd
.\RSU.exe -reconfig

cd $PSScriptRoot