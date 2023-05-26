// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_reqlen4_seq is executed by he_lbbk_reqlen4_test.
// The sequence extends the he_lpbk_sequence and it is constraint for req_len 4 
// This sequence verifies loopback functionality of req_len 4CL
// Sequence is running on virtual_sequencer.
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_REQLEN4_SEQ_SVH
`define HE_LPBK_REQLEN4_SEQ_SVH

class he_lpbk_reqlen4_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_reqlen4_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint req_len_c   { req_len == 2'b10; }
    constraint num_lines_c { num_lines == 1024; }
    constraint report_perf_data_c { report_perf_data == 1; }

    function new(string name = "he_lpbk_reqlen4_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_reqlen4_seq

`endif // HE_LPBK_REQLEN4_SEQ_SVH
