// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//  Test parameters 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_PARAM_DEFS__
`define __TEST_PARAM_DEFS__

package test_param_defs;

    // ******************************************************************************************
    // Traffic Controller Register Values
    // ******************************************************************************************
    parameter TG_NUM_PKT_VAL                = 32'h20;  // Number of packet to be transfered
    parameter TG_PKT_LEN_TYPE_VAL           = 32'h0000;  // 1'b0: Fixed Length; 1'b1: Random length 
    parameter TG_DATA_PATTERN_VAL           = 32'h0001;  // 1'b0: Incremental pattern; 1'b1: Random pattern
    parameter TG_PKT_LEN_VAL                = 32'h42;  // Length of each packet to be transfered

    parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;
    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_NOOP = 32'h0;
    parameter MB_RD = 32'h1;
    parameter MB_WR = 32'h2;
    parameter RX_STATISTICS_ADDR = 32'h3000;
    parameter TX_STATISTICS_ADDR = 32'h7000;
    parameter HSSI_RCFG_CMD_ADDR = 32'h28;

    // ******************************************************************************************
    // MAC Stat Parameters
    // ******************************************************************************************
    parameter STATISTICS_framesOK_OFFSET                        = 32'h008;
    parameter STATISTICS_framesErr_OFFSET                       = 32'h010;
    parameter STATISTICS_framesCRCErr_OFFSET                    = 32'h018;
    parameter STATISTICS_octetsOK_OFFSET                        = 32'h020;
    parameter STATISTICS_pauseMACCtrlFrames_OFFSET              = 32'h028;
    parameter STATISTICS_ifErrors_OFFSET                        = 32'h030;
    parameter STATISTICS_unicastFramesOK_OFFSET                 = 32'h038;
    parameter STATISTICS_unicastFramesErr_OFFSET                = 32'h040;
    parameter STATISTICS_multicastFramesOK_OFFSET               = 32'h048;
    parameter STATISTICS_multicastFramesErr_OFFSET              = 32'h050;
    parameter STATISTICS_broadcastFramesOK_OFFSET               = 32'h058;
    parameter STATISTICS_broadcastFramesErr_OFFSET              = 32'h060;
    parameter STATISTICS_etherStatsOctets_OFFSET                = 32'h068;
    parameter STATISTICS_etherStatsPkts_OFFSET                  = 32'h070;
    parameter STATISTICS_etherStatsUndersizePkts_OFFSET         = 32'h078;
    parameter STATISTICS_etherStatsOversizePkts_OFFSET          = 32'h080;
    parameter STATISTICS_etherStatsPkts64Octets_OFFSET          = 32'h088;
    parameter STATISTICS_etherStatsPkts65to127Octets_OFFSET     = 32'h090;
    parameter STATISTICS_etherStatsPkts128to255Octets_OFFSET    = 32'h098;
    parameter STATISTICS_etherStatsPkts256to511Octets_OFFSET    = 32'h0A0;
    parameter STATISTICS_etherStatsPkts512to1023Octets_OFFSET   = 32'h0A8;
    parameter STATISTICS_etherStatPkts1024to1518Octets_OFFSET   = 32'h0B0;
    parameter STATISTICS_etherStatsPkts1519toXOctets_OFFSET     = 32'h0B8;
    parameter STATISTICS_etherStatsFragments_OFFSET             = 32'h0C0;
    parameter STATISTICS_etherStatsJabbers_OFFSET               = 32'h0C8;
    parameter STATISTICS_etherStatsCRCErr_OFFSET                = 32'h0D0;
    parameter STATISTICS_unicastMACCtrlFrames_OFFSET            = 32'h0D8;
    parameter STATISTICS_multicastMACCtrlFrames_OFFSET          = 32'h0E0;
    parameter STATISTICS_broadcastMACCtrlFrames_OFFSET          = 32'h0E8;

   
endpackage

`endif
