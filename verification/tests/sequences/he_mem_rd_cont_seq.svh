// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_mem_rd_cont_seq is executed by he_mem_rd_cont_test.
// This sequence verifies the read continuous mode functionality of the HE-MEM module  
// The sequence extends the he_mem_lpbk_sequence 
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_MEM_RD_CONT_SEQ_SVH
`define HE_MEM_RD_CONT_SEQ_SVH

class he_mem_rd_cont_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_rd_cont_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b001; } // read only
constraint mode_cont { cont_mode == 1; } // cont mode 1
    function new(string name = "he_mem_rd_cont_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_rd_cont_seq

`endif // HE_MEM_RD_CONT_SEQ_SVH
