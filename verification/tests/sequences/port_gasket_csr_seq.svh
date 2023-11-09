// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class port_gasket_csr_seq is executed by port_gasket_csr_test
// MMIO access for Port Gasket Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef PORT_GASKET_CSR_SEQ_SVH
`define PORT_GASKET_CSR_SEQ_SVH

class port_gasket_csr_seq extends fme_csr_seq;
    `uvm_object_utils(port_gasket_csr_seq)

    function new(string name = "port_gasket_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.port_gasket_regs.get_registers(m_regs);
    endfunction : get_regs

    virtual task check_reset_value();
        uvm_reg_data_t exp_val;
        foreach(m_regs[i]) begin
	    //tb_env0.regs.fme_regs.read_reg_by_name(status, m_regs[i].get_name(), rdata);
	    m_regs[i].read(status, rdata);
	    exp_val = m_regs[i].get_reset();
	    if(m_regs[i].get_name() == "PORT_CONTROL")
	        exp_val[0] = 0;
	    if(rdata !== exp_val)
	        `uvm_error(get_name(), $psprintf("Reset value mismatch! %s: act = %0h exp = %0h", m_regs[i].get_name(), rdata, exp_val))
            else
	        `uvm_info(get_name(), $psprintf("Reset value match! %s: val = %0h", m_regs[i].get_name(), rdata), UVM_MEDIUM)
	end
    endtask : check_reset_value



endclass : port_gasket_csr_seq

`endif // PORT_GASKET_CSR_SEQ_SVH
