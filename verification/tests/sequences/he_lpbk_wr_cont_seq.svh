// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_wr_cont_seq is executed by he_lbbk_wr_cont_test.
// This sequence verifies the write continuous mode functionality of the HE-LPBK module  
// The sequence extends the he_lpbk_sequence  
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_WR_CONT_SEQ_SVH
`define HE_LPBK_WR_CONT_SEQ_SVH

class he_lpbk_wr_cont_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_wr_cont_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only
constraint mode_cont { cont_mode == 1; } // cont mode 1
    constraint report_perf_data_c { report_perf_data == 1; }

    function new(string name = "he_lpbk_wr_cont_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_wr_cont_seq

`endif // HE_LPBK_WR_CONT_SEQ_SVH
