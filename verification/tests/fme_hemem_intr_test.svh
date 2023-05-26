// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : HE_MEM Interrupt  
//-----------------------------------------------------------------------------

`ifndef FME_HEMEM_INTR_TEST_SVH
`define FME_HEMEM_INTR_TEST_SVH

class fme_hemem_intr_test extends base_test;
    `uvm_component_utils(fme_hemem_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        hemem_intr_seq hemem_intr_seq_;
        fme_intr_seq   fme_intr_seq_;
        super.run_phase(phase);
        phase.raise_objection(this);
	hemem_intr_seq_ = hemem_intr_seq::type_id::create("hemem_intr_seq");
	fme_intr_seq_   = fme_intr_seq::type_id::create("fme_intr_seq");
        `uvm_info("SEQ", "Begin FME INTR sequence...",UVM_LOW)
        fme_intr_seq_.randomize();
        fme_intr_seq_.start(tb_env0.v_sequencer);
        `uvm_info("SEQ", "FME INTR sequence done.", UVM_LOW)
        `uvm_info("SEQ", "Begin HE-MEM INTR sequence...", UVM_LOW)
         hemem_intr_seq_.randomize() with { bypass_config_seq == 1; };
         hemem_intr_seq_.start(tb_env0.v_sequencer);
        `uvm_info("SEQ", "HE-MEM INTR sequence done.", UVM_LOW)
         phase.drop_objection(this);
    endtask : run_phase

endclass : fme_hemem_intr_test

`endif // FME_HEMEM_INTR_TEST_SVH
