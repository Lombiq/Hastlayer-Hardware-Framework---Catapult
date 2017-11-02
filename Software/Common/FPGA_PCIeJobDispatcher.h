/*
Name: FPGA_PCIeJobDispatcher.h
Description: Catapult PCIe job dispatcher, wraps up FPGA API calls

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

#ifndef __FPGA_JOB_DISPATCHER_H_
#define __FPGA_JOB_DISPATCHER_H_

#include <stdint.h>
#include <concrt.h>
#include <concurrent_queue.h>
#include <vector>
#include <atomic>
#include <mutex>

#ifdef COSIM
#include "FPGACoreLib_CoSim.h"
#else
#include "../../../../Driver/Include/FPGACoreLib.h"
#pragma comment(lib, "../../../../Driver/Bin/FPGACoreLib.lib")
#include "../../../../Driver/Include/FPGAManagementLib.h"
#endif

#define JOBDISPATCH_QSIZE 1024

class FPGA_PCIeJobDispatcher {
private:
    typedef struct {
        uint32_t size;
        void* inputPtr;
        void* outputPtr;
    } Job;


    typedef struct {
        FPGA_HANDLE handle;
        uint32_t slot;
        volatile bool* finished;
        std::atomic<uint32_t>* dones;
        std::mutex* printLock;
        concurrency::concurrent_queue<Job>* inputQ;
        concurrency::concurrent_queue<Job>* outputQ;
    } DispatchParams;

    uint32_t numSlots;
    FPGA_HANDLE fpgaHandle;
    DispatchParams* dispatchParams;
    std::atomic<uint32_t> dones;
    std::mutex printLock;

    bool useInterrupts;
    volatile bool finished;

    std::vector<concurrency::concurrent_queue<Job> > jobSendQueues;
    std::vector<concurrency::concurrent_queue<Job> > jobRecvQueues;

    static void dispatch(void* params);
public:
    FPGA_PCIeJobDispatcher(FPGA_HANDLE handle, uint32_t slots);
    ~FPGA_PCIeJobDispatcher();
    void sendJob(uint32_t slot, void* inputPtr, void* outputPtr, uint32_t size);
    bool recvJob(uint32_t slot, uint32_t& size);
    void shutdown();
};


#endif