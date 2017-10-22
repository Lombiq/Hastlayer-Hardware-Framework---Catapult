/*
Name: Role.sv
Description: Catapult generic role wrapper. Users should put their code in SimpleRole.sv instead.

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
import SL3Types::*;

module Role
#(parameter NUM_UMI = 2)
(
    // User clock and reset
    input                               clk,
    input                               rst, 

    input                               pcie_clk,
    input                               ddr_clk,

    // User-generated shell
    output                              umi_usr_clk,
    output                              pcie_usr_clk,


    // User Memory Interface (UMI)
    output                              umi_raise_out  [NUM_UMI-1:0],
    output                              umi_write_out  [NUM_UMI-1:0],
    output [UMI_ADDR_WIDTH-1:0]         umi_addr_out   [NUM_UMI-1:0],
    output [UMI_ADDR_WIDTH-1:0]         umi_size_out   [NUM_UMI-1:0],
    input                               umi_grant_in   [NUM_UMI-1:0],

    input  [UMI_DATA_WIDTH-1:0]         umi_rddata_in  [NUM_UMI-1:0],
    input                               umi_rdrdy_in   [NUM_UMI-1:0],
    output                              umi_rden_out   [NUM_UMI-1:0],

    output [UMI_DATA_WIDTH-1:0]         umi_wrdata_out [NUM_UMI-1:0],
    output [UMI_MASK_WIDTH-1:0]         umi_wrmask_out [NUM_UMI-1:0],
    output                              umi_wren_out   [NUM_UMI-1:0],
    input                               umi_wrrdy_in   [NUM_UMI-1:0],

    // PCIe Slot DMA Interface
    input  [PCIE_DATA_WIDTH-1:0]        pcie_data_in,
    input  [PCIE_SLOT_WIDTH-1:0]        pcie_slot_in,
    input  [PCIE_PAD_WIDTH-1:0]         pcie_padbytes_in,
    input                               pcie_last_in,
    output                              pcie_full_out,
    input                               pcie_wren_in,

    output [PCIE_DATA_WIDTH-1:0]        pcie_data_out,
    output [PCIE_SLOT_WIDTH-1:0]        pcie_slot_out,
    output [PCIE_PAD_WIDTH-1:0]         pcie_padbytes_out,
    output                              pcie_last_out,
    input                               pcie_rden_in,
    output                              pcie_empty_out,

    // Soft-shell emulated version and status registers
    output [31:0]                       id_out,
    output [31:0]                       version_out,
    output [31:0]                       status_out,
    
    // Version and status registers
    output [31:0]                       role_id_out,
    output [31:0]                       role_version_out,
    output [31:0]                       role_status_out,

    // Soft shell register interface    
    input                               softreg_read_in,
    input                               softreg_write_in,
    input  [31:0]                       softreg_addr_in,
    input  [63:0]                       softreg_wrdata_in,
    output logic [63:0]                 softreg_rddata_out,
    output logic                        softreg_rdvalid_out,

    input                               sl_rx_clk_in [3:0],
    input                               sl_tx_clk_in [3:0],

    //Data from Serial Links
    input SL3DataInterface              sl_rx_in [3:0],

    //Data to Serial Links
    output SL3DataInterface             sl_tx_out [3:0],
    input                               sl_tx_stall_in [3:0],
    
    //OOB from Serial Links
    input SL3OOBInterface               sl_rx_oob_in [3:0],

    //OOB to Serial Links
    output SL3OOBInterface              sl_tx_oob_out [3:0],
    input                               sl_tx_oob_rden_in [3:0]
);

    // Fake soft shell status registers
    assign status_out                   = 32'h1;
    assign id_out                       = 32'h9A55;     // "Pass"-through
    assign version_out                  = 32'h00020000; // Major 2, minor 0 
    
    assign role_id_out                  = 32'h1009;
    assign role_version_out             = 32'hACAD0001;
    assign role_status_out              = 32'h1;
    
    // Convert PCIe to struct-based interface
    PCIEPacket pcie_packet_in;
    assign pcie_packet_in = '{valid: pcie_wren_in, data: pcie_data_in, slot: pcie_slot_in, 
                              pad: pcie_padbytes_in, last: pcie_last_in};
    
    PCIEPacket pcie_packet_out;
    assign pcie_empty_out = !pcie_packet_out.valid;
    assign pcie_data_out = pcie_packet_out.data;
    assign pcie_slot_out = pcie_packet_out.slot;
    assign pcie_padbytes_out = pcie_packet_out.pad;
    assign pcie_last_out = pcie_packet_out.last;

    // Convert SoftReg to struct-based interface
    SoftRegReq softreg_req;
    assign softreg_req = '{valid: softreg_read_in || softreg_write_in, isWrite: softreg_write_in, addr: softreg_addr_in, data: softreg_wrdata_in};
    
    SoftRegResp softreg_resp;
    assign softreg_rdvalid_out = softreg_resp.valid;
    assign softreg_rddata_out = softreg_resp.data;
    
    // Configure UMI to struct-based interface
    
    UMIReq       umi_req       [NUM_UMI-1:0];
    UMIWriteData umi_writeData [NUM_UMI-1:0];
    UMIReadData  umi_readData  [NUM_UMI-1:0];
    
    genvar i;
    generate
        for(i=0; i < NUM_UMI; i=i+1) begin : umi_connections
            assign umi_raise_out[i] = umi_req[i].valid;
            assign umi_write_out[i] = umi_req[i].isWrite;
            assign umi_addr_out[i]  = umi_req[i].addr;
            assign umi_size_out[i]  = umi_req[i].size;
            
            assign umi_wrmask_out[i] = 0; // unused
            
            assign umi_readData[i] = '{valid: umi_rdrdy_in[i], data: umi_rddata_in[i]};
            
            assign umi_wren_out[i] = umi_writeData[i].valid;
            assign umi_wrdata_out[i] = umi_writeData[i].data;
        end
    endgenerate
  
    // Convert UMI requests to simple DRAM requests
    
    MemReq  mem_reqs        [1:0];
    wire    mem_req_grants  [1:0];
    MemResp mem_resps       [1:0];
    wire    mem_resp_grants [1:0];
    
    generate
        for(i=0; i < 2; i=i+1) begin : simpleDrams
            if(i < NUM_UMI) begin
                SimpleDram dram0
                (
                // User clock and reset
                .clk(clk),
                .rst(rst), 
    
                // User Memory Interface (UMI)
                .umi_req_out(umi_req[i]),
                .umi_req_grant_in(umi_grant_in[i]),
                .umi_write_out(umi_writeData[i]),
                .umi_write_ready_in(umi_wrrdy_in[i]),
                .umi_read_in(umi_readData[i]),
                .umi_read_grant_out(umi_rden_out[i]),
    
                // Simplified Memory Interface
                .mem_req_in(mem_reqs[i]),
                .mem_req_grant_out(mem_req_grants[i]),
                .mem_resp_out(mem_resps[i]),
                .mem_resp_grant_in(mem_resp_grants[i])
                );
            end
            else begin
                assign mem_req_grants[i] = 1'b0;
                assign mem_resps[i] = '{valid: 1'b0, data: 512'b0};
            end
        end
    endgenerate

    
    // Deal with SL3 clock domain crossing
    
    // SL3 receive
    SL3DataInterface  sl_rx_role           [3:0];
    logic             sl_rx_grant_role     [3:0];
    SL3OOBInterface   sl_rx_oob_role       [3:0];
    logic             sl_rx_oob_grant_role [3:0];
    
    // SL3 transmit
    SL3DataInterface  sl_tx_role           [3:0];
    logic             sl_tx_full_role      [3:0];
    SL3OOBInterface   sl_tx_oob_role       [3:0];
    logic             sl_tx_oob_full_role  [3:0];
    
    genvar port;
    generate for(port = 0; port < 4; port = port + 1) begin : port_fifos
        logic txempty;
        logic txemptyoob;
        logic rxempty;
        logic rxemptyoob;
        
        shell_async_fifo #(
            .LOG_DEPTH(8),
            .WIDTH(PHIT_WIDTH+1)
        ) porttx (
            .aclr(rst),
            .wrclk(clk),
            .wrreq(sl_tx_role[port].valid),
            .wrfull(sl_tx_full_role[port]),
            .data({sl_tx_role[port].last, sl_tx_role[port].data}),
            
            .rdclk(sl_tx_clk_in[port]),
            .rdreq(!txempty && !sl_tx_stall_in[port]),
            .q({sl_tx_out[port].last, sl_tx_out[port].data}),
            .rdempty(txempty)
        );

        assign sl_tx_out[port].valid = !txempty;


        shell_async_fifo #(
            .LOG_DEPTH(8),
            .WIDTH(15)
        ) porttxoob (
            .aclr(rst),
            .wrclk(clk),
            .wrreq(sl_tx_oob_role[port].valid),
            .wrfull(sl_tx_oob_full_role[port]),
            .data(sl_tx_oob_role[port].data),
            
            .rdclk(sl_tx_clk_in[port]),
            .rdreq(!txemptyoob && sl_tx_oob_rden_in[port]),
            .q(sl_tx_oob_out[port].data),
            .rdempty(txemptyoob)
        );

        assign sl_tx_oob_out[port].valid = !txemptyoob;


        shell_async_fifo #(
            .LOG_DEPTH(8),
            .WIDTH(PHIT_WIDTH+1)
        ) portrx (
            .aclr(rst),
            .wrclk(sl_rx_clk_in[port]),
            .wrreq(sl_rx_in[port].valid),
            .data({sl_rx_in[port].last, sl_rx_in[port].data}),

            .rdclk(clk),
            .rdreq(sl_rx_grant_role[port]),
            .q({sl_rx_role[port].last, sl_rx_role[port].data}),
            .rdempty(rxempty)
        );

        assign sl_rx_role[port].valid = !rxempty;


        shell_async_fifo #(
            .LOG_DEPTH(8),
            .WIDTH(15)
        ) portrxoob (
            .aclr(rst),
            .wrclk(sl_rx_clk_in[port]),
            .wrreq(sl_rx_oob_in[port].valid),
            .data(sl_rx_oob_in[port].data),

            .rdclk(clk),
            .rdreq(sl_rx_oob_grant_role[port]),
            .q(sl_rx_oob_role[port].data),
            .rdempty(rxemptyoob)
        );

        assign sl_rx_oob_role[port].valid = !rxemptyoob;
    end
    endgenerate
    
    

    assign umi_usr_clk    = clk;
    assign pcie_usr_clk   = clk;

    SimpleRole simplerole
    (
        .clk(clk),
        .rst(rst), 

        // User Memory Interface (UMI)
        .mem_reqs(mem_reqs),
        .mem_req_grants(mem_req_grants),
        .mem_resps(mem_resps),
        .mem_resp_grants(mem_resp_grants),

        // PCIe Slot DMA Interface
        .pcie_packet_in(pcie_packet_in),
        .pcie_full_out(pcie_full_out),

        .pcie_packet_out(pcie_packet_out),
        .pcie_grant_in(pcie_rden_in),

        // Soft register interface
        .softreg_req(softreg_req),
        .softreg_resp(softreg_resp),

        // SerialLite III interface
        .sl_tx_out(sl_tx_role),
        .sl_tx_full_in(sl_tx_full_role),
        .sl_tx_oob_out(sl_tx_oob_role),
        .sl_tx_oob_full_in(sl_tx_oob_full_role),
        
        .sl_rx_in(sl_rx_role),
        .sl_rx_grant_out(sl_rx_grant_role),
        .sl_rx_oob_in(sl_rx_oob_role),
        .sl_rx_oob_grant_out(sl_rx_oob_grant_role)
    );


endmodule