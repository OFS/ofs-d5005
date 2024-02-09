// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
//   HSSI CSR module 
//
//-----------------------------------------------------------------------------
import ofs_fim_eth_if_pkg::NUM_ETH_CHANNELS;
import hssi_csr_pkg::*;

module hssi_csr #(
    parameter END_OF_LIST        = 1'b0,
    parameter NEXT_DFH_OFFSET    = 24'h01_0000,
    
    parameter CMD_W         = 16,   // User command width
    parameter USER_ADDR_W   = 16,   // User address width
    parameter AVMM_ADDR_W   = 13,   // AVMM address width
    parameter DATA_W        = 32,   // Data width
    parameter SIM           = 0
    )(
   ofs_fim_axi_mmio_if.slave                  csr_if,
   	input wire 		                         csr_clk,
	   input wire		                         csr_rst,
      input wire                              plls_locked,
    // Avalon-MM Interface
      output logic [AVMM_ADDR_W-1:0]          o_avmm_addr,            // AVMM address
      output logic                            o_avmm_read,            // AVMM read request
      output logic                            o_avmm_write,           // AVMM write request
      output logic [DATA_W-1:0]               o_avmm_writedata,       // AVMM write data
      input  logic [DATA_W-1:0]               i_avmm_readdata,        // AVMM read data
      input  logic                            i_avmm_waitrequest,      // AVMM wait request
      input hssi_stats_struct_t               hssi_stats[NUM_ETH_CHANNELS-1:0],
      output wire [NUM_ETH_CHANNELS-1:0]      final_channel_rst,
      output wire [7:0]                       final_reconfig_rst
);

import ofs_fim_cfg_pkg::*;
import ofs_csr_pkg::*;



//-------------------------------------
// Number of feature and register
//-------------------------------------

// To add a register, append a new register ID to e_csr_offset
// The register address offset is calculated in CALC_CSR_OFFSET() in 8 bytes increment
//    based on the position of the register ID in e_csr_offset. 
// The calculated offset is stored in CSR_OFFSET and can be indexed using the register ID 
enum {
   HSSI_ETH_DFH,    // 'h0
   HSSI_CAPABILITY, // 'h8
   HSSI_CTRL,       // 'h10
   HSSI_STAT0,      // 'h18
   HSSI_STAT1,      // 'h20
   HSSI_RCFG_CMD,   // 'h28 
   HSSI_RCFG_DATA,  // 'h30
   HSSI_SCRATCHPAD, // 'h38
   HSSI_MAX_OFFSET
} e_csr_id;

localparam CSR_NUM_REG        = HSSI_MAX_OFFSET; 
localparam CSR_REG_ADDR_WIDTH = $clog2(CSR_NUM_REG) + 3;

localparam MAX_CSR_REG_NUM    = 512; // 4KB address space - 512 x 8B register
localparam CSR_ADDR_WIDTH     = $clog2(MAX_CSR_REG_NUM) + 3;
localparam ADDR_WIDTH         = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam DATA_WIDTH         = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam WSTRB_WIDTH        = (DATA_WIDTH/8);

//-------------------------------------
// Register address
//-------------------------------------
function automatic bit [CSR_NUM_REG-1:0][ADDR_WIDTH-1:0] CALC_CSR_OFFSET ();
   bit [31:0] offset;
   for (int i=0; i<CSR_NUM_REG; ++i) begin
      offset = i*8;
      CALC_CSR_OFFSET[i] = offset[ADDR_WIDTH-1:0];
   end
endfunction

localparam bit [CSR_NUM_REG-1:0][ADDR_WIDTH-1:0] CSR_OFFSET = CALC_CSR_OFFSET();

//-------------------------------------
// Signals
//-------------------------------------
logic clk;
logic rst_n;

logic [ADDR_WIDTH-1:0]  csr_waddr;
logic [DATA_WIDTH-1:0]  csr_wdata;
logic [WSTRB_WIDTH-1:0] csr_wstrb;
logic                   csr_write;
csr_access_type_t       csr_write_type;

logic [ADDR_WIDTH-1:0]  csr_raddr;
logic                   csr_read;
logic                   csr_read_32b;
logic [DATA_WIDTH-1:0]  csr_readdata;
logic                   csr_readdata_valid;

