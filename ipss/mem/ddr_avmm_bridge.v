// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
// ddr_avmm_bridge module is the top level instantiation of Customized 
// Avalon-MM pipeline bridge 

`timescale 1 ps / 1 ps
module ddr_avmm_bridge #(
                parameter DATA_WIDTH           = 512,
                parameter SYMBOL_WIDTH         = 8,
                parameter ADDR_WIDTH           = 26,
                parameter BURSTCOUNT_WIDTH     = 1,
                parameter READDATA_PIPE_DEPTH  = 1,

                // Derived parameter
                parameter BYTEEN_WIDTH         = DATA_WIDTH / SYMBOL_WIDTH
) (
		input  wire                          clk,              //   clk.clk
		input  wire                          m0_waitrequest,   //    m0.waitrequest
		input  wire [DATA_WIDTH-1:0]         m0_readdata,      //      .readdata
		input  wire                          m0_readdatavalid, //      .readdatavalid
		output wire [BURSTCOUNT_WIDTH-1:0]   m0_burstcount,    //      .burstcount
		output wire [DATA_WIDTH-1:0]         m0_writedata,     //      .writedata
		output wire [ADDR_WIDTH-1:0]         m0_address,       //      .address
		output wire                          m0_write,         //      .write
		output wire                          m0_read,          //      .read
		output wire [BYTEEN_WIDTH-1:0]       m0_byteenable,    //      .byteenable
		input  wire                          reset,            // reset.reset
		output wire                          s0_waitrequest,   //    s0.waitrequest
		output wire [DATA_WIDTH-1:0]         s0_readdata,      //      .readdata
		output wire                          s0_readdatavalid, //      .readdatavalid
		input  wire [BURSTCOUNT_WIDTH-1:0]   s0_burstcount,    //      .burstcount
		input  wire [DATA_WIDTH-1:0]         s0_writedata,     //      .writedata
		input  wire [ADDR_WIDTH-1:0]         s0_address,       //      .address
		input  wire                          s0_write,         //      .write
		input  wire                          s0_read,          //      .read
		input  wire [BYTEEN_WIDTH-1:0]       s0_byteenable     //      .byteenable
	);

//-----------------------------------------------------------------------------
// ddr_avmm_bridge module instantiation 
//-----------------------------------------------------------------------------
	custom_altera_avalon_mm_bridge #(
		.DATA_WIDTH          (DATA_WIDTH),
		.SYMBOL_WIDTH        (SYMBOL_WIDTH),
		.HDL_ADDR_WIDTH      (ADDR_WIDTH),
		.BURSTCOUNT_WIDTH    (BURSTCOUNT_WIDTH),
		.CMD_PIPE_DEPTH      (1),
		.READDATA_PIPE_DEPTH (READDATA_PIPE_DEPTH)
	) ddr_avmm_bridge (
		.clk              (clk),              //   clk.clk
		.reset            (reset),            // reset.reset
		.s0_waitrequest   (s0_waitrequest),   //    s0.waitrequest
		.s0_readdata      (s0_readdata),      //      .readdata
		.s0_readdatavalid (s0_readdatavalid), //      .readdatavalid
		.s0_burstcount    (s0_burstcount),    //      .burstcount
		.s0_writedata     (s0_writedata),     //      .writedata
		.s0_address       (s0_address),       //      .address
		.s0_write         (s0_write),         //      .write
		.s0_read          (s0_read),          //      .read
		.s0_byteenable    (s0_byteenable),    //      .byteenable
		.s0_debugaccess   (1'b0),             //      .debugaccess
		.m0_waitrequest   (m0_waitrequest),   //    m0.waitrequest
		.m0_readdata      (m0_readdata),      //      .readdata
		.m0_readdatavalid (m0_readdatavalid), //      .readdatavalid
		.m0_burstcount    (m0_burstcount),    //      .burstcount
		.m0_writedata     (m0_writedata),     //      .writedata
		.m0_address       (m0_address),       //      .address
		.m0_write         (m0_write),         //      .write
		.m0_read          (m0_read),          //      .read
		.m0_byteenable    (m0_byteenable),    //      .byteenable
		.m0_debugaccess   (),                 //      .debugaccess
		.s0_response      (),                 // (terminated)
		.m0_response      (2'b00)             // (terminated)
	);

endmodule
