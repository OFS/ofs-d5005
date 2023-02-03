// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//  This file contains SystemVerilog interface definitions defining
//  EMIF/DDR4 related interfaces
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_EMIF_IF_SV__
`define __OFS_FIM_EMIF_IF_SV__

import ofs_fim_emif_cfg_pkg::*;

// Interface between the EMIF IP and the user-logic/GBS. Includes an
// AVMM bus, EMIF source clock, reset, and ECC interrupt flag.
interface ofs_fim_emif_avmm_if #(
    parameter ADDR_WIDTH = ofs_fim_emif_cfg_pkg::AVMM_ADDR_WIDTH,
    parameter DATA_WIDTH = ofs_fim_emif_cfg_pkg::AVMM_DATA_WIDTH,
    parameter BURSTCOUNT_WIDTH = ofs_fim_emif_cfg_pkg::AVMM_BURSTCOUNT_WIDTH,
    parameter BYTEENABLE_WIDTH = ofs_fim_emif_cfg_pkg::AVMM_BYTEENABLE_WIDTH
);
    logic clk;
    logic rst_n;
    logic ecc_interrupt;
    
    logic waitrequest;
    logic [DATA_WIDTH-1:0] readdata;
    logic readdatavalid;
    
    logic [BURSTCOUNT_WIDTH-1:0] burstcount;
    logic [DATA_WIDTH-1:0] writedata;
    logic [ADDR_WIDTH-1:0] address;
    logic write;
    logic read;
    logic [BYTEENABLE_WIDTH-1:0] byteenable;
    
    modport emif (
        input  read, write, writedata, address, burstcount,
               byteenable,
        output readdata, readdatavalid, waitrequest, clk, rst_n, ecc_interrupt
    );
    modport user (
        output read, write, writedata, address, burstcount,
               byteenable,
        input  readdata, readdatavalid, waitrequest, clk, rst_n, ecc_interrupt
    );
endinterface : ofs_fim_emif_avmm_if

//Status and control signals between BBS/FME/CHKR and the EMIF IP.
interface ofs_fim_emif_sideband_if();
    logic pll_locked;
    logic local_reset_done;
    logic cal_success;
    logic cal_failure;
    logic clear_busy;
    logic chkr_clear_n;
    logic chkr_error;
    
    modport csr (
        output  chkr_clear_n,
        input   local_reset_done, pll_locked, 
                cal_failure, cal_success, clear_busy, chkr_error 
    );
endinterface : ofs_fim_emif_sideband_if

//Interface defining the signals between the EMIF IP and external memory.
interface ofs_fim_emif_mem_if #(
    parameter ADDR_WIDTH = ofs_fim_emif_cfg_pkg::MEM_ADDR_WIDTH,
    parameter BA_WIDTH   = ofs_fim_emif_cfg_pkg::MEM_BA_WIDTH,
    parameter BG_WIDTH   = ofs_fim_emif_cfg_pkg::MEM_BG_WIDTH,
    parameter DQS_WIDTH  = ofs_fim_emif_cfg_pkg::MEM_DQS_WIDTH,
    parameter DQ_WIDTH   = ofs_fim_emif_cfg_pkg::MEM_DQ_WIDTH,
    parameter DBI_WIDTH  = ofs_fim_emif_cfg_pkg::MEM_DBI_WIDTH
);
    logic ck;
    logic ck_n;
    logic [ADDR_WIDTH-1:0] a;
    logic act_n;
    logic [BA_WIDTH-1:0] ba;
    logic [BG_WIDTH-1:0] bg;
    logic cke;
    logic cs_n;
    logic odt;
    logic reset_n;
    logic par;    
    logic alert_n;
    wire [DQS_WIDTH-1:0] dqs;
    wire [DQS_WIDTH-1:0] dqs_n;
    wire [DQ_WIDTH-1:0]  dq;
    wire [DBI_WIDTH-1:0] dbi_n;
    logic oct_rzqin;
    logic ref_clk;
    
    modport emif (
        input  alert_n, oct_rzqin, ref_clk,
        output ck, ck_n, cke, reset_n, 
               a, act_n, ba, bg, cs_n, odt, par,
        inout  dqs, dqs_n, dq, dbi_n
    );
endinterface : ofs_fim_emif_mem_if

`endif // __OFS_FIM_EMIF_IF_SV__
