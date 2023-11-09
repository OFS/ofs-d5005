// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_thruput_contmode_seq is executed by he_lbbk_thruput_contmode_test.
// This sequence verifies the thruput continuous mode functionality on HE_LPBK module.  
// The sequence extends the he_lpbk_sequence  
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_THRUPUT_CONTMODE_SEQ_SVH
`define HE_LPBK_THRUPUT_CONTMODE_SEQ_SVH

class he_lpbk_thruput_contmode_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_thruput_contmode_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b011; } // Thruput only
constraint mode_cont { cont_mode == 1; } // cont mode 1
    constraint report_perf_data_c { report_perf_data == 1; }

    function new(string name = "he_lpbk_thruput_contmode_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_thruput_contmode_seq

`endif // HE_LPBK_THRUPUT_CONTMODE_SEQ_SVH
