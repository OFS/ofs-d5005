// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class he_lbbk_port_rst_seq is executed by he_lbbk_port_rst_test
// This sequence is extended from base_sequence
// This sequence perform multiple iteration on he_lpbk module, randomized num_lines, addresses, req_len with port rst
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_PORT_RST_SEQ_SVH
`define HE_LPBK_PORT_RST_SEQ_SVH

class he_lpbk_port_rst_seq extends base_seq;
    `uvm_object_utils(he_lpbk_port_rst_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    he_lpbk_seq lpbk_seq;
    rand int loop;

    constraint loop_c { loop inside {[10:20]}; }

    function new(string name = "he_lpbk_port_rst_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
	for(int i = 0; i < loop; i++) begin
	    `uvm_do_on_with(lpbk_seq, p_sequencer, {
	        mode inside {3'b000, 3'b001, 3'b010, 3'b011};
		bypass_config_seq == 1;
	    })
	    port_rst_flow(1);
	end
	check_afu_intf_error();
    endtask : body

endclass : he_lpbk_port_rst_seq

`endif // HE_LPBK_PORT_RST_SEQ_SVH
