// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// AC Eth Wrapper module instantiate and eth_top module and maps signals to make
// it compatible with HSSI SS IP ports so as to use same HE-HSSI module at client
// side
// 
//-----------------------------------------------------------------------------
//


import ofs_fim_eth_if_pkg::NUM_LANES;
import ofs_fim_eth_if_pkg::MAX_NUM_ETH_CHANNELS;
import ofs_fim_eth_if_pkg::NUM_ETH_CHANNELS;

module eth_ac_wrapper (
   input  logic                                 clk_csr,
   input  logic                                 rst_n_csr,
   input  logic                                 clk_100M,
   input  logic                                 rst_n_100M,

   ofs_fim_axi_lite_if.slave                    csr_lite_if,

   // Streaming data interfaces
   ofs_fim_hssi_ss_tx_axis_if.mac               hssi_ss_st_tx [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ss_rx_axis_if.mac               hssi_ss_st_rx [MAX_NUM_ETH_CHANNELS-1:0],

   // Flow control interfaces
   ofs_fim_hssi_fc_if.mac                       hssi_fc [MAX_NUM_ETH_CHANNELS-1:0],

   output wire [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0]     tx_serial,
   output wire [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0]     tx_serial_n,
   input  wire [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0]     rx_serial,
   input  wire [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0]     rx_serial_n,

   input  wire                                  subsystem_cold_rst_n,

   input  logic [1:0]                           i_clk_ref, 
   output logic [MAX_NUM_ETH_CHANNELS-1:0]      o_hssi_clk_pll,
   output logic [MAX_NUM_ETH_CHANNELS-1:0]      o_hssi_rx_clk_pll

);

//Signal declarations for Ethernet interface
(*noprune*) logic [NUM_ETH_CHANNELS-1:0]     tx_ready_export;
(*noprune*) logic [NUM_ETH_CHANNELS-1:0]     rx_ready_export;
(*noprune*) logic [NUM_ETH_CHANNELS-1:0]     block_lock;
(*noprune*) logic                            atx_pll_locked;

// Tx AXI streaming interface
ofs_fim_eth_tx_axis_if           axis_eth_tx [NUM_ETH_CHANNELS-1:0]();
//RX AXI streaming interface
ofs_fim_eth_rx_axis_if           axis_eth_rx [NUM_ETH_CHANNELS-1:0]();
// Sideband signals
ofs_fim_eth_sideband_rx_axis_if  axi_eth_sideband_rx [NUM_ETH_CHANNELS-1:0] ();
ofs_fim_eth_sideband_tx_axis_if  axi_eth_sideband_tx [NUM_ETH_CHANNELS-1:0] ();

// E-tile to H-tile Shim 
// -----------------CSR Shim---------------------------------//

ofs_fim_axi_mmio_if csr_if(); 

axi_lite2mmio hssi_csr_shim   // Converting AXI-Lite to AXI-MM
(
   .clk(clk_csr),
   .rst_n(rst_n_csr),
   .lite_if(csr_lite_if),
   .mmio_if(csr_if)
);

//========== start loop for number of  ethernet channels========================

genvar portid;
generate

for (portid =0; portid < NUM_ETH_CHANNELS; portid = portid+1)
begin: CHANNEL
   //-----------------------------Clk Shim---------------------------//
   assign o_hssi_clk_pll[portid]    = axis_eth_tx[portid].clk ;

   //----------------------------Tx/Rx Streaming Datapath------------------//
   assign hssi_ss_st_tx[portid].clk                   = axis_eth_tx[portid].clk;
   assign hssi_ss_st_tx[portid].rst_n                 = axis_eth_tx[portid].rst_n;
   assign hssi_ss_st_tx[portid].tready                = axis_eth_tx[portid].tready;
   assign axis_eth_tx[portid].tx.tvalid               = hssi_ss_st_tx[portid].tx.tvalid;
   assign axis_eth_tx[portid].tx.tdata                = hssi_ss_st_tx[portid].tx.tdata;
   assign axis_eth_tx[portid].tx.tkeep                = hssi_ss_st_tx[portid].tx.tkeep;
   assign axis_eth_tx[portid].tx.tlast                = hssi_ss_st_tx[portid].tx.tlast;
   assign axis_eth_tx[portid].tx.tuser                = hssi_ss_st_tx[portid].tx.tuser.client[0];
   assign hssi_ss_st_rx[portid].clk                   = axis_eth_rx[portid].clk;
   assign hssi_ss_st_rx[portid].rst_n                 = axis_eth_rx[portid].rst_n;
   assign hssi_ss_st_rx[portid].rx.tvalid             = axis_eth_rx[portid].rx.tvalid;
   assign hssi_ss_st_rx[portid].rx.tdata              = axis_eth_rx[portid].rx.tdata;
   assign hssi_ss_st_rx[portid].rx.tkeep              = axis_eth_rx[portid].rx.tkeep;
   assign hssi_ss_st_rx[portid].rx.tlast              = axis_eth_rx[portid].rx.tlast;
   `ifdef ETH_100G
      assign hssi_ss_st_rx[portid].rx.tuser.client[0] = axis_eth_rx[portid].rx.tuser[0];
      assign hssi_ss_st_rx[portid].rx.tuser.client[6]    = 1'b0;
   `else
      assign hssi_ss_st_rx[portid].rx.tuser.client[0]    = 1'b0;
      assign hssi_ss_st_rx[portid].rx.tuser.client[6] = axis_eth_rx[portid].rx.tuser[0];
   `endif
   assign hssi_ss_st_rx[portid].rx.tuser.client[5]    = axis_eth_rx[portid].rx.tuser[1];
   assign hssi_ss_st_rx[portid].rx.tuser.client[2]    = axis_eth_rx[portid].rx.tuser[2];
   assign hssi_ss_st_rx[portid].rx.tuser.client[3]    = axis_eth_rx[portid].rx.tuser[3];
   assign hssi_ss_st_rx[portid].rx.tuser.client[4]    = axis_eth_rx[portid].rx.tuser[4];
   assign hssi_ss_st_rx[portid].rx.tuser.client[1]    = 1'b0;
   assign hssi_ss_st_rx[portid].rx.tuser.sts          = 5'h0;
   assign axis_eth_rx[portid].tready                  = 1'b1;

   //----------------Tx/Rx Sideband Interface-------------------------------//
   assign axi_eth_sideband_tx[portid].sb.tvalid            = hssi_fc[portid].tx_pause | (hssi_fc[portid].tx_pfc);
   assign axi_eth_sideband_tx[portid].sb.tdata.pause_xoff  = hssi_fc[portid].tx_pause;
   assign axi_eth_sideband_tx[portid].sb.tdata.pfc_xoff    = hssi_fc[portid].tx_pfc;
   assign axi_eth_sideband_tx[portid].sb.tdata.pause_xon   = '0;

   assign hssi_fc[portid].rx_pause = axi_eth_sideband_rx[portid].sb.tdata.rx_pause & axi_eth_sideband_rx[portid].sb.tvalid;
   assign hssi_fc[portid].rx_pfc   = axi_eth_sideband_rx[portid].sb.tdata.pfc_pause & axi_eth_sideband_rx[portid].sb.tvalid;
end //for loop end
endgenerate

eth_top eth_top (
   // clock and reset
   .csr_clk          (clk_100M),
   .csr_rst_n        (rst_n_100M),
   .tx_rst_n         (subsystem_cold_rst_n),
   .rx_rst_n         (subsystem_cold_rst_n),
   .ref_clk_clk      (i_clk_ref),
   // reset controller
   .tx_ready_export  (tx_ready_export),
   .rx_ready_export  (rx_ready_export),
   .block_lock       (block_lock),
   .atx_pll_locked   (atx_pll_locked),
   .tx_serial_data   (tx_serial),
   .rx_serial_data   (rx_serial),

   .csr_if           (csr_if),

   .pr_freeze        (),

   // Tx AXI streaming interface
   .axi_tx_st        (axis_eth_tx),
   // Rx AXI streaming interface
   .axi_rx_st        (axis_eth_rx),
   // AXI-S sideband interface
   .axi_sideband_rx  (axi_eth_sideband_rx),
   .axi_sideband_tx  (axi_eth_sideband_tx)
);

endmodule
