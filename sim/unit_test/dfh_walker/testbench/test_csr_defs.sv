// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//  CSR addresses are defined for the testcase.
//
//-----------------------------------------------------------------------------
`ifndef __TEST_CSR_DEFS__
`define __TEST_CSR_DEFS__

package test_csr_defs;

typedef struct packed {
      logic [3:0]  feat_type;
      logic [7:0]  rsvd1;
      logic [3:0]  afu_minor_ver;
      logic [6:0]  rsvd0;
      logic        eol;
      logic [23:0] nxt_dfh_offset;
      logic [3:0]  afu_major_ver;
      logic [11:0] feat_id;
   } t_dfh;

   typedef enum {
      FME_DFH_IDX,
      THERM_MNGM_DFH_IDX,
      GLBL_PERF_DFH_IDX,
      GLBL_ERROR_DFH_IDX,
      SPI_DFH_IDX,
      PCIE_DFH_IDX,
      HSSI_DFH_IDX,
      EMIF_DFH_IDX,
      FME_PR_DFH_IDX,
      PORT_DFH_IDX,
      USER_CLOCK_DFH_IDX,
      PORT_STP_DFH_IDX,
      AFU_INTF_DFH_IDX,
      MAX_FME_DFH_IDX
   } t_fme_dfh_idx;

//   typedef enum {
//      PORT_DFH_IDX,
//      PORT_ERROR_DFH_IDX,
//      PORT_UINT_DFH_IDX,
//      PORT_STP_DFH_IDX,
//      USER_CLK_DFH_IDX,
//      MAX_PORT_DFH_IDX
//   } t_port_dfh_idx;

   typedef logic [8*100-1:0] dfh_name;

   localparam FME_BAR = 3'h0; 
   localparam FME_DFH_START_OFFSET = 32'h0; 
   
   localparam PORT_BAR = 3'h2; 
   localparam PORT_DFH_START_OFFSET = 32'h0; 

   function automatic dfh_name[MAX_FME_DFH_IDX-1:0] get_fme_dfh_names();
      dfh_name[MAX_FME_DFH_IDX-1:0] fme_dfh_names;

      fme_dfh_names[FME_DFH_IDX]         = "FME_DFH";
      fme_dfh_names[THERM_MNGM_DFH_IDX]  = "THERM_MNGM_DFH";
      fme_dfh_names[GLBL_PERF_DFH_IDX]   = "GLBL_PERF_DFH";
      fme_dfh_names[GLBL_ERROR_DFH_IDX]  = "GLBL_ERROR_DFH";
      fme_dfh_names[SPI_DFH_IDX]         = "SPI_DFH";
      fme_dfh_names[PCIE_DFH_IDX]        = "PCIE_DFH";
      fme_dfh_names[HSSI_DFH_IDX]        = "HSSI_DFH";
      fme_dfh_names[EMIF_DFH_IDX]        = "EMIF_DFH";
      fme_dfh_names[FME_PR_DFH_IDX]      = "FME_PR_DFH";
      fme_dfh_names[PORT_DFH_IDX]        = "PORT_DFH";
      fme_dfh_names[USER_CLOCK_DFH_IDX]  = "USER_CLOCK_DFH";
      fme_dfh_names[PORT_STP_DFH_IDX]    = "PORT_STP_DFH";
      fme_dfh_names[AFU_INTF_DFH_IDX]    = "AFU_INTF_DFH";

      return fme_dfh_names;
   endfunction

   function automatic [MAX_FME_DFH_IDX-1:0][63:0] get_fme_dfh_values();
      logic[MAX_FME_DFH_IDX-1:0][63:0] fme_dfh_values;

      fme_dfh_values[FME_DFH_IDX]        = 64'h4000_0000_1000_0000;
      fme_dfh_values[THERM_MNGM_DFH_IDX] = 64'h3_00000_002000_0001;
      fme_dfh_values[GLBL_PERF_DFH_IDX]  = 64'h3_00000_001000_0000;
      fme_dfh_values[GLBL_ERROR_DFH_IDX] = 64'h3_00000_00C000_1004;  
      fme_dfh_values[SPI_DFH_IDX]        = 64'h3_00000_010000_000e;  
      fme_dfh_values[PCIE_DFH_IDX]       = 64'h3_00000_010000_0020;  
      fme_dfh_values[HSSI_DFH_IDX]       = 64'h3_00000_010000_100f;  
      fme_dfh_values[EMIF_DFH_IDX]       = 64'h3_00000_050000_0009;  
      fme_dfh_values[FME_PR_DFH_IDX]     = 64'h3_00000_001000_1005;  
      fme_dfh_values[PORT_DFH_IDX]       = 64'h4000_0000_1000_2001;
      fme_dfh_values[USER_CLOCK_DFH_IDX] = 64'h3_00000_001000_0014;
      fme_dfh_values[PORT_STP_DFH_IDX]   = 64'h3_00000_00D000_2013;
      fme_dfh_values[AFU_INTF_DFH_IDX]   = 64'h3_00001_000000_2010; 

      return fme_dfh_values;
   endfunction

endpackage

`endif
