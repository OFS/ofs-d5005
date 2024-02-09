// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_mem_thruput_seq is executed by he_mem_thruput_test
// This sequence verifies the thruput functionality of the HE-MEM module  
// The sequence extends the he_mem_lpbk_sequence     
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_MEM_THRUPUT_SEQ_SVH
`define HE_MEM_THRUPUT_SEQ_SVH

class he_mem_thruput_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_thruput_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b011; } // thruput only

    function new(string name = "he_mem_thruput_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_thruput_seq

`endif // HE_MEM_THRUPUT_SEQ_SVH
