// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class flr_vf0_reset_seq is executed by flr_vf0_reset_test 
// This sequence generates the FLR reset for VF0 set in the testcase
// The MMIO transcations are initated, before and after the reset
// After reset verified if registers are cleared
// Sequence is running on virtual_sequencer
//-----------------------------------------------------------------------------

`ifndef FLR_VF0_RESET_SEQ_SVH
`define FLR_VF0_RESET_SEQ_SVH

//class flr_vf0_reset_seq extends flr_reset_seq;
class flr_vf0_reset_seq extends base_seq;
    `uvm_object_utils(flr_vf0_reset_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
   

    function new(string name = "flr_vf0_reset_seq");
        super.new(name);
    endfunction : new

    task body();
      
     bit [63:0] wdata, rdata, addr;
     super.body();
   
    //====================================== 
    //Writing and Reading HE_LB Scratchpad
    //====================================== 
    addr = he_lb_base_addr + 'h108;
    wdata = 64'hDEAD_BEEF ; 
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(wdata !== rdata)
       `uvm_error(get_name(), $psprintf(" HE_LB scratchpad2 Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" HE_LB scratchpad2 Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
  	set_flr();
  	#7us;
  	unset_flr();
  	reconfig_pfvf();
  	check_afu_intf_error();
    //========================================= 
    //Reading HE_LB Scratchpad after FLR reset
    //========================================= 
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf(" HE_LB scratchpad2 Reset Value mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" HE_LB scratchpad2 Default Value match after FLR reset! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    endtask : body

    virtual task set_flr();
        bit [31:0] rdata;
	flr_rst_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    unset == 0;
	    bdf == 1;
	})
    endtask : set_flr

    virtual task unset_flr();
        bit [31:0] rdata;
	flr_rst_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    unset == 1;
	    bdf == 1;
	})
    endtask : unset_flr
    
    virtual task reconfig_pfvf();
        enumerate_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    m_seq.pf0_bar0 == local::pf0_bar0;
	    m_seq.use_64b_bar == local::use_64b_bar;
	})
    endtask : reconfig_pfvf

endclass : flr_vf0_reset_seq

`endif // FLR_VF0_RESET_SEQ_SVH
