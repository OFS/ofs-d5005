// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : HE-LB; ReqLen = 2CL; 1024 CLs;  Read only mode
//-----------------------------------------------------------------------------

`ifndef HELB_RD_2CL_TEST_SVH
`define HELB_RD_2CL_TEST_SVH

class helb_rd_2cl_test extends base_test;
    `uvm_component_utils(helb_rd_2cl_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        helb_rd_2cl_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = helb_rd_2cl_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : helb_rd_2cl_test

`endif // HELB_RD_2CL_TEST_SVH
