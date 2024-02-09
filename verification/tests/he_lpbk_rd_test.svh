// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : Read only mode. Randomize num_lines, addresses, req_len
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_RD_TEST_SVH
`define HE_LPBK_RD_TEST_SVH

class he_lpbk_rd_test extends base_test;
    `uvm_component_utils(he_lpbk_rd_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        he_lpbk_rd_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_lpbk_rd_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_lpbk_rd_test

`endif // HE_LPBK_RD_TEST_SVH
