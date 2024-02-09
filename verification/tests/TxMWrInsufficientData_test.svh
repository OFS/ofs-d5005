// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :  Protocol checker test for TXMwr Insufficient Data Error
//-----------------------------------------------------------------------------

`ifndef  TXMWRINSUFFICIENTDATA_TEST_SVH
`define  TXMWRINSUFFICIENTDATA_TEST_SVH

class TxMWrInsufficientData_test extends base_test;
 
 `uvm_component_utils(TxMWrInsufficientData_test)

  err_demoter_1 demote;

  function new(string name = "TxMWrInsufficientData_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build();
    super.build();
    //demote = new();//Demoting afu_intf_check error as we have checks in seq itself
    //uvm_report_cb::add(null, demote); 
    //assert(this.randomize());
  endfunction : build 

 task run_phase(uvm_phase phase);
    TxMWrInsufficientData_seq   m_seq;
    super.run_phase(phase);
    phase.raise_objection(this);
    m_seq =TxMWrInsufficientData_seq::type_id::create("m_seq");
    m_seq.randomize();
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
           
   
   endtask : run_phase         

endclass

`endif