// Local Signals for XCVR Reconfiguration Interface
logic [CMD_W-1:0]        i_xcvr_reconfig_cmd;        // Reconfiguration command
logic [USER_ADDR_W-1:0]  i_xcvr_reconfig_addr;       // Reconfiguration address
logic [DATA_W-1:0]       i_xcvr_reconfig_writedata;  // Reconfiguration write data
logic [DATA_W-1:0]       o_xcvr_reconfig_readdata;   // Reconfiguration read data
logic                    o_xcvr_reconfig_ack;        // Reconfiguration acknowledgment

//***************************************************************************************************************************************
    /* HSSI_XCVR_CMD - XCVR Reconfiguration Command and Address Register
    [63:52] : RsvdZ : Reserved
    [51:32] : RW    : XCVR Reconfiguration Address
    [31:3] : RsvdZ : Reserved
    [2]    : RW    : XCVR Reconfiguration Acknowledgment
    [1:0 ] : RW    : XCVR Reconfiguration Command
    */
    logic                       e2c_xcvr_rcfg_ack;
    logic [19:0]                c2e_xcvr_rcfg_addr;
    logic [1:0]                c2e_xcvr_rcfg_cmd;
//***************************************************************************************************************************************
    /* HSSI_XCVR_DATA - XCVR Reconfiguration Read and Write Data Register
    [63:32] : RW    : XCVR Reconfiguration Write Data
    [31:0 ] : RO    : XCVR Reconfiguration Read Data
    */
    logic [31:0]                c2e_xcvr_rcfg_wrdata;
    logic [31:0]                e2c_xcvr_rcfg_rddata;

   
   /* HSSI_CTRL - HSSI Control Register 
            [63:28] : RsvdZ : Reserved
            [27]    : RW    : Select RX Core Clock
            [26]    : RW    : Select TX Core Clock
            [25]    : RW    : Select ATX PLL
            [24:17] : RW    : Channel Reset
            [16:9]  : RW    : Reconfiguration Reset
            [8]     : RW    : Global Reset
            [ 7:0 ] : RO    : Data Rate Selected
            */
            
    logic        c2e_select_rx_core_clk ;
    logic        c2e_select_tx_core_clk ;
    logic        c2e_select_atx_pll     ;
    logic [7:0]  c2e_chan_reset         ;
    logic [7:0]  c2e_rcfg_reset  , synccsr_reconfig_rst ;
    logic        c2e_global_reset , synccsr_global_rst  ;

  
    logic [NUM_ETH_CHANNELS-1:0] synccsr_channel_rst;


    hssi_stats_struct_t      hssi_stats_syncd[NUM_ETH_CHANNELS-1:0];
    logic asynccsr_rst_n;
//*
    logic [63:0] cr2out_hssi_rcfg_cmd;
    logic [63:0] cr2out_hssi_rcfg_data;
    logic [63:0] cr2out_hssi_rcfg_ctrl;
//***************************************************************************************************************************************
    /* HSSI_SCRATCHPAD
    [63:32] : RW    : SCRATCHPAD
    [31:0 ] : RW    : SCRATCHPAD
    */
    logic [63:0]                hssi_scratchpad;

//---------------------------------
// CSR Registers
//---------------------------------
ofs_csr_hw_state_t     hw_state;
logic                  range_valid;
logic                  csr_read_reg;
logic [ADDR_WIDTH-1:0] csr_raddr_reg;
logic                  csr_read_32b_reg;

logic [DATA_WIDTH-1:0] csr_reg [CSR_NUM_REG-1:0];
//--------------------------------------------------------------

assign clk   = csr_if.clk;
assign rst_n = csr_if.rst_n;


//---------------------------------
// Map AXI write/read request to CSR write/read,
// and send the write/read response back
//---------------------------------
ofs_fim_axi_csr_slave emif_csr_slave (
   .csr_if             (csr_if),

   .csr_write          (csr_write),
   .csr_waddr          (csr_waddr),
   .csr_write_type     (csr_write_type),
   .csr_wdata          (csr_wdata),
   .csr_wstrb          (csr_wstrb),

   .csr_read           (csr_read),
   .csr_raddr          (csr_raddr),
   .csr_read_32b       (csr_read_32b),
   .csr_readdata       (csr_readdata),
   .csr_readdata_valid (csr_readdata_valid)
);

//-------------------
// CSR read interface
//-------------------
// Register read control signals to spare 1 clock cycle 
// for address range checking
always_ff @(posedge clk) begin
   csr_read_reg  <= csr_read;
   csr_raddr_reg <= csr_raddr;
   csr_read_32b_reg <= csr_read_32b;

   if (~rst_n) begin
      csr_read_reg <= 1'b0;
   end
   
