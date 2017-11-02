/*
Name: harness.cpp
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

#include <stdint.h>
#include <concrt.h>
#include <concurrent_queue.h>
#include <string>
#include <sstream>
#include <vector>
#include <atomic>
#include <windows.h>
#include <process.h>

#include "harness.h"

// Global variables
FPGAState* fpga;

uint64_t** mem;

concurrency::concurrent_queue<PCIePacket> pcieSwToFpgaQ;
concurrency::concurrent_queue<PCIePacket> pcieFpgaToSwQ;

// External link to testbench main function
extern int main(int argc, char* argv[]);

// Parameters to pass to the testbench main function

bool simDone = false;


// Called by initHarness(), creates argv and argc, launches software testbench thread
void mainHarness(void* unused) {

    std::string argvParams(getenv("CATAPULT_COSIM_ARGS"));
    std::cout << "Cosim arguments: " << argvParams << std::endl;

    // Create argc and argv by parsing argvParams string
    std::string buf;
    std::stringstream ss(argvParams);
    std::vector<std::string> tokens;

    // Break argvParams string into tokens
    while (ss >> buf)
        tokens.push_back(buf);

    unsigned argc = tokens.size();

    // Create argv character array
    char** argv = new char*[argc];
    argv[0] = (char*)argvParams.c_str();

    for (int i = 1; i < argc; i++) {
        argv[i] = new char[100];
        argv[i] = (char*)tokens[i].c_str();
    }

    // Call testbench main function
    main(argc, argv);

    // Mark software test as finished so simulation can end
    simDone = true;
}


// Called in SimTop.sv, initializes data structures and launches software testbench thread
extern "C" DPI_DLLESPEC void initHarness() {
    std::cout << "Initializing C harness\n" << std::flush;

    pcieSwToFpgaQ.clear();
    pcieFpgaToSwQ.clear();

    fpga = new FPGAState(64, 64 * 1024);

    // Allocate memory for DRAM
    mem = new uint64_t*[2];
    mem[0] = new uint64_t[MEM_ALLOC_PER_CHANNEL / sizeof(uint64_t)];
    mem[1] = new uint64_t[MEM_ALLOC_PER_CHANNEL / sizeof(uint64_t)];

    // Start software process
    std::cout << "Spawning simThread" << std::endl;

    HANDLE threadHandle = (HANDLE)_beginthread(mainHarness, 0, NULL);
    std::cout << "Done spawning simThread, exiting harness initialization" << std::endl;
}


// Called in SimTop.sv, for software testbench completion
extern "C" DPI_DLLESPEC int checkDone() {
    return simDone;
}


// Called in SimTop.sv, returns True (1) if successfully wrote to software slot
extern "C" DPI_DLLESPEC int pcieSendToSW(const PCIePacket* packet) {

    // If writing to a full buffer, stall
    if (fpga->outputBufDones[packet->slot]) {
        return 0;
    }

    // Packets should be contiguous; slot num should not change if not finished
    assert(!fpga->outputFSM_started || (packet->slot == fpga->outputFSM_slot));

    // Maximum slot size 64KB = 8192 64-bit entries
    assert(fpga->outputFSM_ptr <= 8192 - 16);

    // If writing new buffer, init
    if (!fpga->outputFSM_started) {
        fpga->outputFSM_started = true;
        fpga->outputFSM_slot = packet->slot;
        fpga->outputFSM_ptr = 0;
    }
    //std::cout << "PCIe sending packet " << (fpga->outputFSM_ptr >> 1) << " data " << std::hex<<packet->data0<<", " << packet->data1<<std::dec << " to SW" << ", last: " << packet->last << std::endl;

    // Write 128-bits (16B) of data
    fpga->outputBufs[packet->slot][fpga->outputFSM_ptr] = packet->data0;
    fpga->outputBufs[packet->slot][fpga->outputFSM_ptr + 1] = packet->data1;

    fpga->outputFSM_ptr += 2;

    if (packet->last) {
        fpga->outputBufDones[packet->slot] = true;
        fpga->outputBufSizes[packet->slot] = fpga->outputFSM_ptr << 3;
        fpga->outputFSM_started = false;
        fpga->outputFSM_slot = -1;
        fpga->outputFSM_ptr = 0;
    }

    return 1;
}

// Called in SimTop.sv, returns True (1) if PCIe has data available to be read
extern "C" DPI_DLLESPEC int pcieValidFromSW() {
    return !pcieSwToFpgaQ.empty();
}

// Called in SimTop.sv, returns True (1) if successfully received PCIe packet
extern "C" DPI_DLLESPEC int pcieRecvFromSW(PCIePacket* packet) {
    return pcieSwToFpgaQ.try_pop(*packet);
}

// Called in SimTop.sv, writes a 512-bit DRAM line to the proper channel and address
// Currently does not support writes to the full 4GB address space due to Modelsim being 32-bit
extern "C" DPI_DLLESPEC void writeDRAM(const int channel, const int addr, const DRAMPacket* val) {
    assert(channel < 2);
    int idx = addr / sizeof(uint64_t);
    assert(idx < MEM_ALLOC_PER_CHANNEL / sizeof(uint64_t));
    //std::cout << "Writing DRAM [" << channel << "][" << idx << "] = " << std::hex << val->data0 << " " << val->data1 << std::dec << std::endl;

    mem[channel][idx + 0] = val->data0;
    mem[channel][idx + 1] = val->data1;
    mem[channel][idx + 2] = val->data2;
    mem[channel][idx + 3] = val->data3;
    mem[channel][idx + 4] = val->data4;
    mem[channel][idx + 5] = val->data5;
    mem[channel][idx + 6] = val->data6;
    mem[channel][idx + 7] = val->data7;
}

// Called in SimTop.sv, reads a 512-bit DRAM line from the proper channel and address
// Currently does not support reads to the full 4GB address space due to Modelsim being 32-bit
extern "C" DPI_DLLESPEC void readDRAM(const int channel, const int addr, DRAMPacket* val) {
    assert(channel < 2);
    int idx = addr / sizeof(uint64_t);
    assert(idx < MEM_ALLOC_PER_CHANNEL / sizeof(uint64_t));

    val->data0 = mem[channel][idx + 0];
    val->data1 = mem[channel][idx + 1];
    val->data2 = mem[channel][idx + 2];
    val->data3 = mem[channel][idx + 3];
    val->data4 = mem[channel][idx + 4];
    val->data5 = mem[channel][idx + 5];
    val->data6 = mem[channel][idx + 6];
    val->data7 = mem[channel][idx + 7];
    //std::cout << "Reading DRAM [" << channel << "][" << idx << "] = " << std::hex << val->data0 << " " << val->data1 << std::dec << std::endl;
}


// Called in SimTop.sv, performs a softreg read request (split phase)
extern "C" DPI_DLLESPEC uint32_t readSoftReg_recvReq(uint32_t* addr, uint32_t* isWrite, uint64_t* writeData) {

    do { concurrency::wait(0); } while (atomic_flag_test_and_set(&fpga->softReg_lock));
    if (fpga->softRegReq_valid) {
        fpga->softRegReq_valid = false;
        *addr = fpga->softRegReq_addr;
        *isWrite = fpga->softRegReq_isWrite;
        *writeData = fpga->softRegReq_writeData;
        //std::cout << "Harness found valid readSoftReg request to addr " << *addr << std::endl;

        atomic_flag_clear(&fpga->softReg_lock);
        return 1;
    }

    atomic_flag_clear(&fpga->softReg_lock);
    return 0;
}

// Called in SimTop.sv, performs a softreg read response (split phase)
extern "C" DPI_DLLESPEC void readSoftReg_sendResp(const uint64_t value) {
    bool done = false;
    while (!done) {
        do { concurrency::wait(0); } while (atomic_flag_test_and_set(&fpga->softReg_lock));
        if (!fpga->softRegResp_valid) {
            fpga->softRegResp_valid = true;
            fpga->softRegResp_data = value;
            done = true;
        }
        atomic_flag_clear(&fpga->softReg_lock);
    }
}

// Called in harness.cpp, initializes simulated Catapult architectural state
FPGAState::FPGAState(uint32_t numBufs, uint32_t bufSize) {
    this->numBufs = numBufs;
    this->bufSize = bufSize;

    outputFSM_started = false;
    outputFSM_ptr = 0;
    outputFSM_slot = -1;

    //std::cout << "Initializing " << numBufs << " inputBufs" << std::endl;
    inputBufs = (volatile uint64_t**)(new uint64_t*[numBufs]);
    outputBufs = (volatile uint64_t**)(new uint64_t*[numBufs]);

    inputBufFulls = new volatile bool[numBufs];
    outputBufDones = new volatile bool[numBufs];

    inputBufSizes = new volatile uint32_t[numBufs];
    outputBufSizes = new volatile uint32_t[numBufs];

    // Initialize SoftReg
    atomic_flag_clear(&softReg_lock);
    softRegReq_valid = false;
    softRegResp_valid = false;

    for (uint32_t i = 0; i < numBufs; i++) {
        inputBufs[i] = new uint64_t[bufSize / sizeof(uint64_t)];
        outputBufs[i] = new uint64_t[bufSize / sizeof(uint64_t)];

        inputBufFulls[i] = false;
        outputBufDones[i] = false;
    }
}

FPGAState::~FPGAState() {
    for (uint32_t i = 0; i < numBufs; i++) {
        delete[] inputBufs[i];
        delete[] outputBufs[i];
    }

    delete[] inputBufs;
    delete[] outputBufs;
    delete[] inputBufFulls;
    delete[] outputBufDones;
    delete[] inputBufSizes;
    delete[] outputBufSizes;
}
