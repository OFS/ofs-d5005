// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description: MMIO access for HE_MEM Registers
//-----------------------------------------------------------------------------

`ifndef HEMEM_CSR_TEST_SVH
`define HEMEM_CSR_TEST_SVH

class hemem_csr_test extends base_test;
    `uvm_component_utils(hemem_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        hemem_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = hemem_csr_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : hemem_csr_test

`endif // HEMEM_CSR_TEST_SVH
