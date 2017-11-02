/*
Name: harness.h
Description: Cosimulator framework C-DPI test harness. Launches software test and models communication between software
             and SystemVerilog testbench.

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

#include <iostream>
#include <deque>
#include <cassert>
#include <atomic>
#include "svdpi.h"

#ifndef __HARNESS_H__
#define __HARNESS_H__

// Can't alloc the full 4GB per channel with 32-bit Modelsim
#define MEM_ALLOC_PER_CHANNEL (1*1024*1024*1024)

typedef struct {
    uint64_t data0;
    uint64_t data1;
    uint32_t slot;
    uint32_t last;
} PCIePacket;

typedef struct {
    uint64_t data0;
    uint64_t data1;
    uint64_t data2;
    uint64_t data3;
    uint64_t data4;
    uint64_t data5;
    uint64_t data6;
    uint64_t data7;
} DRAMPacket;

// FPGA model
class FPGAState {
public:
    volatile uint64_t**     inputBufs;
    volatile uint32_t*      inputBufSizes;
    volatile bool* inputBufFulls;

    volatile uint64_t**     outputBufs;
    volatile uint32_t*      outputBufSizes;
    volatile bool* outputBufDones;

    bool       outputFSM_started;
    uint32_t   outputFSM_ptr;
    uint32_t   outputFSM_slot;

    uint32_t numBufs;
    uint32_t bufSize;

    std::atomic_flag softReg_lock;
    bool softRegReq_valid;
    bool softRegReq_isWrite;
    uint32_t softRegReq_addr;
    uint64_t softRegReq_writeData;

    bool softRegResp_valid;
    uint64_t softRegResp_data;

    FPGAState(uint32_t numBufs, uint32_t bufSize);
    ~FPGAState();
};


// Harness initialization and done checking 
extern "C" DPI_DLLESPEC void initHarness();
extern "C" DPI_DLLESPEC int checkDone();

// PCIe Interface
extern "C" DPI_DLLESPEC int pcieSendToSW(const PCIePacket* packet);
extern "C" DPI_DLLESPEC int pcieValidFromSW();
extern "C" DPI_DLLESPEC int pcieRecvFromSW(PCIePacket* packet);

// DRAM Interface
extern "C" DPI_DLLESPEC void readDRAM(const int channel, const int addr, DRAMPacket* val);
extern "C" DPI_DLLESPEC void writeDRAM(const int channel, const int addr, const DRAMPacket* val);

// SoftReg Interface
extern "C" DPI_DLLESPEC uint32_t readSoftReg_recvReq(uint32_t* addr, uint32_t* isWrite, uint64_t* data);
extern "C" DPI_DLLESPEC void readSoftReg_sendResp(const uint64_t val);
extern "C" DPI_DLLESPEC void writeSoftReg(const int addr, const uint64_t val);

#endif