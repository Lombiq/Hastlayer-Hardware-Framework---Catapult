cd E:\catapult\v1.2\Roles
Remove-Item .\hastlayerhardware.rpd
.\genRpd.ps1 -inputSof .\HastlayerHardwareFramework-Catapult\Project\output_files\Project.sof -outputRpd .\hastlayerhardware.rpd
cd E:\catapult\v1.2\Driver\Bin
.\RSU.exe -write E:\catapult\v1.2\Roles\hastlayerhardware.rpd
.\RSU.exe -reconfig
#cd E:\Catapult\v1.2\Software\LoopbackStressTest\x64\Release
#.\LoopbackStressTest.exe
