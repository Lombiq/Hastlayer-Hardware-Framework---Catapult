/*
Name: DramInterleaver.sv
Description: Runtime-configurable DRAM interleaver. Currently does not handle read response reordering across channels.

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

import ShellTypes::*;

module DramInterleaver
(
    // User clock and reset
    input                               clk,
    input                               rst, 
    
    // Config
    input DramInterleaverConfig         config_in,
    
    // Input interface
    input MemReq                        mem_req_in,
    output reg                          mem_req_grant_out,
    output MemResp                      mem_resp_out,
    input                               mem_resp_grant_in,
    
    // Output interfaces
    output MemReq                       mem_req_c0_out,
    input                               mem_req_grant_c0_in,
    input MemResp                       mem_resp_c0_in,
    output reg                          mem_resp_grant_c0_out,
    
    output MemReq                       mem_req_c1_out,
    input                               mem_req_grant_c1_in,
    input MemResp                       mem_resp_c1_in,
    output reg                          mem_resp_grant_c1_out
);

    DramInterleaverMode mode;
    DramInterleaverMode next_mode;
    MemReq    req_interleaved;
    reg[63:0] addr_interleaved;
    
    wire             reqQ_empty;
    wire             reqQ_full;
    wire             reqQ_enq;
    wire             reqQ_deq;
    wire             reqQ_in;
    wire             reqQ_out;
    
    
    FIFO
    #(
        .WIDTH                  (1),
        .LOG_DEPTH              (9)
    )
    reqQ
    (
        .clock                  (clk),
        .reset_n                (~rst),
        .wrreq                  (reqQ_enq),
        .data                   (reqQ_in),
        .full                   (reqQ_full),
        .q                      (reqQ_out),
        .empty                  (reqQ_empty),
        .rdreq                  (reqQ_deq),
        .almost_full(),
        .almost_empty(),
        .usedw()
    );
    
    wire       resp0Q_enq;
    MemResp    resp0Q_in;
    wire       resp0Q_full;
    MemResp    resp0Q_out;
    wire       resp0Q_empty;
    wire       resp0Q_deq;
    
    FIFO
    #(
        .WIDTH                  ($bits(MemResp)),
        .LOG_DEPTH              (9)
    )
    resp0Q
    (
        .clock                  (clk),
        .reset_n                (~rst),
        .wrreq                  (resp0Q_enq),
        .data                   (resp0Q_in),
        .full                   (resp0Q_full),
        .q                      (resp0Q_out),
        .empty                  (resp0Q_empty),
        .rdreq                  (resp0Q_deq),
        .almost_full(),
        .almost_empty(),
        .usedw()
    );
    
    always@* begin
        mem_req_grant_out = 1'b0;
        mem_resp_out = '{valid: 1'b0, data: 512'b0};
        
        mem_req_c0_out = '{valid: 1'b0, isWrite: 1'b0, addr: 64'b0, data: 512'b0};
        mem_resp_grant_c0_out = 1'b0;
        
        mem_req_c1_out = '{valid: 1'b0, isWrite: 1'b0, addr: 64'b0, data: 512'b0};
        mem_resp_grant_c1_out = 1'b0;
        
        next_mode = mode;
        
        if(config_in.valid) begin
            next_mode = config_in.mode;
        end
        
        // Each 64B line is interleaved across the two channels
        addr_interleaved = {1'b0, mem_req_in.addr[63:7], mem_req_in.addr[5:0]};
        req_interleaved = '{valid: mem_req_in.valid, isWrite: mem_req_in.isWrite, addr: addr_interleaved, data: mem_req_in.data};
        
        // Prioritize channel 0 responses over channel 1
        // TODO: DEAL WITH MEMORY CHANNEL REORDERING
        if(mem_resp_c0_in.valid) begin
            mem_resp_out = mem_resp_c0_in;
            mem_resp_grant_c0_out = mem_resp_grant_in;
        end
        else if(mem_resp_c1_in.valid) begin
            mem_resp_out = mem_resp_c1_in;
            mem_resp_grant_c1_out = mem_resp_grant_in;
        end
        
        // Process requests
        if(mode == CHAN0_ONLY) begin
            mem_req_c0_out = mem_req_in;
            mem_req_grant_out = mem_req_grant_c0_in;
        end
        else if(mode == CHAN1_ONLY) begin
            mem_req_c1_out = mem_req_in;
            mem_req_grant_out = mem_req_grant_c1_in;
        end
        else if(mode == INTERLEAVED) begin
            if(mem_req_in.addr[6] == 0) begin
                mem_req_c0_out = req_interleaved;
                mem_req_grant_out = mem_req_grant_c0_in;
            end
            else begin
                mem_req_c1_out = req_interleaved;
                mem_req_grant_out = mem_req_grant_c1_in;
            end
        end
    end
    
    always@(posedge clk) begin
        if(rst) begin
            mode <= CHAN0_ONLY;
        end
        else begin
            mode <= next_mode;
        end
    end
endmodule
