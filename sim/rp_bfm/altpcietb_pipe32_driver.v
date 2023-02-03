// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

//
// altpcietb_pipe32_driver module consist of driving the HIP pipe 32 -bit
// module altpcietb_pipe32_hip_interface from the PHY IP transceiver
//
module altpcietb_pipe32_driver # (
   parameter LANES=8,
   parameter gen123_lane_rate_mode = "gen1",
   parameter pll_refclk_freq = "100 MHz" //legal value = "100 MHz", "125 MHz"
   )(
   input refclk,
   input npor,
   input  [LANES-1:0]  serdes_rx_serial_data,
   output [LANES-1:0]  serdes_tx_serial_data
);


function [8*25:1] low_str;
// Convert parameter strings to lower case
   input [8*25:1] input_string;
   reg [8*25:1] return_string;
   reg [8*25:1] reg_string;
   reg [8:1] tmp;
   reg [8:1] conv_char;
   integer byte_count;
   begin
      reg_string = input_string;
	  return_string = 0;
      for (byte_count = 25; byte_count >= 1; byte_count = byte_count - 1) begin
         tmp = reg_string[8*25:(8*(25-1)+1)];
         reg_string = reg_string << 8;
         if ((tmp >= 65) && (tmp <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
            begin
            conv_char = tmp + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
            return_string = {return_string, conv_char};
            end
         else
            return_string = {return_string, tmp};
      end
   low_str = return_string;
   end
endfunction

localparam SM_RST_IDLE        = 0,
           SM_RST_NPOR        = 1,
           SM_RST_TXDIG_WAIT  = 2,
           SM_RST_TXDIG       = 3,
           SM_RST_RXPMA_WAIT  = 4,
           SM_RST_RXPMA       = 5,
           SM_RST_RXDIGWAIT   = 6,
           SM_RST_RXDIG       = 7;
localparam [7:0] WAIT_TXDIG   = 8'h20;
localparam [7:0] WAIT_RXPMA   = 8'h20;
localparam [7:0] WAIT_RXDIG   = 8'h20;
localparam [511:0] ZEROS      = {512{1'b0}};
localparam [511:0] ONES       = {512{1'b1}};
localparam protocol_version = (low_str(gen123_lane_rate_mode)=="gen1")?"Gen 1":
                              (low_str(gen123_lane_rate_mode)=="gen1_gen2")?"Gen 2":
                              (low_str(gen123_lane_rate_mode)=="gen1_gen2_gen3")?"Gen 3":"<invalid>"; //legal value: "Gen 1", "Gen 2", "Gen 3"
localparam deser_factor       = 32;
localparam hip_enable         = "true";
localparam hip_hard_reset     = "disable";
localparam rpre_emph_a_val    = 6'd0;
localparam rpre_emph_b_val    = 6'd0;
localparam rpre_emph_c_val    = 6'd0;
localparam rpre_emph_d_val    = 6'd0;
localparam rpre_emph_e_val    = 6'd0;
localparam rvod_sel_a_val     = 6'd0;
localparam rvod_sel_b_val     = 6'd0;
localparam rvod_sel_c_val     = 6'd0;
localparam rvod_sel_d_val     = 6'd0;
localparam rvod_sel_e_val     = 6'd0;
localparam starting_channel_number = 0;

genvar i;

reg        [7:0] sm_rst_counter;
reg [2:0]  next_smrst;
reg [2:0]  curr_smrst;

wire arst         ; // npor synchronized to refclk
reg  [2:0] arst_r ;


wire [512:0] UNCON;
wire UNCON1B;

wire serdes_fixedclk;
wire fboutclk_fixedclk, serdes_pll_fixedclk_locked;

//pipe interface ports
wire  [LANES * deser_factor - 1:0]        serdes_pipe_txdata;
wire  [((LANES * deser_factor)/8) - 1:0]  serdes_pipe_txdatak;
wire  [LANES - 1:0]                       serdes_pipe_txdetectrx_loopback;
wire  [LANES - 1:0]                       serdes_pipe_txcompliance;
wire  [LANES - 1:0]                       serdes_pipe_txelecidle;
wire  [LANES - 1:0]                       serdes_pipe_txdeemph;
wire  [LANES - 1:0]                       serdes_pipe_txswing;
wire  [LANES - 1:0]                       serdes_pipe_tx_data_valid;
wire  [LANES - 1:0]                       serdes_pipe_tx_blk_start;
wire  [LANES*18 -1:0]                     serdes_current_coeff;
wire  [LANES*3  -1:0]                     serdes_current_rxpreset;
wire  [LANES*2  -1:0]                     serdes_pipe_tx_sync_hdr;
wire  [LANES - 1:0]                       serdes_pipe_rxpolarity;

wire  [LANES*3 - 1:0]                     serdes_pipe_txmargin;
wire  [LANES*2 - 1:0]                     serdes_pipe_rate;
wire  [LANES*2 - 1:0]                     serdes_pipe_powerdown;

wire  [8 * deser_factor - 1:0]            serdes_pipe_rxdata;
wire  [((8 * deser_factor)/8) - 1:0]      serdes_pipe_rxdatak;
wire  [8 - 1:0]                           serdes_pipe_rxvalid;
wire  [8 - 1:0]                           serdes_pipe_rxelecidle;
wire  [8 - 1:0]                           serdes_pipe_phystatus;
wire  [8*3 - 1:0]                         serdes_pipe_rxstatus;
wire  [8*2  -1:0]                         serdes_pipe_rx_sync_hdr;
wire  [8 - 1:0]                           serdes_pipe_rx_data_valid;
wire  [8 - 1:0]                           serdes_pipe_rx_blk_start;

//non-PIPE ports
//MM ports
wire  [LANES*3-1:0]                       serdes_rx_eidleinfersel;
wire  [LANES-1:0]                         serdes_rx_set_locktodata;
wire  [LANES-1:0]                         serdes_rx_set_locktoref;
wire  [LANES-1:0]                         serdes_tx_invpolarity;
wire  [((LANES*deser_factor)/8) -1:0]     serdes_rx_errdetect;
wire  [((LANES*deser_factor)/8) -1:0]     serdes_rx_disperr;
wire  [((LANES*deser_factor)/8) -1:0]     serdes_rx_patterndetect;
wire  [((LANES*deser_factor)/8) -1:0]     serdes_rx_syncstatus;
wire  [LANES-1:0]                         serdes_rx_phase_comp_fifo_error;
wire  [LANES-1:0]                         serdes_tx_phase_comp_fifo_error;
wire  [LANES-1:0]                         serdes_rx_is_lockedtoref;
wire  [LANES-1:0]                         serdes_rx_signaldetect;
wire  [LANES-1:0]                         serdes_rx_is_lockedtodata;
wire                                      serdes_pipe_pclk;
wire                                      serdes_pipe_pclkch1      ;
wire                                      serdes_pipe_pclkcentral  ;
wire                                      pipe_pclk;
wire                                      serdes_tx_analogreset;
wire  [LANES-1:0]                         serdes_tx_digitalreset;
wire  [LANES-1:0]                         serdes_rx_analogreset;
wire  [LANES-1:0]                         serdes_rx_digitalreset;

// reset controller signal
wire                                     rst_ctrl_rx_pll_locked  ; //
reg                                      rst_ctrl_rxanalogreset  ;
reg                                      rst_ctrl_rxdigitalreset ;
reg                                      rst_ctrl_txdigitalreset ;

// Access module for the HIP pipe 32-bit interface is altpcietb_pipe32_hip_interface
altpcietb_pipe32_hip_interface  altpcietb_pipe32_hip_interface ( .nop_out   (nop_out));

generic_pll #              ( .reference_clock_frequency(pll_refclk_freq), .output_clock_frequency("125.0 MHz") )
   u_pll_serdes_fixedclk   ( .refclk(refclk), .outclk(serdes_fixedclk), .locked(serdes_pll_fixedclk_locked), .fboutclk(fboutclk_fixedclk), .rst(~npor), .fbclk(fboutclk_fixedclk));

sv_xcvr_pipe_native #(
      .lanes                              (LANES                                 ),
      .starting_channel_number            (starting_channel_number           ),
      .protocol_version                   (protocol_version                  ),
      .deser_factor                       (deser_factor                      ),
      .pll_refclk_freq                    (pll_refclk_freq                   ),
      .hip_hard_reset                     (hip_hard_reset                    ),
      .hip_enable                         (hip_enable                        ),
      .pipe12_rpre_emph_a_val             (rpre_emph_a_val                   ),
      .pipe12_rpre_emph_b_val             (rpre_emph_b_val                   ),
      .pipe12_rpre_emph_c_val             (rpre_emph_c_val                   ),
      .pipe12_rpre_emph_d_val             (rpre_emph_d_val                   ),
      .pipe12_rpre_emph_e_val             (rpre_emph_e_val                   ),
      .pipe12_rvod_sel_a_val              (rvod_sel_a_val                    ),
      .pipe12_rvod_sel_b_val              (rvod_sel_b_val                    ),
      .pipe12_rvod_sel_c_val              (rvod_sel_c_val                    ),
      .pipe12_rvod_sel_d_val              (rvod_sel_d_val                    ),
      .pipe12_rvod_sel_e_val              (rvod_sel_e_val                    )
   ) sv_xcvr_pipe_native     (
      .pll_powerdown                      (1'b0),
      .tx_digitalreset                    (serdes_tx_digitalreset [LANES-1:0]),
      .rx_analogreset                     (serdes_rx_analogreset  [LANES-1:0]), //
      .tx_analogreset                     (serdes_tx_analogreset           ), //
      .rx_digitalreset                    (serdes_rx_digitalreset [LANES-1:0]), //

      //clk signal
      .pll_ref_clk                        (refclk), //
      .fixedclk                           (serdes_fixedclk), //

      //pipe interface ports
      .pipe_txdata                        (serdes_pipe_txdata             [LANES * deser_factor - 1:0]), //
      .pipe_txdatak                       (serdes_pipe_txdatak            [((LANES * deser_factor)/8) - 1:0] ), //
      .pipe_txdetectrx_loopback           (serdes_pipe_txdetectrx_loopback[LANES - 1:0]    ), //?
      .pipe_txcompliance                  (serdes_pipe_txcompliance       [LANES - 1:0]    ), //
      .pipe_txelecidle                    (serdes_pipe_txelecidle         [LANES - 1:0]    ), //

      .pipe_txdeemph                      (serdes_pipe_txdeemph           [LANES - 1:0]    ), //
      .pipe_txswing                       (serdes_pipe_txswing            [LANES - 1:0]    ), //

      .current_coeff                      (serdes_current_coeff           [LANES * 18 -1:0]), // GEN 3
      .current_rxpreset                   (serdes_current_rxpreset        [LANES * 3  -1:0]), // GEN 3
      .pipe_tx_data_valid                 (serdes_pipe_tx_data_valid      [LANES - 1:0]    ), // GEN 3
      .pipe_tx_blk_start                  (serdes_pipe_tx_blk_start       [LANES - 1:0]    ), // GEN 3
      .pipe_tx_sync_hdr                   (serdes_pipe_tx_sync_hdr        [LANES * 2  -1:0]), // GEN 3
      .pipe_rx_data_valid                 (serdes_pipe_rx_data_valid      [LANES - 1:0]    ), // GEN 3
      .pipe_rx_blk_start                  (serdes_pipe_rx_blk_start       [LANES - 1:0]    ), // GEN 3
      .pipe_rx_sync_hdr                   (serdes_pipe_rx_sync_hdr        [LANES * 2  -1:0]), // GEN 3

      .pipe_txmargin                      (serdes_pipe_txmargin           [LANES * 3 - 1:0]), //
      .pipe_rate                          (serdes_pipe_rate               [LANES * 2 - 1:0]),
      .rate_ctrl                          (serdes_pipe_rate               [1:0]            ),
      .pipe_powerdown                     (serdes_pipe_powerdown          [LANES * 2 - 1:0]), //

      .pipe_rxdata                        (serdes_pipe_rxdata             [LANES * deser_factor - 1:0]      ), //
      .pipe_rxdatak                       (serdes_pipe_rxdatak            [((LANES * deser_factor)/8) - 1:0]), //
      .pipe_rxvalid                       (serdes_pipe_rxvalid            [LANES - 1:0]                     ), //
      .pipe_rxpolarity                    (serdes_pipe_rxpolarity         [LANES - 1:0]                     ), //
      .pipe_rxelecidle                    (serdes_pipe_rxelecidle         [LANES - 1:0]                     ), //
      .pipe_phystatus                     (serdes_pipe_phystatus          [LANES - 1:0]                     ), //
      .pipe_rxstatus                      (serdes_pipe_rxstatus           [LANES * 3 - 1:0]                 ), //

      //non-PIPE ports
      .rx_eidleinfersel                   (serdes_rx_eidleinfersel        [LANES*3  -1:0]),
      .rx_set_locktodata                  (serdes_rx_set_locktodata       [LANES-1:0]  ),
      .rx_set_locktoref                   (serdes_rx_set_locktoref        [LANES-1:0]  ),
      .tx_invpolarity                     (serdes_tx_invpolarity          [LANES-1:0]  ),
      .rx_errdetect                       (serdes_rx_errdetect            [((LANES*deser_factor)/8) -1:0]),
      .rx_disperr                         (serdes_rx_disperr              [((LANES*deser_factor)/8) -1:0]),
      .rx_patterndetect                   (serdes_rx_patterndetect        [((LANES*deser_factor)/8) -1:0]),
      .rx_syncstatus                      (serdes_rx_syncstatus           [((LANES*deser_factor)/8) -1:0]),
      .rx_phase_comp_fifo_error           (serdes_rx_phase_comp_fifo_error[LANES-1:0]  ),
      .tx_phase_comp_fifo_error           (serdes_tx_phase_comp_fifo_error[LANES-1:0]  ),
      .rx_is_lockedtoref                  (serdes_rx_is_lockedtoref       [LANES-1:0]  ),
      .rx_signaldetect                    (serdes_rx_signaldetect         [LANES-1:0]  ),
      .rx_is_lockedtodata                 (serdes_rx_is_lockedtodata      [LANES-1:0]  ),
      .pll_locked                         (serdes_pll_locked_xcvr                           ),
      .frefclk                            (serdes_frefclk           ),// HIP input
      //non-MM ports
      .rx_serial_data                     (serdes_rx_serial_data[LANES-1:0]            ),
      .tx_serial_data                     (serdes_tx_serial_data[LANES-1:0]            ),

      // Reconfig interface
      .reconfig_to_xcvr                   (ZEROS[511:0]                                 ),
      .reconfig_from_xcvr                 (reconfig_from_xcvr                           ),

      .pipe_pclk                          (serdes_pipe_pclk                            ),
      .pipe_pclkch1                       (serdes_pipe_pclkch1                         ),
      .pipe_pclkcentral                   (serdes_pipe_pclkcentral                     )
      );

generate begin : g_serdes_pipe_io
   if (LANES==1) begin

      // TX
      assign serdes_pipe_rate[1:0]              = altpcietb_pipe32_hip_interface.rate0[1:0];   // Currently only Gen2 rate0[1] is unconnected
      assign serdes_pipe_txdata[31 :0  ]        = altpcietb_pipe32_hip_interface.txdata0;
      assign serdes_pipe_txdatak[ 3: 0]         = altpcietb_pipe32_hip_interface.txdatak0;
      assign serdes_pipe_txcompliance[0]        = altpcietb_pipe32_hip_interface.txcompl0;
      assign serdes_pipe_txelecidle[0]          = altpcietb_pipe32_hip_interface.txelecidle0;
      assign serdes_pipe_txdeemph[0]            = altpcietb_pipe32_hip_interface.txdeemph0;
      assign serdes_pipe_txswing[0]             = altpcietb_pipe32_hip_interface.txswing0;
      assign serdes_current_coeff[17:0]         = altpcietb_pipe32_hip_interface.currentcoeff0;
      assign serdes_current_rxpreset[2:0]       = altpcietb_pipe32_hip_interface.currentrxpreset0;
      assign serdes_pipe_tx_data_valid[0]       = altpcietb_pipe32_hip_interface.txdataskip0;
      assign serdes_pipe_tx_blk_start[0]        = altpcietb_pipe32_hip_interface.txblkst0;
      assign serdes_pipe_tx_sync_hdr[1:0]       = altpcietb_pipe32_hip_interface.txsynchd0;
      assign serdes_pipe_txmargin[ 2: 0]        = altpcietb_pipe32_hip_interface.txmargin0;
      assign serdes_pipe_powerdown[ 1 : 0]      = altpcietb_pipe32_hip_interface.powerdown0;
      assign serdes_pipe_rxpolarity[0]          = altpcietb_pipe32_hip_interface.rxpolarity0 ;
      assign serdes_pipe_txdetectrx_loopback[0] = altpcietb_pipe32_hip_interface.txdetectrx0;
      assign serdes_rx_eidleinfersel[2:0]       = altpcietb_pipe32_hip_interface.eidleinfersel0;

      //RX
      //
      assign pipe_pclk                  = serdes_pipe_pclk;

      // Reset signals

   end
   else if (LANES==2) begin
      // TX
      assign serdes_pipe_rate[1:0]              = altpcietb_pipe32_hip_interface.rate0[1:0];
      assign serdes_pipe_rate[3:2]              = altpcietb_pipe32_hip_interface.rate1[1:0];
      assign serdes_pipe_txdata[31 :0  ]        = altpcietb_pipe32_hip_interface.txdata0;
      assign serdes_pipe_txdata[63 :32 ]        = altpcietb_pipe32_hip_interface.txdata1;
      assign serdes_pipe_txdatak[ 3: 0]         = altpcietb_pipe32_hip_interface.txdatak0;
      assign serdes_pipe_txdatak[ 7: 4]         = altpcietb_pipe32_hip_interface.txdatak1;
      assign serdes_pipe_txcompliance[0]        = altpcietb_pipe32_hip_interface.txcompl0;
      assign serdes_pipe_txcompliance[1]        = altpcietb_pipe32_hip_interface.txcompl1;
      assign serdes_pipe_txelecidle[0]          = altpcietb_pipe32_hip_interface.txelecidle0;
      assign serdes_pipe_txelecidle[1]          = altpcietb_pipe32_hip_interface.txelecidle1;
      assign serdes_pipe_txdeemph[0]            = altpcietb_pipe32_hip_interface.txdeemph0;
      assign serdes_pipe_txdeemph[1]            = altpcietb_pipe32_hip_interface.txdeemph1;
      assign serdes_pipe_txswing[0]             = altpcietb_pipe32_hip_interface.txswing0;
      assign serdes_pipe_txswing[1]             = altpcietb_pipe32_hip_interface.txswing1;
      assign serdes_current_coeff[17:0]         = altpcietb_pipe32_hip_interface.currentcoeff0;
      assign serdes_current_coeff[35:18]        = altpcietb_pipe32_hip_interface.currentcoeff1;
      assign serdes_current_rxpreset[2:0]       = altpcietb_pipe32_hip_interface.currentrxpreset0;
      assign serdes_current_rxpreset[5:3]       = altpcietb_pipe32_hip_interface.currentrxpreset1;
      assign serdes_pipe_tx_data_valid[0]       = altpcietb_pipe32_hip_interface.txdataskip0;
      assign serdes_pipe_tx_data_valid[1]       = altpcietb_pipe32_hip_interface.txdataskip1;
      assign serdes_pipe_tx_blk_start[0]        = altpcietb_pipe32_hip_interface.txblkst0;
      assign serdes_pipe_tx_blk_start[1]        = altpcietb_pipe32_hip_interface.txblkst1;
      assign serdes_pipe_tx_sync_hdr[1:0]       = altpcietb_pipe32_hip_interface.txsynchd0;
      assign serdes_pipe_tx_sync_hdr[3:2]       = altpcietb_pipe32_hip_interface.txsynchd1;
      assign serdes_pipe_txmargin[ 2: 0]        = altpcietb_pipe32_hip_interface.txmargin0;
      assign serdes_pipe_txmargin[ 5: 3]        = altpcietb_pipe32_hip_interface.txmargin1;
      assign serdes_pipe_powerdown[ 1 : 0]      = altpcietb_pipe32_hip_interface.powerdown0;
      assign serdes_pipe_powerdown[ 3 : 2]      = altpcietb_pipe32_hip_interface.powerdown1;
      assign serdes_pipe_rxpolarity[0]          = altpcietb_pipe32_hip_interface.rxpolarity0 ;
      assign serdes_pipe_rxpolarity[1]          = altpcietb_pipe32_hip_interface.rxpolarity1 ;
      assign serdes_pipe_txdetectrx_loopback[0] = altpcietb_pipe32_hip_interface.txdetectrx0;
      assign serdes_pipe_txdetectrx_loopback[1] = altpcietb_pipe32_hip_interface.txdetectrx1;
      assign serdes_rx_eidleinfersel[2:0]       = altpcietb_pipe32_hip_interface.eidleinfersel0;
      assign serdes_rx_eidleinfersel[5:3]       = altpcietb_pipe32_hip_interface.eidleinfersel1;

      //RX
      //

      assign pipe_pclk      = serdes_pipe_pclkch1;

   end
   else if (LANES==4) begin
      // TX
      assign serdes_pipe_rate[1:0]              = altpcietb_pipe32_hip_interface.rate0[1:0];
      assign serdes_pipe_rate[3:2]              = altpcietb_pipe32_hip_interface.rate1[1:0];
      assign serdes_pipe_rate[5:4]              = altpcietb_pipe32_hip_interface.rate2[1:0];
      assign serdes_pipe_rate[7:6]              = altpcietb_pipe32_hip_interface.rate3[1:0];
      assign serdes_pipe_txdata[31 :0  ]        = altpcietb_pipe32_hip_interface.txdata0;
      assign serdes_pipe_txdata[63 :32 ]        = altpcietb_pipe32_hip_interface.txdata1;
      assign serdes_pipe_txdata[95 :64 ]        = altpcietb_pipe32_hip_interface.txdata2;
      assign serdes_pipe_txdata[127:96 ]        = altpcietb_pipe32_hip_interface.txdata3;
      assign serdes_pipe_txdatak[ 3: 0]         = altpcietb_pipe32_hip_interface.txdatak0;
      assign serdes_pipe_txdatak[ 7: 4]         = altpcietb_pipe32_hip_interface.txdatak1;
      assign serdes_pipe_txdatak[11: 8]         = altpcietb_pipe32_hip_interface.txdatak2;
      assign serdes_pipe_txdatak[15:12]         = altpcietb_pipe32_hip_interface.txdatak3;
      assign serdes_pipe_txcompliance[0]        = altpcietb_pipe32_hip_interface.txcompl0;
      assign serdes_pipe_txcompliance[1]        = altpcietb_pipe32_hip_interface.txcompl1;
      assign serdes_pipe_txcompliance[2]        = altpcietb_pipe32_hip_interface.txcompl2;
      assign serdes_pipe_txcompliance[3]        = altpcietb_pipe32_hip_interface.txcompl3;
      assign serdes_pipe_txelecidle[0]          = altpcietb_pipe32_hip_interface.txelecidle0;
      assign serdes_pipe_txelecidle[1]          = altpcietb_pipe32_hip_interface.txelecidle1;
      assign serdes_pipe_txelecidle[2]          = altpcietb_pipe32_hip_interface.txelecidle2;
      assign serdes_pipe_txelecidle[3]          = altpcietb_pipe32_hip_interface.txelecidle3;
      assign serdes_pipe_txdeemph[0]            = altpcietb_pipe32_hip_interface.txdeemph0;
      assign serdes_pipe_txdeemph[1]            = altpcietb_pipe32_hip_interface.txdeemph1;
      assign serdes_pipe_txdeemph[2]            = altpcietb_pipe32_hip_interface.txdeemph2;
      assign serdes_pipe_txdeemph[3]            = altpcietb_pipe32_hip_interface.txdeemph3;
      assign serdes_pipe_txswing[0]             = altpcietb_pipe32_hip_interface.txswing0;
      assign serdes_pipe_txswing[1]             = altpcietb_pipe32_hip_interface.txswing1;
      assign serdes_pipe_txswing[2]             = altpcietb_pipe32_hip_interface.txswing2;
      assign serdes_pipe_txswing[3]             = altpcietb_pipe32_hip_interface.txswing3;
      assign serdes_current_coeff[17:0]         = altpcietb_pipe32_hip_interface.currentcoeff0;
      assign serdes_current_coeff[35:18]        = altpcietb_pipe32_hip_interface.currentcoeff1;
      assign serdes_current_coeff[53:36]        = altpcietb_pipe32_hip_interface.currentcoeff2;
      assign serdes_current_coeff[71:54]        = altpcietb_pipe32_hip_interface.currentcoeff3;
      assign serdes_current_rxpreset[2:0]       = altpcietb_pipe32_hip_interface.currentrxpreset0;
      assign serdes_current_rxpreset[5:3]       = altpcietb_pipe32_hip_interface.currentrxpreset1;
      assign serdes_current_rxpreset[8:6]       = altpcietb_pipe32_hip_interface.currentrxpreset2;
      assign serdes_current_rxpreset[11:9]      = altpcietb_pipe32_hip_interface.currentrxpreset3;
      assign serdes_pipe_tx_data_valid[0]       = altpcietb_pipe32_hip_interface.txdataskip0;
      assign serdes_pipe_tx_data_valid[1]       = altpcietb_pipe32_hip_interface.txdataskip1;
      assign serdes_pipe_tx_data_valid[2]       = altpcietb_pipe32_hip_interface.txdataskip2;
      assign serdes_pipe_tx_data_valid[3]       = altpcietb_pipe32_hip_interface.txdataskip3;
      assign serdes_pipe_tx_blk_start[0]        = altpcietb_pipe32_hip_interface.txblkst0;
      assign serdes_pipe_tx_blk_start[1]        = altpcietb_pipe32_hip_interface.txblkst1;
      assign serdes_pipe_tx_blk_start[2]        = altpcietb_pipe32_hip_interface.txblkst2;
      assign serdes_pipe_tx_blk_start[3]        = altpcietb_pipe32_hip_interface.txblkst3;
      assign serdes_pipe_tx_sync_hdr[1:0]       = altpcietb_pipe32_hip_interface.txsynchd0;
      assign serdes_pipe_tx_sync_hdr[3:2]       = altpcietb_pipe32_hip_interface.txsynchd1;
      assign serdes_pipe_tx_sync_hdr[5:4]       = altpcietb_pipe32_hip_interface.txsynchd2;
      assign serdes_pipe_tx_sync_hdr[7:6]       = altpcietb_pipe32_hip_interface.txsynchd3;
      assign serdes_pipe_txmargin[ 2: 0]        = altpcietb_pipe32_hip_interface.txmargin0;
      assign serdes_pipe_txmargin[ 5: 3]        = altpcietb_pipe32_hip_interface.txmargin1;
      assign serdes_pipe_txmargin[ 8: 6]        = altpcietb_pipe32_hip_interface.txmargin2;
      assign serdes_pipe_txmargin[11: 9]        = altpcietb_pipe32_hip_interface.txmargin3;
      assign serdes_pipe_powerdown[ 1 : 0]      = altpcietb_pipe32_hip_interface.powerdown0;
      assign serdes_pipe_powerdown[ 3 : 2]      = altpcietb_pipe32_hip_interface.powerdown1;
      assign serdes_pipe_powerdown[ 5 : 4]      = altpcietb_pipe32_hip_interface.powerdown2;
      assign serdes_pipe_powerdown[ 7 : 6]      = altpcietb_pipe32_hip_interface.powerdown3;
      assign serdes_pipe_rxpolarity[0]          = altpcietb_pipe32_hip_interface.rxpolarity0 ;
      assign serdes_pipe_rxpolarity[1]          = altpcietb_pipe32_hip_interface.rxpolarity1 ;
      assign serdes_pipe_rxpolarity[2]          = altpcietb_pipe32_hip_interface.rxpolarity2 ;
      assign serdes_pipe_rxpolarity[3]          = altpcietb_pipe32_hip_interface.rxpolarity3 ;
      assign serdes_pipe_txdetectrx_loopback[0] = altpcietb_pipe32_hip_interface.txdetectrx0;
      assign serdes_pipe_txdetectrx_loopback[1] = altpcietb_pipe32_hip_interface.txdetectrx1;
      assign serdes_pipe_txdetectrx_loopback[2] = altpcietb_pipe32_hip_interface.txdetectrx2;
      assign serdes_pipe_txdetectrx_loopback[3] = altpcietb_pipe32_hip_interface.txdetectrx3;
      assign  serdes_rx_eidleinfersel[2:0]      = altpcietb_pipe32_hip_interface.eidleinfersel0;
      assign  serdes_rx_eidleinfersel[5:3]      = altpcietb_pipe32_hip_interface.eidleinfersel1;
      assign  serdes_rx_eidleinfersel[8:6]      = altpcietb_pipe32_hip_interface.eidleinfersel2;
      assign  serdes_rx_eidleinfersel[11:9]     = altpcietb_pipe32_hip_interface.eidleinfersel3;

      //RX
      //

      assign pipe_pclk      = serdes_pipe_pclkch1;

   end
   else begin // x8
      // TX
      assign serdes_pipe_rate[1 : 0]            = altpcietb_pipe32_hip_interface.rate0[1:0];
      assign serdes_pipe_rate[3 : 2]            = altpcietb_pipe32_hip_interface.rate1[1:0];
      assign serdes_pipe_rate[5 : 4]            = altpcietb_pipe32_hip_interface.rate2[1:0];
      assign serdes_pipe_rate[7 : 6]            = altpcietb_pipe32_hip_interface.rate3[1:0];
      assign serdes_pipe_rate[9 : 8]            = altpcietb_pipe32_hip_interface.rate4[1:0];
      assign serdes_pipe_rate[11:10]            = altpcietb_pipe32_hip_interface.rate5[1:0];
      assign serdes_pipe_rate[13:12]            = altpcietb_pipe32_hip_interface.rate6[1:0];
      assign serdes_pipe_rate[15:14]            = altpcietb_pipe32_hip_interface.rate7[1:0];
      assign serdes_pipe_txdata[31 :0  ]        = altpcietb_pipe32_hip_interface.txdata0;
      assign serdes_pipe_txdata[63 :32 ]        = altpcietb_pipe32_hip_interface.txdata1;
      assign serdes_pipe_txdata[95 :64 ]        = altpcietb_pipe32_hip_interface.txdata2;
      assign serdes_pipe_txdata[127:96 ]        = altpcietb_pipe32_hip_interface.txdata3;
      assign serdes_pipe_txdata[159:128]        = altpcietb_pipe32_hip_interface.txdata4;
      assign serdes_pipe_txdata[191:160]        = altpcietb_pipe32_hip_interface.txdata5;
      assign serdes_pipe_txdata[223:192]        = altpcietb_pipe32_hip_interface.txdata6;
      assign serdes_pipe_txdata[255:224]        = altpcietb_pipe32_hip_interface.txdata7;
      assign serdes_pipe_txdatak[ 3: 0]         = altpcietb_pipe32_hip_interface.txdatak0;
      assign serdes_pipe_txdatak[ 7: 4]         = altpcietb_pipe32_hip_interface.txdatak1;
      assign serdes_pipe_txdatak[11: 8]         = altpcietb_pipe32_hip_interface.txdatak2;
      assign serdes_pipe_txdatak[15:12]         = altpcietb_pipe32_hip_interface.txdatak3;
      assign serdes_pipe_txdatak[19:16]         = altpcietb_pipe32_hip_interface.txdatak4;
      assign serdes_pipe_txdatak[23:20]         = altpcietb_pipe32_hip_interface.txdatak5;
      assign serdes_pipe_txdatak[27:24]         = altpcietb_pipe32_hip_interface.txdatak6;
      assign serdes_pipe_txdatak[31:28]         = altpcietb_pipe32_hip_interface.txdatak7;
      assign serdes_pipe_txcompliance[0]        = altpcietb_pipe32_hip_interface.txcompl0;
      assign serdes_pipe_txcompliance[1]        = altpcietb_pipe32_hip_interface.txcompl1;
      assign serdes_pipe_txcompliance[2]        = altpcietb_pipe32_hip_interface.txcompl2;
      assign serdes_pipe_txcompliance[3]        = altpcietb_pipe32_hip_interface.txcompl3;
      assign serdes_pipe_txcompliance[4]        = altpcietb_pipe32_hip_interface.txcompl4;
      assign serdes_pipe_txcompliance[5]        = altpcietb_pipe32_hip_interface.txcompl5;
      assign serdes_pipe_txcompliance[6]        = altpcietb_pipe32_hip_interface.txcompl6;
      assign serdes_pipe_txcompliance[7]        = altpcietb_pipe32_hip_interface.txcompl7;
      assign serdes_pipe_txelecidle[0]          = altpcietb_pipe32_hip_interface.txelecidle0;
      assign serdes_pipe_txelecidle[1]          = altpcietb_pipe32_hip_interface.txelecidle1;
      assign serdes_pipe_txelecidle[2]          = altpcietb_pipe32_hip_interface.txelecidle2;
      assign serdes_pipe_txelecidle[3]          = altpcietb_pipe32_hip_interface.txelecidle3;
      assign serdes_pipe_txelecidle[4]          = altpcietb_pipe32_hip_interface.txelecidle4;
      assign serdes_pipe_txelecidle[5]          = altpcietb_pipe32_hip_interface.txelecidle5;
      assign serdes_pipe_txelecidle[6]          = altpcietb_pipe32_hip_interface.txelecidle6;
      assign serdes_pipe_txelecidle[7]          = altpcietb_pipe32_hip_interface.txelecidle7;
      assign serdes_pipe_txdeemph[0]            = altpcietb_pipe32_hip_interface.txdeemph0;
      assign serdes_pipe_txdeemph[1]            = altpcietb_pipe32_hip_interface.txdeemph1;
      assign serdes_pipe_txdeemph[2]            = altpcietb_pipe32_hip_interface.txdeemph2;
      assign serdes_pipe_txdeemph[3]            = altpcietb_pipe32_hip_interface.txdeemph3;
      assign serdes_pipe_txdeemph[4]            = altpcietb_pipe32_hip_interface.txdeemph4;
      assign serdes_pipe_txdeemph[5]            = altpcietb_pipe32_hip_interface.txdeemph5;
      assign serdes_pipe_txdeemph[6]            = altpcietb_pipe32_hip_interface.txdeemph6;
      assign serdes_pipe_txdeemph[7]            = altpcietb_pipe32_hip_interface.txdeemph7;
      assign serdes_pipe_txswing[0]             = altpcietb_pipe32_hip_interface.txswing0;
      assign serdes_pipe_txswing[1]             = altpcietb_pipe32_hip_interface.txswing1;
      assign serdes_pipe_txswing[2]             = altpcietb_pipe32_hip_interface.txswing2;
      assign serdes_pipe_txswing[3]             = altpcietb_pipe32_hip_interface.txswing3;
      assign serdes_pipe_txswing[4]             = altpcietb_pipe32_hip_interface.txswing4;
      assign serdes_pipe_txswing[5]             = altpcietb_pipe32_hip_interface.txswing5;
      assign serdes_pipe_txswing[6]             = altpcietb_pipe32_hip_interface.txswing6;
      assign serdes_pipe_txswing[7]             = altpcietb_pipe32_hip_interface.txswing7;
      assign serdes_current_coeff[17:0]         = altpcietb_pipe32_hip_interface.currentcoeff0;
      assign serdes_current_coeff[35:18]        = altpcietb_pipe32_hip_interface.currentcoeff1;
      assign serdes_current_coeff[53:36]        = altpcietb_pipe32_hip_interface.currentcoeff2;
      assign serdes_current_coeff[71:54]        = altpcietb_pipe32_hip_interface.currentcoeff3;
      assign serdes_current_coeff[89:72]        = altpcietb_pipe32_hip_interface.currentcoeff4;
      assign serdes_current_coeff[107:90]       = altpcietb_pipe32_hip_interface.currentcoeff5;
      assign serdes_current_coeff[125:108]      = altpcietb_pipe32_hip_interface.currentcoeff6;
      assign serdes_current_coeff[143:126]      = altpcietb_pipe32_hip_interface.currentcoeff7;
      assign serdes_current_rxpreset[2:0]       = altpcietb_pipe32_hip_interface.currentrxpreset0;
      assign serdes_current_rxpreset[5:3]       = altpcietb_pipe32_hip_interface.currentrxpreset1;
      assign serdes_current_rxpreset[8:6]       = altpcietb_pipe32_hip_interface.currentrxpreset2;
      assign serdes_current_rxpreset[11:9]      = altpcietb_pipe32_hip_interface.currentrxpreset3;
      assign serdes_current_rxpreset[14:12]     = altpcietb_pipe32_hip_interface.currentrxpreset4;
      assign serdes_current_rxpreset[17:15]     = altpcietb_pipe32_hip_interface.currentrxpreset5;
      assign serdes_current_rxpreset[20:18]     = altpcietb_pipe32_hip_interface.currentrxpreset6;
      assign serdes_current_rxpreset[23:21]     = altpcietb_pipe32_hip_interface.currentrxpreset7;
      assign serdes_pipe_tx_data_valid[0]       = altpcietb_pipe32_hip_interface.txdataskip0;
      assign serdes_pipe_tx_data_valid[1]       = altpcietb_pipe32_hip_interface.txdataskip1;
      assign serdes_pipe_tx_data_valid[2]       = altpcietb_pipe32_hip_interface.txdataskip2;
      assign serdes_pipe_tx_data_valid[3]       = altpcietb_pipe32_hip_interface.txdataskip3;
      assign serdes_pipe_tx_data_valid[4]       = altpcietb_pipe32_hip_interface.txdataskip4;
      assign serdes_pipe_tx_data_valid[5]       = altpcietb_pipe32_hip_interface.txdataskip5;
      assign serdes_pipe_tx_data_valid[6]       = altpcietb_pipe32_hip_interface.txdataskip6;
      assign serdes_pipe_tx_data_valid[7]       = altpcietb_pipe32_hip_interface.txdataskip7;
      assign serdes_pipe_tx_blk_start[0]        = altpcietb_pipe32_hip_interface.txblkst0;
      assign serdes_pipe_tx_blk_start[1]        = altpcietb_pipe32_hip_interface.txblkst1;
      assign serdes_pipe_tx_blk_start[2]        = altpcietb_pipe32_hip_interface.txblkst2;
      assign serdes_pipe_tx_blk_start[3]        = altpcietb_pipe32_hip_interface.txblkst3;
      assign serdes_pipe_tx_blk_start[4]        = altpcietb_pipe32_hip_interface.txblkst4;
      assign serdes_pipe_tx_blk_start[5]        = altpcietb_pipe32_hip_interface.txblkst5;
      assign serdes_pipe_tx_blk_start[6]        = altpcietb_pipe32_hip_interface.txblkst6;
      assign serdes_pipe_tx_blk_start[7]        = altpcietb_pipe32_hip_interface.txblkst7;
      assign serdes_pipe_tx_sync_hdr[1:0]       = altpcietb_pipe32_hip_interface.txsynchd0;
      assign serdes_pipe_tx_sync_hdr[3:2]       = altpcietb_pipe32_hip_interface.txsynchd1;
      assign serdes_pipe_tx_sync_hdr[5:4]       = altpcietb_pipe32_hip_interface.txsynchd2;
      assign serdes_pipe_tx_sync_hdr[7:6]       = altpcietb_pipe32_hip_interface.txsynchd3;
      assign serdes_pipe_tx_sync_hdr[9:8]       = altpcietb_pipe32_hip_interface.txsynchd4;
      assign serdes_pipe_tx_sync_hdr[11:10]     = altpcietb_pipe32_hip_interface.txsynchd5;
      assign serdes_pipe_tx_sync_hdr[13:12]     = altpcietb_pipe32_hip_interface.txsynchd6;
      assign serdes_pipe_tx_sync_hdr[15:14]     = altpcietb_pipe32_hip_interface.txsynchd7;
      assign serdes_pipe_txmargin[ 2: 0]        = altpcietb_pipe32_hip_interface.txmargin0;
      assign serdes_pipe_txmargin[ 5: 3]        = altpcietb_pipe32_hip_interface.txmargin1;
      assign serdes_pipe_txmargin[ 8: 6]        = altpcietb_pipe32_hip_interface.txmargin2;
      assign serdes_pipe_txmargin[11: 9]        = altpcietb_pipe32_hip_interface.txmargin3;
      assign serdes_pipe_txmargin[14:12]        = altpcietb_pipe32_hip_interface.txmargin4;
      assign serdes_pipe_txmargin[17:15]        = altpcietb_pipe32_hip_interface.txmargin5;
      assign serdes_pipe_txmargin[20:18]        = altpcietb_pipe32_hip_interface.txmargin6;
      assign serdes_pipe_txmargin[23:21]        = altpcietb_pipe32_hip_interface.txmargin7;
      assign serdes_pipe_powerdown[ 1 : 0]      = altpcietb_pipe32_hip_interface.powerdown0;
      assign serdes_pipe_powerdown[ 3 : 2]      = altpcietb_pipe32_hip_interface.powerdown1;
      assign serdes_pipe_powerdown[ 5 : 4]      = altpcietb_pipe32_hip_interface.powerdown2;
      assign serdes_pipe_powerdown[ 7 : 6]      = altpcietb_pipe32_hip_interface.powerdown3;
      assign serdes_pipe_powerdown[ 9 : 8]      = altpcietb_pipe32_hip_interface.powerdown4;
      assign serdes_pipe_powerdown[11 :10]      = altpcietb_pipe32_hip_interface.powerdown5;
      assign serdes_pipe_powerdown[13 :12]      = altpcietb_pipe32_hip_interface.powerdown6;
      assign serdes_pipe_powerdown[15 :14]      = altpcietb_pipe32_hip_interface.powerdown7;
      assign serdes_pipe_rxpolarity[0]          = altpcietb_pipe32_hip_interface.rxpolarity0 ;
      assign serdes_pipe_rxpolarity[1]          = altpcietb_pipe32_hip_interface.rxpolarity1 ;
      assign serdes_pipe_rxpolarity[2]          = altpcietb_pipe32_hip_interface.rxpolarity2 ;
      assign serdes_pipe_rxpolarity[3]          = altpcietb_pipe32_hip_interface.rxpolarity3 ;
      assign serdes_pipe_rxpolarity[4]          = altpcietb_pipe32_hip_interface.rxpolarity4 ;
      assign serdes_pipe_rxpolarity[5]          = altpcietb_pipe32_hip_interface.rxpolarity5 ;
      assign serdes_pipe_rxpolarity[6]          = altpcietb_pipe32_hip_interface.rxpolarity6 ;
      assign serdes_pipe_rxpolarity[7]          = altpcietb_pipe32_hip_interface.rxpolarity7 ;
      assign serdes_pipe_txdetectrx_loopback[0] = altpcietb_pipe32_hip_interface.txdetectrx0;
      assign serdes_pipe_txdetectrx_loopback[1] = altpcietb_pipe32_hip_interface.txdetectrx1;
      assign serdes_pipe_txdetectrx_loopback[2] = altpcietb_pipe32_hip_interface.txdetectrx2;
      assign serdes_pipe_txdetectrx_loopback[3] = altpcietb_pipe32_hip_interface.txdetectrx3;
      assign serdes_pipe_txdetectrx_loopback[4] = altpcietb_pipe32_hip_interface.txdetectrx4;
      assign serdes_pipe_txdetectrx_loopback[5] = altpcietb_pipe32_hip_interface.txdetectrx5;
      assign serdes_pipe_txdetectrx_loopback[6] = altpcietb_pipe32_hip_interface.txdetectrx6;
      assign serdes_pipe_txdetectrx_loopback[7] = altpcietb_pipe32_hip_interface.txdetectrx7;
      assign serdes_rx_eidleinfersel[2:0]       = altpcietb_pipe32_hip_interface.eidleinfersel0;
      assign serdes_rx_eidleinfersel[5:3]       = altpcietb_pipe32_hip_interface.eidleinfersel1;
      assign serdes_rx_eidleinfersel[8:6]       = altpcietb_pipe32_hip_interface.eidleinfersel2;
      assign serdes_rx_eidleinfersel[11:9]      = altpcietb_pipe32_hip_interface.eidleinfersel3;
      assign serdes_rx_eidleinfersel[14:12]     = altpcietb_pipe32_hip_interface.eidleinfersel4;
      assign serdes_rx_eidleinfersel[17:15]     = altpcietb_pipe32_hip_interface.eidleinfersel5;
      assign serdes_rx_eidleinfersel[20:18]     = altpcietb_pipe32_hip_interface.eidleinfersel6;
      assign serdes_rx_eidleinfersel[23:21]     = altpcietb_pipe32_hip_interface.eidleinfersel7;

      //RX
      //
      assign pipe_pclk  = serdes_pipe_pclkcentral;

   end
end
endgenerate

always @ (*) begin
   altpcietb_pipe32_hip_interface.rxdata0       =                                               serdes_pipe_rxdata[31 :0  ];
   altpcietb_pipe32_hip_interface.rxdata1       = ((LANES<2)                      )?ZEROS[31:0]:serdes_pipe_rxdata[63 :32 ];
   altpcietb_pipe32_hip_interface.rxdata2       = ((LANES<2)||(LANES<4)           )?ZEROS[31:0]:serdes_pipe_rxdata[95 :64 ];
   altpcietb_pipe32_hip_interface.rxdata3       = ((LANES<2)||(LANES<4)           )?ZEROS[31:0]:serdes_pipe_rxdata[127:96 ];
   altpcietb_pipe32_hip_interface.rxdata4       = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[31:0]:serdes_pipe_rxdata[159:128];
   altpcietb_pipe32_hip_interface.rxdata5       = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[31:0]:serdes_pipe_rxdata[191:160];
   altpcietb_pipe32_hip_interface.rxdata6       = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[31:0]:serdes_pipe_rxdata[223:192];
   altpcietb_pipe32_hip_interface.rxdata7       = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[31:0]:serdes_pipe_rxdata[255:224];
   altpcietb_pipe32_hip_interface.rxdatak0      =                                               serdes_pipe_rxdatak[ 3: 0] ;
   altpcietb_pipe32_hip_interface.rxdatak1      = ((LANES<2)                      )?ZEROS[ 3:0]:serdes_pipe_rxdatak[ 7: 4] ;
   altpcietb_pipe32_hip_interface.rxdatak2      = ((LANES<2)||(LANES<4)           )?ZEROS[ 3:0]:serdes_pipe_rxdatak[11: 8] ;
   altpcietb_pipe32_hip_interface.rxdatak3      = ((LANES<2)||(LANES<4)           )?ZEROS[ 3:0]:serdes_pipe_rxdatak[15:12] ;
   altpcietb_pipe32_hip_interface.rxdatak4      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 3:0]:serdes_pipe_rxdatak[19:16] ;
   altpcietb_pipe32_hip_interface.rxdatak5      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 3:0]:serdes_pipe_rxdatak[23:20] ;
   altpcietb_pipe32_hip_interface.rxdatak6      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 3:0]:serdes_pipe_rxdatak[27:24] ;
   altpcietb_pipe32_hip_interface.rxdatak7      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 3:0]:serdes_pipe_rxdatak[31:28] ;
   altpcietb_pipe32_hip_interface.rxvalid0      =                                               serdes_pipe_rxvalid[0] ;
   altpcietb_pipe32_hip_interface.rxvalid1      = ((LANES<2)                      )?ZEROS[ 0:0]:serdes_pipe_rxvalid[1] ;
   altpcietb_pipe32_hip_interface.rxvalid2      = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rxvalid[2] ;
   altpcietb_pipe32_hip_interface.rxvalid3      = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rxvalid[3] ;
   altpcietb_pipe32_hip_interface.rxvalid4      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxvalid[4] ;
   altpcietb_pipe32_hip_interface.rxvalid5      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxvalid[5] ;
   altpcietb_pipe32_hip_interface.rxvalid6      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxvalid[6] ;
   altpcietb_pipe32_hip_interface.rxvalid7      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxvalid[7] ;
   altpcietb_pipe32_hip_interface.rxelecidle0   =                                               serdes_pipe_rxelecidle[0] ;
   altpcietb_pipe32_hip_interface.rxelecidle1   = ((LANES<2)                      )?ZEROS[ 0:0]:serdes_pipe_rxelecidle[1] ;
   altpcietb_pipe32_hip_interface.rxelecidle2   = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rxelecidle[2] ;
   altpcietb_pipe32_hip_interface.rxelecidle3   = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rxelecidle[3] ;
   altpcietb_pipe32_hip_interface.rxelecidle4   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxelecidle[4] ;
   altpcietb_pipe32_hip_interface.rxelecidle5   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxelecidle[5] ;
   altpcietb_pipe32_hip_interface.rxelecidle6   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxelecidle[6] ;
   altpcietb_pipe32_hip_interface.rxelecidle7   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rxelecidle[7] ;
   altpcietb_pipe32_hip_interface.phystatus0    =                                               serdes_pipe_phystatus[0] ;
   altpcietb_pipe32_hip_interface.phystatus1    = ((LANES<2)                      )?ZEROS[ 0:0]:serdes_pipe_phystatus[1] ;
   altpcietb_pipe32_hip_interface.phystatus2    = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_phystatus[2] ;
   altpcietb_pipe32_hip_interface.phystatus3    = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_phystatus[3] ;
   altpcietb_pipe32_hip_interface.phystatus4    = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_phystatus[4] ;
   altpcietb_pipe32_hip_interface.phystatus5    = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_phystatus[5] ;
   altpcietb_pipe32_hip_interface.phystatus6    = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_phystatus[6] ;
   altpcietb_pipe32_hip_interface.phystatus7    = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_phystatus[7] ;
   altpcietb_pipe32_hip_interface.rxstatus0     =                                               serdes_pipe_rxstatus[ 2: 0];
   altpcietb_pipe32_hip_interface.rxstatus1     = ((LANES<2)                      )?ZEROS[ 2:0]:serdes_pipe_rxstatus[ 5: 3];
   altpcietb_pipe32_hip_interface.rxstatus2     = ((LANES<2)||(LANES<4)           )?ZEROS[ 2:0]:serdes_pipe_rxstatus[ 8: 6];
   altpcietb_pipe32_hip_interface.rxstatus3     = ((LANES<2)||(LANES<4)           )?ZEROS[ 2:0]:serdes_pipe_rxstatus[11: 9];
   altpcietb_pipe32_hip_interface.rxstatus4     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 2:0]:serdes_pipe_rxstatus[14:12];
   altpcietb_pipe32_hip_interface.rxstatus5     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 2:0]:serdes_pipe_rxstatus[17:15];
   altpcietb_pipe32_hip_interface.rxstatus6     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 2:0]:serdes_pipe_rxstatus[20:18];
   altpcietb_pipe32_hip_interface.rxstatus7     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 2:0]:serdes_pipe_rxstatus[23:21];
   altpcietb_pipe32_hip_interface.rxdataskip0   =                                               serdes_pipe_rx_data_valid[0];
   altpcietb_pipe32_hip_interface.rxdataskip1   = ((LANES<2)                      )?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[1];
   altpcietb_pipe32_hip_interface.rxdataskip2   = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[2];
   altpcietb_pipe32_hip_interface.rxdataskip3   = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[3];
   altpcietb_pipe32_hip_interface.rxdataskip4   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[4];
   altpcietb_pipe32_hip_interface.rxdataskip5   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[5];
   altpcietb_pipe32_hip_interface.rxdataskip6   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[6];
   altpcietb_pipe32_hip_interface.rxdataskip7   = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_data_valid[7];
   altpcietb_pipe32_hip_interface.rxblkst0      =                                               serdes_pipe_rx_blk_start[0];
   altpcietb_pipe32_hip_interface.rxblkst1      = ((LANES<2)                      )?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[1];
   altpcietb_pipe32_hip_interface.rxblkst2      = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[2];
   altpcietb_pipe32_hip_interface.rxblkst3      = ((LANES<2)||(LANES<4)           )?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[3];
   altpcietb_pipe32_hip_interface.rxblkst4      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[4];
   altpcietb_pipe32_hip_interface.rxblkst5      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[5];
   altpcietb_pipe32_hip_interface.rxblkst6      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[6];
   altpcietb_pipe32_hip_interface.rxblkst7      = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 0:0]:serdes_pipe_rx_blk_start[7];
   altpcietb_pipe32_hip_interface.rxsynchd0     =                                               serdes_pipe_rx_sync_hdr[1:0];
   altpcietb_pipe32_hip_interface.rxsynchd1     = ((LANES<2)                      )?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[3:2];
   altpcietb_pipe32_hip_interface.rxsynchd2     = ((LANES<2)||(LANES<4)           )?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[5:4];
   altpcietb_pipe32_hip_interface.rxsynchd3     = ((LANES<2)||(LANES<4)           )?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[7:6];
   altpcietb_pipe32_hip_interface.rxsynchd4     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[9:8];
   altpcietb_pipe32_hip_interface.rxsynchd5     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[11:10];
   altpcietb_pipe32_hip_interface.rxsynchd6     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[13:12];
   altpcietb_pipe32_hip_interface.rxsynchd7     = ((LANES<2)||(LANES<4)||(LANES<8))?ZEROS[ 1:0]:serdes_pipe_rx_sync_hdr[15:14];

   altpcietb_pipe32_hip_interface.pipe_pclk          = pipe_pclk;
