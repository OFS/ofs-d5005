// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : MMIO acccess to unimplemented addresses
//-----------------------------------------------------------------------------

`ifndef MMIO_UNIMP_TEST_SVH
`define MMIO_UNIMP_TEST_SVH

class mmio_unimp_test extends base_test;
    `uvm_component_utils(mmio_unimp_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        mmio_unimp_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = mmio_unimp_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : mmio_unimp_test

`endif // MMIO_UNIMP_TEST_SVH
