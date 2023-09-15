// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class pmci_csr_seq is executed by pmci_csr_test
// MMIO access for PMCI CSR Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef PMCI_CSR_SEQ_SVH
`define PMCI_CSR_SEQ_SVH

class pmci_csr_seq extends fme_csr_seq;
    `uvm_object_utils(pmci_csr_seq)

    function new(string name = "pmci_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.pmci_regs.get_registers(m_regs);
    endfunction : get_regs

endclass : pmci_csr_seq

`endif // PMCI_CSR_SEQ_SVH
