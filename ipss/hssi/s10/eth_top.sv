// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Top level module of HSSI subsystem.
//
//-----------------------------------------------------------------------------

`default_nettype none
import ofs_fim_eth_if_pkg::NUM_ETH_CHANNELS;
import ofs_fim_eth_if_pkg::MAX_NUM_ETH_CHANNELS;

import hssi_csr_pkg::*;

module eth_top (

   // clock and reset
   input wire                             csr_clk,
   input wire                             csr_rst_n,
   input wire                             tx_rst_n,
   input wire                             rx_rst_n,
   input wire                             ref_clk_clk,

   // Status and debug signals
   output wire [NUM_ETH_CHANNELS-1:0]      tx_ready_export,
   output wire [NUM_ETH_CHANNELS-1:0]      rx_ready_export,
   output wire [NUM_ETH_CHANNELS-1:0]      block_lock,
   output wire                             atx_pll_locked,
   output wire                             core_pll_locked,

   // Serial data
   output wire [NUM_ETH_CHANNELS-1:0]      tx_serial_data,
   input wire  [NUM_ETH_CHANNELS-1:0]      rx_serial_data,

   // AXI4 CSR interface
   ofs_fim_axi_mmio_if.slave              csr_if,

   // PR Freeze signal to stop ready while PR process is in progress
   input wire                             pr_freeze,

   // Tx AXI streaming interface 
   ofs_fim_eth_tx_axis_if.slave           axi_tx_st [NUM_ETH_CHANNELS-1:0],

   //RX AXI streaming interface 
   ofs_fim_eth_rx_axis_if.master          axi_rx_st [NUM_ETH_CHANNELS-1:0],

   // RX AXI sideband interface
   ofs_fim_eth_sideband_rx_axis_if.master axi_sideband_rx [NUM_ETH_CHANNELS-1:0],

   // TX AXI sideband interface
   ofs_fim_eth_sideband_tx_axis_if.slave  axi_sideband_tx [NUM_ETH_CHANNELS-1:0]
);

parameter   DEVICE_FAMILY           = "Stratix 10";
localparam  AVM_ADDR_WIDTH          = 11 ;

wire        csr_waitrequest;
wire [31:0] csr_readdata;
wire [31:0] csr_writedata;
wire [15:0] csr_address;
wire        csr_write;
wire        csr_read;

wire    [NUM_ETH_CHANNELS-1:0]              mac_csr_read_32;
wire    [NUM_ETH_CHANNELS-1:0]              mac_csr_write_32;
wire    [NUM_ETH_CHANNELS-1:0][31:0]        mac_csr_readdata_32;
wire    [NUM_ETH_CHANNELS-1:0][31:0]        mac_csr_writedata_32;
wire    [NUM_ETH_CHANNELS-1:0]              mac_csr_waitrequest_32;
wire    [NUM_ETH_CHANNELS-1:0][9:0]         mac_csr_address_32;

wire    [MAX_NUM_ETH_CHANNELS-1:0]          mac_csr_read_64;
wire    [MAX_NUM_ETH_CHANNELS-1:0]          mac_csr_write_64;
wire    [MAX_NUM_ETH_CHANNELS-1:0][31:0]    mac_csr_readdata_64;
wire    [MAX_NUM_ETH_CHANNELS-1:0][31:0]    mac_csr_writedata_64;
wire    [MAX_NUM_ETH_CHANNELS-1:0]          mac_csr_waitrequest_64;
wire    [MAX_NUM_ETH_CHANNELS-1:0][13:0]    mac_csr_address_64;

wire    [MAX_NUM_ETH_CHANNELS-1:0]          phy_csr_read;
wire    [MAX_NUM_ETH_CHANNELS-1:0]          phy_csr_write;
wire    [MAX_NUM_ETH_CHANNELS-1:0][31:0]    phy_csr_readdata;
wire    [MAX_NUM_ETH_CHANNELS-1:0][31:0]    phy_csr_writedata;
wire    [MAX_NUM_ETH_CHANNELS-1:0]          phy_csr_waitrequest;
wire    [MAX_NUM_ETH_CHANNELS-1:0][AVM_ADDR_WIDTH-1:0]     phy_csr_address;

wire    [NUM_ETH_CHANNELS-1:0][1:0]         avalon_st_pause_data_sync , avalon_st_tx_pause_data_156;
wire    [NUM_ETH_CHANNELS-1:0][15:0]        avalon_st_tx_pfc_data_sync, avalon_st_tx_pfc_data_156; 
wire    [NUM_ETH_CHANNELS-1:0][7:0]         avalon_st_rx_pfc_data_sync, avalon_st_rx_pfc_pause_data_156;
logic   [NUM_ETH_CHANNELS-1:0][39:0]        avalon_st_rxstatus_data_312;
logic   [NUM_ETH_CHANNELS-1:0][4:0]         avalon_st_rxstatus_data_156;
logic   [NUM_ETH_CHANNELS-1:0]              avalon_st_rxstatus_valid_312, avalon_st_rxstatus_valid_156;

wire    sync_rx_rst_n;
wire    sync_rx_half_rst_n;
wire    sync_tx_half_rst_n;
wire    sync_tx_rst_n;

wire    sync_tx_half_rst;
wire    sync_rx_half_rst;

wire    sync_tx_rst;
wire    sync_rx_rst;

wire    tx_serial_clk;
wire    core_clk_312;
wire    core_clk_156;
wire    csr_clk_156  ;
wire    csr_rst_n_156;
assign  sync_tx_rst_n      = ~sync_tx_rst;
assign  sync_rx_rst_n      = ~sync_rx_rst;

assign  sync_rx_half_rst_n = ~sync_rx_half_rst;
assign  sync_tx_half_rst_n = ~sync_tx_half_rst;


assign csr_clk_156    = core_clk_156;
assign csr_rst_n_156  = sync_tx_half_rst_n;

wire    [NUM_ETH_CHANNELS-1:0][31:0]    mac_in_data;
wire    [NUM_ETH_CHANNELS-1:0]          mac_in_valid;
wire    [NUM_ETH_CHANNELS-1:0]          mac_in_ready;
wire    [NUM_ETH_CHANNELS-1:0]          mac_in_startofpacket;
wire    [NUM_ETH_CHANNELS-1:0]          mac_in_endofpacket;
wire    [NUM_ETH_CHANNELS-1:0][1:0]     mac_in_empty;
wire    [NUM_ETH_CHANNELS-1:0][0:0]     mac_in_error;
wire    [NUM_ETH_CHANNELS-1:0]          mac_in_ready_pr;

wire    [NUM_ETH_CHANNELS-1:0][63:0]    tx_out_data;
wire    [NUM_ETH_CHANNELS-1:0]          tx_out_valid;
wire    [NUM_ETH_CHANNELS-1:0]          tx_out_ready;
wire    [NUM_ETH_CHANNELS-1:0]          tx_out_startofpacket;
wire    [NUM_ETH_CHANNELS-1:0]          tx_out_endofpacket;
wire    [NUM_ETH_CHANNELS-1:0][2:0]     tx_out_empty;
wire    [NUM_ETH_CHANNELS-1:0][0:0]     tx_out_error;

wire    [NUM_ETH_CHANNELS-1:0][31:0]    mac_out_data;
wire    [NUM_ETH_CHANNELS-1:0]          mac_out_valid;
wire    [NUM_ETH_CHANNELS-1:0]          mac_out_ready;
wire    [NUM_ETH_CHANNELS-1:0]          mac_out_startofpacket;
wire    [NUM_ETH_CHANNELS-1:0]          mac_out_endofpacket;
wire    [NUM_ETH_CHANNELS-1:0][1:0]     mac_out_empty;
wire    [NUM_ETH_CHANNELS-1:0][5:0]     mac_out_error;

wire    [NUM_ETH_CHANNELS-1:0][63:0]    rx_in_data;
wire    [NUM_ETH_CHANNELS-1:0]          rx_in_valid;
wire    [NUM_ETH_CHANNELS-1:0]          rx_in_ready;
wire    [NUM_ETH_CHANNELS-1:0]          rx_in_startofpacket;
wire    [NUM_ETH_CHANNELS-1:0]          rx_in_endofpacket;
wire    [NUM_ETH_CHANNELS-1:0][2:0]     rx_in_empty;
wire    [NUM_ETH_CHANNELS-1:0][5:0]     rx_in_error;

hssi_stats_struct_t                     hssi_stats[NUM_ETH_CHANNELS-1:0];
wire   [NUM_ETH_CHANNELS-1:0]           final_channel_rst;
wire   [7:0]                            final_reconfig_rst;

wire                                    hssi_pr_freeze;

// PLLs locked
wire plls_locked ;
assign plls_locked     = atx_pll_locked & core_pll_locked; 

//HSSI CSR
localparam MM_CMD_W      = 3;    // MM Reconfiguration Controller command width
localparam MM_ADDR_W     = 20;   // MM Reconfiguration Controller address width
localparam MM_DATA_W     = 32;   // MM Reconfiguration Controller data width
localparam RCFG_ADDR_W   = 16;   // PHY reconfiguration address width
localparam RCFG_DATA_W   = 32;   // PHY reconfiguration data width

hssi_csr #(
   .CMD_W          (MM_CMD_W),     // User command width
   .USER_ADDR_W    (MM_ADDR_W),    // User address width
   .AVMM_ADDR_W    (RCFG_ADDR_W),  // AVMM address width
   .DATA_W         (RCFG_DATA_W),  // Data width
   .SIM            (0)
)hssi_csr_inst (
   .csr_clk             (csr_clk_156),
   .csr_rst             (~csr_rst_n_156),
   .csr_if              (csr_if),
   .i_avmm_waitrequest  (csr_waitrequest),
   .i_avmm_readdata     (csr_readdata),
   .o_avmm_writedata    (csr_writedata),
   .o_avmm_addr         (csr_address),
   .o_avmm_write        (csr_write),
   .o_avmm_read         (csr_read),
   .plls_locked         (plls_locked),
   .hssi_stats          (hssi_stats),
   .final_channel_rst   (final_channel_rst),
   .final_reconfig_rst  (final_reconfig_rst)
);

// Address decoder to map indirect access csr address into MAC and PHY space
address_decode address_decoder_inst (

    .clk_csr_clk                                                    (csr_clk_156),
    .csr_reset_n                                                    (csr_rst_n_156),

    .tx_xcvr_half_clk_clk                                           (core_clk_156),
    .sync_tx_half_rst_reset_n                                       (sync_tx_half_rst_n),
    .tx_xcvr_clk_clk                                                (core_clk_312),
    .sync_tx_rst_reset_n                                            (sync_tx_rst_n),
    .rx_xcvr_clk_clk                                                (core_clk_312),
    .sync_rx_rst_reset_n                                            (sync_rx_rst_n),

    .merlin_master_translator_0_avalon_anti_master_0_address        (csr_address),
    .merlin_master_translator_0_avalon_anti_master_0_waitrequest    (csr_waitrequest),
    .merlin_master_translator_0_avalon_anti_master_0_read           (csr_read),
    .merlin_master_translator_0_avalon_anti_master_0_readdata       (csr_readdata),
    .merlin_master_translator_0_avalon_anti_master_0_write          (csr_write),
    .merlin_master_translator_0_avalon_anti_master_0_writedata      (csr_writedata),
    .mac_0_avalon_anti_slave_0_address                              (mac_csr_address_64[0][12:0]),
    .mac_0_avalon_anti_slave_0_write                                (mac_csr_write_64[0]),
    .mac_0_avalon_anti_slave_0_read                                 (mac_csr_read_64[0]),
    .mac_0_avalon_anti_slave_0_readdata                             (mac_csr_readdata_64[0]),
    .mac_0_avalon_anti_slave_0_writedata                            (mac_csr_writedata_64[0]),
    .mac_0_avalon_anti_slave_0_waitrequest                          (mac_csr_waitrequest_64[0]),
    .phy_0_avalon_anti_slave_0_address                              (phy_csr_address[0]),
    .phy_0_avalon_anti_slave_0_write                                (phy_csr_write[0]),
    .phy_0_avalon_anti_slave_0_read                                 (phy_csr_read[0]),
    .phy_0_avalon_anti_slave_0_readdata                             (phy_csr_readdata[0]),
    .phy_0_avalon_anti_slave_0_writedata                            (phy_csr_writedata[0]),
    .phy_0_avalon_anti_slave_0_waitrequest                          (phy_csr_waitrequest[0])
  );

//========== start loop for number of  ethernet channels========================

genvar portid;
generate

for (portid =0; portid < NUM_ETH_CHANNELS; portid = portid+1)
begin: CHANNEL

   // csr adapter to convert legacy megacore 64b IP CSR address to LL 32b IP interface
   altera_eth_avalon_mm_adapter csr_adapter_inst(
      // Avalon Slave Interface
      .sl_clock               (csr_clk_156),
      .sl_reset               (~csr_rst_n_156),
      .sl_csr_readdata_o      (mac_csr_readdata_64[portid]),
      .sl_csr_address_i       (mac_csr_address_64[portid][12:0]),
      .sl_csr_read_i          (mac_csr_read_64[portid]),
      .sl_csr_write_i         (mac_csr_write_64[portid]),
      .sl_csr_writedata_i     (mac_csr_writedata_64[portid]),
      .sl_csr_waitrequest_o   (mac_csr_waitrequest_64[portid]),

      // Avalon Master Interface
      .ms_clock               (),
      .ms_reset               (),
      .ms_csr_readdata_i      (mac_csr_readdata_32[portid]),
      .ms_csr_address_o       (mac_csr_address_32[portid]),
      .ms_csr_read_o          (mac_csr_read_32[portid]),
      .ms_csr_write_o         (mac_csr_write_32[portid]),
      .ms_csr_writedata_o     (mac_csr_writedata_32[portid]),
      .ms_csr_waitrequest_i   (mac_csr_waitrequest_32[portid])
   );

   // HSSI AVST <-> HE-HSSI AXIS conversion
   av_axi_st_eth_bridge av_axi_st_eth_bridge_inst (
      .tx_clk                     (core_clk_156),
      .tx_rst_n                   (sync_tx_half_rst_n),
      .rx_clk                     (core_clk_156),
      .rx_rst_n                   (sync_rx_half_rst_n),

      .axi_tx_st                  (axi_tx_st[portid]),
      .avalon_st_tx_startofpacket (tx_out_startofpacket[portid]),
      .avalon_st_tx_endofpacket   (tx_out_endofpacket[portid]),
      .avalon_st_tx_valid         (tx_out_valid[portid]),
      .avalon_st_tx_data          (tx_out_data[portid]),
      .avalon_st_tx_empty         (tx_out_empty[portid]),
      .avalon_st_tx_ready         (tx_out_ready[portid]),
      .avalon_st_tx_error         (tx_out_error[portid]),

      .axi_rx_st                  (axi_rx_st[portid]),
      .avalon_st_rx_startofpacket (rx_in_startofpacket[portid]),
      .avalon_st_rx_endofpacket   (rx_in_endofpacket[portid]),
      .avalon_st_rx_valid         (rx_in_valid[portid]),
      .avalon_st_rx_data          (rx_in_data[portid]),
      .avalon_st_rx_empty         (rx_in_empty[portid]),
      .avalon_st_rx_ready         (rx_in_ready[portid]),
      .avalon_st_rx_error         (rx_in_error[portid])
   );

   // Deassert tx ready when pr_freeze is high
   assign mac_in_ready_pr[portid] = hssi_pr_freeze ? 'b0 : mac_in_ready[portid];
   // Tx (AFU -> MAC) sideband requests XOFF/XON pause frames
   assign axi_sideband_tx[portid].clk           = core_clk_156;
   assign axi_sideband_tx[portid].rst_n         = sync_tx_half_rst_n;
   assign avalon_st_tx_pause_data_156[portid]   = axi_sideband_tx[portid].sb.tvalid ?
                                                  { axi_sideband_tx[portid].sb.tdata.pause_xoff, axi_sideband_tx[portid].sb.tdata.pause_xon } :
                                                  '0;
   // Flow control signal assignements
   assign avalon_st_tx_pfc_data_156[portid][0]  = '0;
   assign avalon_st_tx_pfc_data_156[portid][2]  = '0;
   assign avalon_st_tx_pfc_data_156[portid][4]  = '0;
   assign avalon_st_tx_pfc_data_156[portid][6]  = '0;
   assign avalon_st_tx_pfc_data_156[portid][8]  = '0;
   assign avalon_st_tx_pfc_data_156[portid][10] = '0;
   assign avalon_st_tx_pfc_data_156[portid][12] = '0;
   assign avalon_st_tx_pfc_data_156[portid][14] = '0;

   assign avalon_st_tx_pfc_data_156[portid][1]  = axi_sideband_tx[portid].sb.tdata.pfc_xoff[0];
   assign avalon_st_tx_pfc_data_156[portid][3]  = axi_sideband_tx[portid].sb.tdata.pfc_xoff[1];
   assign avalon_st_tx_pfc_data_156[portid][5]  = axi_sideband_tx[portid].sb.tdata.pfc_xoff[2];
   assign avalon_st_tx_pfc_data_156[portid][7]  = axi_sideband_tx[portid].sb.tdata.pfc_xoff[3];
   assign avalon_st_tx_pfc_data_156[portid][9]  = axi_sideband_tx[portid].sb.tdata.pfc_xoff[4];
   assign avalon_st_tx_pfc_data_156[portid][11] = axi_sideband_tx[portid].sb.tdata.pfc_xoff[5];
   assign avalon_st_tx_pfc_data_156[portid][13] = axi_sideband_tx[portid].sb.tdata.pfc_xoff[6];
   assign avalon_st_tx_pfc_data_156[portid][15] = axi_sideband_tx[portid].sb.tdata.pfc_xoff[7];

   // Rx sideband not currently used
   assign axi_sideband_rx[portid].clk                 = core_clk_156;
   assign axi_sideband_rx[portid].rst_n               = sync_rx_half_rst_n;
   assign axi_sideband_rx[portid].sb.tvalid           = (|avalon_st_rx_pfc_pause_data_156[portid] || avalon_st_rxstatus_data_156[portid][0]);
   assign axi_sideband_rx[portid].sb.tdata.pfc_pause  = avalon_st_rx_pfc_pause_data_156[portid];
   assign axi_sideband_rx[portid].sb.tdata.rx_pause   = avalon_st_rxstatus_data_156[portid][0]; //FC Bit

   // AVST adapter to convert legacy megacore 64b IP interface to LL 32b IP interface
   altera_eth_avalon_st_adapter #(
      .DEVICE_FAMILY (DEVICE_FAMILY),
      .ENABLE_PFC (1)
   ) dc_fifo_adapter_inst(

      .csr_tx_adptdcff_rdwtrmrk     (3'b010),
      .csr_tx_adptdcff_vldpkt_minwt (3'b010),
      .csr_tx_adptdcff_rdwtrmrk_dis (1'b0),

      .avalon_st_tx_clk_312            (core_clk_312),
      .avalon_st_tx_312_reset_n        (sync_tx_rst_n),
      .avalon_st_tx_clk_156            (core_clk_156),
      .avalon_st_tx_156_reset_n        (sync_tx_half_rst_n),

      .avalon_st_tx_156_ready          (tx_out_ready[portid]),
      .avalon_st_tx_156_valid          (tx_out_valid[portid]),
      .avalon_st_tx_156_data           (tx_out_data[portid]),
      .avalon_st_tx_156_error          (tx_out_error[portid]),
      .avalon_st_tx_156_startofpacket  (tx_out_startofpacket[portid]),
      .avalon_st_tx_156_endofpacket    (tx_out_endofpacket[portid]),
      .avalon_st_tx_156_empty          (tx_out_empty[portid]),

      .avalon_st_tx_312_ready          (mac_in_ready[portid]),
      .avalon_st_tx_312_valid          (mac_in_valid[portid]),
      .avalon_st_tx_312_data           (mac_in_data[portid]),
      .avalon_st_tx_312_error          (mac_in_error[portid]),
      .avalon_st_tx_312_startofpacket  (mac_in_startofpacket[portid]),
      .avalon_st_tx_312_endofpacket    (mac_in_endofpacket[portid]),
      .avalon_st_tx_312_empty          (mac_in_empty[portid]),

      //rx clock and reset    
      .avalon_st_rx_clk_312            (core_clk_312),
      .avalon_st_rx_312_reset_n        (sync_rx_rst_n),
      .avalon_st_rx_clk_156            (core_clk_156),
      .avalon_st_rx_156_reset_n        (sync_rx_half_rst_n),

      .avalon_st_rx_312_ready          (mac_out_ready[portid]),
      .avalon_st_rx_312_valid          (mac_out_valid[portid]),
      .avalon_st_rx_312_data           (mac_out_data[portid]),
      .avalon_st_rx_312_error          (mac_out_error[portid]),
      .avalon_st_rx_312_startofpacket  (mac_out_startofpacket[portid]),
      .avalon_st_rx_312_endofpacket    (mac_out_endofpacket[portid]),
      .avalon_st_rx_312_empty          (mac_out_empty[portid]),

      .avalon_st_rx_156_ready          (rx_in_ready[portid]),
      .avalon_st_rx_156_valid          (rx_in_valid[portid]),
      .avalon_st_rx_156_data           (rx_in_data[portid]),
      .avalon_st_rx_156_error          (rx_in_error[portid]),
      .avalon_st_rx_156_startofpacket  (rx_in_startofpacket[portid]),
      .avalon_st_rx_156_endofpacket    (rx_in_endofpacket[portid]),
      .avalon_st_rx_156_empty          (rx_in_empty[portid]),

      // TX 1588 signals at 156mhz domain
      .tx_egress_timestamp_request_valid_156                (1'b0),
      .tx_egress_timestamp_request_fingerprint_156          (4'b0),
      .tx_etstamp_ins_ctrl_timestamp_insert_156             (1'b0),
      .tx_etstamp_ins_ctrl_timestamp_format_156             (1'b0),
      .tx_etstamp_ins_ctrl_residence_time_update_156        (1'b0),
      .tx_etstamp_ins_ctrl_ingress_timestamp_96b_156        (96'b0),
      .tx_etstamp_ins_ctrl_ingress_timestamp_64b_156        (64'b0),
      .tx_etstamp_ins_ctrl_residence_time_calc_format_156   (1'b0),
      .tx_etstamp_ins_ctrl_checksum_zero_156                (1'b0),
      .tx_etstamp_ins_ctrl_checksum_correct_156             (1'b0),
      .tx_etstamp_ins_ctrl_offset_timestamp_156             (16'b0),
      .tx_etstamp_ins_ctrl_offset_correction_field_156      (16'b0),
      .tx_etstamp_ins_ctrl_offset_checksum_field_156        (16'b0),
      .tx_etstamp_ins_ctrl_offset_checksum_correction_156   (16'b0),

      // TX 1588 signals at 312mhz domain
      .tx_egress_timestamp_96b_data_312                     (96'b0),
      .tx_egress_timestamp_96b_valid_312                    (1'b0),
      .tx_egress_timestamp_96b_fingerprint_312              (4'b0),
      .tx_egress_timestamp_64b_data_312                     (64'b0),
      .tx_egress_timestamp_64b_valid_312                    (1'b0),
      .tx_egress_timestamp_64b_fingerprint_312              (4'b0),

      //TX Status Signals
      .avalon_st_txstatus_valid_156                         (),
      .avalon_st_txstatus_data_156                          (),
      .avalon_st_txstatus_error_156                         (),

      .avalon_st_txstatus_valid_312                         (1'b0),
      .avalon_st_txstatus_data_312                          (40'b0),
      .avalon_st_txstatus_error_312                         (7'b0),

      //TX PFC Status Signals
      .avalon_st_tx_pfc_data_156                      (avalon_st_tx_pfc_data_156[portid]),
      .avalon_st_tx_pfc_status_valid_312              (1'b0),
      .avalon_st_tx_pfc_status_data_312               (16'b0),

      // TX Pause Data
      .avalon_st_tx_pause_data_156                    (avalon_st_tx_pause_data_156[portid]),

      // Pause Quanta (For TX only variant)
      .avalon_st_tx_pause_length_valid_156            (1'b0),
      .avalon_st_tx_pause_length_data_156             (16'b0),

      // RX 1588 signals
      .rx_ingress_timestamp_96b_valid_312             (1'b0),
      .rx_ingress_timestamp_96b_data_312              (96'b0),
      .rx_ingress_timestamp_64b_valid_312             (1'b0),
      .rx_ingress_timestamp_64b_data_312              (64'b0),

      //RX Status Signals
      .avalon_st_rxstatus_valid_312                   (1'b0),
      .avalon_st_rxstatus_data_312                    (/*avalon_st_rxstatus_data_312*/),
      .avalon_st_rxstatus_error_312                   (7'b0),

      //RX PFC Status Signals
      .avalon_st_rx_pfc_pause_data_312                (avalon_st_rx_pfc_data_sync[portid]),
      .avalon_st_rx_pfc_status_valid_312              (1'b0),
      .avalon_st_rx_pfc_status_data_312               (16'b0),

      // Pause Quanta (For RX only variant)
      .avalon_st_rx_pause_length_valid_312            (1'b0),
      .avalon_st_rx_pause_length_data_312             (16'b0),

      .tx_egress_timestamp_96b_data_156                     (),
      .tx_egress_timestamp_96b_valid_156                    (),
      .tx_egress_timestamp_96b_fingerprint_156              (),
      .tx_egress_timestamp_64b_data_156                     (),
      .tx_egress_timestamp_64b_valid_156                    (),
      .tx_egress_timestamp_64b_fingerprint_156              (),
      .tx_egress_timestamp_request_valid_312                (),
      .tx_egress_timestamp_request_fingerprint_312          (),
      .tx_etstamp_ins_ctrl_timestamp_insert_312             (),
      .tx_etstamp_ins_ctrl_timestamp_format_312             (),

      .tx_etstamp_ins_ctrl_residence_time_update_312        (),
      .tx_etstamp_ins_ctrl_ingress_timestamp_96b_312        (),
      .tx_etstamp_ins_ctrl_ingress_timestamp_64b_312        (),
      .tx_etstamp_ins_ctrl_residence_time_calc_format_312   (),
      .tx_etstamp_ins_ctrl_checksum_zero_312                (),
      .tx_etstamp_ins_ctrl_checksum_correct_312             (),
      .tx_etstamp_ins_ctrl_offset_timestamp_312             (),
      .tx_etstamp_ins_ctrl_offset_correction_field_312      (),
      .tx_etstamp_ins_ctrl_offset_checksum_field_312        (),
      .tx_etstamp_ins_ctrl_offset_checksum_correction_312   (),

      .avalon_st_tx_pfc_data_312                            (avalon_st_tx_pfc_data_sync[portid]),
      .avalon_st_tx_pfc_status_valid_156                    (),
      .avalon_st_tx_pfc_status_data_156                     (),
      .avalon_st_tx_pause_data_312                          (avalon_st_pause_data_sync[portid]),
      .avalon_st_tx_pause_length_valid_312                  (),
      .avalon_st_tx_pause_length_data_312                   (),
      .rx_ingress_timestamp_96b_valid_156                   (),
      .rx_ingress_timestamp_96b_data_156                    (),
      .rx_ingress_timestamp_64b_valid_156                   (),
      .rx_ingress_timestamp_64b_data_156                    (),

      .avalon_st_rxstatus_valid_156                         (),
      .avalon_st_rxstatus_data_156                          (/*avalon_st_rxstatus_data_156*/),
      .avalon_st_rxstatus_error_156                         (),
      .avalon_st_rx_pfc_pause_data_156                      (avalon_st_rx_pfc_pause_data_156[portid]),
      .avalon_st_rx_pfc_status_valid_156                    (),
      .avalon_st_rx_pfc_status_data_156                     (),
      .avalon_st_rx_pause_length_valid_156                  (),
      .avalon_st_rx_pause_length_data_156                   ()

   );

   // MAC+PHY Instance 
   altera_eth_10g_mac_base_r_wrap wrapper_inst (

      .csr_clk                         (csr_clk_156),
      .csr_rst_n                       (csr_rst_n_156),
      .tx_clk_312                      (core_clk_312),
      .tx_clk_156                      (core_clk_156),
      .sync_tx_rst_n                   (sync_tx_rst_n),
      .rx_clk_312                      (core_clk_312),
      .rx_clk_156                      (core_clk_156),
      .sync_rx_rst_n                   (sync_rx_rst_n),
      .ref_clk_clk                     (ref_clk_clk),

      .avalon_st_tx_startofpacket      (mac_in_startofpacket[portid]),
      .avalon_st_tx_endofpacket        (mac_in_endofpacket[portid]),
      .avalon_st_tx_valid              (mac_in_valid[portid]),
      .avalon_st_tx_data               (mac_in_data[portid]),
      .avalon_st_tx_empty              (mac_in_empty[portid]),
      .avalon_st_tx_ready              (mac_in_ready[portid]),
      .avalon_st_tx_error              (mac_in_error[portid]),

      .avalon_st_rx_startofpacket      (mac_out_startofpacket[portid]),
      .avalon_st_rx_endofpacket        (mac_out_endofpacket[portid]),
      .avalon_st_rx_valid              (mac_out_valid[portid]),
      .avalon_st_rx_data               (mac_out_data[portid]),
      .avalon_st_rx_empty              (mac_out_empty[portid]),
      .avalon_st_rx_ready              (mac_out_ready[portid]),
      .avalon_st_rx_error              (mac_out_error[portid]),

      .avalon_st_pause_data            (avalon_st_pause_data_sync[portid]),
      .avalon_st_tx_pfc_gen_data       (avalon_st_tx_pfc_data_sync[portid]),
      .avalon_st_rx_pfc_pause_data     (avalon_st_rx_pfc_data_sync[portid]),
      .avalon_st_txstatus_valid        (),
      .avalon_st_txstatus_data         (),
      .avalon_st_txstatus_error        (),

      .avalon_st_rxstatus_valid        (avalon_st_rxstatus_valid_312[portid]),
      .avalon_st_rxstatus_error        (),
      .avalon_st_rxstatus_data         (avalon_st_rxstatus_data_312[portid]),

      .link_fault_status_xgmii_rx_data (),

      .tx_ready_export                 (tx_ready_export[portid]),
      .rx_ready_export                 (rx_ready_export[portid]),
      .block_lock                      (block_lock[portid]),

      .tx_serial_data                  (tx_serial_data[portid]),
      .rx_serial_data                  (rx_serial_data[portid]),

      .mac_csr_read                    (mac_csr_read_32[portid]),
      .mac_csr_write                   (mac_csr_write_32[portid]),
      .mac_csr_readdata                (mac_csr_readdata_32[portid]),
      .mac_csr_writedata               (mac_csr_writedata_32[portid]),
      .mac_csr_waitrequest             (mac_csr_waitrequest_32[portid]),
      .mac_csr_address                 (mac_csr_address_32[portid]),

      .phy_csr_read                    (phy_csr_read[portid]),
      .phy_csr_write                   (phy_csr_write[portid]),
      .phy_csr_readdata                (phy_csr_readdata[portid]),
      .phy_csr_writedata               (phy_csr_writedata[portid]),
      .phy_csr_waitrequest             (phy_csr_waitrequest[portid]),
      .phy_csr_address                 (phy_csr_address[portid]),

      .tx_serial_clk                   (tx_serial_clk),
      .atx_pll_locked                  (atx_pll_locked),
      .hssi_stats                      (hssi_stats[portid]),
      .final_channel_rst               (final_channel_rst[portid]),
      .final_reconfig_rst              (final_reconfig_rst[portid])
   );

   //RX Status signals sync
   // Use the pr_freeze signal to mask the tx ready
   resync #(
      .SYNC_CHAIN_LENGTH   (2),
      .WIDTH               (5),
      .INIT_VALUE          (0),
      .NO_CUT              (1)
   ) rx_status_sync (
      .clk                 (core_clk_156),
      .reset               (sync_rx_half_rst),
      .d                   (avalon_st_rxstatus_data_312[portid][39:35]),
      .q                   (avalon_st_rxstatus_data_156[portid][0])
   );

   //Sync Valid signal
   resync #(
      .SYNC_CHAIN_LENGTH   (2),
      .WIDTH               (NUM_ETH_CHANNELS),
      .INIT_VALUE          (0),
      .NO_CUT              (1)
   ) rx_status_valid (
      .clk                 (core_clk_156),
      .reset               (sync_rx_half_rst),
      .d                   (avalon_st_rxstatus_valid_312[portid]),
      .q                   (avalon_st_rxstatus_valid_156[portid])
   );

end //for loop end
endgenerate

// 
pll fpll_inst (
   .pll_refclk0    (ref_clk_clk),
   .pll_cal_busy   (),
   .outclk_div2    (core_clk_156),             // 156.25MHz clock
   .outclk_div1    (core_clk_312),             // 312.50MHz clock
   .pll_locked     (core_pll_locked)
);

altera_xcvr_atx_pll_ip atx_pll_inst(
   .pll_refclk0     (ref_clk_clk),
   .tx_serial_clk   (tx_serial_clk),
   .pll_locked      (atx_pll_locked)
);

altera_reset_synchronizer # (
   .ASYNC_RESET (1),
   .DEPTH       (4)
) tx_reset_synchronizer_inst(
   .clk         (core_clk_312),
   .reset_in    (~tx_rst_n),
   .reset_out   (sync_tx_rst)
);

altera_reset_synchronizer # (
   .ASYNC_RESET (1),
   .DEPTH       (4)
) rx_reset_synchronizer_inst(
   .clk         (core_clk_312),
   .reset_in    (~rx_rst_n),
   .reset_out   (sync_rx_rst)
);

altera_reset_synchronizer # (
   .ASYNC_RESET (1),
   .DEPTH       (4)
) tx_half_clk_reset_synchronizer_inst(
   .clk         (core_clk_156),
   .reset_in    (~tx_rst_n),
   .reset_out   (sync_tx_half_rst)
);

altera_reset_synchronizer # (
   .ASYNC_RESET (1),
   .DEPTH       (4)
) rx_half_clk_reset_synchronizer_inst(
   .clk         (core_clk_156),
   .reset_in    (~rx_rst_n),
   .reset_out   (sync_rx_half_rst)
);

// Use the pr_freeze signal to mask the tx ready
resync #(
   .SYNC_CHAIN_LENGTH  (2),
   .WIDTH              (1),
   .INIT_VALUE         (0),
   .NO_CUT             (1)
) pr_freeze_sync (
   .clk                (core_clk_312),
   .reset              (1'b0),
   .d                  (pr_freeze),
   .q                  (hssi_pr_freeze)
);

endmodule
