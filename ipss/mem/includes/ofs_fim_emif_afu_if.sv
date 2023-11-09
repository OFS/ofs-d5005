// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//  Definition of AFU Memory Mapped Interfaces to EMIF
//
//-----------------------------------------------------------------------------

`ifndef __OFS_FIM_EMIF_AFU_IF_SV__
`define __OFS_FIM_EMIF_AFU_IF_SV__

// EMIF AVMM interface
interface ofs_fim_emif_afu_avmm_if #(
   parameter ADDR_WIDTH = 27,
   parameter DATA_WIDTH = 576,
   parameter BURSTCOUNT_WIDTH = 7,
   parameter BYTEENABLE_WIDTH = 72
);
   //---------------------------
   // Memory clock and reset
   //---------------------------
   logic                         mem_clk;
   logic                         mem_rst_n;

   //---------------------------
   // AVMM interface signals
   //---------------------------
    logic                        waitrequest;
    logic                        readdatavalid;
    logic [DATA_WIDTH-1:0]       readdata;
    
    logic [ADDR_WIDTH-1:0]       address;
    logic                        write;
    logic                        read;
    logic [BURSTCOUNT_WIDTH-1:0] burstcount;
    logic [DATA_WIDTH-1:0]       writedata;
    logic [BYTEENABLE_WIDTH-1:0] byteenable;
    
    modport slave (
        input  read, write, writedata, address, burstcount,
               byteenable,
        output readdata, readdatavalid, waitrequest, mem_clk, mem_rst_n
    );

    modport master (
        output read, write, writedata, address, burstcount,
               byteenable,
        input  readdata, readdatavalid, waitrequest, mem_clk, mem_rst_n 
    );
endinterface : ofs_fim_emif_afu_avmm_if

// EMIF AXI interface
interface ofs_fim_emif_afu_axi_if #(
   parameter AWID_WIDTH   = 6,
   parameter AWADDR_WIDTH = 34,
   parameter WDATA_WIDTH  = 1024,
   parameter ARID_WIDTH   = 6,
   parameter ARADDR_WIDTH = 34,
   parameter RDATA_WIDTH  = 1024
);

   //---------------------------
   // Memory clock and reset
   //---------------------------
   logic                       mem_clk;
   logic                       mem_rst_n;

   //---------------------------
   // AXI interface signals
   //---------------------------
   logic                       clk;
   logic                       rst_n;

   // Write address channel
   logic                       awready;
   logic                       awvalid;
   logic [AWID_WIDTH-1:0]      awid;
   logic [AWADDR_WIDTH-1:0]    awaddr;
   logic [7:0]                 awlen;
   logic [2:0]                 awsize;
   logic [1:0]                 awburst;
   logic [2:0]                 awprot;

   // Write data channel
   logic                       wready;
   logic                       wvalid;
   logic [WDATA_WIDTH-1:0]     wdata;
   logic [(WDATA_WIDTH/8-1):0] wstrb;
   logic                       wlast;

   // Write response channel
   logic                       bready;
   logic                       bvalid;
   logic [AWID_WIDTH-1:0]      bid;
   logic [1:0]                 bresp;

   // Read address channel
   logic                       arready;
   logic                       arvalid;
   logic [ARID_WIDTH-1:0]      arid;
   logic [ARADDR_WIDTH-1:0]    araddr;
   logic [7:0]                 arlen;
   logic [2:0]                 arsize;
   logic [1:0]                 arburst;
   logic [2:0]                 arprot;

   // Read response channel
   logic                       rready;
   logic                       rvalid;
   logic [ARID_WIDTH-1:0]      rid;
   logic [RDATA_WIDTH-1:0]     rdata;
   logic [1:0]                 rresp;
   logic                       rlast;
	
   modport master (
      input    mem_clk, mem_rst_n,
               awready, wready, 
               bvalid, bid, bresp, 
               arready, 
               rvalid, rid, rdata, rresp, rlast,

      output   clk, rst_n, 
               awvalid, awid, awaddr, awlen, awsize, awburst, awprot,
               wvalid, wdata, wstrb, wlast,
               bready, 
               arvalid, arid, araddr, arlen, arsize, arburst, arprot,
               rready
   );

   modport slave (
      output   mem_clk, mem_rst_n,
               awready, wready, 
               bvalid, bid, bresp, 
               arready, 
               rvalid, rid, rdata, rresp, rlast,

      input    clk, rst_n, 
               awvalid, awid, awaddr, awlen, awsize, awburst, awprot,
               wvalid, wdata, wstrb, wlast,
               bready, 
               arvalid, arid, araddr, arlen, arsize, arburst, arprot,
               rready
   );
   
endinterface : ofs_fim_emif_afu_axi_if 
`endif // __OFS_FIM_EMIF_AFU_IF_SV__
