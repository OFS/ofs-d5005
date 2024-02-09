// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : MMIO Access for HE HSSI Registers.
//-----------------------------------------------------------------------------

`ifndef HEHSSI_CSR_TEST_SVH
`define HEHSSI_CSR_TEST_SVH

class hehssi_csr_test extends base_test;
    `uvm_component_utils(hehssi_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        hehssi_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = hehssi_csr_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : hehssi_csr_test

`endif // HEHSSI_CSR_TEST_SVH
