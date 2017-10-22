/*
Name: SimpleDram.sv
Description: Converts UMI memory requests to SimpleDRAM memory requests. Simplifies flow control.

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


module SimpleDram
(
    // User clock and reset
    input                               clk,
    input                               rst, 
    
    
    // User Memory Interface (UMI)
    output UMIReq                       umi_req_out,
    input                               umi_req_grant_in,
    output UMIWriteData                 umi_write_out,
    input                               umi_write_ready_in,
    input UMIReadData                   umi_read_in,
    output                              umi_read_grant_out,
    
    // Simplified Memory Interface
    input MemReq                        mem_req_in,
    output                              mem_req_grant_out,
    output MemResp                      mem_resp_out,
    input                               mem_resp_grant_in
);

    wire             reqQ_empty;
    wire             reqQ_full;
    wire             reqQ_enq;
    wire             reqQ_deq;
    MemReq           reqQ_in;
    MemReq           reqQ_out;
    
    FIFO
    #(
        .WIDTH                  ($bits(MemReq)),
        .LOG_DEPTH              (9)
    )
    memReqQ
    (
        .clock                  (clk),
        .reset_n                (~rst),
        .wrreq                  (reqQ_enq),
        .data                   (reqQ_in),
        .full                   (reqQ_full),
        .q                      (reqQ_out),
        .empty                  (reqQ_empty),
        .rdreq                  (reqQ_deq)
    );
    
    wire             respQ_empty;
    wire             respQ_full;
    wire             respQ_enq;
    wire             respQ_deq;
    MemResp           respQ_in;
    MemResp           respQ_out;
    
    reg [31:0]       respQ_size; // Max should be set to same as FIFO queue size
    wire [31:0]      next_respQ_size;
    
    
    FIFO
    #(
        .WIDTH                  ($bits(MemResp)),
        .LOG_DEPTH              (9)
    )
    memReadRespQ
    (
        .clock                  (clk),
        .reset_n                (~rst),
        .wrreq                  (respQ_enq),
        .data                   (respQ_in),
        .full                   (respQ_full),
        .q                      (respQ_out),
        .empty                  (respQ_empty),
        .rdreq                  (respQ_deq)
    );
    
    wire incSize;
    wire decSize;
    
    assign reqQ_enq = mem_req_in.valid && !reqQ_full;
    assign reqQ_in = mem_req_in;
    
    assign reqQ_deq = umi_req_grant_in;
    assign mem_req_grant_out = reqQ_enq;
    
    wire validWrite = !reqQ_empty && reqQ_out.isWrite && umi_write_ready_in;
    wire validRead = !reqQ_empty && !reqQ_out.isWrite && (respQ_size < 32'd512);
    wire validReq = validWrite || validRead;
    
    assign umi_req_out = '{valid: validReq, isWrite: validWrite, addr: reqQ_out.addr, size: 64'd64};
    
    assign umi_write_out = '{valid: validWrite && umi_req_grant_in, data: reqQ_out.data};
    
    assign respQ_enq = umi_read_in.valid && !respQ_full;
    assign respQ_in = '{valid: umi_read_in.valid, data: umi_read_in.data};
    
    assign respQ_deq = mem_resp_grant_in && !respQ_empty;
    assign mem_resp_out = '{valid: !respQ_empty, data: respQ_out.data};
    assign umi_read_grant_out = respQ_enq;
    
    // Allocate response queue entries prior to sending requests
    assign incSize = validRead && umi_req_grant_in;
    assign decSize = respQ_deq;
    
    assign next_respQ_size = (incSize && !decSize) ? respQ_size + 1 : ((!incSize && decSize) ? respQ_size - 1 : respQ_size);
    
    always@(posedge clk) begin
        if(rst) begin
            respQ_size <= 32'd0;
        end
        else begin
            respQ_size <= next_respQ_size;
        end
    end
    
endmodule
    