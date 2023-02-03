// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   PCIe CSR module 
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;

module pcie_csr #(
   parameter END_OF_LIST        = 1'b0,
   parameter NEXT_DFH_OFFSET    = 24'h01_0000
)(
   ofs_fim_axi_mmio_if.slave                     csr_if,

   // Inputs
   input  logic                                  avl_clk,
   input  logic                                  i_pcie_linkup,
   
   input  logic                                  i_chk_rx_err,
   input  logic                                  i_chk_rx_err_vf_act,
   input  logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] i_chk_rx_err_pfn,
   input  logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] i_chk_rx_err_vfn,
   input  logic [31:0]                           i_chk_rx_err_code,

   // Outputs
   output logic                                  o_pcie_linkup,
   output logic [31:0]                           o_chk_rx_err_code
);

import ofs_fim_cfg_pkg::*;
import ofs_csr_pkg::*;

localparam DATA_WIDTH   = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam WSTRB_WIDTH  = (DATA_WIDTH/8);

//-------------------------------------
// Number of feature and register
//-------------------------------------

// To add a register, append a new register ID to e_csr_offset
// The register address offset is calculated in CALC_CSR_OFFSET() in 8 bytes increment
//    based on the position of the register ID in e_csr_offset. 
// The calculated offset is stored in CSR_OFFSET and can be indexed using the register ID 
enum {
   PCIE_DFH,        // 'h0
   PCIE_SCRATCHPAD, // 'h8
   PCIE_STAT,       // 'h10
   PCIE_ERROR_MASK, // 'h18 
   PCIE_ERROR,      // 'h20 
   PCIE_MAX_OFFSET
} e_csr_id;

localparam CSR_NUM_REG        = PCIE_MAX_OFFSET; 
localparam CSR_REG_ADDR_WIDTH = $clog2(CSR_NUM_REG) + 3;

localparam MAX_CSR_REG_NUM    = 512; // 4KB address space - 512 x 8B register
localparam CSR_ADDR_WIDTH     = $clog2(MAX_CSR_REG_NUM) + 3;
localparam ADDR_WIDTH         = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;

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

logic [31:0]            chk_rx_err_code;
logic [31:0]            chk_rx_err_code_q0;
logic [31:0]            chk_rx_err_code_q1;

logic                   cr_pcie_linkup;
logic [31:0]            cr_chk_rx_err_code;

//--------------------------------------------------------------

assign clk   = csr_if.clk;
assign rst_n = csr_if.rst_n;

// Extend error code pulse for CDC
always_ff @(posedge avl_clk) begin
   chk_rx_err_code_q1 <= chk_rx_err_code_q0;
   chk_rx_err_code_q0 <= i_chk_rx_err_code;
end

assign chk_rx_err_code = (chk_rx_err_code_q1 | chk_rx_err_code_q0);

// Synchronizer
localparam CSR_STAT_SYNC_WIDTH = 33;
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(CSR_STAT_SYNC_WIDTH),
   .INIT_VALUE(0),
   .NO_CUT(1)
) csr_resync (
   .clk   (clk),
   .reset (~rst_n),
   .d     ({i_pcie_linkup, chk_rx_err_code}),
   .q     ({cr_pcie_linkup, cr_chk_rx_err_code})
);

//-------------------------------------
// Status signals to shadow registers in corefim FME CSR
// (Global error feature)
//-------------------------------------
assign o_pcie_linkup = cr_pcie_linkup;
assign o_chk_rx_err_code = cr_chk_rx_err_code;

//---------------------------------
// Map AXI write/read request to CSR write/read,
// and send the write/read response back
//---------------------------------
ofs_fim_axi_csr_slave pcie_csr_slave (
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

//-------------------
// CSR Definition 
//-------------------
assign hw_state.reset_n    = rst_n;
assign hw_state.pwr_good_n = rst_n;
assign hw_state.wr_data    = csr_wdata;
assign hw_state.write_type = csr_write_type; 

always_ff @(posedge clk) begin
   def_reg (CSR_OFFSET[PCIE_DFH],
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
               {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h020},
               {4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h020}
   );

   def_reg (CSR_OFFSET[PCIE_SCRATCHPAD],
               {64{RW}},
               64'h0,
               64'h0
   );
    
   def_reg (CSR_OFFSET[PCIE_STAT],
               /*
                  [63:1]:  Reserved
                  [0   ]:  PCIe linkup status 
               */
               {{63{RsvdZ}}, RO},
               64'h0000000000000000,
               {63'h0, cr_pcie_linkup}
   );

   def_reg (CSR_OFFSET[PCIE_ERROR_MASK],
            {{54{RO}},
             {10{RW}}
            },
            64'h0000000000000000,
            64'h0000000000000000
   );

   def_err_reg (CSR_OFFSET[PCIE_ERROR],
                CSR_OFFSET[PCIE_ERROR_MASK],
                64'h0000000000000000,
                {32'h0, cr_chk_rx_err_code}
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

// This task defines a Readable/Write-1-to-Clear, Sticky register (RW1CS)
// It is intended mainly for Error Status Registers that capture 1-cycle active error signals
task def_err_reg;
   input logic [ADDR_WIDTH-1:0] addr;
   input logic [ADDR_WIDTH-1:0] mask_addr;
   input logic [63:0]           reset_val;
   input logic [63:0]           update_val;
begin
   for(int i=0; i<64; i=i+1) begin
      if(~rst_n) begin
         csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]][i] <= reset_val[i];
      end else begin
         // Clear when SW writes 1
         if (csr_write && f_addr_hit(csr_waddr, addr) && csr_wdata[i])
         begin
            // 64b access
            if (csr_write_type == ofs_csr_pkg::FULL64) begin
               csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]][i] <= 1'b0;
            end else begin
              // 32b access
              if (csr_write_type == ofs_csr_pkg::UPPER32) begin
                 // update 32 MSBs
                 if (i >= 32) csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]][i-32] <= 1'b0;
              end else begin
                 // update 32 LSBs
                 if (i < 32) csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]][i] <= 1'b0;
              end    
            end
         end 
         else begin
            // HW updates (set) only for active-high level
            if (~csr_reg[mask_addr[CSR_REG_ADDR_WIDTH-1:3]][i] & update_val[i]) begin
               csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]][i] <= 1'b1;
            end
         end
      end
   end
end
endtask

endmodule
