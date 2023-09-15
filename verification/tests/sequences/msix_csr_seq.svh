// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class msix_csr_seq is executed by msix_csr_test
// MMIO access for  Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef MSIX_CSR_SEQ_SVH
`define MSIX_CSR_SEQ_SVH

 class msix_csr_seq extends fme_csr_seq;
    `uvm_object_utils(msix_csr_seq)

    function new(string name = "msix_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.msix_regs.get_registers(m_regs);
    endfunction : get_regs

endclass : msix_csr_seq

`endif // MSIX_CSR_SEQ_SVH 
