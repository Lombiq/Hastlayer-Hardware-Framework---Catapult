/*
Name: SimpleRole.sv
Description: HastIp.vhd wrapper for Catapult
*/
 

import ShellTypes::*;
import SL3Types::*;


module SimpleRole
(
    // User clock and reset
    input                               clk,
    input                               rst, 

    // Simplified Memory interface
    output MemReq                       mem_reqs        [1:0],
    input                               mem_req_grants  [1:0],
    input MemResp                       mem_resps       [1:0],
    output                              mem_resp_grants [1:0],

    // PCIe Slot DMA interface
    input PCIEPacket                    pcie_packet_in,
    output reg                             pcie_full_out,

    output PCIEPacket                   pcie_packet_out,
    input                               pcie_grant_in,

    // Soft register interface
    input SoftRegReq                    softreg_req,
    output SoftRegResp                  softreg_resp,
    
    // SerialLite III interface
    output SL3DataInterface             sl_tx_out           [3:0],
    input                               sl_tx_full_in       [3:0],
    output SL3OOBInterface              sl_tx_oob_out       [3:0],
    input                               sl_tx_oob_full_in   [3:0],

    input SL3DataInterface              sl_rx_in            [3:0],
    output                              sl_rx_grant_out     [3:0],
    input SL3OOBInterface               sl_rx_oob_in        [3:0],
    output                              sl_rx_oob_grant_out [3:0]
);

    // Disable SL3 links
    genvar i;
    generate
        for(i = 0; i < 4; i=i+1) begin: disableSL3
            assign sl_tx_out[i] = '{valid: 1'b0, data: 128'b0, last: 1'b0};
            assign sl_tx_oob_out[i] = '{valid: 1'b0, data: 15'b0};
            assign sl_rx_grant_out[i] = 1'b0;
            assign sl_rx_oob_grant_out[i] = 1'b0;
        end
    endgenerate
    
    // Set up DRAM interleaver
    DramInterleaverConfig dramConfig;
    MemReq  mem_interleaved_req;
    wire    mem_interleaved_req_grant;
    MemResp mem_interleaved_resp;
    reg     mem_interleaved_resp_grant;
    
    DramInterleaver interleaver
    (
    // User clock and reset
    .clk(clk),
    .rst(rst),
    
    // Config
    .config_in(dramConfig),
    
    // Input interface
    .mem_req_in(mem_interleaved_req),
    .mem_req_grant_out(mem_interleaved_req_grant),
    .mem_resp_out(mem_interleaved_resp),
    .mem_resp_grant_in(mem_interleaved_resp_grant),
    
    // Output interfaces
    .mem_req_c0_out(mem_reqs[0]),
    .mem_req_grant_c0_in(mem_req_grants[0]),
    .mem_resp_c0_in(mem_resps[0]),
    .mem_resp_grant_c0_out(mem_resp_grants[0]),
    
    .mem_req_c1_out(mem_reqs[1]),
    .mem_req_grant_c1_in(mem_req_grants[1]),
    .mem_resp_c1_in(mem_resps[1]),
    .mem_resp_grant_c1_out(mem_resp_grants[1])
    );

    // Report events 
    always @(negedge clk) begin
      if (0) begin // disabled
        if (softreg_req.valid) begin
          $display("%0d: softreg_req: addr = %x, data = %x, isWrite = %d", $time, softreg_req.addr, softreg_req.data, softreg_req.isWrite);
        end
        if (pcie_packet_in.valid) begin
          $display("%0d: pcie_packet_in: slot: %d, data: %x, last: %d", $time, pcie_packet_in.slot, pcie_packet_in.data, pcie_packet_in.last);
        end
        if (pcie_packet_out.valid) begin
          $display("%0d: pcie_packet_out: slot: %d, data: %x, last: %d", $time, pcie_packet_out.slot, pcie_packet_out.data, pcie_packet_out.last);
        end
        if (mem_interleaved_req.valid) begin
          $display("%0d: mem_interleaved_req: isWrite: %d, addr: %x, data: %x", $time, mem_interleaved_req.isWrite, mem_interleaved_req.addr, mem_interleaved_req.data);
        end
        if (mem_interleaved_resp.valid) begin
          $display("%0d: mem_interleaved_resp: data: %x", $time, mem_interleaved_resp.data);
        end
      end
    end
    
    // Debug counter
    reg[31:0] debug_counter;
    always @(posedge clk) begin
        if (rst) begin
            debug_counter = 0;
        end
        else begin
          debug_counter = debug_counter + 1;
        end
    end
        
    // Hast_IP.vhd

    reg [7:0] ALLOWED_SLOTS = 4;
    reg [15:0] ALLOWED_BYTES_PER_SLOT = 16'h0100;
    
    // parameter ALLOWED_SLOTS = 64;
    // parameter ALLOWED_BYTES_PER_SLOT = 16'hFF80;

    parameter HAST_IP_DATA_WIDTH = 512;
    parameter HAST_IP_MEMBER_ID = 0;
    
    // localparam FPGA_USER_CLOCK = `FPGA_USER_CLOCK;

    reg  [HAST_IP_DATA_WIDTH-1:0]  hastipDataIn;
    wire [HAST_IP_DATA_WIDTH-1:0]  hastipDataOut;
    integer      hastipCellIndex;
    wire         hastipReadEnable;
    wire         hastipWriteEnable;
    reg          hastipReadsDone;
    reg          hastipWritesDone;
    integer      hastipMemberId;
    reg          hastipStarted;
    wire         hastipFinished;

	Hast_ip hastip
	(
		.DataIn      (hastipDataIn),
		.DataOut     (hastipDataOut),
		.CellIndex   (hastipCellIndex),
		.ReadEnable  (hastipReadEnable),
		.WriteEnable (hastipWriteEnable),
		.ReadsDone   (hastipReadsDone),
		.WritesDone  (hastipWritesDone),
		.MemberId    (hastipMemberId),
		.Reset       (rst),
		.Started     (hastipStarted),
		.Finished    (hastipFinished),
		.Clock       (clk)
	);
    
    // Main state machine
    
    typedef enum {
        IDLE,
        PCIE_RECV_HEADER,
        PCIE_RECV_0,
        PCIE_RECV_1,
        PCIE_RECV_2,
        PCIE_RECV_3,
        PCIE_RECV_MWR,
        RUN,
        RUN_RD_REQ,
        RUN_RD_WAIT,
        RUN_WR_REQ,
        RUN_WR_WAIT,
        PCIE_SEND_HEADER,
        PCIE_SEND_MRD_REQ,
        PCIE_SEND_MRD_WAIT,
        PCIE_SEND_0,
        PCIE_SEND_1,
        PCIE_SEND_2,
        PCIE_SEND_3,
        PCIE_SEND_DONE,
        DONE,
        PCIE_SEND_ACK_0,
        PCIE_SEND_ACK_1,
        LAST
    } FSMState;
    
    FSMState state = IDLE;
    reg [PCIE_SLOT_WIDTH-1:0] headerSlotId;
    reg[31:0] headerMemberId;
    reg[31:0] headerDataLengthBytes;
    reg[31:0] headerSliceIndex;
    reg[31:0] headerSliceCount;
    reg[63:0] writeAddr;
    reg[63:0] readAddr;
    reg[31:0] acceptedSliceCount;
    reg[63:0] receivedByteCount;
    reg pcie_packet_in_last;
    
    reg[31:0] readLen;

    reg[63:0] hastipRunCounter;
    reg[63:0] hastipRunTime;
        
    always @(posedge clk) begin
        if (rst) begin
            state = IDLE;
        end
        else begin
            hastipRunCounter = hastipRunCounter + 1;
            case (state)
            
                IDLE:
                    begin
                        hastipMemberId = headerMemberId; // HAST_IP_MEMBER_ID;
                        hastipStarted = 0;
                        hastipReadsDone = 0;
                        hastipWritesDone = 0;
                        hastipDataIn = 32'd0;
                        pcie_full_out = 1'b0;
                        pcie_packet_out = '{valid: 1'b0, data: 128'b0, slot: 16'd17, pad: 4'b0, last: 1'b0};
                        mem_interleaved_req = '{valid: 1'b0, isWrite: 1'b0, addr: 64'b0, data: 512'b0};
                        writeAddr = 64'b0;
                        // readAddr = 64'b0;
                        acceptedSliceCount = 32'd0;
                        receivedByteCount = 64'd0;
                        mem_interleaved_resp_grant = 1'b0;
                        state = PCIE_RECV_HEADER;
                    end
                
                PCIE_RECV_HEADER:
                    begin
                        // header = pcie_packet_in.data;
                        headerSlotId          = pcie_packet_in.slot;
                        headerMemberId        = pcie_packet_in.data[0*32+31:0*32];
                        headerDataLengthBytes = pcie_packet_in.data[1*32+31:1*32];
                        headerSliceIndex      = pcie_packet_in.data[2*32+31:2*32];
                        headerSliceCount      = pcie_packet_in.data[3*32+31:3*32];
                        writeAddr = ALLOWED_BYTES_PER_SLOT * pcie_packet_in.data[2*32+31:2*32];
                        if (pcie_packet_in.valid) begin
                            acceptedSliceCount = acceptedSliceCount + 1;
                            state = PCIE_RECV_0;
                        end
                    end
                
                PCIE_RECV_0:
                    begin
                        mem_interleaved_req.data[0*128+127:0*128] = pcie_packet_in.data;
                        if (pcie_packet_in.valid) begin
                            state = PCIE_RECV_1;
                        end
                    end
                
                PCIE_RECV_1:
                    begin
                        mem_interleaved_req.data[1*128+127:1*128] = pcie_packet_in.data;
                        if (pcie_packet_in.valid) begin
                            state = PCIE_RECV_2;
                        end
                    end
                
                PCIE_RECV_2:
                    begin
                        mem_interleaved_req.data[2*128+127:2*128] = pcie_packet_in.data;
                        if (pcie_packet_in.valid) begin
                            state = PCIE_RECV_3;
                        end
                    end
                
                PCIE_RECV_3:
                    begin
                        mem_interleaved_req.data[3*128+127:3*128] = pcie_packet_in.data;
                        pcie_packet_in_last = pcie_packet_in.last;
                        if (pcie_packet_in.valid) begin
                            pcie_full_out = 1'b1;
                            state = PCIE_RECV_MWR;
                        end
                    end
                
                PCIE_RECV_MWR:
                    begin
                        mem_interleaved_req.valid = 1'b1;
                        mem_interleaved_req.isWrite = 1'b1;
                        mem_interleaved_req.addr = writeAddr;
                        if (mem_interleaved_req_grant) begin
                            mem_interleaved_req.valid = 1'b0;
                            writeAddr = writeAddr + 64;
                            receivedByteCount = receivedByteCount + 64;
                            if (pcie_packet_in_last == 1) begin
                              state = PCIE_SEND_ACK_0;
                            end else begin
                              pcie_full_out = 1'b0;
                              state = PCIE_RECV_0;
                            end
                        end
                    end
                
                RUN:
                    begin
                        hastipMemberId = headerMemberId; // HAST_IP_MEMBER_ID;
                        hastipStarted = 1;
                        hastipReadsDone = 0;
                        hastipWritesDone = 0;
                        mem_interleaved_resp_grant = 1'b0;
                        if (hastipReadEnable) begin
                          state = RUN_RD_REQ;
                        end else if (hastipWriteEnable) begin
                          state = RUN_WR_REQ;
                        end else if (hastipFinished) begin
                          hastipRunTime = hastipRunCounter;
                          readAddr = 0;
                          headerSlotId = 0;
                          headerSliceIndex = 0;
                          state = PCIE_SEND_HEADER;
                        end
                    end
                
                RUN_RD_REQ:
                    begin
                        mem_interleaved_req = '{valid: 1'b1, isWrite: 1'b0, addr: 64 * hastipCellIndex, data: 512'b0};
                        if (mem_interleaved_req_grant) begin
                            mem_interleaved_req.valid = 1'b0;
                            state = RUN_RD_WAIT;
                        end
                    end
                
                RUN_RD_WAIT:
                    begin
                        if (mem_interleaved_resp.valid) begin
                          hastipDataIn = mem_interleaved_resp.data[HAST_IP_DATA_WIDTH-1:0];
                          hastipReadsDone = 1;
                        end
                        if (!hastipReadEnable) begin
                          mem_interleaved_resp_grant = 1'b1;
                          hastipReadsDone = 0;
                          state = RUN;
                        end
                    end
                
                RUN_WR_REQ:
                    begin
                        hastipWritesDone = 1;
                        mem_interleaved_req = '{valid: 1'b1, isWrite: 1'b1, addr: 64 * hastipCellIndex, data: hastipDataOut};
                        if (mem_interleaved_req_grant) begin
                            mem_interleaved_req.valid = 1'b0;
                            state = RUN_WR_WAIT;
                        end
                    end
                
                RUN_WR_WAIT:
                    begin
                        hastipWritesDone = 1;
                        if (!hastipWriteEnable) begin
                          hastipWritesDone = 0;
                          state = RUN;
                        end
                    end
                
                PCIE_SEND_HEADER:
                    begin
                        pcie_packet_out.slot = headerSlotId;
                        pcie_packet_out.valid = 1'b1;
                        pcie_packet_out.last = 1'b0;
                        pcie_packet_out.data[63:00] = hastipRunTime;
                        // pcie_packet_out.data[95:64] = headerSliceIndex;
                        // pcie_packet_out.data[127:96] = (writeAddr + ALLOWED_BYTES_PER_SLOT - 1) / ALLOWED_BYTES_PER_SLOT; // headerSliceCount;
                        pcie_packet_out.data[95:64] = receivedByteCount >> 2;
                        pcie_packet_out.data[127:96] = headerSliceIndex;
                        readLen = ALLOWED_BYTES_PER_SLOT;
                        if (pcie_grant_in) begin
                            pcie_packet_out.valid = 1'b0;
                            state = PCIE_SEND_MRD_REQ;
                        end
                    end
                
                PCIE_SEND_MRD_REQ:
                    begin
                        mem_interleaved_resp_grant = 1'b0;
                        mem_interleaved_req = '{valid: 1'b1, isWrite: 1'b0, addr: readAddr, data: 512'b0};
                        if (mem_interleaved_req_grant) begin
                            mem_interleaved_req.valid = 1'b0;
                            readAddr = readAddr + 64;
                            readLen = readLen - 64;
                            state = PCIE_SEND_MRD_WAIT;
                        end
                    end
                
                PCIE_SEND_MRD_WAIT:
                    begin
                        if (mem_interleaved_resp.valid) begin
                            pcie_packet_out.valid = 1'b1;
                            pcie_packet_out.last = 1'b0;
                            pcie_packet_out.data = mem_interleaved_resp.data[0*128+127:0*128];
                            state = PCIE_SEND_0;
                        end
                    end
                
                PCIE_SEND_0:
                    begin
                        if (pcie_grant_in) begin
                            pcie_packet_out.data = mem_interleaved_resp.data[1*128+127:1*128];
                            state = PCIE_SEND_1;
                        end
                    end
                
                PCIE_SEND_1:
                    begin
                        if (pcie_grant_in) begin
                            pcie_packet_out.data = mem_interleaved_resp.data[2*128+127:2*128];
                            state = PCIE_SEND_2;
                        end
                    end
                
                PCIE_SEND_2:
                    begin
                        if (pcie_grant_in) begin
                            pcie_packet_out.last = (readAddr == receivedByteCount) || (readLen == 0);
                            pcie_packet_out.data = mem_interleaved_resp.data[3*128+127:3*128];
                            state = PCIE_SEND_3;
                        end
                    end
                
                PCIE_SEND_3:
                    begin
                        if (pcie_grant_in) begin
                            pcie_packet_out.valid = 1'b0;
                            mem_interleaved_resp_grant = 1'b1;
                            if ((readAddr == receivedByteCount) || (readLen == 0)) begin
                                state = PCIE_SEND_DONE;
                            end else begin
                                state = PCIE_SEND_MRD_REQ;
                            end
                        end
                    end
                
                PCIE_SEND_DONE:
                    begin
                        mem_interleaved_resp_grant = 1'b0;
                        // headerSlotId = (headerSlotId + 1) % ALLOWED_SLOTS;
                        if (headerSlotId == (ALLOWED_SLOTS -1)) begin
                          headerSlotId = 0;
                        end else begin
                          headerSlotId = headerSlotId + 1;
                        end
                        headerSliceIndex = headerSliceIndex + 1;
                        if (readAddr != receivedByteCount) begin
                            state = PCIE_SEND_HEADER;
                        end else begin
                            state = IDLE;
                        end
                    end
                
                DONE:
                    begin
                        if (pcie_grant_in) begin
                            pcie_packet_out.valid = 1'b0;
                            state = IDLE;
                        end
                    end
                
                PCIE_SEND_ACK_0:
                  begin
                    pcie_packet_out.valid = 1'b1;
                    pcie_packet_out.last = 1'b0;
                    pcie_packet_out.slot = headerSlotId;
                    pcie_packet_out.data[0*32+31:0*32] = headerMemberId;
                    pcie_packet_out.data[1*32+31:1*32] = headerDataLengthBytes;
                    pcie_packet_out.data[2*32+31:2*32] = headerSliceIndex;
                    pcie_packet_out.data[3*32+31:3*32] = headerSliceCount;
                    if (pcie_grant_in) begin
                      pcie_packet_out.last = 1'b1;
                      pcie_packet_out.data = 0;
                      state = PCIE_SEND_ACK_1;
                    end
                  end
                  
                PCIE_SEND_ACK_1:
                  begin
                    if (pcie_grant_in) begin
                      pcie_packet_out.valid = 1'b0;
                      //if (headerSliceIndex == headerSliceCount - 1) begin
                      if (acceptedSliceCount == headerSliceCount) begin
                        hastipRunCounter = 0;
                        state = RUN;
                      end else begin
                        pcie_full_out = 1'b0;
                        state = PCIE_RECV_HEADER;
                      end
                    end
                  end
                  
                default:
                    begin
                        state = IDLE;
                    end
            endcase        
        end
    end
    
    // Softreg request handling
    always @(posedge clk) begin
        // Write
        if (rst) begin
          dramConfig = '{valid: 1'b1, mode: INTERLEAVED}; // CHAN0_ONLY, CHAN1_ONLY, INTERLEAVED
        end
        else if (softreg_req.valid && softreg_req.isWrite) begin 
          case (softreg_req.addr)
            64'h02: ALLOWED_SLOTS = softreg_req.data;
            64'h03: ALLOWED_BYTES_PER_SLOT = softreg_req.data;
            64'h08: dramConfig.mode = INTERLEAVED; // softreg_req.data;
          endcase
        end
        // Read
        softreg_resp = '{valid:1'b0, data: 64'b0};
        if (softreg_req.valid && softreg_req.isWrite == 0) begin
          softreg_resp.valid = 1;
          case (softreg_req.addr)
            64'h00: softreg_resp.data = 64'h704974736148; // HastIp
            64'h01: softreg_resp.data = 64'h0001; // v 0.1
            64'h02: softreg_resp.data = ALLOWED_SLOTS;
            64'h03: softreg_resp.data = ALLOWED_BYTES_PER_SLOT;
            64'h04: softreg_resp.data = writeAddr;
            64'h05: softreg_resp.data = readAddr;
            64'h06: softreg_resp.data = hastipRunTime;
            64'h07: softreg_resp.data = debug_counter;
            64'h08: softreg_resp.data = acceptedSliceCount;
            64'h09: softreg_resp.data = receivedByteCount;
          endcase
        end
    end
    
endmodule
