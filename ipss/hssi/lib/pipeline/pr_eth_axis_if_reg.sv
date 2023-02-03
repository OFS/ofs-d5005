// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   Green BS PCIE AXI-S interface pipeline registers
//
//-----------------------------------------------------------------------------

import ofs_fim_eth_if_pkg::ETH_PACKET_WIDTH;
import ofs_fim_eth_if_pkg::ETH_RX_ERROR_WIDTH;
import ofs_fim_eth_if_pkg::ETH_TX_ERROR_WIDTH;

module pr_eth_axis_if_reg (
   // AXIS Ethernet RX channels
   ofs_fim_eth_rx_axis_if.slave       s_eth_rx_st,
   ofs_fim_eth_rx_axis_if.master      m_eth_rx_st,

   // AXIS Ethernet TX channels
   ofs_fim_eth_tx_axis_if.slave       s_eth_tx_st,
   ofs_fim_eth_tx_axis_if.master      m_eth_tx_st,
   // AXIS Ethernet RX sideband
   ofs_fim_eth_sideband_rx_axis_if.slave         s_sideband_rx,
   ofs_fim_eth_sideband_rx_axis_if.master        m_sideband_rx,
   // AXIS Ethernet RX sideband
   ofs_fim_eth_sideband_tx_axis_if.slave         s_sideband_tx,
   ofs_fim_eth_sideband_tx_axis_if.master        m_sideband_tx
);

   //--------------------
   // RX pipeline
   //--------------------
   axis_register #(
       .MODE           (0), // 0: skid buffer 1: simple buffer 2: bypass
       .TREADY_RST_VAL (0), // Keep tready deasserted during reset
       .ENABLE_TKEEP   (1),
       .ENABLE_TLAST   (1),
       .ENABLE_TID     (0),
       .ENABLE_TDEST   (0),
       .ENABLE_TUSER   (1),
       .TDATA_WIDTH    (ETH_PACKET_WIDTH),
       .TUSER_WIDTH    (ETH_RX_ERROR_WIDTH )
   ) rx_pipeln (
       .clk         (s_eth_rx_st.clk),
       .rst_n       (s_eth_rx_st.rst_n),
       // Slave interface
       .s_tready    (s_eth_rx_st.tready),
       .s_tvalid    (s_eth_rx_st.rx.tvalid),
       .s_tdata     (s_eth_rx_st.rx.tdata),
       .s_tlast     (s_eth_rx_st.rx.tlast),
       .s_tkeep     (s_eth_rx_st.rx.tkeep),
       .s_tuser     (s_eth_rx_st.rx.tuser),
       // Master interface
       .m_tready    (m_eth_rx_st.tready),
       .m_tvalid    (m_eth_rx_st.rx.tvalid),
       .m_tdata     (m_eth_rx_st.rx.tdata),
       .m_tlast     (m_eth_rx_st.rx.tlast),
       .m_tkeep     (m_eth_rx_st.rx.tkeep),
       .m_tuser     (m_eth_rx_st.rx.tuser)
   );
   // Connect Clock and resets
   assign m_eth_rx_st.clk   = s_eth_rx_st.clk;
   assign m_eth_rx_st.rst_n = s_eth_rx_st.rst_n;
   
   //--------------------
   // TX pipeline
   //--------------------
   axis_register #(
       .MODE           (0), // 0: skid buffer 1: simple buffer 2: bypass
       .TREADY_RST_VAL (0), // Keep tready deasserted during reset
       .ENABLE_TKEEP   (1),
       .ENABLE_TLAST   (1),
       .ENABLE_TID     (0),
       .ENABLE_TDEST   (0),
       .ENABLE_TUSER   (1),
       .TDATA_WIDTH    (ETH_PACKET_WIDTH),
       .TUSER_WIDTH    (ETH_TX_ERROR_WIDTH)
   ) tx_pipeln (
       .clk         (m_eth_tx_st.clk),
       .rst_n       (m_eth_tx_st.rst_n),
       // Slave interface
       .s_tready    (s_eth_tx_st.tready),
       .s_tvalid    (s_eth_tx_st.tx.tvalid),
       .s_tdata     (s_eth_tx_st.tx.tdata),
       .s_tlast     (s_eth_tx_st.tx.tlast),
       .s_tkeep     (s_eth_tx_st.tx.tkeep),
       .s_tuser     (s_eth_tx_st.tx.tuser),
       // Master interface
       .m_tready    (m_eth_tx_st.tready),
       .m_tvalid    (m_eth_tx_st.tx.tvalid),
       .m_tdata     (m_eth_tx_st.tx.tdata),
       .m_tlast     (m_eth_tx_st.tx.tlast),
       .m_tkeep     (m_eth_tx_st.tx.tkeep),
       .m_tuser     (m_eth_tx_st.tx.tuser)
   );
   // Connect Clock and resets
   assign s_eth_tx_st.clk   = m_eth_tx_st.clk;
   assign s_eth_tx_st.rst_n = m_eth_tx_st.rst_n;
   
   //--------------------
   // Ethernet Sideband pipeline
   //--------------------
   
   always @(posedge s_sideband_rx.clk) begin
      if (~s_sideband_rx.rst_n) begin
         m_sideband_rx.sb.tvalid <= 1'b0;
      end
      else begin
         m_sideband_rx.sb <= s_sideband_rx.sb;
      end
   end
 
 always @(posedge m_sideband_tx.clk) begin
      if (~m_sideband_tx.rst_n) begin
         m_sideband_tx.sb.tvalid <= 1'b0;
      end
      else begin
         m_sideband_tx.sb <= s_sideband_tx.sb;
      end
   end
   // Connect Clock and resets
   assign m_sideband_rx.clk   = s_sideband_rx.clk;
   assign m_sideband_rx.rst_n = s_sideband_rx.rst_n;
   
   assign s_sideband_tx.clk   = m_sideband_tx.clk;
   assign s_sideband_tx.rst_n = m_sideband_tx.rst_n;

endmodule

