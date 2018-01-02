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
	FPGA_HANDLE fpgaHandle;
	DWORD *pInputBuffer, *pOutputBuffer;
	DWORD whichBuffer = 17; // which buffer (aka slot) to send the message on
	//DWORD sendBytes = 112, recvBytes;
	DWORD sendBytes = 112, recvBytes;
	//DWORD sendBytes = 163840, recvBytes;
	// Open handle to FPGA
	FPGA_CreateHandle(&fpgaHandle, PCIE_HIP_NUM, 0x0, NULL, NULL);
	// Grab pinned input and output buffers
	enablePCIe(fpgaHandle);
	FPGA_GetInputBufferPointer(fpgaHandle, whichBuffer, &pInputBuffer);
	FPGA_GetOutputBufferPointer(fpgaHandle, whichBuffer, &pOutputBuffer);
	// Write 112B (7 words) of random data into input buffer
	for (DWORD i = 0; i < sendBytes / sizeof(DWORD); i++)
	{
		pInputBuffer[i] = 1 + i*2;
		printf("Input buffer content: %X\n", pInputBuffer[i]);
	}
	// Send the data to the FPGA
	FPGA_SendInputBuffer(fpgaHandle, whichBuffer, sendBytes, 1);
	// Wait for the response to come back
	FPGA_WaitOutputBuffer(fpgaHandle, whichBuffer, &recvBytes, 1);
	// Consume the contents of pOutputBuffer

	for (DWORD i = 0; i < recvBytes / sizeof(DWORD); i++)
	{				
		printf("Output buffer content: %X\n", pOutputBuffer[i]);
	}

	// ...
	// Discard the buffer
	FPGA_DiscardOutputBuffer(fpgaHandle, whichBuffer);
	// Close handle.
	FPGA_CloseHandle(fpgaHandle);
}
