# Getting started

On the Catapult node clone this repository to a subfolder of *E:\catapult\v1.2\Roles\* (the default Catapult location, which you should use) with a folder name something like *HastlayerHardwareFramework-Catapult*. Make sure that the folder is not read-only.

The HastlayerHardwareFramework-Catapult FPGA design is a modified verson of the formerly created hastlayer-hardware-framework-xilinx. The design runs on a Microsoft Catapult node, which consists of a Host-PC, and an "Mt Granite" FPGA board connected to it. Mt Granite contains an Altera Stratix V 5SGSMD5H2F35 and two channels of DDR3, each providing 4GB for a total of 8GB. The card connects to the server (Host-PC) via eight lanes of Gen3 PCI Express (PCIe).
For a detailed description of the Mt Granite card, you can check the Mt Granite Architectural Spec v1.0.pdf in the catapult-init folder of the version control system.

HastlayerHardwareFramework-Catapult FPGA project originates from the AcademicDRAMLoopback example project, which is provided by Microsoft. This is a simple loopback test, which uses PCIe, and FPGA -> Memory operations. In this example project, the Host-PC sends data to the FPGA board via PCIe. Each transmission consists of 128 bits of data, plus control bits (buffer number, last bit, and pad). The incoming data is written to the DDR3 memory by the FPGA. The memory can be addressed via 64 bit addresses, on a simplified memory interface. After all of the incoming data has been written to the memory (we got a last bit on the PCIe), we start to read memory. The data is then sent back to the PC via PCIe packet by packet.

A PC side software is also needed to see the operation of the AcademicDRAMLoopback example project. For this, Microsoft provided the LoopbackStressTest project, which can be recompiled in Microsoft Visual Studio, and can be used in PowerShell.
During the project, a much easier PC side software has been also created, this is the SimpleLoopbackTest(will be detailed in a later section).

For more information of the AcademicDRAMLoopback example project, and the LoopbackStressTest you can check Catapult TACC Getting Started Guide v1.2.pdf and Catapult User Guide v1.2.pdf in the catapult-init folder.

The most important sources of the HastlayerHardwareFramework-Catapult project are detailed below.

# The HastlayerHardwareFramework-Catapult project
The HastlayerHardwareFramework-Catapult FPGA project runs on the Mt Granite board, which contains an Altera Stratix V 5SGSMD5H2F35 FPGA. The FPGA project created in the Altera Quartus Prime IDE. 

## The Project files
The project files are located in the HastlayerHardwareFramework-Catapult\Project\ folder in the version control system.
- Project.qpf: This is the main Quartus project file. You can open the project by running Project.qpf.
- Project.qsf: Main Quartus project settings file. Contains settings and points to the TCL file(s).
- Project.tcl: Quartus settings file. Supports a limited set of TCL script. The FPGA clock frequency is set in this file. By default, it is 150 MHz. The User guide recommends to target your final FPGA design to this clock frequency, but they also provided a list of valid clock frequencies: 25MHz, 50MHz, 75MHz, 125MHz, 133MHz, 150MHz, 160MHz, 166MHz, 175MHz, 180MHz, 187MHz, 200MHz, 220MHz, 233MHz, 250MHz, 275MHz, 300MHz.
 
