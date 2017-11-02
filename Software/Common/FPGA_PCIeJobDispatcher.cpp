/*
Name: FPGA_PCIeJobDispatcher.cpp
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

#include <stdint.h>
#include <concrt.h>
#include <concurrent_queue.h>
#include <vector>
#include <atomic>
#include <iostream>

#ifdef COSIM
#include "FPGACoreLib_CoSim.h"
#else
#include "../../../../Driver/Include/FPGACoreLib.h"
#pragma comment(lib, "../../../../Driver/Bin/FPGACoreLib.lib")
#include "../../../../Driver/Include/FPGAManagementLib.h"
#endif

#include "FPGA_PCIeJobDispatcher.h"

void FPGA_PCIeJobDispatcher::dispatch(void* params) {
    DispatchParams* dparams = (DispatchParams*)params;
    FPGA_HANDLE fpgaHandle = dparams->handle;
    uint32_t slot = dparams->slot;
    volatile bool* finished = dparams->finished;
    std::atomic<uint32_t>* dones = dparams->dones;
    std::mutex* printLock = dparams->printLock;
    concurrency::concurrent_queue<Job>* inputQ = dparams->inputQ;
    concurrency::concurrent_queue<Job>* outputQ = dparams->outputQ;

    FPGA_STATUS status = FPGA_STATUS_SUCCESS;
    bool useInterrupts = true;

    Job job;

    PDWORD *pInputBuffer = new PDWORD;
    PDWORD *pOutputBuffer = new PDWORD;
    DWORD* pSize = new DWORD;

    DWORD *inputBuf, *outputBuf;

    if ((status = FPGA_GetInputBufferPointer(fpgaHandle, slot, pInputBuffer)) != FPGA_STATUS_SUCCESS) {
        std::cerr << "Slot " << slot << " FPGA_GetInputBufferPointer failed" << std::endl;
        goto finish;
    };

    if ((status = FPGA_GetOutputBufferPointer(fpgaHandle, slot, pOutputBuffer)) != FPGA_STATUS_SUCCESS) {
        std::cerr << "Slot " << slot << " FPGA_GetOutputBufferPointer failed" << std::endl;
        goto finish;
    }

    inputBuf = (DWORD*)*pInputBuffer;
    outputBuf = (DWORD*)*pOutputBuffer;

    uint64_t numSent = 0;
    while (!*finished || !inputQ->empty()) {
        if (!inputQ->try_pop(job)) {
            concurrency::wait(0);
            continue;
        }

        // Clear output buffer as sanity check
        memset(outputBuf, 0, 64 * 1024);

        // If job exists, send it out
        memcpy(inputBuf, job.inputPtr, job.size);
        if ((status = FPGA_SendInputBuffer(fpgaHandle, slot, job.size, useInterrupts)) != FPGA_STATUS_SUCCESS) {
            std::cerr << "Slot " << slot << " FPGA_SendInputBuffer failed" << std::endl;
            goto finish;
        }

        // Wait for response
        BOOL isDone = false;
        while (!isDone) {
            if ((status = FPGA_GetOutputBufferDone(fpgaHandle, slot, &isDone)) != FPGA_STATUS_SUCCESS) {
                std::cerr << "Slot " << slot << " FPGA_GetOutputBufferDone failed" << std::endl;
                goto finish;
            }
            concurrency::wait(0);
        }

        DWORD size;
        if ((status = FPGA_WaitOutputBuffer(fpgaHandle, slot, pSize, useInterrupts, 0)) != FPGA_STATUS_SUCCESS) {
            std::cerr << "Slot " << slot << " FPGA_WaitOutputBuffer failed" << std::endl;
            goto finish;
        }
        size = *pSize;
        memcpy(job.outputPtr, outputBuf, size);

        if ((status = FPGA_DiscardOutputBuffer(fpgaHandle, slot)) != FPGA_STATUS_SUCCESS) {
            std::cerr << "Slot " << slot << " FPGA_DiscardOutputBuffer failed" << std::endl;
            goto finish;
        }
        outputQ->push({ size, job.inputPtr, job.outputPtr });
        concurrency::wait(0);
    }

finish:
    delete pInputBuffer;
    delete pOutputBuffer;
    delete pSize;

    dones->fetch_add(1, std::memory_order_relaxed);
    printLock->lock();
    std::cout << "Dispatch slot " << slot << ", finished = " << *finished << ", error status = " << status << ", done = " << *dones << std::endl;
    printLock->unlock();
}

void FPGA_PCIeJobDispatcher::sendJob(uint32_t slot, void* inputPtr, void* outputPtr, uint32_t size) {
    while (jobSendQueues[slot].unsafe_size() > JOBDISPATCH_QSIZE) {
        concurrency::wait(0);
    }
    jobSendQueues[slot].push({ size, inputPtr, outputPtr });
}

bool FPGA_PCIeJobDispatcher::recvJob(uint32_t slot, uint32_t& size) {
    Job job;
    bool success = jobRecvQueues[slot].try_pop(job);
    size = job.size;
    return success;
}


// TODO: CONVERT TO REGULAR THREADS! Use WinThreads?
FPGA_PCIeJobDispatcher::FPGA_PCIeJobDispatcher(FPGA_HANDLE handle, uint32_t slots) {
    fpgaHandle = handle;
    numSlots = slots;
    useInterrupts = true;
    finished = false;
    dones = 0;

    // Create job queues (TODO: improve perf with fixed-size circular queues)
    for (uint32_t i = 0; i < numSlots; i++) {
        jobSendQueues.push_back(concurrency::concurrent_queue<Job>());
        jobRecvQueues.push_back(concurrency::concurrent_queue<Job>());
    }

    // Construct dispatch options
    dispatchParams = new DispatchParams[slots];

    for (uint32_t i = 0; i < slots; i++) {
        dispatchParams[i].handle = handle;
        dispatchParams[i].slot = i;
        dispatchParams[i].finished = &finished;
        dispatchParams[i].dones = &dones;
        dispatchParams[i].printLock = &printLock;
        dispatchParams[i].inputQ = &jobSendQueues[i];
        dispatchParams[i].outputQ = &jobRecvQueues[i];

        Concurrency::CurrentScheduler::ScheduleTask(dispatch, (void*)&dispatchParams[i]);
    }

}

void FPGA_PCIeJobDispatcher::shutdown() {
    finished = true;

    while (dones != numSlots) {
        concurrency::wait(0);
    }
}

FPGA_PCIeJobDispatcher::~FPGA_PCIeJobDispatcher() {
    shutdown();
}