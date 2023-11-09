// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : Top level Virtual sequencer which instance other env sequencer
//-----------------------------------------------------------------------------

`ifndef VIRTUAL_SEQUENCER_SVH
`define VIRTUAL_SEQUENCER_SVH

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    tb_config tb_cfg0;
    `PCIE_DEV_VIR_SQR root_virt_seqr;
    `AXI_SYS_SQR          axi_seqr;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass : virtual_sequencer

`endif // VIRTUAL_SEQUENCER_SVH
