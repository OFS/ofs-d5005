// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_hssi_rx_lpbk_seq is executed by he_hssi_rx_lpbk_test 
// This sequnce waits for HSSI IP to be stable and ENABLES the RX_LPBK bit of HE_HSSI
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_RX_LPBK_SEQ_SVH
`define HE_HSSI_RX_LPBK_SEQ_SVH

class he_hssi_rx_lpbk_seq extends base_seq;
    `uvm_object_utils(he_hssi_rx_lpbk_seq)

    function new (string name = "he_hssi_rx_lpbk_seq");
        super.new(name);
    endfunction : new

`ifndef INCLUDE_HSSI
    task body();
        ` AXI_TRANSACTION_CLASS axi_pkt;
        super.body();
	`uvm_info(get_name(), "Entering sequence...", UVM_LOW)
	`uvm_do_on_with(axi_pkt, tb_env0.axi_system_env.master[0].sequencer, {
	    xact_type == `AXI_TRANSACTION_CLASS::DATA_STREAM;
	    stream_burst_length == 1;
	    tdata.size() == 1;
	    foreach(tdata[i]) {
	        tdata[i][((fim_if_pkg::AXIS_PCIE_DW*2) - 1):0] == 'hdead_beef;
	    }
	    foreach(tstrb[i]) tstrb[i] == '1;
	    foreach(tkeep[i]) tkeep[i] == '1;
	    foreach(tuser[i]) tuser[i] == '0;
	  })
       	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask : body
`endif // INCLUDE_HSSI

endclass : he_hssi_rx_lpbk_seq

`endif // HE_HSSI_RX_LPBK_SEQ_SVH
