// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :  HE HSSI Error test
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_ERR_TEST_SVH
`define HE_HSSI_ERR_TEST_SVH

class he_hssi_err_test extends base_test;
    `uvm_component_utils(he_hssi_err_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        he_hssi_err_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_hssi_err_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_hssi_err_test

`endif // HE_HSSI_ERR_TEST_SVH
