// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : MMIO access for Port Gasket Registers
//-----------------------------------------------------------------------------

`ifndef PORT_GASKET_CSR_TEST_SVH
`define PORT_GASKET_CSR_TEST_SVH

class port_gasket_csr_test extends base_test;
    `uvm_component_utils(port_gasket_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        port_gasket_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = port_gasket_csr_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : port_gasket_csr_test

`endif // PORT_GASKET_CSR_TEST_SVH
