// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------

`ifndef REG2PCIE_REG_ADAPTER_SVH
`define REG2PCIE_REG_ADAPTER_SVH

class reg2pcie_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(reg2pcie_reg_adapter)

    //uvm_reg_map reg_map;
    //uvm_reg     curr_reg;

    function new(string name = "reg2pcie_reg_adapter");
        super.new(name);
    endfunction : new

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        uvm_reg_item item = get_item();
	 `PCIE_DRIVER_TRANSACTION_CLASS  tlp =  `PCIE_DRIVER_TRANSACTION_CLASS ::type_id::create("tlp");

	tlp.transaction_type = (rw.kind == UVM_READ) ? 0 : 2;
	tlp.address = rw.addr;
	tlp.traffic_class = 0;
	tlp.first_dw_be = 4'b1111;
	tlp.th = 0;
	tlp.ep = 0;

        //curr_reg=reg_map.get_reg_by_offset(rw.addr);
	tlp.length = rw.n_bits >> 5;
	if(tlp.length == 1) begin
	    tlp.last_dw_be  = 4'b0000;
	end
	else if(tlp.length == 2) begin
	    tlp.last_dw_be  = 4'b1111;
	end
	else begin
            `uvm_fatal(get_name(), "RAL PCIe TLP length is not 1 or 2")
	end

        if(rw.kind == UVM_WRITE) begin
	    tlp.payload = new[tlp.length];
	    tlp.payload[0] = changeEndian(rw.data[31:0]);
	    if(tlp.length == 2)
	        tlp.payload[1] = changeEndian(rw.data[63:32]);
	end

	return tlp;
    endfunction : reg2bus

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
         `PCIE_DRIVER_TRANSACTION_CLASS  tlp;
	if(!$cast(tlp, bus_item)) begin
	    `uvm_error(get_name(),"tlp cast failed on bus2reg call...");
            return;
	end

	rw.kind = (tlp.transaction_type == 0) ? UVM_READ : UVM_WRITE;
	rw.status = UVM_IS_OK;
        rw.data[31:0]   = changeEndian(tlp.payload[0]);
	if(tlp.payload.size == 2)
            rw.data[63:32]  = changeEndian(tlp.payload[1]);
    endfunction : bus2reg

    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

endclass : reg2pcie_reg_adapter

`endif // REG2PCIE_REG_ADAPTER_SVH
