//=======================================================================
// COPYRIGHT (C) 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

// Description : AXI VIP Cust System Configuration

`ifndef CUST_AXI_SYSTEM_CONFIGURATION_SVH
`define CUST_AXI_SYSTEM_CONFIGURATION_SVH

class cust_axi_system_configuration extends `AXI_SYS_CFG_CLASS  ;
    `uvm_object_utils(cust_axi_system_configuration)

    function new(string name = "cust_axi_system_configuration");
        super.new(name);

	this.num_masters = `NUM_MASTERS;
	this.num_slaves  = `NUM_SLAVES;

	this.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

	this.master_cfg[0].axi_interface_type =  `AXI_PORT_CFG_CLASS  ::AXI4_STREAM;
	this.slave_cfg[0].axi_interface_type =  `AXI_PORT_CFG_CLASS  ::AXI4_STREAM;
	this.master_cfg[0].is_active = 1;
	this.master_cfg[0].tdata_width = 512;
	this.master_cfg[0].tuser_width = 5;
	this.slave_cfg[0].is_active = 1;

    endfunction : new

endclass : cust_axi_system_configuration

`endif // CUST__AXI_SYSTEM_CONFIGURATION_SVH
