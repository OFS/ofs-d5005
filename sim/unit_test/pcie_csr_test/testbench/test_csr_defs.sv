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

   localparam EMIF_DFH           = 32'h41000;
   localparam PCIE_DFH_VALUE     = 64'h3000000010000020; 
   localparam EMIF_DFH_VALUE     = 64'h3000000010000009; 
   localparam HSSI_DFH_VALUE     = 64'h300000001000100f; 
   localparam USER_CLK_DFH_VALUE = 64'h3000010000000014;
   localparam SPI_DFH            = 32'h43000;
   localparam SPI_DFH_VALUE      = 64'h300001000000000e; 
   localparam SPI_WRITEDATA      = 32'h43020;
   localparam HSSI_RCFG_DATA     = 32'h42030;
   localparam VFME_AFU_ID_L      = 32'h8;
   localparam VFME_AFU_ID_L_VALUE = 64'hBEE40B2B259849A9;
   localparam VFME_AFU_ID_H      = 32'h10;
   localparam VFME_AFU_ID_H_VALUE = 64'hA8E434048329FE10;
   localparam VFME_MSIX_VADDR0   = 32'h3000;
   localparam USER_CLK_DFH       = 32'h20000;
   localparam USER_CLK_CMD_0     = 32'h20008;

	 localparam USER_IRQ0_ADDR = 64'h20000; 
   localparam USER_IRQ1_ADDR = 64'h21000; 
   localparam USER_IRQ2_ADDR = 64'h22000; 
   localparam USER_IRQ3_ADDR = 64'h23000; 
   localparam USER_IRQ4_ADDR = 64'h24000; 
   localparam USER_IRQ5_ADDR = 64'h25000; 
   localparam USER_IRQ6_ADDR = 64'h26000; 

   localparam USER_IRQ0_DATA = 32'hbeef_0000; 
   localparam USER_IRQ1_DATA = 32'hbeef_0001; 
   localparam USER_IRQ2_DATA = 32'hbeef_0002; 
   localparam USER_IRQ3_DATA = 32'hbeef_0003; 
   localparam USER_IRQ4_DATA = 32'hbeef_0004; 
   localparam USER_IRQ5_DATA = 32'hbeef_0005; 
   localparam USER_IRQ6_DATA = 32'hbeef_0006;

   //Added for PCIE_CSR_TEST
   localparam PCIE0_ERROR        = 32'h4020;
   localparam PCIE_STAT          = 32'h20010;
   localparam PCIE_ERROR_MASK    = 32'h20018;
   localparam PCIE_ERROR         = 32'h20020;
   localparam PCIE_UNUSED_OFFSET = 32'h40ff8;
/*
   localparam PCIE_DFH           = 32'h10000;
   localparam PCIE_SCRATCHPAD    = PCIE_DFH + 32'h8;
   localparam PCIE_TESTPAD       = PCIE_DFH + 32'h38;

   localparam HE_LB_SCRATCHPAD   = 32'h100;

   localparam HSSI_DFH           = 32'h60000;
   localparam HSSI_RCFG_DATA     = HSSI_DFH + 32'h30;

   //localparam USER_CLK_DFH       = 32'h20000;
   //localparam USER_CLK_CMD_0     = 32'h20008;

*/

endpackage

`endif