end


generate begin : g_serdes_soft_rst_input
   for (i=0;i<LANES;i=i+1) begin : g_serdes_rst
      assign serdes_tx_digitalreset[i] = rst_ctrl_txdigitalreset    ;
      assign serdes_rx_analogreset [i] = rst_ctrl_rxanalogreset     ;
      assign serdes_rx_digitalreset[i] = rst_ctrl_rxdigitalreset    ;
   end
end
endgenerate

   assign serdes_tx_analogreset      = ~npor;

   always @(posedge refclk or negedge npor) begin
      if (npor == 1'b0) begin
         arst_r[2:0] <= 3'b111;
      end
      else begin
         arst_r[2:0] <= {arst_r[1],arst_r[0],1'b0};
      end
   end
   assign arst = arst_r[2];

reg [3:0]  mask_tx_pll_lock_count=0;

//AP ADDED
   always @(posedge refclk or  negedge npor ) begin
      if (npor == 1'b0) begin
          altpcietb_pipe32_hip_interface.mask_tx_pll_lock <= 1'b0;
      end
      if (altpcietb_pipe32_hip_interface.rate0 == 2'b00 ) begin
           altpcietb_pipe32_hip_interface.mask_tx_pll_lock <= 1'b0;
      end
      else begin
           if ( mask_tx_pll_lock_count <= 4'b1010 ) begin
	        altpcietb_pipe32_hip_interface.mask_tx_pll_lock <= 1'b1;
                mask_tx_pll_lock_count <= mask_tx_pll_lock_count+4'b0001; 
	   end
	   else if ( mask_tx_pll_lock_count == 4'b1011 ) begin
                altpcietb_pipe32_hip_interface.mask_tx_pll_lock <= 1'b0;
                mask_tx_pll_lock_count <= mask_tx_pll_lock_count+4'b0001;
           end
      end
   end





   always @*  begin
   case (curr_smrst)
      SM_RST_IDLE        :
      begin
         next_smrst=SM_RST_IDLE;
      end
      SM_RST_NPOR        :
      begin
         next_smrst=SM_RST_TXDIG_WAIT;
      end
      SM_RST_TXDIG_WAIT  :
      begin
         if (sm_rst_counter>WAIT_TXDIG) next_smrst=SM_RST_TXDIG;
         else                           next_smrst=SM_RST_TXDIG_WAIT;
      end
      SM_RST_TXDIG       :
      begin
         next_smrst=SM_RST_RXPMA_WAIT;
      end
      SM_RST_RXPMA_WAIT  :
      begin
         if (sm_rst_counter>WAIT_RXPMA) next_smrst=SM_RST_RXPMA;
         else                           next_smrst=SM_RST_RXPMA_WAIT;
      end
      SM_RST_RXPMA       :
      begin
         next_smrst=SM_RST_RXDIGWAIT;
      end
      SM_RST_RXDIGWAIT   :
      begin
         if (sm_rst_counter>WAIT_RXDIG) next_smrst=SM_RST_RXDIG;
         else                           next_smrst=SM_RST_RXDIGWAIT;
      end
      SM_RST_RXDIG       :
      begin
         next_smrst=SM_RST_IDLE;
      end
      default: next_smrst = SM_RST_IDLE;
   endcase
   end

   always @(posedge refclk or posedge arst) begin
      if (arst==1) begin
         curr_smrst     <= SM_RST_NPOR;
         sm_rst_counter <= 8'h0;
         rst_ctrl_rxanalogreset  <=1'b1;
         rst_ctrl_rxdigitalreset <=1'b1;
         rst_ctrl_txdigitalreset <=1'b1;
      end
      else begin
         curr_smrst <= next_smrst;
         if ((curr_smrst==SM_RST_IDLE)||
             (curr_smrst==SM_RST_NPOR)||
             (curr_smrst==SM_RST_TXDIG)||
             (curr_smrst==SM_RST_RXPMA)||
             (curr_smrst==SM_RST_RXDIG)) begin
            sm_rst_counter <= 16'h0;
         end
         else if (serdes_pll_fixedclk_locked==1'b1) begin
            sm_rst_counter <= sm_rst_counter+8'h1;
         end
         if (curr_smrst==SM_RST_TXDIG) begin
            rst_ctrl_txdigitalreset <= 1'b0;
         end
         if (curr_smrst==SM_RST_RXPMA) begin
            rst_ctrl_rxanalogreset <= 1'b0;
         end
         if (curr_smrst==SM_RST_RXDIG) begin
            rst_ctrl_rxdigitalreset <= 1'b0;
         end
      end
   end

endmodule
