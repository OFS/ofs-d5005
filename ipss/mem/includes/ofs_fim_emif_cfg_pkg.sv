// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//  This file contains SystemVerilog package definitions for EMIF related 
//  parameters and types
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_EMIF_CFG_PKG_SV__
`define __OFS_FIM_EMIF_CFG_PKG_SV__

`include "fpga_defines.vh"

package ofs_fim_emif_cfg_pkg;
   
   // Width of the "real" data bus (without ECC)
   localparam AVMM_DATA_BASE_WIDTH = 512;

   // Width of extra ECC memory
   localparam AVMM_ECC_WIDTH = 64;

   // Full data bus, including ECC
   localparam AVMM_DATA_WIDTH = AVMM_DATA_BASE_WIDTH + AVMM_ECC_WIDTH;
   localparam AVMM_BYTEENABLE_WIDTH = (AVMM_DATA_WIDTH / 8);
   localparam AVMM_ADDR_WIDTH = 27;
   localparam AVMM_BURSTCOUNT_WIDTH = 7;
   
   localparam MEM_ADDR_WIDTH = 17;
   localparam MEM_BA_WIDTH = 2;
   localparam MEM_BG_WIDTH = 2;
   localparam MEM_DQS_WIDTH = 9;
   localparam MEM_DQ_WIDTH = 72;
   localparam MEM_DBI_WIDTH = 9;

endpackage : ofs_fim_emif_cfg_pkg

`endif // __OFS_FIM_EMIF_CFG_PKG_SV__ 
