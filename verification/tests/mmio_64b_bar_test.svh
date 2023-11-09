// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 64b BAR MMIO access for all registers
//-----------------------------------------------------------------------------

`ifndef MMIO_64B_BAR_TEST_SVH
`define MMIO_64B_BAR_TEST_SVH

class mmio_64b_bar_test extends base_test;
    `uvm_component_utils(mmio_64b_bar_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        mmio_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = mmio_seq::type_id::create("m_seq");
	m_seq.randomize() with { use_64b_bar == 1; };
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : mmio_64b_bar_test

`endif // MMIO_64B_BAR_TEST_SVH
