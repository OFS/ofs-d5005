// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   QSYS endpoint component to allow an external DDR AXI master interface
//   to be connected to QSYS interconnect
//
//   DDR AXI slave interface has the following requirements: 
//      * awsize  (128B)
//           * LSB 64B : data
//           * MSB 64B : {unused, 8B ECC}
//      * awburst (INCR)
//
//   Currently, the endpoint doesn't perform any error checking.
//   It assumes all requests coming from the AXI master comply with
//   DDR slave interface requirements.
//
//   Future release may include error checking to return error response
//   for unsupported requests.
//  
//-----------------------------------------------------------------------------

module ddr_axi_master_endpoint #(
   parameter ID_WIDTH    = 6,
   parameter ADDR_WIDTH  = 34,
   parameter DATA_WIDTH  = 1024, 
   parameter ACTUAL_DATA_WIDTH = 576, // Number of bits in 1024-bit data that is actually used
                                      // i.e. only lower 576 bits are used, 512-bit data and 64-bit ECC

   // Derived parameter
   parameter WSTRB_WIDTH = (DATA_WIDTH/8),
   parameter ACTUAL_WSTRB_WIDTH = (ACTUAL_DATA_WIDTH/8) 
)(

   //---------------------------------
   // AXI slave interface
   //---------------------------------
   input  logic                   axi_s0_clk,
   input  logic                   axi_s0_resetn,

   // Write address channel
   input  logic                   axi_s0_awvalid,
   input  logic [ID_WIDTH-1:0]    axi_s0_awid,
   input  logic [ADDR_WIDTH-1:0]  axi_s0_awaddr,
   input  logic [7:0]             axi_s0_awlen,
   input  logic [2:0]             axi_s0_awsize,
   input  logic [1:0]             axi_s0_awburst,
   output logic                   axi_s0_awready,

   // Write data channel
   input  logic                   axi_s0_wvalid,
   input  logic [DATA_WIDTH-1:0]  axi_s0_wdata,
   input  logic [WSTRB_WIDTH-1:0] axi_s0_wstrb,
   input  logic                   axi_s0_wlast,
   output logic                   axi_s0_wready,

   // Write response channel
   output logic                   axi_s0_bvalid,
   output logic [ID_WIDTH-1:0]    axi_s0_bid,
   output logic [1:0]             axi_s0_bresp,
   input  logic                   axi_s0_bready,

   // Read address channel
   input  logic                   axi_s0_arvalid,
   input  logic [ID_WIDTH-1:0]    axi_s0_arid,
   input  logic [ADDR_WIDTH-1:0]  axi_s0_araddr,
   input  logic [7:0]             axi_s0_arlen,
   input  logic [2:0]             axi_s0_arsize,
   input  logic [1:0]             axi_s0_arburst,
   output logic                   axi_s0_arready,

   // Read response channel
   output logic                   axi_s0_rvalid,
   output logic [ID_WIDTH-1:0]    axi_s0_rid,
   output logic [DATA_WIDTH-1:0]  axi_s0_rdata,
   output logic [1:0]             axi_s0_rresp,
   output logic                   axi_s0_rlast,
   input  logic                   axi_s0_rready,

   //---------------------------------
   // AXI master interface
   //---------------------------------
   output logic                   axi_m0_clk,
   output logic                   axi_m0_resetn,
   
   // Write address channel
   output logic                   axi_m0_awvalid,
   output logic [ID_WIDTH-1:0]    axi_m0_awid,
   output logic [ADDR_WIDTH-1:0]  axi_m0_awaddr,
   output logic [7:0]             axi_m0_awlen,
   output logic [2:0]             axi_m0_awsize,
   output logic [1:0]             axi_m0_awburst,
   output logic [2:0]             axi_m0_awprot,
   input  logic                   axi_m0_awready,

   // Write data channel
   output logic                   axi_m0_wvalid,
   output logic [DATA_WIDTH-1:0]  axi_m0_wdata,
   output logic [WSTRB_WIDTH-1:0] axi_m0_wstrb,
   output logic                   axi_m0_wlast,
   input  logic                   axi_m0_wready,

   // Write response channel
   input  logic                   axi_m0_bvalid,
   input  logic [ID_WIDTH-1:0]    axi_m0_bid,
   input  logic [1:0]             axi_m0_bresp,
   output logic                   axi_m0_bready,

   // Read address channel
   output logic                   axi_m0_arvalid,
   output logic [ID_WIDTH-1:0]    axi_m0_arid,
   output logic [ADDR_WIDTH-1:0]  axi_m0_araddr,
   output logic [7:0]             axi_m0_arlen,
   output logic [2:0]             axi_m0_arsize,
   output logic [1:0]             axi_m0_arburst,
   output logic [2:0]             axi_m0_arprot,
   input  logic                   axi_m0_arready,

   // Read response channel
   input  logic                   axi_m0_rvalid,
   input  logic [ID_WIDTH-1:0]    axi_m0_rid,
   input  logic [DATA_WIDTH-1:0]  axi_m0_rdata,
   input  logic [1:0]             axi_m0_rresp,
   input  logic                   axi_m0_rlast,
   output logic                   axi_m0_rready
);

localparam MAX_PENDING_READS = 16;
localparam MAX_PENDING_READS_WIDTH = $clog2(MAX_PENDING_READS);

typedef struct packed {
   logic [ID_WIDTH-1:0]    arid;
   logic [ADDR_WIDTH-1:0]  araddr;
   logic [7:0]             arlen;
   logic [2:0]             arsize;
   logic [1:0]             arburst;
} t_ar_if;
localparam AR_IF_WIDTH = $bits(t_ar_if);

logic   m0_arvalid;
logic   m0_arready;
t_ar_if m0_ar_if;

