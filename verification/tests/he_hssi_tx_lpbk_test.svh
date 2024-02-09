// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : HE_HSSI TX LPBK Test
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_TX_LPBK_TEST_SVH
`define HE_HSSI_TX_LPBK_TEST_SVH

class he_hssi_tx_lpbk_test extends base_test;
    `uvm_component_utils(he_hssi_tx_lpbk_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        he_hssi_tx_lpbk_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_hssi_tx_lpbk_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_hssi_tx_lpbk_test

`endif // HE_HSSI_TX_LPBK_TEST_SVH
