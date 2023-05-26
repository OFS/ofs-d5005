// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// EMIF FME and Port CSR module 
//
//-----------------------------------------------------------------------------

import ofs_fim_emif_cfg_pkg::*;

module emif_csr #(
  parameter NUM_LOCAL_MEM_BANKS = 1,
  parameter END_OF_LIST         = 1'b0,
  parameter NEXT_DFH_OFFSET     = 24'h05_0000
)
(
   ofs_fim_emif_sideband_if.csr emif_csr_sigs [NUM_LOCAL_MEM_BANKS-1:0],
   ofs_fim_axi_mmio_if.slave    csr_if
);

import ofs_fim_cfg_pkg::*;
import ofs_csr_pkg::*;

//-------------------------------------
// Number of feature and register
//-------------------------------------
localparam MAX_CSR_REG_NUM  = 512; // 4KB address space - 512 x 8B register
localparam CSR_ADDR_WIDTH   = $clog2(MAX_CSR_REG_NUM) + 3;

localparam CSR_NUM_REG = 3;
localparam CSR_REG_ADDR_WIDTH = $clog2(CSR_NUM_REG) + 3;

localparam ADDR_WIDTH  = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam DATA_WIDTH  = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam WSTRB_WIDTH = (DATA_WIDTH/8);

//-------------------------------------
// Register address
//-------------------------------------
localparam EMIF_DFH  = 5'h0;
localparam EMIF_STAT = 5'h8;
localparam EMIF_CTRL = 5'h10; 

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

logic [ADDR_WIDTH-1:0] csr_raddr;
logic                  csr_read;
logic                  csr_read_32b;
logic [DATA_WIDTH-1:0] csr_readdata;
logic                  csr_readdata_valid;

//--------------------------------------------------------------
assign clk = csr_if.clk;
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

//---------------------------------
// CSR Registers
//---------------------------------
logic [NUM_LOCAL_MEM_BANKS-1:0] emif_clear_busy,  emif_clear_busy_sync;
logic [NUM_LOCAL_MEM_BANKS-1:0] emif_cal_failure, emif_cal_failure_sync;
logic [NUM_LOCAL_MEM_BANKS-1:0] emif_cal_success, emif_cal_success_sync;

ofs_csr_hw_state_t     hw_state;
logic                  range_valid;
logic                  csr_read_reg;
logic [ADDR_WIDTH-1:0] csr_raddr_reg;
logic                  csr_read_32b_reg;

logic [DATA_WIDTH-1:0] csr_reg [CSR_NUM_REG-1:0];

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
   range_valid <= (csr_raddr[CSR_ADDR_WIDTH-1:3] < CSR_NUM_REG) ? 1'b1 : 1'b0; 
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

//-------------------
// CSR Definition 
//-------------------
assign hw_state.reset_n    = rst_n;
assign hw_state.pwr_good_n = rst_n;
assign hw_state.wr_data    = csr_wdata;
assign hw_state.write_type = csr_write_type; 

always_ff @(posedge clk) begin
   def_reg (EMIF_DFH,
               {64{RO}},
                /* 
                   [63:60]: Feature Type
                   [59:52]: Reserved
                   [51:48]: If AFU - AFU Minor Revision Number (else, reserved)
                   [47:41]: Reserved
                   [40   ]: EOL (End of DFH list)
                   [39:16]: Next DFH Byte Offset
                   [15:12]: If AfU, AFU Major version number (else feature #)
                   [11:0 ]: Feature ID
                */
                {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h009},
                {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h009}
   );
    
   def_reg (EMIF_STAT,
               /*
                  [63:20]: Reserved
                  [19:16]  EMIF clearing busy
                  [15:12]  Reserved
                  [11: 8]  EMIF Calibration failure
                  [ 7: 4]  Reserved
                  [ 3: 0]  EMIF Calibration complete
               */
               {{40{RsvdZ}},{4{RO}},{4{RsvdZ}},{4{RO}},{4{RsvdZ}},{4{RO}}},
               64'h0000000000000000,
               {40'h0,
                  {(8-NUM_LOCAL_MEM_BANKS){1'b0}}, emif_clear_busy_sync,
                  {(8-NUM_LOCAL_MEM_BANKS){1'b0}}, emif_cal_failure_sync,
                  {(8-NUM_LOCAL_MEM_BANKS){1'b0}}, emif_cal_success_sync}
   );

   def_reg (EMIF_CTRL,
               {{60{RsvdZ}},{4{RW1C}}},
               64'h000000000000000f,
               64'h000000000000000f
   );
end

genvar ig;
generate 
   for (ig=0; ig<NUM_LOCAL_MEM_BANKS; ig=ig+1) 
   begin : csr_sig
      // EMIF CSR status signals
      assign emif_clear_busy[ig]  = emif_csr_sigs[ig].clear_busy;
      assign emif_cal_failure[ig] = emif_csr_sigs[ig].cal_failure;
      assign emif_cal_success[ig] = emif_csr_sigs[ig].cal_success;

      // CSR control signal   
      assign emif_csr_sigs[ig].chkr_clear_n = csr_reg[EMIF_CTRL[CSR_REG_ADDR_WIDTH-1:3]][ig];
   end
endgenerate


localparam CSR_STAT_SYNC_WIDTH = NUM_LOCAL_MEM_BANKS*3;

fim_resync #(
    .SYNC_CHAIN_LENGTH(3),
    .WIDTH(CSR_STAT_SYNC_WIDTH),
    .INIT_VALUE(0),
    .NO_CUT(1)
) emif_csr_stat_sync (
    .clk(clk),
    .reset(1'b0),
    .d( {emif_clear_busy,      emif_cal_failure,      emif_cal_success} ),
    .q( {emif_clear_busy_sync, emif_cal_failure_sync, emif_cal_success_sync} )
);

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
