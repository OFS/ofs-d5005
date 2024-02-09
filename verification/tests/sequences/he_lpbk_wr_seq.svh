// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_wr_seq is executed by he_lbbk_wr_test.
// This sequence verifies the write functionality of the HE-LPBK module  
// The sequence extends the he_lpbk_sequence 
// The number of write transaction is verified comparing with DSM status register
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_WR_SEQ_SVH
`define HE_LPBK_WR_SEQ_SVH

class he_lpbk_wr_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_wr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only
    constraint report_perf_data_c { report_perf_data == 1; }

    function new(string name = "he_lpbk_wr_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_wr_seq

`endif // HE_LPBK_WR_SEQ_SVH
