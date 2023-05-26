// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class flr_reset_seq is executed by flr_reset_test 
// This sequence generates the FLR reset for PF set in the testcase
// The MMIO transcations are initated, before and after the reset
// After reset verified if registers are cleared
// Sequence is running on virtual_sequencer
//-----------------------------------------------------------------------------

`ifndef FLR_RESET_SEQ_SVH
`define FLR_RESET_SEQ_SVH

class flr_reset_seq extends base_seq;
    `uvm_object_utils(flr_reset_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

   
    function new(string name = "flr_reset_seq");
        super.new(name);
    endfunction : new

    task body();
           
	  bit [63:0] wdata, rdata, addr;
        super.body();
     //====================================== 
    //Writing and Reading ST2MM Scratchpad
    //====================================== 
    addr = st2mm_base_addr + 'h8;
    wdata = 64'hDEAD_BEEF ; 
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(wdata !== rdata)
       `uvm_error(get_name(), $psprintf(" ST2MM scratchpad Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" ST2MM scratchpad Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    //====================================== 
    //Writing and Reading FME Scratchpad
    //====================================== 
    addr = fme_base_addr + 'h28;
    wdata = 64'hFEED_CAFE ; 
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(wdata !== rdata)
       `uvm_error(get_name(), $psprintf(" FME scratchpad Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" FME scratchpad Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
	  //he_lpbk_traffic();
	  set_flr();
	  #7us;
	  unset_flr();
	  reconfig_pfvf();
	  //print_debug();
	  //he_lpbk_traffic();
	  check_afu_intf_error();
    //========================================= 
    //Reading ST2MM Scratchpad after FLR reset
    //========================================= 
    addr = st2mm_base_addr + 'h8;
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf(" ST2MM scratchpad Reset Value mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" ST2MM scratchpad Default Value match after FLR reset! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    //====================================== 
    // Reading FME Scratchpad after FLR reset
    //====================================== 
    addr = fme_base_addr + 'h28;
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(rdata !== 64'hFEED_CAFE)
       `uvm_error(get_name(), $psprintf(" FME scratchpad Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf(" FME scratchpad Data match after Reset! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    endtask : body

    task he_lpbk_traffic();
        he_lpbk_seq lpbk_seq;
	`uvm_do_on_with(lpbk_seq, p_sequencer, {
	    mode inside {3'b000, 3'b001, 3'b010, 3'b011};
	    bypass_config_seq == 1;
	})
    endtask : he_lpbk_traffic

    task he_mem_traffic();
        he_mem_lpbk_seq lpbk_seq;
	`uvm_do_on_with(lpbk_seq, p_sequencer, {
	    mode inside {3'b000, 3'b001, 3'b010, 3'b011};
	    bypass_config_seq == 1;
	})
    endtask : he_mem_traffic

    virtual task set_flr();
        bit [31:0] rdata;
	flr_rst_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    unset == 0;
	})
    endtask : set_flr

    virtual task unset_flr();
        bit [31:0] rdata;
	flr_rst_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    unset == 1;
	})
    endtask : unset_flr

    virtual task reconfig_pfvf();
        enumerate_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    m_seq.pf0_bar0 == local::pf0_bar0;
	    m_seq.use_64b_bar == local::use_64b_bar;
	})
    endtask : reconfig_pfvf

    virtual task print_debug();
	flr_rst_seq m_seq;
	`uvm_do_on_with(m_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
	    debug == 1;
	})
    endtask : print_debug

endclass : flr_reset_seq

`endif // FLR_RESET_SEQ_SVH
