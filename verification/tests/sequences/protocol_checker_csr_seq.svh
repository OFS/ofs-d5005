// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class protocol_checker_csr_seq is executed by protocol_checker_csr_test
// MMIO access for Protocol Checker Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef AFU_INTF_CSR_SEQ_SVH
`define AFU_INTF_CSR_SEQ_SVH

 class protocol_checker_csr_seq extends fme_csr_seq;
    `uvm_object_utils(protocol_checker_csr_seq)

    function new(string name = "protocol_checker_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.afu_intf_regs.get_registers(m_regs);
    endfunction : get_regs

endclass : protocol_checker_csr_seq

`endif // AFU_INTF_CSR_SEQ_SVH
