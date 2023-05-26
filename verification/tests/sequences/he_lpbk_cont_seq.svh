// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_cont_seq is executed by he_lbbk_cont_test.
// This sequence verifies the Continuous mode/LPBK mode,random num_lines,req_len of HE-LPBK module  
// The sequence extends the he_lpbk_seq 
// Sequence is running on virtual_sequencer .
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_CONT_SEQ_SVH
`define HE_LPBK_CONT_SEQ_SVH

class he_lpbk_cont_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_cont_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint cont_mode_c {
        cont_mode == 1;
    }

    constraint num_lines_c {
        num_lines inside {[1:16]};
	if(mode != 3'b011) {
	    (num_lines % (2**req_len)) == 0;
	    (num_lines / (2**req_len)) >  0;
	}
	else {
	    num_lines % 2 == 0;
	    ((num_lines/2) % (2**req_len)) == 0;
	    ((num_lines/2) / (2**req_len)) >  0;
	}
	solve mode before num_lines;
	solve req_len before num_lines;
    }

    function new(string name = "he_lpbk_cont_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_cont_seq

`endif // HE_LPBK_CONT_SEQ_SVH