end

// CSR address range check 
always_ff @(posedge clk) begin
   range_valid <= (csr_raddr[ADDR_WIDTH-1:3] < CSR_NUM_REG) ? 1'b1 : 1'b0; 
end

// CSR readdata
always_ff @(posedge clk) begin
   csr_readdata <= '0;

   if (csr_read_reg && range_valid) begin
      if (csr_read_32b_reg) begin
         if (csr_raddr_reg[2]) begin
            csr_readdata[63:32] <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]][63:32];
         end else begin
            csr_readdata[31:0] <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]][31:0];
         end
      end else begin
         csr_readdata <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]];
      end
   end
end

// CSR readatavalid
always_ff @(posedge clk) begin
   csr_readdata_valid <= csr_read_reg;
end

 always_comb
        begin
       cr2out_hssi_rcfg_cmd    = csr_reg[HSSI_RCFG_CMD ][63:0];
       cr2out_hssi_rcfg_data   = csr_reg[HSSI_RCFG_DATA][63:0];            
       cr2out_hssi_rcfg_ctrl = csr_reg[HSSI_CTRL][63:0]; 
       /* HSSI_XCVR_CMD - XCVR Reconfiguration Command and Address Register
         [63:52] : RsvdZ : Reserved
         [51:32] : RW    : XCVR Reconfiguration Address
         [31:3] : RsvdZ : Reserved
         [2]    : RW    : XCVR Reconfiguration Acknowledgment
         [1:0 ] : RW    : XCVR Reconfiguration Command
         */
      
      c2e_xcvr_rcfg_addr       = cr2out_hssi_rcfg_cmd[51:32];
      c2e_xcvr_rcfg_cmd        = cr2out_hssi_rcfg_cmd[1:0];
      /* HSSI_XCVR_DATA - XCVR Reconfiguration Read and Write Data Register
      [63:32] : RW    : XCVR Reconfiguration Write Data
      [31:0 ] : RO    : XCVR Reconfiguration Read Data
      */
      
      c2e_xcvr_rcfg_wrdata         = cr2out_hssi_rcfg_data[63:32];
      i_xcvr_reconfig_cmd          =  {18'b0 , c2e_xcvr_rcfg_cmd};
      i_xcvr_reconfig_addr         =  c2e_xcvr_rcfg_addr;  
      i_xcvr_reconfig_writedata    =  c2e_xcvr_rcfg_wrdata ;
      e2c_xcvr_rcfg_ack            = o_xcvr_reconfig_ack;
      e2c_xcvr_rcfg_rddata         = o_xcvr_reconfig_readdata;
            

      c2e_select_rx_core_clk   = '0;
      c2e_select_tx_core_clk   = '0;
      c2e_select_atx_pll       = '0;
      c2e_chan_reset           = '0;
      c2e_rcfg_reset           = '0;
      c2e_global_reset         = '0;
      c2e_select_rx_core_clk   = cr2out_hssi_rcfg_ctrl[27];
      c2e_select_tx_core_clk   = cr2out_hssi_rcfg_ctrl[26];
      c2e_select_atx_pll       = cr2out_hssi_rcfg_ctrl[25];
      c2e_chan_reset           = cr2out_hssi_rcfg_ctrl[24:17];
      c2e_rcfg_reset           = cr2out_hssi_rcfg_ctrl[16:9];
      c2e_global_reset         = cr2out_hssi_rcfg_ctrl[8];

        end
//--------------------------------
//  synchronizer chains
resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (NUM_ETH_CHANNELS),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_synccsr_reset_0 (
    .clk                (csr_clk),
    .reset              (1'b0),
    .d                  (c2e_chan_reset[NUM_ETH_CHANNELS-1:0]),
    .q                  (synccsr_channel_rst)
);

resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (9),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_synccsr_reset_2 (
    .clk                (csr_clk),
    .reset              (1'b0),
    .d                  ({c2e_global_reset, c2e_rcfg_reset}),
    .q                  ({synccsr_global_rst, synccsr_reconfig_rst})
);
/* Active-low reset asserted asynchronously on PLL lock loss, and
   dasserted synchronous to csr_clk when PLL is locked again. */
resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (1),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_asynccsr_reset (
    .clk                (csr_clk),
    .reset              (~plls_locked),
    .d                  (1'b1),
    .q                  (asynccsr_rst_n)
);

// Synchronizers for HSSI Stats Registers

hssi_stats_sync #(
    .NUM_LN             (NUM_ETH_CHANNELS)
) inst_hssi_stats_sync (
    .i_fme_clk          (csr_if.clk),
    .i_hssi_stats       (hssi_stats),
    .o_hssi_stats_sync  (hssi_stats_syncd)
);

genvar i;
generate
 for( i=0; i<NUM_ETH_CHANNELS; i++) 
 begin : GenRst
 assign final_channel_rst[i]  = ~asynccsr_rst_n | synccsr_global_rst | synccsr_channel_rst[i] ;
 assign final_reconfig_rst[i] = ~asynccsr_rst_n | synccsr_global_rst | synccsr_reconfig_rst[i];
 end 
endgenerate
// Reconfig reset


// Memory-Mapped Reconfiguration Controller for the XCVR and PLL CSRs
mm_ctrl_xcvr #(
    .CMD_W          (CMD_W),     // User command width
    .USER_ADDR_W    (USER_ADDR_W),    // User address width
    .AVMM_ADDR_W    (AVMM_ADDR_W),  // AVMM address width
    .DATA_W         (DATA_W),  // Data width
    .SIM            (SIM)
) inst_mm_ctrl_xcvr (
    // Clocks and Reset
    .i_usr_clk              (csr_if.clk),            // CSR clock
    .i_avmm_clk             (csr_clk),       // reconfiguration interface clock
    .i_avmm_rst             (final_reconfig_rst[0]),   // reconfig reset
    // User Interface
    .i_usr_cmd              (i_xcvr_reconfig_cmd),
    .i_usr_addr             (i_xcvr_reconfig_addr),
    .i_usr_writedata        (i_xcvr_reconfig_writedata),
    .o_usr_readdata         (o_xcvr_reconfig_readdata),
    .o_usr_ack              (o_xcvr_reconfig_ack),
    // AvalonMM Interface
    .o_avmm_addr            (o_avmm_addr),
    .o_avmm_read            (o_avmm_read),
    .o_avmm_write           (o_avmm_write),
    .o_avmm_writedata       (o_avmm_writedata),
    .i_avmm_readdata        (i_avmm_readdata),
    .i_avmm_readdata_valid  (/*does not exist for XCVR reconfig interfaces*/),
    .i_avmm_waitrequest     (i_avmm_waitrequest)
);

//-------------------
// CSR Definition 
//-------------------
assign hw_state.reset_n    = rst_n;
assign hw_state.pwr_good_n = rst_n;
assign hw_state.wr_data    = csr_wdata;
assign hw_state.write_type = csr_write_type; 


always_ff @(posedge clk) begin
    def_reg (CSR_OFFSET[HSSI_ETH_DFH],
            {64{RO}},
            /*
            [63:60] = 0x3    : Feature Type
            [59:41] = 0x0    : Reserved
            [40]    = 0x1    : EOL
            [39:16] = 0x1000 : Next DFH Byte Offset
            [15:12] = 0x1    : Feature Revision (0x0 for Rush Creek, 0x1 for Darby Creek)
            [11:0 ] = 0xA    : Feature ID (0xA for both Rush Creek and Darby Creek)
            */
            {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h1,12'h00f},
            {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h1,12'h00f}
    );

    def_reg (CSR_OFFSET[HSSI_CAPABILITY],
            {64{RO}},
            /*
            [63:44] = 0x0    : Reserved
            [43:40] = 0x2    : Number of QSFP Interfaces (0x2 on IOFS EA)
            [39:36] = 0x1    : Num_channels
            [39:32] = 0x1    : Num_channels_CSR interface
            [31:28] = 0x1    : Num_CSR_interface
            [27]    = 0x0    : MAC Enabled/Disabled
            [26]    = 0x0    : Auto Negotiation Enabled/Disabled
            [25]    = 0x0    : Link Training Enabled/Disabled
            [24]    = 0x0    : Dynamic Data Rate Switching Enabled/Disabled
            [23:16] = 0x0    : FEC Enabled/Disabled per supported rate
            [15:8 ] = 0x2    : PCS Enabled/Disabled per supported rate
            [ 7:0 ] = 0x2    : Available Data Rates
            */
            64'h0000021110000202,
            64'h0000021110000202
            );

    def_reg (CSR_OFFSET[HSSI_CTRL],
            {{36{RsvdZ}},
             { 20{RW}},
             { 8{RO}}
            },
            /*
            [63:28] = 0x0    : Reserved
            [27]    = 0x0    : Select RX Core Clock
            [26]    = 0x0    : Select TX Core Clock
            [25]    = 0x0    : Select ATX PLL
            [24:17]    = 0x0    : Channel-0 Reset
            [16:9]     = 0x0    : Reconfiguration Reset
            [8]     = 0x0    : Global Reset
            [ 7:0 ] = 0x0    : Data Rate Selected
            */
            {56'h0,
             8'h1
            },
            {c2e_select_rx_core_clk,
             c2e_select_tx_core_clk,
             c2e_select_atx_pll,
             c2e_chan_reset[7:0],
             c2e_rcfg_reset[7:0],
             c2e_global_reset,
             8'h0
            }
            );
  

       def_reg (CSR_OFFSET[HSSI_STAT0],
               {64{RO}},
               /*
               [63:48] = 0x0    : Channel-3 Stats
               [47:32] = 0x0    : Channel-2 Stats
               [31:16] = 0x0    : Channel-1 Stats
               [15:0 ] = 0x0    : Channel-0 Stats
               */
               64'h0,
               {58'h0,
                hssi_stats_syncd[0]
               }
               );

       def_reg (CSR_OFFSET[HSSI_STAT1],
               {64{RO}},
               /*
               [63:48] = 0x0    : Channel-3 Stats
               [47:32] = 0x0    : Channel-2 Stats
               [31:16] = 0x0    : Channel-1 Stats
               [15:0 ] = 0x0    : Channel-0 Stats
               */
               64'h0,
               64'h0
               );               

    def_reg (CSR_OFFSET[HSSI_RCFG_CMD],
            {{12{RsvdZ}},
             { 20{RW}},
             {29{RsvdZ}},
             {1{RO}},
             {2{RW}}
            },
            /*
            [63:42] = 0x0    : Reserved
            [41:32] = 0x0    : XCVR Reconfiguration Address
            [31:3] = 0x0    : Reserved
            [2]    = 0x0    : XCVR Reconfiguration Acknowledgment
            [1:0 ] = 0x0    : XCVR Reconfiguration Command
            */
            {64'h0
            },
            {12'h0,
             c2e_xcvr_rcfg_addr,
             29'h0,
             e2c_xcvr_rcfg_ack,
             c2e_xcvr_rcfg_cmd
            }
    );

    def_reg (CSR_OFFSET[HSSI_RCFG_DATA],
            {{32{RW}},
             {32{RO}}
            },
            /*
            [63:32] = 0x0    : XCVR Reconfiguration Write Data
            [31:0 ] = 0x0    : XCVR Reconfiguration Read Data
            */
            {32'h0,
             32'h0
            },
            {c2e_xcvr_rcfg_wrdata,
             e2c_xcvr_rcfg_rddata
            }
            );

    def_reg (CSR_OFFSET[HSSI_SCRATCHPAD],
            {{32{RW}},
             {32{RW}}
            },
            /*
            [63:32] = 0x0    : SCRATCHPAD
            [31:0 ] = 0x0    : SCRATCHPAD
            */
            {32'h0,
             32'h0
            },
            {hssi_scratchpad[63:32],
             hssi_scratchpad[31:0]
            }
            );

      
end

//--------------------------------
// Function & Task
//--------------------------------
// Check if address matches
function automatic bit f_addr_hit (
   input logic [ADDR_WIDTH-1:0] csr_addr, 
   input logic [ADDR_WIDTH-1:0] ref_addr
);
   return (csr_addr[CSR_ADDR_WIDTH-1:3] == ref_addr[CSR_ADDR_WIDTH-1:3]);
endfunction

// Task to update CSR register bit based on bit attribute
task def_reg;
   input logic [ADDR_WIDTH-1:0] addr;
   input csr_bit_attr_t [63:0]  attr;
   input logic [63:0]           reset_val;
   input logic [63:0]           update_val;
begin
   csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]] <= ofs_csr_pkg::update_reg (
      attr,
      reset_val,
      update_val,
      csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]],
      (csr_write && f_addr_hit(csr_waddr, addr)),
      hw_state
   );
end
endtask


endmodule
