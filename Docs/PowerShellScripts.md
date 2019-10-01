# PowerShell scripts


We use PowerShell on TACC Catapult nodes. PowerShell is a Windows command line shell that is much more advanced than the basic Command Prompt (cmd). There are some applications available on the Catapult nodes that we can use via PowerShell, like FpgaDiagnostics or RSU (for FPGA reconfiguration) and also some PowerShell scripts like genRpd that help us to to automate tasks performed frequently. We also create such scripts to speed up work. 

So far the following scripts has been made:
- **Hastlayer_programmer.ps1:** The script is located at the root of this repository.

    **Usage of the script:** Run the PowerShell as administrator (Right click on it in the Catapult Desktop, and choose Run as administrator). Navigate to the appropriate folder by typing the following: `cd E:\catapult\v1.2\Roles\HastlayerHardwareFramework-Catapult`. Then run the script with `.\Hastlayer_programmer.ps1`.

    **Script functionality:** This script first deletes the old *hastlayerhardware.rpd* file and then generates a new *hastlayerhardware.rpd* from the *Project.sof* file (located at *Project\output_files*) using the *genRpd.ps1* script too. After these it overwrites the Catapult FPGA board's flash memory with the new *.rpd* file and finally reconfigures the FPGA.              
                                                                  