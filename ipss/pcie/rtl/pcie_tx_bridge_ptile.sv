// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   ------- 
//   Functions:
//   ------- 
//   Adapt AXI4-S TX streaming interface to PCIe HIP IP AVST TX interface 
//      * The AVST TX interface contains two 256-bit data channels
//      * The AXI4-S TX interface contains single AXI4-S channel with multiple TLP data streams
//        (See fim_if_pkg.sv for details)
//
//   ------- 
//   Clock domain 
//   ------- 
//   All the inputs and outputs are synchronous to input clock : avl_clk
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_tx_bridge_ptile (
   input  logic                         avl_clk,
   input  logic                         avl_rst_n,
   output t_avst_txs                    avl_tx_st,
   input  logic                         avl_tx_ready,

   ofs_fim_pcie_txs_axis_if.slave       axis_tx_st,

   output logic                         tx_mrd_valid,
   output logic [10:0]                  tx_mrd_length,
   output logic [PCIE_EP_TAG_WIDTH-1:0] tx_mrd_tag,
   output logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]          tx_mrd_pfn,
   output logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]          tx_mrd_vfn,
   output logic                         tx_mrd_vf_act,
   input  logic [CPL_CREDIT_WIDTH-1:0]  cpl_pending_data_cnt
);

// Place holder for future release 

endmodule
