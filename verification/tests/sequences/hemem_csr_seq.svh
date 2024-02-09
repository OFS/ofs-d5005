// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class hemem_csr_seq is executed by hemem_csr_test
// MMIO access for HE_MEM Registers
//-----------------------------------------------------------------------------

`ifndef HEMEM_CSR_SEQ_SVH
`define HEMEM_CSR_SEQ_SVH

class hemem_csr_seq extends helb_csr_seq;
    `uvm_object_utils(hemem_csr_seq)

    function new(string name = "hemem_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.hemem_regs.get_registers(m_regs);
    endfunction : get_regs

    virtual task program_ctl();
        wdata = 64'h1;
	tb_env0.hemem_regs.CTL.write(status, wdata);
    endtask : program_ctl

endclass : hemem_csr_seq

`endif // HEMEM_CSR_SEQ_SVH
