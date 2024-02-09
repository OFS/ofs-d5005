// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Connector component to connect DDR AXI master interface 
// to QSYS interconnect
//  
//-----------------------------------------------------------------------------

module ddr_avmm_slave_endpoint #(
   parameter S_ADDR_WIDTH       = 27,
   parameter S_DATA_WIDTH       = 1024, 
   parameter S_BYTEENABLE_WIDTH = 128,
   parameter S_BURSTCOUNT_WIDTH = 7,

   parameter M_ADDR_WIDTH       = 27,
   parameter M_DATA_WIDTH       = 576, 
   parameter M_BYTEENABLE_WIDTH = 72,
   parameter M_BURSTCOUNT_WIDTH = 7
)(
   input  logic                          clk,
   input  logic                          reset,

   input  logic [S_ADDR_WIDTH-1:0]       s0_address,
   input  logic                          s0_write,
   input  logic                          s0_read,
   input  logic [S_BURSTCOUNT_WIDTH-1:0] s0_burstcount,
   input  logic [S_DATA_WIDTH-1:0]       s0_writedata,
   input  logic [S_BYTEENABLE_WIDTH-1:0] s0_byteenable,
   output logic                          s0_readdatavalid,
   output logic [S_DATA_WIDTH-1:0]       s0_readdata,
   output logic                          s0_waitrequest,

   output logic [M_ADDR_WIDTH-1:0]       m0_address,
   output logic                          m0_write,
   output logic                          m0_read,
   output logic [M_BURSTCOUNT_WIDTH-1:0] m0_burstcount,
   output logic [M_DATA_WIDTH-1:0]       m0_writedata,
   output logic [M_BYTEENABLE_WIDTH-1:0] m0_byteenable,
   input  logic                          m0_readdatavalid,
   input  logic [M_DATA_WIDTH-1:0]       m0_readdata,
   input  logic                          m0_waitrequest
);

   // Interface connections
   assign m0_address        =  s0_address;
   assign m0_write          =  s0_write;
   assign m0_read           =  s0_read;
   assign m0_burstcount     =  s0_burstcount [0+:M_BURSTCOUNT_WIDTH];
   assign m0_writedata      =  s0_writedata  [0+:M_DATA_WIDTH];
   assign m0_byteenable     =  s0_byteenable [0+:M_BYTEENABLE_WIDTH];

   assign s0_readdatavalid  =  m0_readdatavalid;
   assign s0_readdata       =  m0_readdata   [0+:M_DATA_WIDTH];
   assign s0_waitrequest    =  m0_waitrequest;

endmodule