logic   s0_arready;
t_ar_if axi_s0_ar_if;
t_ar_if s0_ar_if;

logic [MAX_PENDING_READS_WIDTH:0] pending_reads_cnt;
logic max_pending_hit;

logic last_response;

//--------------------------------------------------------------

//--------------------------
// Slave interface pipeline 
//--------------------------
assign axi_s0_ar_if.arid    =  axi_s0_arid;
assign axi_s0_ar_if.araddr  =  axi_s0_araddr;
assign axi_s0_ar_if.arlen   =  axi_s0_arlen;
assign axi_s0_ar_if.arsize  =  axi_s0_arsize;
assign axi_s0_ar_if.arburst =  axi_s0_arburst;

ofs_pipeline_reg #(
   .REG_MODE    (0), // skid-buffer
   .WIDTH       (AR_IF_WIDTH)
) axi_s0_arreg (
   .clk     (axi_s0_clk),
   .rst_n   (axi_s0_resetn),
   .s_ready (axi_s0_arready),
   .s_valid (axi_s0_arvalid),
   .s_data  (axi_s0_ar_if),
   .m_ready (s0_arready),
   .m_valid (s0_arvalid),
   .m_data  (s0_ar_if)
);

assign max_pending_hit = pending_reads_cnt[MAX_PENDING_READS_WIDTH];
assign m0_arready      = (~axi_m0_arvalid || axi_m0_arready);
assign s0_arready      = m0_arready && ~max_pending_hit;

//--------------------------
// Max pending reads = 16 
//--------------------------
//
//   Restrict maximum pending reads to 16 to meet QSYS read FIFO size limitation (2^23)
//   AXI-4 supports up to 256 burst length, so, the maximum payload per read request is 256*1024-bit (2^18)
//   QSYS appended 2 extra bits to the payload (1026-bit) when it is written into the readdata FIFO in QSYS interconnect
//   So, with 2^23 bits limitation, the max pending reads that can be supported is 16 (2^4)
//
//   The pending_reads_cnt tracks the number of pending reads
//   s0_arready will be de-asserted when the counter reaches the max pending reads allowed
//
//--------------------------

// Decrement the counter in the next cycle after the last response of a read reqeust is received
// to reduce fanin to pending_reads_cnt, adding 1 cycle of pessimism
always_ff @(posedge axi_s0_clk) begin
   if (~axi_s0_resetn) begin
      last_response <= 1'b0;
   end else begin
      last_response <= (axi_m0_rvalid && axi_m0_rlast && axi_m0_rready);
   end
end

always_ff @(posedge axi_s0_clk) begin
   if (~axi_s0_resetn) begin
      pending_reads_cnt <= 'd1;
   end else begin
      if (m0_arvalid && m0_arready) begin
         if (~last_response) pending_reads_cnt <= pending_reads_cnt + 1'b1;
      end else if (last_response) begin
         pending_reads_cnt <= pending_reads_cnt - 1'b1;
      end
   end
end

//--------------------------
// Master interface pipeline 
//--------------------------
always_ff @(posedge axi_s0_clk) begin
   if (m0_arready) m0_ar_if <= s0_ar_if;
end

always_ff @(posedge axi_s0_clk) begin
   if (~axi_s0_resetn) begin
      m0_arvalid <= 1'b0;
   end else if (m0_arready) begin
      m0_arvalid <= 1'b0;
      if (s0_arvalid && ~max_pending_hit) m0_arvalid <= 1'b1;
   end
end

//------------------------
// Interface assignments 
//------------------------
assign axi_m0_clk      =  axi_s0_clk;
assign axi_m0_resetn   =  axi_s0_resetn;

assign axi_m0_awvalid  =  axi_s0_awvalid;
assign axi_m0_awid     =  axi_s0_awid;
assign axi_m0_awaddr   =  axi_s0_awaddr;
assign axi_m0_awlen    =  axi_s0_awlen;
assign axi_m0_awsize   =  axi_s0_awsize;
assign axi_m0_awburst  =  axi_s0_awburst;
assign axi_m0_awprot   =  '0;
assign axi_s0_awready  =  axi_m0_awready;

assign axi_m0_wvalid   =  axi_s0_wvalid;
assign axi_m0_wdata    =  axi_s0_wdata[0+:ACTUAL_DATA_WIDTH];
assign axi_m0_wstrb    =  {'0, axi_s0_wstrb[0+:ACTUAL_WSTRB_WIDTH]};
assign axi_m0_wlast    =  axi_s0_wlast;
assign axi_s0_wready   =  axi_m0_wready;

assign axi_s0_bvalid   =  axi_m0_bvalid;
assign axi_s0_bid      =  axi_m0_bid;
assign axi_s0_bresp    =  axi_m0_bresp;
assign axi_m0_bready   =  axi_s0_bready;

assign axi_m0_arvalid  =  m0_arvalid;
assign axi_m0_arid     =  m0_ar_if.arid;
assign axi_m0_araddr   =  m0_ar_if.araddr;
assign axi_m0_arlen    =  m0_ar_if.arlen;
assign axi_m0_arsize   =  m0_ar_if.arsize;
assign axi_m0_arburst  =  m0_ar_if.arburst;
assign axi_m0_arprot   =  '0;

assign axi_s0_rvalid   =  axi_m0_rvalid;
assign axi_s0_rid      =  axi_m0_rid;
assign axi_s0_rdata    =  {'0, axi_m0_rdata[0+:ACTUAL_DATA_WIDTH]};
assign axi_s0_rresp    =  axi_m0_rresp;
assign axi_s0_rlast    =  axi_m0_rlast;
assign axi_m0_rready   =  axi_s0_rready;

endmodule

