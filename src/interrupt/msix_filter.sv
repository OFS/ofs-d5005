// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   * Filter AFU interrupts from the incoming AFU TLP packets on i_afu_tx and 
//     forward AFU interrupts to MSIX module on o_msix_tx
// 
//-----------------------------------------------------------------------------

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;

module msix_filter (
   ofs_fim_pcie_txs_axis_if.slave   i_afu_tx,
   ofs_fim_pcie_txs_axis_if.master  o_afu_tx,
   ofs_fim_pcie_txs_axis_if.master  o_msix_tx
);

//-------------------
// Internal wires
//-------------------
   wire clk;
   wire rst_n;

   t_axis_pcie_txs afu_tx;
   t_axis_pcie_txs up_afu_tx;
   t_axis_pcie_txs up_msix_tx;

   logic up_afu_tx_tready;
   logic up_msix_tx_tready;

   logic [FIM_PCIE_TLP_CH-1:0] up_afu_valid;
   logic [FIM_PCIE_TLP_CH-1:0] up_msix_valid;
   logic [FIM_PCIE_TLP_CH-1:0] is_msix;
   logic [FIM_PCIE_TLP_CH-1:0] is_afu_packet;

   logic upstream_afu_ready;
   logic upstream_msix_ready;
   logic upstream_ready;

//-----------------------------------------------------------------------------
   // Interface assignment
   assign clk             = i_afu_tx.clk;
   assign rst_n           = i_afu_tx.rst_n;
   assign afu_tx          = i_afu_tx.tx;
   assign i_afu_tx.tready = upstream_ready; 

   assign o_afu_tx.tx = up_afu_tx;
   assign o_afu_tx.clk = clk;
   assign o_afu_tx.rst_n = rst_n;
   assign up_afu_tx_tready = o_afu_tx.tready;

   assign o_msix_tx.tx = up_msix_tx;
   assign o_msix_tx.clk = clk;
   assign o_msix_tx.rst_n = rst_n;
   assign up_msix_tx_tready = o_msix_tx.tready;


   // Upstream ready to take packets
   assign upstream_msix_ready = (~up_msix_tx.tvalid | up_msix_tx_tready);
   assign upstream_afu_ready  = (~up_afu_tx.tvalid | up_afu_tx_tready);
   assign upstream_ready = (upstream_msix_ready && upstream_afu_ready);
   
   always_comb begin
      up_afu_tx = afu_tx;
      up_msix_tx = afu_tx;
      
      for (int ch=0; ch<FIM_PCIE_TLP_CH; ch=ch+1) begin
         is_msix[ch]       = afu_tx.tvalid && afu_tx.tdata[ch].valid && afu_tx.tuser[ch].afu_irq;
         is_afu_packet[ch] = afu_tx.tvalid && afu_tx.tdata[ch].valid && ~afu_tx.tuser[ch].afu_irq;

         up_afu_tx.tdata[ch].valid = is_afu_packet[ch];
         up_msix_tx.tdata[ch].valid = is_msix[ch];
      end
      
      up_afu_tx.tvalid  = |is_afu_packet;
      up_msix_tx.tvalid = |is_msix;
   end

endmodule

