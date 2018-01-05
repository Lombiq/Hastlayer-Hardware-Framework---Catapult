# Debugging

The Microsoft Catapult Project is constantly evolving and developing, so you might need to face unexpected errors. This section is a collection of such errors that we have solved before, so you are advised to find answers here before you go to the Catapult Support.

## Licensing Issues

Microsoft uses license servers to grant access to the Microsoft Project Catapult Academic Shell, Driver, and to the Intel/Altera FPGA IP core libraries. 

### Modelsim license issue

In 11.2017, Microsoft changed its license servers from troy.tacc.utexas.edu (detailed in Catapult TACC Getting Started Guide v1.1.pdf, section 2.2) to license02.tacc.utexas.edu (detailed in Catapult TACC Getting Started Guide v1.2.pdf, section 2.2) to host license files. 
After the license server moved, we had got licensing issues constantly. The error message says: "**Error: Faliure to obtain a Verilog simulation license. Unable to checkout any of the license features: alteramtivsim or alteramtivlog. Error loading design."
![Modelsim licensing error](Images/Modelsim_license_error.png)  
The issue was escalated to Altera, and they fixed the issue. The setup of the environmental variables is also corrected in the Catapult TACC Getting Started Guide v1.2.pdf

### Quartus Prime license issue   

We also had got license issues with Quartus Prime. It manifests itself in that we get many "-- current license file does not contain a valid license for encrypted file.. " in the Quartus Messages window after you start to compile a Quartus project.
It has been revealed, that a typo in the environmental variables caused that the Quartus wasn't able to check the MSFTAcademic.dat file.

If you get any kind of licensing error, do the following:
Double check the environmental variables! On the Microsoft Catapult node you can set the environmental variables by do ing the following:
- Click on the Windows Start menu
- Start to type env. On the top right part of the screen you will see "Edit the system environment variables". Click on it.
- The System Properties window will be shown. Click on the "Environment Variables..." button.
- Make sure that the following is set both in the user and the system environmental variables section: 
  - Variable name: LM_LICENSE_FILE   
  - Variable value: 27000@license02.tacc.utexas.edu;E:\catapult\v1.2\MSFTAcademic.dat     
- After you have set the environmental variables, restart the node, and try to use Modelsim or Quartus project compilation again.
- If Modelsim works, but Quartus project compilation doesn't, check that the right Device has been chosen for your project. The device name has to be "5SGSMD5H2F35I3L". The Catapult support also suggests to keep the .qsf file read-only, becouse it might get corrupted somethimes.
- If none of the above helped, write to the Catapult Support for help on catapsup@microsoft.com. 

### Modelsim Simulation Issues

We use Modelsim to simulate Simplerole and our IP cores instantiated in it for test and development purposes.
You can pull in selected signals to the Modelsim wave window, which you want to examine. You are also able to manipulate these signals, like set radix, organize signals into groups, etc. This setup of signals can be saved to a .do file so you don't have to setup your signals every time when you run a test in Modelsim.
The waveform can be also saved in a .wlf file, which is the only way to examine the simulation results when you run it in batch mode. When you start a simulation in batch mode, the simulation results are saved in a .wlf file, which can be loaded to the Modelsim GUI after the simulation is finished, so you can examine the results.
There is an error which occures somethimes, when you quit Modelsim, and you want to restart it later - in batch mode - with another simulation. 
The message says: "Warning: (vsim-WLF-5000) WLF file currently in use: vsim.wlf." However Modelsim is not running currently, some process still holds the previously generated .wlf file for some reason.
This is only a warninng message, but you have to deal with it, because Modelsim cannot be started. 
![Modelsim licensing error](Images/Modelsim_vsim_wlf_error.png)  
The solution in this case is the following: 
- You need to navigate to the simulation directory (e:\catapult\v1.2\Roles\HastlayerHardwareFramework-Catapult\Sim\) and delete the previously generated vsim.wlf file
- You need to restart the simulation in batch mode. The simulation results will be saved in a new vsim.wlf file.
- After the batch mode simulation finished, you need to start Modelsim GUI, and load the .wlf file.
If you get into any Modelsim related issue, [Modelsim User's Manual](https://www.microsemi.com/document-portal/doc_view/131619-modelsim-user) is a good start for searching. 


                                            