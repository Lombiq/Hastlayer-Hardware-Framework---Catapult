/*
Name: FPGACoreLib_CoSim.h
Description: Override for the Catapult FPGACoreLib library. Each API call is overridden to interface with the simulator.
             Note that ReadShellRegister and WriteShellRegister don't do anything since the cosim framework only models SimpleRole.

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

#ifndef _FPGACORELIB_COSIM_H_
#define _FPGACORELIB_COSIM_H_


#include <concurrent_queue.h>
#include <concrt.h>
#include <ppl.h>
#include <assert.h>
#include <windows.h>
#include <process.h>

#include "harness.h"

extern FPGAState* fpga;

extern concurrency::concurrent_queue<PCIePacket> pcieSwToFpgaQ;
extern concurrency::concurrent_queue<PCIePacket> pcieFpgaToSwQ;


typedef FPGAState* FPGA_HANDLE;
typedef uint32_t FPGA_STATUS;
#define FPGA_STATUS_SUCCESS 0


FPGA_STATUS FPGA_CreateHandle(FPGA_HANDLE *fpgaHandle, DWORD endpointNumber, DWORD flags, const char *pchVerDefnsFile, const char *pchVerManifestFile);
FPGA_STATUS FPGA_CloseHandle(FPGA_HANDLE fpgaHandle);

FPGA_STATUS FPGA_ReadShellRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD* readValue);
FPGA_STATUS FPGA_WriteShellRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD writeValue);

FPGA_STATUS FPGA_ReadSoftRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD64* readValue);
FPGA_STATUS FPGA_WriteSoftRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD64 writeValue);

FPGA_STATUS FPGA_GetInputBufferPointer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, PDWORD *inputBufferPtr);
FPGA_STATUS FPGA_GetOutputBufferPointer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, PDWORD *outputBufferPtr);

FPGA_STATUS FPGA_SendInputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, DWORD sizeBytes, BOOL useInterrupt);
FPGA_STATUS FPGA_WaitOutputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, DWORD *pBytesReceived, BOOL useInterrupt, double timeout = 1.0e-5);
FPGA_STATUS FPGA_DiscardOutputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer);

FPGA_STATUS FPGA_GetInputBufferFull(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, BOOL *isFull);
FPGA_STATUS FPGA_GetOutputBufferDone(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, BOOL *isDone);

#endif