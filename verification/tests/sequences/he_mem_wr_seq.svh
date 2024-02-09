// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_mem_wr_sequence is executed by he_mem_wr_test.
// This sequence verifies the write functionality of the HE-MEM module  
// The sequence extends the he_mem_lpbk_sequence
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_MEM_WR_SEQ_SVH
`define HE_MEM_WR_SEQ_SVH

class he_mem_wr_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_wr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only

    function new(string name = "he_mem_wr_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_wr_seq

`endif // HE_MEM_WR_SEQ_SVH
