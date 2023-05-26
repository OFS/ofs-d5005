// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : Enable all HEs and randomize modes for mutliple iterations
//-----------------------------------------------------------------------------

`ifndef HE_RANDOM_LONG_TEST_SVH
`define HE_RANDOM_LONG_TEST_SVH

class he_random_long_test extends base_test;
    `uvm_component_utils(he_random_long_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        he_random_long_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_random_long_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_random_long_test

`endif // HE_RANDOM_LONG_TEST_SVH
