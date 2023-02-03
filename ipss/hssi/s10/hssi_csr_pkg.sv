// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT


package hssi_csr_pkg ;
//***************************************************************************************************************************************
// Channel Stats Structure
typedef struct packed
{
    logic rx_ready;
    logic tx_ready;
    logic rx_is_lockedtoref;
    logic rx_is_lockedtodata;
    logic rx_cal_busy;
    logic tx_cal_busy;
    logic rx_transfer_ready;
    logic tx_transfer_ready;
    logic rx_fifo_ready;
    logic tx_fifo_ready;
    logic rx_digitalreset_timeout;
    logic tx_digitalreset_timeout;
    logic rx_digitalreset_stat;
    logic rx_analogreset_stat;
    logic tx_digitalreset_stat;
    logic tx_analogreset_stat;
} hssi_stats_struct_t;
//***************************************************************************************************************************************

endpackage    