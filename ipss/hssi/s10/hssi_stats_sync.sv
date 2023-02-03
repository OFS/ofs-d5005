// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

/*
    *** Synchronizers for HSSI Stats Registers ***
*/

`timescale 1ps/1ps

import hssi_csr_pkg::*;

module hssi_stats_sync #(
    parameter NUM_LN = 4
) (
    input  logic                    i_fme_clk,
    input  hssi_stats_struct_t      i_hssi_stats        [NUM_LN],
    output hssi_stats_struct_t      o_hssi_stats_sync   [NUM_LN]
);

genvar lane;
generate
    for (lane=0; lane<NUM_LN; lane++)
    begin : HSSI_STAT_CHAN
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_ready
            inst_sync_rx_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_ready),
                             .q(o_hssi_stats_sync[lane].rx_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_ready
            inst_sync_tx_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_ready),
                             .q(o_hssi_stats_sync[lane].tx_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_is_lockedtoref
            inst_sync_rx_is_lockedtoref (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_is_lockedtoref),
                             .q(o_hssi_stats_sync[lane].rx_is_lockedtoref));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_is_lockedtodata
            inst_sync_rx_is_lockedtodata (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_is_lockedtodata),
                             .q(o_hssi_stats_sync[lane].rx_is_lockedtodata));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_cal_busy
            inst_sync_rx_cal_busy (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_cal_busy),
                             .q(o_hssi_stats_sync[lane].rx_cal_busy));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_cal_busy
            inst_sync_tx_cal_busy (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_cal_busy),
                             .q(o_hssi_stats_sync[lane].tx_cal_busy));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_transfer_ready
            inst_sync_rx_transfer_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_transfer_ready),
                             .q(o_hssi_stats_sync[lane].rx_transfer_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_transfer_ready
            inst_sync_tx_transfer_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_transfer_ready),
                             .q(o_hssi_stats_sync[lane].tx_transfer_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_fifo_ready
            inst_sync_rx_fifo_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_fifo_ready),
                             .q(o_hssi_stats_sync[lane].rx_fifo_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_fifo_ready
            inst_sync_tx_fifo_ready (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_fifo_ready),
                             .q(o_hssi_stats_sync[lane].tx_fifo_ready));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_digitalreset_timeout
            inst_sync_rx_digitalreset_timeout (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_digitalreset_timeout),
                             .q(o_hssi_stats_sync[lane].rx_digitalreset_timeout));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_digitalreset_timeout
            inst_sync_tx_digitalreset_timeout (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_digitalreset_timeout),
                             .q(o_hssi_stats_sync[lane].tx_digitalreset_timeout));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_digitalreset_stat
            inst_sync_rx_digitalreset_stat (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_digitalreset_stat),
                             .q(o_hssi_stats_sync[lane].rx_digitalreset_stat));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // rx_analogreset_stat
            inst_sync_rx_analogreset_stat (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].rx_analogreset_stat),
                             .q(o_hssi_stats_sync[lane].rx_analogreset_stat));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_digitalreset_stat
            inst_sync_tx_digitalreset_stat (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_digitalreset_stat),
                             .q(o_hssi_stats_sync[lane].tx_digitalreset_stat));
        fim_resync #(.SYNC_CHAIN_LENGTH(2), .WIDTH(1), .INIT_VALUE(0), .NO_CUT(0)) // tx_analogreset_stat
            inst_sync_tx_analogreset_stat (.clk(i_fme_clk), .reset(1'b0),
                             .d(i_hssi_stats[lane].tx_analogreset_stat),
                             .q(o_hssi_stats_sync[lane].tx_analogreset_stat));
    end
endgenerate

endmodule // hssi_stats_sync
