/*
Name: SimpleLoopbackTest.cpp
Description: Catapult PCIe loopback stress test, demonstrates basic Catapult functionality

Copyright (c) Microsoft Corporation

All rights reserved.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the ""Software""), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#include <concurrent_queue.h>
#include <concrt.h>
#include <ppl.h>
#include <assert.h>

#ifdef COSIM
#include "../Common/FPGACoreLib_CoSim.h"
#else
#include "../../../../Driver/Include/FPGACoreLib.h"
#pragma comment(lib, "../../../../Driver/Bin/FPGACoreLib.lib")
#include "../../../../Driver/Include/FPGAManagementLib.h"
#endif

#include "../Common/FPGA_PCIeJobDispatcher.h"

typedef uint32_t PCIePayload;

typedef struct {
	bool eom;
	PCIePayload payload;
} PCIeSendPayload;


#define PCIE_HIP_NUM 0x0

#define MAX_BUF_SIZE_BYTES 65536
#define USE_INTERRUPT false

#define CONFIG_DRAM_CHAN0 600
#define CONFIG_DRAM_CHAN1 700
#define CONFIG_DRAM_INTERLEAVED 800

typedef enum {
	SINGLE_INORDER = 0,
	SINGLE_OOO = 1,
	PARALLEL = 2,
	PARALLEL_DECOUPLED = 3
} TestMode;



// Enable PCIe (default disabled)
void enablePCIe(FPGA_HANDLE fpgaHandle) {
	DWORD pcie = -1;
	FPGA_ReadShellRegister(fpgaHandle, 0, &pcie);

	// set control_register[6]
	pcie = pcie | (1 << 6);
	FPGA_WriteShellRegister(fpgaHandle, 0, pcie);
}

// Disable PCIe
void disablePCIe(FPGA_HANDLE fpgaHandle) {
	DWORD pcie = -1;
	FPGA_ReadShellRegister(fpgaHandle, 0, &pcie);

	// clear control_register[6]
	pcie = pcie & ~(1 << 6);
	FPGA_WriteShellRegister(fpgaHandle, 0, pcie);
}


int main()
{
	//CONST data
	//DWORD testData[] = {2,10,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21};
	DWORD testData[] = { 1,20,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,2,20,3,3,3,3,3,3,3,3,3,3,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30 ,2,20,3,3,3,3,3,3,3,3,3,3,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,2,20,3,3,3,3,3,3,3,3,3,3,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30 };

	FPGA_STATUS fpgaStatusFlag;
	FPGA_HANDLE fpgaHandle;
	DWORD *pInputBuffer, *pOutputBuffer;
	DWORD whichBuffer = 17; // which buffer (aka slot) to send the message on
							//DWORD sendBytes = 112, recvBytes;
	//DWORD sendBytes = 112, recvBytes;
	//DWORD sendBytes = 256, recvBytes =256;  //Writes 112/4 DWORDs to the Input Buffer
	//DWORD sendBytes = 448, recvBytes = 448;
	DWORD sendBytes = 384, recvBytes = 384;
	//DWORD sendBytes = 640, recvBytes;
	// Open handle to FPGA

	fpgaStatusFlag= FPGA_CreateHandle(&fpgaHandle, PCIE_HIP_NUM, 0x0, NULL, NULL);
	printf("Status FPGA FPGA_CreateHandle: %d\n", fpgaStatusFlag);
	// Grab pinned input and output buffers
	FPGA_WriteSoftRegister(fpgaHandle, CONFIG_DRAM_CHAN0, 0);
	enablePCIe(fpgaHandle);
	DWORD reg = -1;
	FPGA_ReadShellRegister(fpgaHandle, 0, &reg);
	printf("Control register value: 0x%08x\n", reg);

	fpgaStatusFlag=	FPGA_GetInputBufferPointer(fpgaHandle, whichBuffer, &pInputBuffer);
	printf("Status FPGA FPGA_GetInputBufferPointer: %d\n", fpgaStatusFlag);
	fpgaStatusFlag = FPGA_GetOutputBufferPointer(fpgaHandle, whichBuffer, &pOutputBuffer);
	printf("Status FPGA FPGA_GetOutputBufferPointer: %d\n", fpgaStatusFlag);
	// Write 112B (7 words) of random data into input buffer


	//printf("DWORD Size: %d\n", sizeof(DWORD));

	/*for (DWORD i = 0; i < 448 / sizeof(DWORD); i++)
	{
		printf("Testing TestData - index:%d, content: %d\n", i, testData[i]);
	}*/

	for (DWORD i = 0; i < sendBytes / sizeof(DWORD); i++)
	{
		//pInputBuffer[i] = rand();
		//pInputBuffer[i] = 100 + i;//rand();
		pInputBuffer[i] = testData[i];//rand();
		//printf("TestData index:%d, content: %X\n", i, testData[i]);
		printf("Input buffer index:%d, content: %X\n",i, pInputBuffer[i]);
	}
	// Send the data to the FPGA
	fpgaStatusFlag = FPGA_SendInputBuffer(fpgaHandle, whichBuffer, sendBytes, 1);
	printf("Status FPGA FPGA_SendInputBuffer: %d\n", fpgaStatusFlag);
	// Wait for the response to come back
	fpgaStatusFlag=	FPGA_WaitOutputBuffer(fpgaHandle, whichBuffer, &recvBytes, 1);
	printf("Status FPGA FPGA_WaitOutputBuffer: %d\n", fpgaStatusFlag);
	
	// Consume the contents of pOutputBuffer

	for (DWORD i = 0; i < recvBytes / sizeof(DWORD); i++)
	{
		printf("Output buffer index: %d, content: %X\n",i, pOutputBuffer[i]);
	}

	// ...
	// Discard the buffer
	FPGA_DiscardOutputBuffer(fpgaHandle, whichBuffer);
	// Close handle.
	FPGA_CloseHandle(fpgaHandle);
}
