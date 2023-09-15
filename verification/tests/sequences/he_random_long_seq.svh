// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_random_long_seq is executed by he_random_long_test
// This sequence is extended from he_random_seq
// Enable all HEs and randomize modes for mutliple iterations
// This sequence perform multiple iteration on he_lpbk and he_mem modules
// Simultaniously running he_lpbk and he_mem with all the modes constrains
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_RANDOM_LONG_SEQ_SVH
`define HE_RANDOM_LONG_SEQ_SVH

class he_random_long_seq extends he_random_seq;
    `uvm_object_utils(he_random_long_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint loop_c { loop inside {[10:20]}; }

    function new(string name = "he_random_long_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
    endtask : body

endclass : he_random_long_seq

`endif // HE_RANDOM_LONG_SEQ_SVH
