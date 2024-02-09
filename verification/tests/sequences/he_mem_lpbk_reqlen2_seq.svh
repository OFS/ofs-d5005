// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_mem_lpbk_reqlen2_seq is executed by he_mem_lbbk_reqlen2_test.
// This sequence verifies the loopback functionality of he_mem module.   
// The sequence extends the he_mem_lpbk_sequence and it is constraint for req_len 2CL, random addresses
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_MEM_LPBK_REQLEN2_SEQ_SVH
`define HE_MEM_LPBK_REQLEN2_SEQ_SVH

class he_mem_lpbk_reqlen2_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_lpbk_reqlen2_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint req_len_c   { req_len == 2'b01; }
    constraint num_lines_c { num_lines == 1024; }

    function new(string name = "he_mem_lpbk_reqlen2_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_lpbk_reqlen2_seq

`endif // HE_MEM_LPBK_REQLEN2_SEQ_SVH