## The RTL files
The RTL design files are located in the hastlayer-hardware-framework-catapult\RTL\ folder.
- app.tcl: This is a list of source files to load to the project. Our custom made source files (Hast_IP.vhd, Hast_ip_wrapper.vhd) also need to be listed in this file.
- Role.sv: This is the SimpleRole wrapper file. You must not modify this file. All of the Catapult side RTL design must be made inside the SimpleRole.sv file, or in files instantiated in it.
- SimpleDram.sv: DRAM wrapper for SimpleRole, instantiated within Role.sv. Do not modify this file.
- SimpleRole.sv: The actual role containing user logic. This logic handles the PCIe communication with the Host-PC, controls memory operations, and communicates with our custom made modules. The logic is controlled by a State Machine. The Hast_IP wrapper and the Hast_IP are also instantiated under this source.
- Hast_IP_wrapper: This is a wrapper file for the Hast_IP. It contains typecasts of the Hast_IP ports, ie. casts integer type ports to std_logic_vector, and boolean to std_logic and vice versa. It is necessary becouse in the Simplerole we use standard logic signals to control memory, and to handle data. 
In the Hast_IP_wrapper, we create Hast_IP_Read_Addr_out and Hast_IP_Write_Addr_out ports, so the read and write addresses go out to the SimpleRole on dedicated ports (in the Hast_IP the addresses are sent on the same port, this is called there \CellIndex\). \CellIndex\ is specified to be a Hast_IP_Read_Addr_out, if there is a valid \ReadEnable\ coming out of the Hast_IP, and is specified to be a Hast_IP_Write_Addr_out if there is a valid \WriteEnable\ coming out of the Hast_IP.
Hast_IP_wrapper operates with 512 bit data input and output ports (Hast_IP_Data_in and Hast_IP_Data_out). 
A performance counter is also implemented in this source, which is controlled by a State Machine. The Performance counter starts to count when a valid Hast_IP_Started_in occures, and stops counting for a valid Hast_IP_Finished_out signal. The counter's final value will be the number of clock signals counted between these two signals.
The Hast_IP_wrapper creates the outgoing Control packet too. The control packet is a 512 bit packet, which contains control and status data, which are the following: 31-0 bits: MemberID. 63-32 bits: Number of data to process, 127-64 bits: Performance counter. The Control packet has a dedicated 512 bit port in the Hast_IP_wrapper, and is sent out to the memory, when the  processing ended (\Finished\ = 1 comes from the the Hast_IP).
- Hast_IP: For the HastlayerHardwareFramework-Catapult project, a "hand written", simplified Hast_IP code has been developed. Its purpose is to test Hast_IP control, memory read/write operations, and data flow of the Hast_IP in the Catapult system. This is an initial code for test purposes, in the final version it has to be changed to a generated Hast_IP.
The Hast_IP operates with 512 bit data, which is handled on the \DataIn\ and \DataOut\ ports. The source deals with only 1 member, which is handled in a State Machine(SM_Member). As for the Hast_IP interface, only the \DataIn\ and \DataOut\ ports datawidth has been changed since the original version, which was targeted for Xilinx FPGA.
The SM_Member State Machine waits for a \Started\ = true and a \MemberId\ = 1 signals to get started. The \Started\ = true signal must be created in the SimpleRole logic. The MemberID comes in to the Hast_IP from the control packet (which is read out from the memory in the SimpleRole). The Control packet is the first 512 bit memory slot. The incoming control slot currently contains the MemberID, and the Number of data to process (the outgoing control packet is created in the Hast_IP_wrapper, and also contains the Performance counter). The control packet does not contain any data to processed by the Hast_IP, the data comes from the following 512 bit memory slot, so the read address needs to be incremented (which goes out on the \CellIndex\ port) and a \ReadEnable\ signal needs to be set. The addresses must be 64 bit aligned, so valid memory addresses are ie. 0x0, 0x40, 0x80, etc. Write operations must be handled similarly. A 64 bit aligned adress must be set on the \CellIndex\ port, and \WriteEnable\ needs to be set to 1. 
The simplified Hast_IP does not contain a real data processing algorithm, it only simulates the control, and dataflow. So we don't do any calculations on the incoming data, rather just exchange as many data to constant test values, as needed (ie. if 10 numbers must be calculated by the Hast_IP, then it exchanges 10 data to constant values, etc). The logic handles the case, if the number of data to be processed is not a multiple of 16 (there are 16 slices of 32 bit data in an 512 bit package).
For example if the number of data to be processed is 10, then the remaining 6 data are not exchanged with the constant value, but will be sent back to the memory unchanged.
The State machine's logic also handles if there are numerous packages to be processed. Basically, it reads an 512 bit package from the memory, exchanges it's 32 bit data slices to constant values, and then it sends it back to memory. If the number of data is more then which comes in a package, then the State Machine increments the address, and reads the corresponding package, processes it, and writes it back again. After all the data processed, the State Machine goes to its finish state. This is also indicated in the Hast_IP_wrapper, where the Performance counter stops its operation for the \Finished\ signal, creates the outgoing Control package, and sends it to the memory in the SimpleRole.
- Test_Hast_IP_wrapper: This is a simulation file to test Hast_IP, and Hast_IP_wrapper. It produces the necessary control signals and data for the operation. The Test_Hast_IP_wrapper (and also Hast_IP and Hast_IP_wrapper) are not tied to the Catapult system, they can be also simulated in Xilinx IDE. Simulation is faster if you use it on your own PC, not on a remote node. It also runs in Xilinx Vivado simulator, but Vivado simulator does not support to visualize 512 bit data, so its not practical. Rather use the older simulator (iSim), which can be used by installing the old development environment (Xilinx ISE).

