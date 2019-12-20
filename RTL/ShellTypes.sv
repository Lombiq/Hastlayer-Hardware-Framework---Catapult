//
// Academic Shell Types
//
`ifndef SHELLTYPES_SV_INCLUDED
`define SHELLTYPES_SV_INCLUDED

package ShellTypes;

// 
// Global constants, should not be changed
//

`ifdef USE_ECC_DDR
parameter USE_ECC                 = 1;
`else
parameter USE_ECC                 = 0;
`endif

parameter AVL_ADDR_WIDTH          = 26;
parameter AVL_DATA_WIDTH          = USE_ECC == 1 ? 512 : 576;
parameter AVL_SPARE_WIDTH         = USE_ECC == 1 ? 0   : 64;
parameter AVL_BE_WIDTH            = USE_ECC == 1 ? 64  : 72;
parameter AVL_SIZE                = 7;

parameter NUM_UMI                 = 1;

parameter UMI_ADDR_WIDTH          = 64;
parameter UMI_DATA_WIDTH          = USE_ECC == 0 ? 576 : 512;
parameter UMI_SPARE_WIDTH         = USE_ECC == 0 ?  64 :   0;
parameter UMI_MASK_WIDTH          = UMI_DATA_WIDTH / 8;

parameter PCIE_DATA_WIDTH         = 128;
parameter PCIE_SLOT_WIDTH         = 16; // 16 bits are available, but only first 6 bits are valid (64 slots)
parameter PCIE_PAD_WIDTH          = $clog2(PCIE_DATA_WIDTH/8);

// 
// Internal I2C types
//
typedef enum logic [7:0] {
    MEZZ_I2C_DUMMY_WRITE            = 8'h00,
    MEZZ_I2C_FPGA_TEMPERATURE       = 8'h01,
    MEZZ_I2C_NETWORK_PASSTHROUGH    = 8'h02,
    MEZZ_I2C_FPGA_HEALTH            = 8'h03,
    MEZZ_I2C_VERSION                = 8'h04,
    MEZZ_I2C_MAC_REG_ADDR0          = 8'h05,
    MEZZ_I2C_MAC_REG_ADDR1          = 8'h06,
    MEZZ_I2C_NIC_REG_B0             = 8'h07,
    MEZZ_I2C_NIC_REG_B1             = 8'h08,
    MEZZ_I2C_NIC_REG_B2             = 8'h09,
    MEZZ_I2C_NIC_REG_B3             = 8'h0A,
    
    MEZZ_I2C_TOR_REG_B0             = 8'h0B,
    MEZZ_I2C_TOR_REG_B1             = 8'h0C,
    MEZZ_I2C_TOR_REG_B2             = 8'h0D,
    MEZZ_I2C_TOR_REG_B3             = 8'h0E,

    MEZZ_I2C_NIC_FCS_B0             = 8'h0F,
    MEZZ_I2C_NIC_FCS_B1             = 8'h10,
    MEZZ_I2C_NIC_FCS_B2             = 8'h11,
    MEZZ_I2C_NIC_FCS_B3             = 8'h12,

    MEZZ_I2C_TOR_FCS_B0             = 8'h13,
    MEZZ_I2C_TOR_FCS_B1             = 8'h14,
    MEZZ_I2C_TOR_FCS_B2             = 8'h15,
    MEZZ_I2C_TOR_FCS_B3             = 8'h16,
    MEZZ_I2C_NET_DEBUG              = 8'h17
} MEZZ_I2C_REGS; 


typedef struct packed
{
    logic  [255:0]  data          ;
    logic  [4:0]    padbytes      ;
    logic           endofpacket   ;
    logic           startofpacket ;
} NetworkStream;

typedef struct packed {
	logic                      valid;
	logic                      isWrite;
	logic [UMI_ADDR_WIDTH-1:0] addr;
	logic [63:0]               size;
} UMIReq;

typedef struct packed {
	logic                      valid;
	logic [UMI_DATA_WIDTH-1:0] data;
} UMIWriteData;

typedef struct packed {
	logic                      valid;
	logic [UMI_DATA_WIDTH-1:0] data;
} UMIReadData;

typedef struct packed {
	logic                      valid;
	logic                      isWrite;
	logic [UMI_ADDR_WIDTH-1:0] addr;
	logic [UMI_DATA_WIDTH-1:0] data;
} MemReq;

typedef struct packed {
	logic                      valid;
	logic [UMI_DATA_WIDTH-1:0] data;
} MemResp;

typedef struct packed {
	logic                       valid;
	logic [PCIE_DATA_WIDTH-1:0] data;
	logic [PCIE_SLOT_WIDTH-1:0] slot;
	logic [PCIE_PAD_WIDTH-1:0]  pad;
	logic                       last;
} PCIEPacket;

typedef struct packed {
	logic                       valid;
	logic                       isWrite;
	logic [31:0]                addr;
	logic [63:0]                data;
} SoftRegReq;

typedef struct packed {
	logic                       valid;
	logic [63:0]                data;
} SoftRegResp;

typedef enum {
	CHAN0_ONLY,
	CHAN1_ONLY,
	INTERLEAVED
} DramInterleaverMode;
	
typedef struct packed {
	logic                       valid;
	DramInterleaverMode         mode;
} DramInterleaverConfig;


endpackage
`endif

