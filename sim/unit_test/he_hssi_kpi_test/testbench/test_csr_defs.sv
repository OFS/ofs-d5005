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

   // ******************************************************************************************
   // CSR Address Space
   // ******************************************************************************************
   localparam HSSI_BASE_ADDR        = 32'h30000;
   localparam HE_HSSI_BASE_ADDR     = 32'h180000;
   localparam PORT_CONTROL          = 32'h91038;

   // ******************************************************************************************
   // HE-HSSI CSR Address
   // ******************************************************************************************
   parameter TG_PKT_LEN_ADDR                = 32'hE034; // 'h380D
   parameter TG_DATA_PATTERN_ADDR           = 32'hE008; // 'h3802
   parameter TG_NUM_PKT_ADDR                = 32'hE000; // 'h3800
   parameter TG_START_XFR_ADDR              = 32'hE00C; // 'h3803
   parameter TG_END_TS_ADDR                 = 32'hE3D0; // 'h38F4

   parameter TM_PKT_GOOD_ADDR               = 32'hE404; // 'h3901
   parameter TM_PKT_BAD_ADDR                = 32'hE408; // 'h3902
   parameter TM_START_TS_ADDR               = 32'hE42C; // 'h390B
   parameter TM_END_TS_ADDR                 = 32'hE430; // 'h390C

    /*
   parameter TG_PKT_LEN_TYPE_ADDR           = 32'h01;
   parameter TG_DATA_PATTERN_ADDR           = 32'h02;
   parameter TG_STOP_XFR_ADDR               = 32'h04;
   parameter TG_SRC_MAC_L_ADDR              = 32'h05;
   parameter TG_SRC_MAC_H_ADDR              = 32'h06;
   parameter TG_DST_MAC_L_ADDR              = 32'h07;
   parameter TG_DST_MAC_H_ADDR              = 32'h08;
   parameter TG_PKT_XFRD_ADDR               = 32'h09;
   parameter TG_RANDOM_SEED0_ADDR           = 32'h0A;
   parameter TG_RANDOM_SEED1_ADDR           = 32'h0B;
   parameter TG_RANDOM_SEED2_ADDR           = 32'h0C;
   
   parameter TM_NUM_PKT_ADDR                = 32'h100;
   parameter TM_BYTE_CNT0_ADDR              = 32'h103;
   parameter TM_BYTE_CNT1_ADDR              = 32'h104;
   parameter TM_AVST_RX_ERR_ADDR            = 32'h107;
   
   parameter LOOPBACK_EN_ADDR               = 32'h200;
   */



endpackage

`endif
