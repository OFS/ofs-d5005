// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

import ofs_fim_eth_if_pkg::*;
import ofs_fim_eth_avst_if_pkg::*;
//Assumption : All packets are more than a cycle long 
module av_axi_st_eth_bridge (

    //clock & reset
   input wire    tx_clk,
   input wire    tx_rst_n,
   input wire    rx_clk,
   input wire    rx_rst_n,

   // Tx AXI streaming interface (i/p)
   ofs_fim_eth_tx_axis_if.slave axi_tx_st,

   //TX Av streaming interface (o/p)
   output logic                            avalon_st_tx_startofpacket,
   output logic                            avalon_st_tx_endofpacket,
   output logic                            avalon_st_tx_valid,
   output logic [ETH_PACKET_WIDTH-1:0]     avalon_st_tx_data,
   output logic [AVST_ETH_EMPTY_WIDTH-1:0] avalon_st_tx_empty,
   output logic [ETH_TX_ERROR_WIDTH-1:0]   avalon_st_tx_error,
   input  logic                            avalon_st_tx_ready,

   //RX Av streaming interface (i/p)
   input  logic                            avalon_st_rx_startofpacket,
   input  logic                            avalon_st_rx_endofpacket,
   input  logic                            avalon_st_rx_valid,
   input  logic [ETH_PACKET_WIDTH-1:0]     avalon_st_rx_data,
   input  logic [AVST_ETH_EMPTY_WIDTH-1:0] avalon_st_rx_empty,
   output logic                            avalon_st_rx_ready,
   input  logic [ETH_RX_ERROR_WIDTH-1:0]   avalon_st_rx_error,
    
   //RX AXI streaming interface (o/p)
   ofs_fim_eth_rx_axis_if.master axi_rx_st
);

logic is_tx_sop;

// ****************************************************
// *-----------------TX Bridge------------------------*
// ****************************************************
always_comb
begin
   axi_tx_st.tready           = avalon_st_tx_ready;
   avalon_st_tx_valid         = axi_tx_st.tx.tvalid;
   avalon_st_tx_data          = ofs_fim_eth_avst_if_pkg::eth_axi_to_avst_data(axi_tx_st.tx.tdata);
   avalon_st_tx_startofpacket = avalon_st_tx_ready & axi_tx_st.tx.tvalid & is_tx_sop;
   avalon_st_tx_endofpacket   = avalon_st_tx_ready & axi_tx_st.tx.tvalid & axi_tx_st.tx.tlast;
   avalon_st_tx_error         = axi_tx_st.tx.tuser.error;
   avalon_st_tx_empty         = ofs_fim_eth_avst_if_pkg::eth_tkeep_to_empty(axi_tx_st.tx.tkeep);

   axi_tx_st.clk         = tx_clk;
   axi_tx_st.rst_n       = tx_rst_n;
end

// Tx SOP always follows a tlast AXI-S flit
always_ff @(posedge tx_clk)
begin
   if (!tx_rst_n)
      is_tx_sop <= 1'b1;
   else if (axi_tx_st.tx.tvalid && axi_tx_st.tready)
      is_tx_sop <= axi_tx_st.tx.tlast;
end
   
// ****************************************************
// *-----------------RX Bridge------------------------*
// ****************************************************
always_comb
begin
   avalon_st_rx_ready       = axi_rx_st.tready;
   axi_rx_st.rx.tvalid      = avalon_st_rx_valid ; 
   axi_rx_st.rx.tdata       = ofs_fim_eth_avst_if_pkg::eth_avst_to_axi_data(avalon_st_rx_data);
   axi_rx_st.rx.tlast       = avalon_st_rx_endofpacket& avalon_st_rx_valid;
   axi_rx_st.rx.tuser.error = avalon_st_rx_error ;
   axi_rx_st.rx.tkeep       = ofs_fim_eth_avst_if_pkg::eth_empty_to_tkeep(avalon_st_rx_empty);

   axi_rx_st.clk         = rx_clk;
   axi_rx_st.rst_n       = rx_rst_n;
end

endmodule
