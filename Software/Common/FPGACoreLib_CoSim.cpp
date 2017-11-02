/*
Name: FPGACoreLib_CoSim.cpp
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

#include <atomic>
#include <concurrent_queue.h>
#include <concrt.h>
#include <ppl.h>
#include <assert.h>
#include <windows.h>
#include <process.h>

#include "FPGACoreLib_CoSim.h"

std::atomic_flag coreLock = ATOMIC_FLAG_INIT;

FPGA_STATUS FPGA_CreateHandle(FPGA_HANDLE *fpgaHandle, DWORD endpointNumber, DWORD flags, const char *pchVerDefnsFile, const char *pchVerManifestFile) {
    // Allocate input and output buffers: 64 buffers each 64KB
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *fpgaHandle = fpga;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_CloseHandle(FPGA_HANDLE fpgaHandle) {
    // Do nothing
    //delete fpgaHandle;
    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_ReadShellRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD* readValue) {
    // TODO: Connect to model
    // Currently returns dummy value
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *readValue = 1337;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}


FPGA_STATUS FPGA_WriteShellRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD writeValue) {
    // TODO: Connect to model
    // Currently does nothing
    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_ReadSoftRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD64* readValue) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    //std::cout << "Starting FPGA_ReadSoftRegister request to addr " << registerNumber << std::endl;
    // Send read request. Spin if previous request not yet fulfilled
    bool done = false;
    while (!done) {
        do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&fpga->softReg_lock));
        if (!fpga->softRegReq_valid) {
            fpga->softRegReq_valid = true;
            fpga->softRegReq_addr = registerNumber;
            fpga->softRegReq_isWrite = false;
            done = true;
        }
        std::atomic_flag_clear(&fpga->softReg_lock);
    }
    // Wait for simulation to respond. Spin until response data is valid
    done = false;
    uint64_t result = -1;
    //std::cout << "Waiting for readSoftReg response from SimTop..." << std::endl;
    while (!done) {
        do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&fpga->softReg_lock));
        if (fpga->softRegResp_valid) {
            fpga->softRegResp_valid = false;
            fpga->softRegReq_valid = false;
            result = fpga->softRegResp_data;
            done = true;
        }
        std::atomic_flag_clear(&fpga->softReg_lock);
    }
    //std::cout << "ReadSoftReg addr " << registerNumber << " val " << result << std::endl;
    *readValue = result;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_WriteSoftRegister(FPGA_HANDLE fpgaHandle, DWORD registerNumber, DWORD64 writeValue) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    bool done = false;
    while (!done) {
        do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&fpga->softReg_lock));
        if (!fpga->softRegReq_valid) {
            fpga->softRegReq_valid = true;
            fpga->softRegReq_addr = registerNumber;
            fpga->softRegReq_isWrite = true;
            fpga->softRegReq_writeData = writeValue;
            done = true;
        }
        std::atomic_flag_clear(&fpga->softReg_lock);
    }
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}


FPGA_STATUS FPGA_GetInputBufferPointer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, PDWORD *inputBufferPtr) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *inputBufferPtr = (PDWORD)fpgaHandle->inputBufs[whichBuffer];
    //std::cout << "Getting input buffer slot " << whichBuffer << " ptr " << *inputBufferPtr << " ptrLoc " << inputBufferPtr << std::endl;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_GetOutputBufferPointer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, PDWORD *outputBufferPtr) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *outputBufferPtr = (PDWORD)fpgaHandle->outputBufs[whichBuffer];
    //std::cout << "Getting output buffer slot " << whichBuffer << " ptr " << *outputBufferPtr << " ptrLoc " << outputBufferPtr << std::endl;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_SendInputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, DWORD sizeBytes, BOOL useInterrupt) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    assert(sizeBytes % 16 == 0);
    fpgaHandle->inputBufFulls[whichBuffer] = true;
    //std::cout << "Sending to input buffer " << whichBuffer << ", sizeBytes: " << sizeBytes << std::endl;

    for (uint32_t i = 0; i < sizeBytes * 2 / 16; i += 2) {
        uint64_t data0 = fpgaHandle->inputBufs[whichBuffer][i];
        uint64_t data1 = fpgaHandle->inputBufs[whichBuffer][i + 1];

        PCIePacket packet;
        packet.data0 = data0;
        packet.data1 = data1;
        packet.slot = whichBuffer;
        packet.last = (i == (sizeBytes * 2 / 16) - 2);
        //std::cout << "  Sending packet " << i/2 << " data: " << std::hex << data0 << ", " << data1 << std::dec << " last: " << packet.last << std::endl;
        pcieSwToFpgaQ.push(packet);
    }
    fpgaHandle->inputBufFulls[whichBuffer] = false;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_WaitOutputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, DWORD *pBytesReceived, BOOL useInterrupt, double timeout) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    while (!fpgaHandle->outputBufDones[whichBuffer]) {
        concurrency::wait(0);
    }

    *pBytesReceived = fpgaHandle->outputBufSizes[whichBuffer];
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_DiscardOutputBuffer(FPGA_HANDLE fpgaHandle, DWORD whichBuffer) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    fpgaHandle->outputBufDones[whichBuffer] = false;
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_GetInputBufferFull(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, BOOL *isFull) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *isFull = fpgaHandle->inputBufFulls[whichBuffer];
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}

FPGA_STATUS FPGA_GetOutputBufferDone(FPGA_HANDLE fpgaHandle, DWORD whichBuffer, BOOL *isDone) {
    do { concurrency::wait(0); } while (std::atomic_flag_test_and_set(&coreLock));
    *isDone = fpgaHandle->outputBufDones[whichBuffer];
    std::atomic_flag_clear(&coreLock);

    return FPGA_STATUS_SUCCESS;
}