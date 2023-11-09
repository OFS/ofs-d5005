// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :  Protocol checker test for TXMwr Data Payload Overrun Error
//-----------------------------------------------------------------------------

`ifndef TXMWRDATAPAYLOADOVERRUN_TEST_SVH
`define TXMWRDATAPAYLOADOVERRUN_TEST_SVH

class TxMWrDataPayloadOverrun_test extends base_test;
 `uvm_component_utils(TxMWrDataPayloadOverrun_test)
  
  function new(string name = "TxMWrDataPayloadOverrun_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    TxMWrDataPayloadOverrun_seq m_seq;
    super.run_phase(phase);
    phase.raise_objection(this);
    m_seq = TxMWrDataPayloadOverrun_seq::type_id::create("m_seq");
    m_seq.randomize();
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase         

endclass

`endif
