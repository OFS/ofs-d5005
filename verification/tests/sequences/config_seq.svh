// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class config_seq is executed from base sequence.
// Config sequence for Linkup, Enumeration, Port reset 
// Once enumeraion is done it generates the soft_reset
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef CONFIG_SEQ_SVH
`define CONFIG_SEQ_SVH

class config_seq extends uvm_sequence;
    `uvm_object_utils(config_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    pcie_device_bring_up_link_sequence bring_up_link_seq;
    enumerate_seq                      enumerate_seq;
    bit [2:0]                          tc;
    rand bit [63:0]                    pf0_bar0;
    rand bit                           use_64b_bar;

    function new(string name = "config_seq");
        super.new(name);
    endfunction : new

    task body();
        bit status;
        super.body();
	`uvm_info(get_name(), "Entering config sequence", UVM_LOW)
	// linkup
	`uvm_info(get_name(), "Linking up...", UVM_LOW)
	`uvm_do_on(bring_up_link_seq, p_sequencer.root_virt_seqr)
	`uvm_info(get_name(), "Link is up now", UVM_LOW)
	// enumerating PCIe HIP
	`uvm_info(get_name(), "Enumerating...", UVM_LOW)
	`uvm_do_on_with(enumerate_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    enumerate_seq.pf0_bar0 == local::pf0_bar0;
	    enumerate_seq.use_64b_bar == local::use_64b_bar;
	})
	`uvm_info(get_name(), "Enumeration is done", UVM_LOW)

	status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "tc", tc);
	tc = (status) ? tc : 0;

        // initial port reset
	`uvm_info(get_name(), "Port reseting", UVM_LOW)

	//port_rst();
	`uvm_info(get_name(), "Port reset is done", UVM_LOW)

	`uvm_info(get_name(), "Exiting config sequence", UVM_LOW)
    endtask : body

   
    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

endclass : config_seq

`endif // CONFIG_SEQ_SVH