## PC-side software
The Host-PC runs a software which sends and receives data to/from the FPGA via PCIe interface. There is a LoopbackStressTest provided by Microsoft to test the communication, but a more simple PC software has been also developed. This simplified version can be found at hastlayer-hardware-framework-catapult\Software\.
It sets the buffer to send and receive data to and from. Generates test data to send to the FPGA, and prints the sent and received data to the console. The functions used in the code are also provided by Microsoft. You have to build it in x64 Release mode.
To test your project on FPGA with the PC-side software, do the following:
- Compile the FPGA design in Quartus Prime.
- Navigate to catapult\v1.2\Roles\. Convert the binary to .rpd file with the genRpd.ps1 PowerShell script. You can check the command in the Catapult TACC Getting Started Guide v1.2.pdf.
- Upload the .rpd file to the FPGA flash memory, then reconfigure the FPGA. You can use the RSU program for that.
- Navigate to catapult\v1.2\Roles\HastlayerHardwareFramework-Catapult\Software\SimpleLoopbackTest\Release\ in PowerShell.
- Run the .exe file.

## Modelsim Altera simulation
Microsoft provided a simulation environment, in which the simulate the PC -> FPGA data flow, and you can also check your custom made logic created inside SimpleRole. You need a set of files to run the simulation.
- SimTop.sv: This is a system verilog test file, which is located at catapult\v1.2\Roles\Sim\ on the Catapult filesystem.
SimTop simulates feeds SimpleRole with test data. You can only simulate SimpleRole, and the modules instantiated inside of it. No modules on a higher level then SimpleRole can be simulated.
-buildSim.ps1: A PowerShell script that builds the simulation. At the top of the script, you have to specify the PC side software project to run in the simulation (ie. LoopbackStressTest or SimpleLoopbackTest).
-RunSim.ps1: The simulation itself can be started by running the RunSim.ps1 PowerShell script located at HastlayerHardwareFramework-Catapult\Sim\. RunSim.ps1 will start buildSim.ps1 too.
-build.do: This is a Modelsim .do file located at located at HastlayerHardwareFramework-Catapult\Sim\. There is no option the run a Catapult design simulation in Modelsim in GUI mode. So you need to run your simulations in batch mode. When you run a simulation in batch mode, you will only see console messages, no wave window signals. So you need to "record" the simulation, and when it is done, you can load it to Modelsim, and visualize it. The .do file is modified to do so.
The process to run a simulation is the following:
- Navigate to the following directory: catapult\v1.2\Roles\HastlayerHardwareFramework-Catapult\Sim\
- .\runSim.ps1
- After the build and simulation process finished, type: vsim -view vsim.wlf -do wave.do


 

