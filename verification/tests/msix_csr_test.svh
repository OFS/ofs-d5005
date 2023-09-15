// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef MSIX_CSR_TEST_SVH
`define MSIX_CSR_TEST_SVH

class msix_csr_test extends base_test;
    `uvm_component_utils(msix_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        msix_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = msix_csr_seq::type_id::create("m_seq");
    m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : msix_csr_test

`endif // MSIX_CSR_TEST_SVH
