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
   localparam FME_DFH               = 32'h0;
   localparam FME_SCRATCHPAD0       = FME_DFH + 32'h28;

   localparam PMCI_DFH              = 32'h10000;
   localparam PMCI_SCRATCHPAD       = PMCI_DFH + 32'h28;

   localparam PCIE_DFH              = 32'h20000;
   localparam PCIE_SCRATCHPAD       = PCIE_DFH + 32'h8;

   localparam ST2MM_DFH             = 32'h80000;
   localparam ST2MM_SCRATCHPAD      = ST2MM_DFH + 32'h8;

   localparam PGSK_DFH              = 32'h90000;
   localparam PGSK_SCRATCHPAD       = PGSK_DFH + 32'hb8;

   localparam HSSI_DFH              = 32'h30000;
   localparam HSSI_SCRATCHPAD       = HSSI_DFH + 32'h38;

   localparam HE_LB_DFH             = 32'h00000;
   localparam HE_LB_SCRATCHPAD      = HE_LB_DFH + 32'h100;

   localparam HE_HSSI_SCRATCHPAD    = HE_LB_DFH + 32'h48;

   localparam PORT_CONTROL          = 32'h91038;

/*
   localparam PCIE_DFH           = 32'h10000;
   localparam PCIE_SCRATCHPAD    = PCIE_DFH + 32'h8;
   localparam PCIE_TESTPAD       = PCIE_DFH + 32'h38;

   localparam HE_LB_SCRATCHPAD   = 32'h100;
   //localparam EMIF_DFH           = 32'h41000;

   localparam HSSI_DFH           = 32'h60000;
   localparam HSSI_RCFG_DATA     = HSSI_DFH + 32'h30;

   //localparam USER_CLK_DFH       = 32'h20000;
   //localparam USER_CLK_CMD_0     = 32'h20008;

   //localparam PCIE_DFH_VALUE     = 64'h3000000010000020; 
   //localparam EMIF_DFH_VALUE     = 64'h3000000010000009; 
   //localparam HSSI_DFH_VALUE     = 64'h300000001000100f; 
   //localparam USER_CLK_DFH_VALUE = 64'h3000010000000014;
*/

endpackage

`endif
