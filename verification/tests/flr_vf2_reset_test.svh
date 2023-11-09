// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description  : FLR test for VF2
//-----------------------------------------------------------------------------

`ifndef FLR_VF2_RESET_TEST_SVH
`define FLR_VF2_RESET_TEST_SVH

class flr_vf2_reset_test extends base_test;
    `uvm_component_utils(flr_vf2_reset_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        flr_vf2_reset_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = flr_vf2_reset_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : flr_vf2_reset_test

`endif // FLR_VF2_RESET_TEST_SVH
