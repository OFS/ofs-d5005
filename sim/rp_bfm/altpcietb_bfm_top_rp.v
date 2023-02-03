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





//////////////////////////////////////////
//
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcietb_bfm_top_rp  # (
   parameter pll_refclk_freq_hwtcl       = "100 MHz",
   parameter gen123_lane_rate_mode_hwtcl = "gen1",
   parameter lane_mask_hwtcl             = "x4",
   parameter apps_type_hwtcl             = 1,// "1:Link training and configuration", "2:Link training, configuration and chaining DMA","3:Link training, configuration and target"
   parameter port_type_hwtcl             = "Native Endpoint",
   parameter serial_sim_hwtcl            = 0
) (
   // Clock
   output                  refclk,
   output                  npor,
      // Reset signals
   output                 simu_mode,
   output                 simu_mode_pipe,

   output  [31 : 0]       test_in,

   // Input PIPE simulation _ext for simulation only
   input [1:0]            sim_pipe_rate,
   input                  sim_pipe_pclk_in,
   input                  sim_pipe_clk250_out,
   input                  sim_pipe_clk500_out,
   input [5:0]            sim_ltssmstate,
   output                 phystatus0,
   output                 phystatus1,
   output                 phystatus2,
   output                 phystatus3,
   output                 phystatus4,
   output                 phystatus5,
   output                 phystatus6,
   output                 phystatus7,
   output  [7 : 0]        rxdata0,
   output  [7 : 0]        rxdata1,
   output  [7 : 0]        rxdata2,
   output  [7 : 0]        rxdata3,
   output  [7 : 0]        rxdata4,
   output  [7 : 0]        rxdata5,
   output  [7 : 0]        rxdata6,
   output  [7 : 0]        rxdata7,
   output                 rxdatak0,
   output                 rxdatak1,
   output                 rxdatak2,
   output                 rxdatak3,
   output                 rxdatak4,
   output                 rxdatak5,
   output                 rxdatak6,
   output                 rxdatak7,
   output                 rxelecidle0,
   output                 rxelecidle1,
   output                 rxelecidle2,
   output                 rxelecidle3,
   output                 rxelecidle4,
   output                 rxelecidle5,
   output                 rxelecidle6,
   output                 rxelecidle7,
   output                 rxfreqlocked0,
   output                 rxfreqlocked1,
   output                 rxfreqlocked2,
   output                 rxfreqlocked3,
   output                 rxfreqlocked4,
   output                 rxfreqlocked5,
   output                 rxfreqlocked6,
   output                 rxfreqlocked7,
   output  [2 : 0]        rxstatus0,
   output  [2 : 0]        rxstatus1,
   output  [2 : 0]        rxstatus2,
   output  [2 : 0]        rxstatus3,
   output  [2 : 0]        rxstatus4,
   output  [2 : 0]        rxstatus5,
   output  [2 : 0]        rxstatus6,
   output  [2 : 0]        rxstatus7,
   output                 rxdataskip0,
   output                 rxdataskip1,
   output                 rxdataskip2,
   output                 rxdataskip3,
   output                 rxdataskip4,
   output                 rxdataskip5,
   output                 rxdataskip6,
   output                 rxdataskip7,
   output                 rxblkst0,
   output                 rxblkst1,
   output                 rxblkst2,
   output                 rxblkst3,
   output                 rxblkst4,
   output                 rxblkst5,
   output                 rxblkst6,
   output                 rxblkst7,
   output  [1 : 0]        rxsynchd0,
   output  [1 : 0]        rxsynchd1,
   output  [1 : 0]        rxsynchd2,
   output  [1 : 0]        rxsynchd3,
   output  [1 : 0]        rxsynchd4,
   output  [1 : 0]        rxsynchd5,
   output  [1 : 0]        rxsynchd6,
   output  [1 : 0]        rxsynchd7,
   output                 rxvalid0,
   output                 rxvalid1,
   output                 rxvalid2,
   output                 rxvalid3,
   output                 rxvalid4,
   output                 rxvalid5,
   output                 rxvalid6,
   output                 rxvalid7,

   // Output Pipe interface
   input [2 : 0]        eidleinfersel0,
   input [2 : 0]        eidleinfersel1,
   input [2 : 0]        eidleinfersel2,
   input [2 : 0]        eidleinfersel3,
   input [2 : 0]        eidleinfersel4,
   input [2 : 0]        eidleinfersel5,
   input [2 : 0]        eidleinfersel6,
   input [2 : 0]        eidleinfersel7,
   input [1 : 0]        powerdown0,
   input [1 : 0]        powerdown1,
   input [1 : 0]        powerdown2,
   input [1 : 0]        powerdown3,
   input [1 : 0]        powerdown4,
   input [1 : 0]        powerdown5,
   input [1 : 0]        powerdown6,
   input [1 : 0]        powerdown7,
   input                rxpolarity0,
   input                rxpolarity1,
   input                rxpolarity2,
   input                rxpolarity3,
   input                rxpolarity4,
   input                rxpolarity5,
   input                rxpolarity6,
   input                rxpolarity7,
   input                txcompl0,
   input                txcompl1,
   input                txcompl2,
   input                txcompl3,
   input                txcompl4,
   input                txcompl5,
   input                txcompl6,
   input                txcompl7,
   input [7 : 0]        txdata0,
   input [7 : 0]        txdata1,
   input [7 : 0]        txdata2,
   input [7 : 0]        txdata3,
   input [7 : 0]        txdata4,
   input [7 : 0]        txdata5,
   input [7 : 0]        txdata6,
   input [7 : 0]        txdata7,
   input                txdatak0,
   input                txdatak1,
   input                txdatak2,
   input                txdatak3,
   input                txdatak4,
   input                txdatak5,
   input                txdatak6,
   input                txdatak7,
   input                txdetectrx0,
   input                txdetectrx1,
   input                txdetectrx2,
   input                txdetectrx3,
   input                txdetectrx4,
   input                txdetectrx5,
   input                txdetectrx6,
   input                txdetectrx7,
   input                txelecidle0,
   input                txelecidle1,
   input                txelecidle2,
   input                txelecidle3,
   input                txelecidle4,
   input                txelecidle5,
   input                txelecidle6,
   input                txelecidle7,
   input [2 : 0]        txmargin0,
   input [2 : 0]        txmargin1,
   input [2 : 0]        txmargin2,
   input [2 : 0]        txmargin3,
   input [2 : 0]        txmargin4,
   input [2 : 0]        txmargin5,
   input [2 : 0]        txmargin6,
   input [2 : 0]        txmargin7,
   input                txswing0,
   input                txswing1,
   input                txswing2,
   input                txswing3,
   input                txswing4,
   input                txswing5,
   input                txswing6,
   input                txswing7,
   input                txdeemph0,
   input                txdeemph1,
   input                txdeemph2,
   input                txdeemph3,
   input                txdeemph4,
   input                txdeemph5,
   input                txdeemph6,
   input                txdeemph7,
   input                txblkst0,
   input                txblkst1,
   input                txblkst2,
   input                txblkst3,
   input                txblkst4,
   input                txblkst5,
   input                txblkst6,
   input                txblkst7,
   input [1 : 0]        txsynchd0,
   input [1 : 0]        txsynchd1,
   input [1 : 0]        txsynchd2,
   input [1 : 0]        txsynchd3,
   input [1 : 0]        txsynchd4,
   input [1 : 0]        txsynchd5,
   input [1 : 0]        txsynchd6,
   input [1 : 0]        txsynchd7,
   input [17 : 0]       currentcoeff0,
   input [17 : 0]       currentcoeff1,
   input [17 : 0]       currentcoeff2,
   input [17 : 0]       currentcoeff3,
   input [17 : 0]       currentcoeff4,
   input [17 : 0]       currentcoeff5,
   input [17 : 0]       currentcoeff6,
   input [17 : 0]       currentcoeff7,
   input [2 : 0]        currentrxpreset0,
   input [2 : 0]        currentrxpreset1,
   input [2 : 0]        currentrxpreset2,
   input [2 : 0]        currentrxpreset3,
   input [2 : 0]        currentrxpreset4,
   input [2 : 0]        currentrxpreset5,
   input [2 : 0]        currentrxpreset6,
   input [2 : 0]        currentrxpreset7,


   // serial interface
   output    rx_in0,
   output    rx_in1,
   output    rx_in2,
   output    rx_in3,
   output    rx_in4,
   output    rx_in5,
   output    rx_in6,
   output    rx_in7,

   input     tx_out0,
   input     tx_out1,
   input     tx_out2,
   input     tx_out3,
   input     tx_out4,
   input     tx_out5,
   input     tx_out6,
   input     tx_out7

   );

genvar i;
localparam NLANES = (lane_mask_hwtcl == "x1")?1:(lane_mask_hwtcl == "x2")?2:(lane_mask_hwtcl == "x4")?4:8;
localparam CONNECTED_LANES = 8;
localparam SIMULATE_CONFIG_BYPASS = 10;
localparam SIM_SRIOV_DMA    = 12;
localparam SIM_SRIOV_TARGET = 13;
localparam USE_CONFIG_BYPASS_HWTCL = (apps_type_hwtcl== SIMULATE_CONFIG_BYPASS) || (apps_type_hwtcl== SIM_SRIOV_DMA) || (apps_type_hwtcl== SIM_SRIOV_TARGET) ;

wire    [  4: 0] rp_ltssm;
wire             pclk_pipe_rp;
wire             rp_phystatus0_ext;
wire             rp_phystatus1_ext;
wire             rp_phystatus2_ext;
wire             rp_phystatus3_ext;
wire             rp_phystatus4_ext;
wire             rp_phystatus5_ext;
wire             rp_phystatus6_ext;
wire             rp_phystatus7_ext;
wire    [  1: 0] rp_powerdown0_ext;
wire    [  1: 0] rp_powerdown1_ext;
wire    [  1: 0] rp_powerdown2_ext;
wire    [  1: 0] rp_powerdown3_ext;
wire    [  1: 0] rp_powerdown4_ext;
wire    [  1: 0] rp_powerdown5_ext;
wire    [  1: 0] rp_powerdown6_ext;
wire    [  1: 0] rp_powerdown7_ext;
wire             rp_rate;
wire             rp_rstn;
wire             rp_rx_in0;
wire             rp_rx_in1;
wire             rp_rx_in2;
wire             rp_rx_in3;
wire             rp_rx_in4;
wire             rp_rx_in5;
wire             rp_rx_in6;
wire             rp_rx_in7;
wire    [  7: 0] rp_rxdata0_ext;
wire    [  7: 0] rp_rxdata1_ext;
wire    [  7: 0] rp_rxdata2_ext;
wire    [  7: 0] rp_rxdata3_ext;
wire    [  7: 0] rp_rxdata4_ext;
wire    [  7: 0] rp_rxdata5_ext;
wire    [  7: 0] rp_rxdata6_ext;
wire    [  7: 0] rp_rxdata7_ext;
wire             rp_rxdatak0_ext;
wire             rp_rxdatak1_ext;
wire             rp_rxdatak2_ext;
wire             rp_rxdatak3_ext;
wire             rp_rxdatak4_ext;
wire             rp_rxdatak5_ext;
wire             rp_rxdatak6_ext;
wire             rp_rxdatak7_ext;
wire             rp_rxelecidle0_ext;
wire             rp_rxelecidle1_ext;
wire             rp_rxelecidle2_ext;
wire             rp_rxelecidle3_ext;
wire             rp_rxelecidle4_ext;
wire             rp_rxelecidle5_ext;
wire             rp_rxelecidle6_ext;
wire             rp_rxelecidle7_ext;
wire             rp_rxpolarity0_ext;
wire             rp_rxpolarity1_ext;
wire             rp_rxpolarity2_ext;
wire             rp_rxpolarity3_ext;
wire             rp_rxpolarity4_ext;
wire             rp_rxpolarity5_ext;
wire             rp_rxpolarity6_ext;
wire             rp_rxpolarity7_ext;
wire    [  2: 0] rp_rxstatus0_ext;
wire    [  2: 0] rp_rxstatus1_ext;
wire    [  2: 0] rp_rxstatus2_ext;
wire    [  2: 0] rp_rxstatus3_ext;
wire    [  2: 0] rp_rxstatus4_ext;
wire    [  2: 0] rp_rxstatus5_ext;
wire    [  2: 0] rp_rxstatus6_ext;
wire    [  2: 0] rp_rxstatus7_ext;
wire             rp_rxvalid0_ext;
wire             rp_rxvalid1_ext;
wire             rp_rxvalid2_ext;
wire             rp_rxvalid3_ext;
wire             rp_rxvalid4_ext;
wire             rp_rxvalid5_ext;
wire             rp_rxvalid6_ext;
wire             rp_rxvalid7_ext;
wire    [ 31: 0] rp_test_in;
wire    [511: 0] rp_test_out;
wire             rp_tx_out0;
wire             rp_tx_out1;
wire             rp_tx_out2;
wire             rp_tx_out3;
wire             rp_tx_out4;
wire             rp_tx_out5;
wire             rp_tx_out6;
wire             rp_tx_out7;


wire             rp_txcompl0_ext;
wire             rp_txcompl1_ext;
wire             rp_txcompl2_ext;
wire             rp_txcompl3_ext;
wire             rp_txcompl4_ext;
wire             rp_txcompl5_ext;
wire             rp_txcompl6_ext;
wire             rp_txcompl7_ext;
wire    [  7: 0] rp_txdata0_ext;
wire    [  7: 0] rp_txdata1_ext;
wire    [  7: 0] rp_txdata2_ext;
wire    [  7: 0] rp_txdata3_ext;
wire    [  7: 0] rp_txdata4_ext;
wire    [  7: 0] rp_txdata5_ext;
wire    [  7: 0] rp_txdata6_ext;
wire    [  7: 0] rp_txdata7_ext;
wire             rp_txdatak0_ext;
wire             rp_txdatak1_ext;
wire             rp_txdatak2_ext;
wire             rp_txdatak3_ext;
wire             rp_txdatak4_ext;
wire             rp_txdatak5_ext;
wire             rp_txdatak6_ext;
wire             rp_txdatak7_ext;
wire             rp_txdetectrx0_ext;
wire             rp_txdetectrx1_ext;
wire             rp_txdetectrx2_ext;
wire             rp_txdetectrx3_ext;
wire             rp_txdetectrx4_ext;
wire             rp_txdetectrx5_ext;
wire             rp_txdetectrx6_ext;
wire             rp_txdetectrx7_ext;
wire             rp_txelecidle0_ext;
wire             rp_txelecidle1_ext;
wire             rp_txelecidle2_ext;
wire             rp_txelecidle3_ext;
wire             rp_txelecidle4_ext;
wire             rp_txelecidle5_ext;
wire             rp_txelecidle6_ext;
wire             rp_txelecidle7_ext;
wire    [  5: 0] swdn_out;

wire [7:0]     rp_phystatus_ext ;
wire [63:0]    rp_rxdata_ext;
wire [7:0]     rp_rxdatak_ext ;
wire [7:0]     rp_rxelecidle_ext ;
wire [23:0]    rp_rxstatus_ext;
wire [7:0]     rp_rxvalid_ext ;
wire [7:0]     rp_rxpolarity_ext ;
wire [7:0]     phystatus ;
wire [63:0]    rxdata;
wire [7:0]     rxdatak ;
wire [7:0]     rxelecidle ;
wire [7:0]     rxpolarity ;
wire [23:0]    rxstatus;
wire [7:0]     rxvalid ;
wire [7:0]     connected_bits;
wire           bfm_log_common_dummy_out;
wire           bfm_req_intf_common_dummy_out;
wire           bfm_shmem_common_dummy_out;

wire [31:0] open_wire;
tri0 spec_version;
tri0 lane_rate;


   assign simu_mode        = 1'b1;
   assign simu_mode_pipe   =  (serial_sim_hwtcl==1)?1'b0:1'b1;

   assign local_rstn       = 1;

   assign test_in[31 : 10] = 0;
   assign test_in[9]       = 1;
   assign test_in[8 : 4]   = 0;
   assign test_in[3]       = 0;
   assign test_in[2 : 1]   = 0;
   //Bit 0: Speed up the simulation but making counters faster than normal
   assign test_in[0]       = simu_mode;
   assign connected_bits = (CONNECTED_LANES==8)?8'hFF:(CONNECTED_LANES==4)?8'h0F:(CONNECTED_LANES==2)?8'h03:8'h1;
   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Driver and monitors
   //

   altpcietb_bfm_log_common bfm_log_common ( .dummy_out (bfm_log_common_dummy_out));
   altpcietb_bfm_req_intf_common bfm_req_intf_common ( .dummy_out (bfm_req_intf_common_dummy_out));
   altpcietb_bfm_shmem_common bfm_shmem_common ( .dummy_out (bfm_shmem_common_dummy_out));

// NOT NEEDED FOR SIMPLE PIO DOWNSTREAM
/*   generate
      if (apps_type_hwtcl == 11) begin
           altpcietb_bfm_driver_simple_ep_downstream
            drv (
              .INTA (swdn_out[0]),
              .INTB (swdn_out[1]),
              .INTC (swdn_out[2]),
              .INTD (swdn_out[3]),
              .clk_in (pclk_pipe_rp),
              .dummy_out (dummy_out),
              .rstn (npor));
      end
      else if ( (gen123_lane_rate_mode_hwtcl!="Gen3 (8.0 Gbps)") && ((apps_type_hwtcl == 1)||(apps_type_hwtcl == 2)) ) begin
           altpcietb_bfm_driver_chaining # (
               .TEST_LEVEL(1),
               .USE_CDMA  ((apps_type_hwtcl == 2)?1:0),
               .USE_TARGET((apps_type_hwtcl == 2)?1:0)
              ) drvr (
              .INTA (swdn_out[0]),
              .INTB (swdn_out[1]),
              .INTC (swdn_out[2]),
              .INTD (swdn_out[3]),
              .clk_in (pclk_pipe_rp),
              .dummy_out (dummy_out),
              .rstn (npor));
      end
      else if ((gen123_lane_rate_mode_hwtcl!="Gen3 (8.0 Gbps)") && (USE_CONFIG_BYPASS_HWTCL == 1)) begin
           altpcietb_bfm_driver_cfgbp # (
               .TEST_LEVEL(1),
               .RUN_SRIOV_TEST(((apps_type_hwtcl == SIM_SRIOV_DMA) || (apps_type_hwtcl == SIM_SRIOV_TARGET)) ?1:0),
               .APPS_TYPE_HWTCL (apps_type_hwtcl),
               .USE_CDMA  (0),
               .USE_TARGET(0)
              ) drvr (
              .INTA (swdn_out[0]),
              .INTB (swdn_out[1]),
              .INTC (swdn_out[2]),
              .INTD (swdn_out[3]),
              .clk_in (pclk_pipe_rp),
              .dummy_out (dummy_out),
              .rstn (npor));
      end
      else if ( (gen123_lane_rate_mode_hwtcl!="Gen3 (8.0 Gbps)") && (apps_type_hwtcl == 3) )  begin
         altpcietb_bfm_driver_downstream # (
            .TEST_LEVEL(1)
            ) drvr (
            .INTA (swdn_out[0]),
            .INTB (swdn_out[1]),
            .INTC (swdn_out[2]),
            .INTD (swdn_out[3]),
            .clk_in (pclk_pipe_rp),
            .dummy_out (dummy_out),
            .rstn (npor));
      end
      else if (  (gen123_lane_rate_mode_hwtcl!="Gen3 (8.0 Gbps)") && ((apps_type_hwtcl == 4) || (apps_type_hwtcl == 5)) )  begin
         altpcietb_bfm_driver_avmm # (
            .APPS_TYPE_HWTCL(apps_type_hwtcl)
            ) drvr (
            .INTA (swdn_out[0]),
            .INTB (swdn_out[1]),
            .INTC (swdn_out[2]),
            .INTD (swdn_out[3]),
            .clk_in (pclk_pipe_rp),
            .dummy_out (dummy_out),
            .rstn (npor)
         );
     end
   endgenerate
*/

   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Reset and monitors
   //
   altpcietb_rst_clk # (
         .REFCLK_HALF_PERIOD((pll_refclk_freq_hwtcl== "100 MHz")?5000:4000)
        ) rst_clk_gen (
       .pcie_rstn          (npor),
       .ref_clk_out        (refclk),
       .rp_rstn            (rp_rstn));

   altpcietb_ltssm_mon ltssm_mon (
      .dummy_out  (ltssm_dummy_out),
      .ep_ltssm   (sim_ltssmstate),
      .rp_clk     (pclk_pipe_rp),
      .rp_ltssm   (rp_ltssm),
      .rstn       (npor)
    );

   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Root Port BFM
   //
   assign rp_test_in[31 : 8] = 0;
   assign rp_test_in[6] = 0;
   assign rp_test_in[4] = 0;
   assign rp_test_in[2 : 1] = 0;
   //Bit 0: Speed up the simulation but making counters faster than normal
   assign rp_test_in[0] = 1'b1;
   //Bit 3: Forces all lanes to detect the receiver
   //For Stratix GX we must force but can use Rx Detect for
   //the generic PIPE interface
   assign rp_test_in[3] = ~simu_mode_pipe;
   //Bit 5: Disable polling.compliance
   assign rp_test_in[5] = 1;
   //Bit 7: Disable any entrance to low power link states (for Stratix GX)
   //For Stratix GX we must disable but can use Low Power for
   //the generic PIPE interface
   assign rp_test_in[7] = ~simu_mode_pipe;

   assign rp_ltssm = rp_test_out[324 : 320];

   generate begin :  g_bfm
      if (USE_CONFIG_BYPASS_HWTCL == 0)  begin
         altpcietb_bfm_rp_gen3_x8 # (
            .apps_type_hwtcl(apps_type_hwtcl),
            .port_type_hwtcl(port_type_hwtcl)
            ) rp (
            .reconfig_xcvr_clk_clk (1'b0),
            .refclk_clk (refclk),
            .hip_ctrl_test_in (rp_test_in),
            .hip_ctrl_simu_mode_pipe (simu_mode_pipe),
            .hip_serial_rx_in0 (rp_rx_in0),
            .hip_serial_rx_in1 (rp_rx_in1),
            .hip_serial_rx_in2 (rp_rx_in2),
            .hip_serial_rx_in3 (rp_rx_in3),
            .hip_serial_rx_in4 (rp_rx_in4),
            .hip_serial_rx_in5 (rp_rx_in5),
            .hip_serial_rx_in6 (rp_rx_in6),
            .hip_serial_rx_in7 (rp_rx_in7),
            .hip_serial_tx_out0 (rp_tx_out0),
            .hip_serial_tx_out1 (rp_tx_out1),
            .hip_serial_tx_out2 (rp_tx_out2),
            .hip_serial_tx_out3 (rp_tx_out3),
            .hip_serial_tx_out4 (rp_tx_out4),
            .hip_serial_tx_out5 (rp_tx_out5),
            .hip_serial_tx_out6 (rp_tx_out6),
            .hip_serial_tx_out7 (rp_tx_out7),
            .hip_pipe_sim_pipe_pclk_in (pclk_pipe_rp),
            .hip_pipe_sim_pipe_rate (rp_rate),
            .hip_pipe_sim_ltssmstate (rp_ltssm),
            .hip_pipe_eidleinfersel0 (),
            .hip_pipe_eidleinfersel1 (),
            .hip_pipe_eidleinfersel2 (),
            .hip_pipe_eidleinfersel3 (),
            .hip_pipe_eidleinfersel4 (),
            .hip_pipe_eidleinfersel5 (),
            .hip_pipe_eidleinfersel6 (),
            .hip_pipe_eidleinfersel7 (),
            .hip_pipe_powerdown0 (rp_powerdown0_ext),
            .hip_pipe_powerdown1 (rp_powerdown1_ext),
            .hip_pipe_powerdown2 (rp_powerdown2_ext),
            .hip_pipe_powerdown3 (rp_powerdown3_ext),
            .hip_pipe_powerdown4 (rp_powerdown4_ext),
            .hip_pipe_powerdown5 (rp_powerdown5_ext),
            .hip_pipe_powerdown6 (rp_powerdown6_ext),
            .hip_pipe_powerdown7 (rp_powerdown7_ext),
            .hip_pipe_rxpolarity0 (rp_rxpolarity0_ext),
            .hip_pipe_rxpolarity1 (rp_rxpolarity1_ext),
            .hip_pipe_rxpolarity2 (rp_rxpolarity2_ext),
            .hip_pipe_rxpolarity3 (rp_rxpolarity3_ext),
            .hip_pipe_rxpolarity4 (rp_rxpolarity4_ext),
            .hip_pipe_rxpolarity5 (rp_rxpolarity5_ext),
            .hip_pipe_rxpolarity6 (rp_rxpolarity6_ext),
            .hip_pipe_rxpolarity7 (rp_rxpolarity7_ext),
            .hip_pipe_txcompl0 (rp_txcompl0_ext),
            .hip_pipe_txcompl1 (rp_txcompl1_ext),
            .hip_pipe_txcompl2 (rp_txcompl2_ext),
            .hip_pipe_txcompl3 (rp_txcompl3_ext),
            .hip_pipe_txcompl4 (rp_txcompl4_ext),
            .hip_pipe_txcompl5 (rp_txcompl5_ext),
            .hip_pipe_txcompl6 (rp_txcompl6_ext),
            .hip_pipe_txcompl7 (rp_txcompl7_ext),
            .hip_pipe_txdata0 (rp_txdata0_ext),
            .hip_pipe_txdata1 (rp_txdata1_ext),
            .hip_pipe_txdata2 (rp_txdata2_ext),
            .hip_pipe_txdata3 (rp_txdata3_ext),
            .hip_pipe_txdata4 (rp_txdata4_ext),
            .hip_pipe_txdata5 (rp_txdata5_ext),
            .hip_pipe_txdata6 (rp_txdata6_ext),
            .hip_pipe_txdata7 (rp_txdata7_ext),
            .hip_pipe_txdatak0 (rp_txdatak0_ext),
            .hip_pipe_txdatak1 (rp_txdatak0_ext),
            .hip_pipe_txdatak2 (rp_txdatak0_ext),
            .hip_pipe_txdatak3 (rp_txdatak0_ext),
            .hip_pipe_txdatak4 (rp_txdatak0_ext),
            .hip_pipe_txdatak5 (rp_txdatak0_ext),
            .hip_pipe_txdatak6 (rp_txdatak0_ext),
            .hip_pipe_txdatak7 (rp_txdatak0_ext),
            .hip_pipe_txdetectrx0 (rp_txdetectrx0_ext),
            .hip_pipe_txdetectrx1 (rp_txdetectrx1_ext),
            .hip_pipe_txdetectrx2 (rp_txdetectrx2_ext),
            .hip_pipe_txdetectrx3 (rp_txdetectrx3_ext),
            .hip_pipe_txdetectrx4 (rp_txdetectrx4_ext),
            .hip_pipe_txdetectrx5 (rp_txdetectrx5_ext),
            .hip_pipe_txdetectrx6 (rp_txdetectrx6_ext),
            .hip_pipe_txdetectrx7 (rp_txdetectrx7_ext),
            .hip_pipe_txelecidle0 (rp_txelecidle0_ext),
            .hip_pipe_txelecidle1 (rp_txelecidle1_ext),
            .hip_pipe_txelecidle2 (rp_txelecidle2_ext),
            .hip_pipe_txelecidle3 (rp_txelecidle3_ext),
            .hip_pipe_txelecidle4 (rp_txelecidle4_ext),
            .hip_pipe_txelecidle5 (rp_txelecidle5_ext),
            .hip_pipe_txelecidle6 (rp_txelecidle6_ext),
            .hip_pipe_txelecidle7 (rp_txelecidle7_ext),
            .hip_pipe_txdeemph0 (),
            .hip_pipe_txdeemph1 (),
            .hip_pipe_txdeemph2 (),
            .hip_pipe_txdeemph3 (),
            .hip_pipe_txdeemph4 (),
            .hip_pipe_txdeemph5 (),
            .hip_pipe_txdeemph6 (),
            .hip_pipe_txdeemph7 (),
            .hip_pipe_phystatus0 (rp_phystatus0_ext),
            .hip_pipe_phystatus1 (rp_phystatus1_ext),
            .hip_pipe_phystatus2 (rp_phystatus2_ext),
            .hip_pipe_phystatus3 (rp_phystatus3_ext),
            .hip_pipe_phystatus4 (rp_phystatus4_ext),
            .hip_pipe_phystatus5 (rp_phystatus5_ext),
            .hip_pipe_phystatus6 (rp_phystatus6_ext),
            .hip_pipe_phystatus7 (rp_phystatus7_ext),
            .hip_pipe_rxdata0 (rp_rxdata0_ext),
            .hip_pipe_rxdata1 (rp_rxdata1_ext),
            .hip_pipe_rxdata2 (rp_rxdata2_ext),
            .hip_pipe_rxdata3 (rp_rxdata3_ext),
            .hip_pipe_rxdata4 (rp_rxdata4_ext),
            .hip_pipe_rxdata5 (rp_rxdata5_ext),
            .hip_pipe_rxdata6 (rp_rxdata6_ext),
            .hip_pipe_rxdata7 (rp_rxdata7_ext),
            .hip_pipe_rxdatak0 (rp_rxdatak0_ext),
            .hip_pipe_rxdatak1 (rp_rxdatak1_ext),
            .hip_pipe_rxdatak2 (rp_rxdatak2_ext),
            .hip_pipe_rxdatak3 (rp_rxdatak3_ext),
            .hip_pipe_rxdatak4 (rp_rxdatak4_ext),
            .hip_pipe_rxdatak5 (rp_rxdatak5_ext),
            .hip_pipe_rxdatak6 (rp_rxdatak6_ext),
            .hip_pipe_rxdatak7 (rp_rxdatak7_ext),
            .hip_pipe_rxelecidle0 (rp_rxelecidle0_ext),
            .hip_pipe_rxelecidle1 (rp_rxelecidle1_ext),
            .hip_pipe_rxelecidle2 (rp_rxelecidle2_ext),
            .hip_pipe_rxelecidle3 (rp_rxelecidle3_ext),
            .hip_pipe_rxelecidle4 (rp_rxelecidle4_ext),
            .hip_pipe_rxelecidle5 (rp_rxelecidle5_ext),
            .hip_pipe_rxelecidle6 (rp_rxelecidle6_ext),
            .hip_pipe_rxelecidle7 (rp_rxelecidle7_ext),
            .hip_pipe_rxstatus0 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus1 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus2 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus3 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus4 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus5 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus6 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus7 (rp_rxstatus0_ext),
            .hip_pipe_rxvalid0 (rp_rxvalid0_ext),
            .hip_pipe_rxvalid1 (rp_rxvalid1_ext),
            .hip_pipe_rxvalid2 (rp_rxvalid2_ext),
            .hip_pipe_rxvalid3 (rp_rxvalid3_ext),
            .hip_pipe_rxvalid4 (rp_rxvalid4_ext),
            .hip_pipe_rxvalid5 (rp_rxvalid5_ext),
            .hip_pipe_rxvalid6 (rp_rxvalid6_ext),
            .hip_pipe_rxvalid7 (rp_rxvalid7_ext),
            .pcie_rstn_npor (rp_rstn),
            .pcie_rstn_pin_perst (rp_rstn)
            );
      end else /*if (USE_CONFIG_BYPASS_HWTCL == 1)*/ begin
         altpcietb_bfm_rp_gen3_x8_cfgbp # (
            .apps_type_hwtcl(apps_type_hwtcl)
            ) rp (
            .reconfig_xcvr_clk_clk (1'b0),
            .refclk_clk (refclk),
            .hip_ctrl_test_in (rp_test_in),
            .hip_ctrl_simu_mode_pipe (simu_mode_pipe),
            .hip_serial_rx_in0 (rp_rx_in0),
            .hip_serial_rx_in1 (rp_rx_in1),
            .hip_serial_rx_in2 (rp_rx_in2),
            .hip_serial_rx_in3 (rp_rx_in3),
            .hip_serial_rx_in4 (rp_rx_in4),
            .hip_serial_rx_in5 (rp_rx_in5),
            .hip_serial_rx_in6 (rp_rx_in6),
            .hip_serial_rx_in7 (rp_rx_in7),
            .hip_serial_tx_out0 (rp_tx_out0),
            .hip_serial_tx_out1 (rp_tx_out1),
            .hip_serial_tx_out2 (rp_tx_out2),
            .hip_serial_tx_out3 (rp_tx_out3),
            .hip_serial_tx_out4 (rp_tx_out4),
            .hip_serial_tx_out5 (rp_tx_out5),
            .hip_serial_tx_out6 (rp_tx_out6),
            .hip_serial_tx_out7 (rp_tx_out7),
            .hip_pipe_sim_pipe_pclk_in (pclk_pipe_rp),
            .hip_pipe_sim_pipe_rate (rp_rate),
            .hip_pipe_sim_ltssmstate (rp_ltssm),
            .hip_pipe_eidleinfersel0 (),
            .hip_pipe_eidleinfersel1 (),
            .hip_pipe_eidleinfersel2 (),
            .hip_pipe_eidleinfersel3 (),
            .hip_pipe_eidleinfersel4 (),
            .hip_pipe_eidleinfersel5 (),
            .hip_pipe_eidleinfersel6 (),
            .hip_pipe_eidleinfersel7 (),
            .hip_pipe_powerdown0 (rp_powerdown0_ext),
            .hip_pipe_powerdown1 (rp_powerdown1_ext),
            .hip_pipe_powerdown2 (rp_powerdown2_ext),
            .hip_pipe_powerdown3 (rp_powerdown3_ext),
            .hip_pipe_powerdown4 (rp_powerdown4_ext),
            .hip_pipe_powerdown5 (rp_powerdown5_ext),
            .hip_pipe_powerdown6 (rp_powerdown6_ext),
            .hip_pipe_powerdown7 (rp_powerdown7_ext),
            .hip_pipe_rxpolarity0 (rp_rxpolarity0_ext),
            .hip_pipe_rxpolarity1 (rp_rxpolarity1_ext),
            .hip_pipe_rxpolarity2 (rp_rxpolarity2_ext),
            .hip_pipe_rxpolarity3 (rp_rxpolarity3_ext),
            .hip_pipe_rxpolarity4 (rp_rxpolarity4_ext),
            .hip_pipe_rxpolarity5 (rp_rxpolarity5_ext),
            .hip_pipe_rxpolarity6 (rp_rxpolarity6_ext),
            .hip_pipe_rxpolarity7 (rp_rxpolarity7_ext),
            .hip_pipe_txcompl0 (rp_txcompl0_ext),
            .hip_pipe_txcompl1 (rp_txcompl1_ext),
            .hip_pipe_txcompl2 (rp_txcompl2_ext),
            .hip_pipe_txcompl3 (rp_txcompl3_ext),
            .hip_pipe_txcompl4 (rp_txcompl4_ext),
            .hip_pipe_txcompl5 (rp_txcompl5_ext),
            .hip_pipe_txcompl6 (rp_txcompl6_ext),
            .hip_pipe_txcompl7 (rp_txcompl7_ext),
            .hip_pipe_txdata0 (rp_txdata0_ext),
            .hip_pipe_txdata1 (rp_txdata1_ext),
            .hip_pipe_txdata2 (rp_txdata2_ext),
            .hip_pipe_txdata3 (rp_txdata3_ext),
            .hip_pipe_txdata4 (rp_txdata4_ext),
            .hip_pipe_txdata5 (rp_txdata5_ext),
            .hip_pipe_txdata6 (rp_txdata6_ext),
            .hip_pipe_txdata7 (rp_txdata7_ext),
            .hip_pipe_txdatak0 (rp_txdatak0_ext),
            .hip_pipe_txdatak1 (rp_txdatak0_ext),
            .hip_pipe_txdatak2 (rp_txdatak0_ext),
            .hip_pipe_txdatak3 (rp_txdatak0_ext),
            .hip_pipe_txdatak4 (rp_txdatak0_ext),
            .hip_pipe_txdatak5 (rp_txdatak0_ext),
            .hip_pipe_txdatak6 (rp_txdatak0_ext),
            .hip_pipe_txdatak7 (rp_txdatak0_ext),
            .hip_pipe_txdetectrx0 (rp_txdetectrx0_ext),
            .hip_pipe_txdetectrx1 (rp_txdetectrx1_ext),
            .hip_pipe_txdetectrx2 (rp_txdetectrx2_ext),
            .hip_pipe_txdetectrx3 (rp_txdetectrx3_ext),
            .hip_pipe_txdetectrx4 (rp_txdetectrx4_ext),
            .hip_pipe_txdetectrx5 (rp_txdetectrx5_ext),
            .hip_pipe_txdetectrx6 (rp_txdetectrx6_ext),
            .hip_pipe_txdetectrx7 (rp_txdetectrx7_ext),
            .hip_pipe_txelecidle0 (rp_txelecidle0_ext),
            .hip_pipe_txelecidle1 (rp_txelecidle1_ext),
            .hip_pipe_txelecidle2 (rp_txelecidle2_ext),
            .hip_pipe_txelecidle3 (rp_txelecidle3_ext),
            .hip_pipe_txelecidle4 (rp_txelecidle4_ext),
            .hip_pipe_txelecidle5 (rp_txelecidle5_ext),
            .hip_pipe_txelecidle6 (rp_txelecidle6_ext),
            .hip_pipe_txelecidle7 (rp_txelecidle7_ext),
            .hip_pipe_txdeemph0 (),
            .hip_pipe_txdeemph1 (),
            .hip_pipe_txdeemph2 (),
            .hip_pipe_txdeemph3 (),
            .hip_pipe_txdeemph4 (),
            .hip_pipe_txdeemph5 (),
            .hip_pipe_txdeemph6 (),
            .hip_pipe_txdeemph7 (),
            .hip_pipe_phystatus0 (rp_phystatus0_ext),
            .hip_pipe_phystatus1 (rp_phystatus1_ext),
            .hip_pipe_phystatus2 (rp_phystatus2_ext),
            .hip_pipe_phystatus3 (rp_phystatus3_ext),
            .hip_pipe_phystatus4 (rp_phystatus4_ext),
            .hip_pipe_phystatus5 (rp_phystatus5_ext),
            .hip_pipe_phystatus6 (rp_phystatus6_ext),
            .hip_pipe_phystatus7 (rp_phystatus7_ext),
            .hip_pipe_rxdata0 (rp_rxdata0_ext),
            .hip_pipe_rxdata1 (rp_rxdata1_ext),
            .hip_pipe_rxdata2 (rp_rxdata2_ext),
            .hip_pipe_rxdata3 (rp_rxdata3_ext),
            .hip_pipe_rxdata4 (rp_rxdata4_ext),
            .hip_pipe_rxdata5 (rp_rxdata5_ext),
            .hip_pipe_rxdata6 (rp_rxdata6_ext),
            .hip_pipe_rxdata7 (rp_rxdata7_ext),
            .hip_pipe_rxdatak0 (rp_rxdatak0_ext),
            .hip_pipe_rxdatak1 (rp_rxdatak1_ext),
            .hip_pipe_rxdatak2 (rp_rxdatak2_ext),
            .hip_pipe_rxdatak3 (rp_rxdatak3_ext),
            .hip_pipe_rxdatak4 (rp_rxdatak4_ext),
            .hip_pipe_rxdatak5 (rp_rxdatak5_ext),
            .hip_pipe_rxdatak6 (rp_rxdatak6_ext),
            .hip_pipe_rxdatak7 (rp_rxdatak7_ext),
            .hip_pipe_rxelecidle0 (rp_rxelecidle0_ext),
            .hip_pipe_rxelecidle1 (rp_rxelecidle1_ext),
            .hip_pipe_rxelecidle2 (rp_rxelecidle2_ext),
            .hip_pipe_rxelecidle3 (rp_rxelecidle3_ext),
            .hip_pipe_rxelecidle4 (rp_rxelecidle4_ext),
            .hip_pipe_rxelecidle5 (rp_rxelecidle5_ext),
            .hip_pipe_rxelecidle6 (rp_rxelecidle6_ext),
            .hip_pipe_rxelecidle7 (rp_rxelecidle7_ext),
            .hip_pipe_rxstatus0 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus1 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus2 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus3 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus4 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus5 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus6 (rp_rxstatus0_ext),
            .hip_pipe_rxstatus7 (rp_rxstatus0_ext),
            .hip_pipe_rxvalid0 (rp_rxvalid0_ext),
            .hip_pipe_rxvalid1 (rp_rxvalid1_ext),
            .hip_pipe_rxvalid2 (rp_rxvalid2_ext),
            .hip_pipe_rxvalid3 (rp_rxvalid3_ext),
            .hip_pipe_rxvalid4 (rp_rxvalid4_ext),
            .hip_pipe_rxvalid5 (rp_rxvalid5_ext),
            .hip_pipe_rxvalid6 (rp_rxvalid6_ext),
            .hip_pipe_rxvalid7 (rp_rxvalid7_ext),
            .pcie_rstn_npor (rp_rstn),
            .pcie_rstn_pin_perst (rp_rstn)
            );
      end
   end // g_bfm
   endgenerate

   ///////////////////////////////////////////////////////////////////////////////////
   //
   // Serial Interface
   //

   assign rx_in7    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[7] == 1'b1) ?  rp_tx_out7 : 1'b1;
   assign rx_in6    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[6] == 1'b1) ?  rp_tx_out6 : 1'b1;
   assign rx_in5    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[5] == 1'b1) ?  rp_tx_out5 : 1'b1;
   assign rx_in4    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:(connected_bits[4] == 1'b1) ?  rp_tx_out4 : 1'b1;
   assign rx_in3    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                (connected_bits[3] == 1'b1) ?  rp_tx_out3 : 1'b1;
   assign rx_in2    = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                (connected_bits[2] == 1'b1) ?  rp_tx_out2 : 1'b1;
   assign rx_in1    = (NLANES<2)?1'b1:                                 (connected_bits[1] == 1'b1) ?  rp_tx_out1 : 1'b1;
   assign rx_in0    =                                                  (connected_bits[0] == 1'b1) ?  rp_tx_out0 : 1'b1;

   assign rp_rx_in7 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out7;
   assign rp_rx_in6 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out6;
   assign rp_rx_in5 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out5;
   assign rp_rx_in4 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:(NLANES<8)?1'b1:tx_out4;
   assign rp_rx_in3 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                tx_out3;
   assign rp_rx_in2 = (NLANES<2)?1'b1: (NLANES<4)?1'b1:                tx_out2;
   assign rp_rx_in1 = (NLANES<2)?1'b1:                                 tx_out1;
   assign rp_rx_in0 =                                                  tx_out0;

   ///////////////////////////////////////////////////////////////////////////////////
   //
   // PIPE Simulation Interface
   //
   //generate

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 0)
                  ) lane0 (
            .A_lane_conn            (connected_bits[0] ),
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_phystatus            (phystatus0        ),
            .A_rxdata               (rxdata0           ),
            .A_rxdatak              (rxdatak0          ),
            .A_rxelecidle           (rxelecidle0       ),
            .A_rxpolarity           (rxpolarity0       ),
            .A_rxstatus             (rxstatus0         ),
            .A_rxvalid              (rxvalid0          ),
            .A_powerdown            (powerdown0        ),
            .A_txcompl              (txcompl0          ),
            .A_txdata               (txdata0           ),
            .A_txdatak              (txdatak0          ),
            .A_txdetectrx           (txdetectrx0       ),
            .A_txelecidle           (txelecidle0       ),

            .B_phystatus            (rp_phystatus0_ext ),
            .B_rxdata               (rp_rxdata0_ext    ),
            .B_rxdatak              (rp_rxdatak0_ext   ),
            .B_rxelecidle           (rp_rxelecidle0_ext),
            .B_rxpolarity           (rp_rxpolarity0_ext),
            .B_rxstatus             (rp_rxstatus0_ext  ),
            .B_rxvalid              (rp_rxvalid0_ext   ),
            .B_powerdown            (rp_powerdown0_ext ),
            .B_txcompl              (rp_txcompl0_ext   ),
            .B_txdata               (rp_txdata0_ext    ),
            .B_txdatak              (rp_txdatak0_ext   ),
            .B_txdetectrx           (rp_txdetectrx0_ext),
            .B_txelecidle           (rp_txelecidle0_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus1 ;
      wire [7:0] irxdata1    ;
      wire       irxdatak1   ;
      wire       irxelecidle1;
      wire [2:0] irxstatus1  ;
      wire       irxvalid1   ;

      assign phystatus1 = (NLANES>1)?iphystatus1 :open_wire[0];
      assign rxdata1    = (NLANES>1)?irxdata1    :open_wire[7:0];
      assign rxdatak1   = (NLANES>1)?irxdatak1   :open_wire[0];
      assign rxelecidle1= (NLANES>1)?irxelecidle1:open_wire[0];
      assign rxstatus1  = (NLANES>1)?irxstatus1  :open_wire[2:0];
      assign rxvalid1   = (NLANES>1)?irxvalid1   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 1)
                  ) lane1 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>1)?connected_bits[1] : 1'b0),

            .A_phystatus            (iphystatus1 ),
            .A_rxdata               (irxdata1    ),
            .A_rxdatak              (irxdatak1   ),
            .A_rxelecidle           (irxelecidle1),
            .A_rxstatus             (irxstatus1  ),
            .A_rxvalid              (irxvalid1   ),
            .A_rxpolarity           ((NLANES>1)?rxpolarity1:1'b0),
            .A_powerdown            ((NLANES>1)?powerdown1 :2'h0),
            .A_txcompl              ((NLANES>1)?txcompl1   :1'b0),
            .A_txdata               ((NLANES>1)?txdata1    :8'h0),
            .A_txdatak              ((NLANES>1)?txdatak1   :1'b0),
            .A_txdetectrx           ((NLANES>1)?txdetectrx1:1'b0),
            .A_txelecidle           ((NLANES>1)?txelecidle1:1'b0),

            .B_phystatus            (rp_phystatus1_ext ),
            .B_rxdata               (rp_rxdata1_ext    ),
            .B_rxdatak              (rp_rxdatak1_ext   ),
            .B_rxelecidle           (rp_rxelecidle1_ext),
            .B_rxpolarity           (rp_rxpolarity1_ext),
            .B_rxstatus             (rp_rxstatus1_ext  ),
            .B_rxvalid              (rp_rxvalid1_ext   ),
            .B_powerdown            (rp_powerdown1_ext ),
            .B_txcompl              (rp_txcompl1_ext   ),
            .B_txdata               (rp_txdata1_ext    ),
            .B_txdatak              (rp_txdatak1_ext   ),
            .B_txdetectrx           (rp_txdetectrx1_ext),
            .B_txelecidle           (rp_txelecidle1_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus2 ;
      wire [7:0] irxdata2    ;
      wire       irxdatak2   ;
      wire       irxelecidle2;
      wire [2:0] irxstatus2  ;
      wire       irxvalid2   ;

      assign phystatus2 = (NLANES>3)?iphystatus2 :open_wire[0];
      assign rxdata2    = (NLANES>3)?irxdata2    :open_wire[7:0];
      assign rxdatak2   = (NLANES>3)?irxdatak2   :open_wire[0];
      assign rxelecidle2= (NLANES>3)?irxelecidle2:open_wire[0];
      assign rxstatus2  = (NLANES>3)?irxstatus2  :open_wire[2:0];
      assign rxvalid2   = (NLANES>3)?irxvalid2   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 2)
                  ) lane2 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>3)?connected_bits[2] :1'b0),
            .A_phystatus            (iphystatus2 ),
            .A_rxdata               (irxdata2    ),
            .A_rxdatak              (irxdatak2   ),
            .A_rxelecidle           (irxelecidle2),
            .A_rxstatus             (irxstatus2  ),
            .A_rxvalid              (irxvalid2   ),
            .A_rxpolarity           ((NLANES>3)?rxpolarity2:1'b0),
            .A_powerdown            ((NLANES>3)?powerdown2 :2'h0),
            .A_txcompl              ((NLANES>3)?txcompl2   :1'b0),
            .A_txdata               ((NLANES>3)?txdata2    :8'h0),
            .A_txdatak              ((NLANES>3)?txdatak2   :1'b0),
            .A_txdetectrx           ((NLANES>3)?txdetectrx2:1'b0),
            .A_txelecidle           ((NLANES>3)?txelecidle2:1'b0),

            .B_phystatus            (rp_phystatus2_ext ),
            .B_rxdata               (rp_rxdata2_ext    ),
            .B_rxdatak              (rp_rxdatak2_ext   ),
            .B_rxelecidle           (rp_rxelecidle2_ext),
            .B_rxpolarity           (rp_rxpolarity2_ext),
            .B_rxstatus             (rp_rxstatus2_ext  ),
            .B_rxvalid              (rp_rxvalid2_ext   ),
            .B_powerdown            (rp_powerdown2_ext ),
            .B_txcompl              (rp_txcompl2_ext   ),
            .B_txdata               (rp_txdata2_ext    ),
            .B_txdatak              (rp_txdatak2_ext   ),
            .B_txdetectrx           (rp_txdetectrx2_ext),
            .B_txelecidle           (rp_txelecidle2_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );


      wire       iphystatus3 ;
      wire [7:0] irxdata3    ;
      wire       irxdatak3   ;
      wire       irxelecidle3;
      wire [2:0] irxstatus3  ;
      wire       irxvalid3   ;

      assign phystatus3 = (NLANES>3)?iphystatus3 :open_wire[0];
      assign rxdata3    = (NLANES>3)?irxdata3    :open_wire[7:0];
      assign rxdatak3   = (NLANES>3)?irxdatak3   :open_wire[0];
      assign rxelecidle3= (NLANES>3)?irxelecidle3:open_wire[0];
      assign rxstatus3  = (NLANES>3)?irxstatus3  :open_wire[2:0];
      assign rxvalid3   = (NLANES>3)?irxvalid3   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 3)
                  ) lane3 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>3)?connected_bits[3] :1'b0),
            .A_phystatus            (iphystatus3 ),
            .A_rxdata               (irxdata3    ),
            .A_rxdatak              (irxdatak3   ),
            .A_rxelecidle           (irxelecidle3),
            .A_rxstatus             (irxstatus3  ),
            .A_rxvalid              (irxvalid3   ),
            .A_rxpolarity           ((NLANES>3)?rxpolarity3:1'b0),
            .A_powerdown            ((NLANES>3)?powerdown3 :2'h0),
            .A_txcompl              ((NLANES>3)?txcompl3   :1'b0),
            .A_txdata               ((NLANES>3)?txdata3    :8'h0),
            .A_txdatak              ((NLANES>3)?txdatak3   :1'b0),
            .A_txdetectrx           ((NLANES>3)?txdetectrx3:1'b0),
            .A_txelecidle           ((NLANES>3)?txelecidle3:1'b0),

            .B_phystatus            (rp_phystatus3_ext ),
            .B_rxdata               (rp_rxdata3_ext    ),
            .B_rxdatak              (rp_rxdatak3_ext   ),
            .B_rxelecidle           (rp_rxelecidle3_ext),
            .B_rxpolarity           (rp_rxpolarity3_ext),
            .B_rxstatus             (rp_rxstatus3_ext  ),
            .B_rxvalid              (rp_rxvalid3_ext   ),
            .B_powerdown            (rp_powerdown3_ext ),
            .B_txcompl              (rp_txcompl3_ext   ),
            .B_txdata               (rp_txdata3_ext    ),
            .B_txdatak              (rp_txdatak3_ext   ),
            .B_txdetectrx           (rp_txdetectrx3_ext),
            .B_txelecidle           (rp_txelecidle3_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus4 ;
      wire [7:0] irxdata4    ;
      wire       irxdatak4   ;
      wire       irxelecidle4;
      wire [2:0] irxstatus4  ;
      wire       irxvalid4   ;

      assign phystatus4 = (NLANES>7)?iphystatus4 :open_wire[0];
      assign rxdata4    = (NLANES>7)?irxdata4    :open_wire[7:0];
      assign rxdatak4   = (NLANES>7)?irxdatak4   :open_wire[0];
      assign rxelecidle4= (NLANES>7)?irxelecidle4:open_wire[0];
      assign rxstatus4  = (NLANES>7)?irxstatus4  :open_wire[2:0];
      assign rxvalid4   = (NLANES>7)?irxvalid4   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 4)
                  ) lane4 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[4]:1'b0),
            .A_phystatus            (iphystatus4 ),
            .A_rxdata               (irxdata4    ),
            .A_rxdatak              (irxdatak4   ),
            .A_rxelecidle           (irxelecidle4),
            .A_rxstatus             (irxstatus4  ),
            .A_rxvalid              (irxvalid4   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity4:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown4 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl4   :1'b0),
            .A_txdata               ((NLANES>7)?txdata4    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak4   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx4:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle4:1'b0),

            .B_phystatus            (rp_phystatus4_ext ),
            .B_rxdata               (rp_rxdata4_ext    ),
            .B_rxdatak              (rp_rxdatak4_ext   ),
            .B_rxelecidle           (rp_rxelecidle4_ext),
            .B_rxpolarity           (rp_rxpolarity4_ext),
            .B_rxstatus             (rp_rxstatus4_ext  ),
            .B_rxvalid              (rp_rxvalid4_ext   ),
            .B_powerdown            (rp_powerdown4_ext ),
            .B_txcompl              (rp_txcompl4_ext   ),
            .B_txdata               (rp_txdata4_ext    ),
            .B_txdatak              (rp_txdatak4_ext   ),
            .B_txdetectrx           (rp_txdetectrx4_ext),
            .B_txelecidle           (rp_txelecidle4_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );



      wire       iphystatus5 ;
      wire [7:0] irxdata5    ;
      wire       irxdatak5   ;
      wire       irxelecidle5;
      wire [2:0] irxstatus5  ;
      wire       irxvalid5   ;

      assign phystatus5 = (NLANES>7)?iphystatus5 :open_wire[0];
      assign rxdata5    = (NLANES>7)?irxdata5    :open_wire[7:0];
      assign rxdatak5   = (NLANES>7)?irxdatak5   :open_wire[0];
      assign rxelecidle5= (NLANES>7)?irxelecidle5:open_wire[0];
      assign rxstatus5  = (NLANES>7)?irxstatus5  :open_wire[2:0];
      assign rxvalid5   = (NLANES>7)?irxvalid5   :open_wire[0];


      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 5)
                  ) lane5 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[5]:1'b0),
            .A_phystatus            (iphystatus5 ),
            .A_rxdata               (irxdata5    ),
            .A_rxdatak              (irxdatak5   ),
            .A_rxelecidle           (irxelecidle5),
            .A_rxstatus             (irxstatus5  ),
            .A_rxvalid              (irxvalid5   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity5:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown5 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl5   :1'b0),
            .A_txdata               ((NLANES>7)?txdata5    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak5   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx5:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle5:1'b0),

            .B_phystatus            (rp_phystatus5_ext ),
            .B_rxdata               (rp_rxdata5_ext    ),
            .B_rxdatak              (rp_rxdatak5_ext   ),
            .B_rxelecidle           (rp_rxelecidle5_ext),
            .B_rxpolarity           (rp_rxpolarity5_ext),
            .B_rxstatus             (rp_rxstatus5_ext  ),
            .B_rxvalid              (rp_rxvalid5_ext   ),
            .B_powerdown            (rp_powerdown5_ext ),
            .B_txcompl              (rp_txcompl5_ext   ),
            .B_txdata               (rp_txdata5_ext    ),
            .B_txdatak              (rp_txdatak5_ext   ),
            .B_txdetectrx           (rp_txdetectrx5_ext),
            .B_txelecidle           (rp_txelecidle5_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );


      wire       iphystatus6 ;
      wire [7:0] irxdata6    ;
      wire       irxdatak6   ;
      wire       irxelecidle6;
      wire [2:0] irxstatus6  ;
      wire       irxvalid6   ;

      assign phystatus6 = (NLANES>7)?iphystatus6 :open_wire[0];
      assign rxdata6    = (NLANES>7)?irxdata6    :open_wire[7:0];
      assign rxdatak6   = (NLANES>7)?irxdatak6   :open_wire[0];
      assign rxelecidle6= (NLANES>7)?irxelecidle6:open_wire[0];
      assign rxstatus6  = (NLANES>7)?irxstatus6  :open_wire[2:0];
      assign rxvalid6   = (NLANES>7)?irxvalid6   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 6)
                  ) lane6 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[6]:1'b0),
            .A_phystatus            (iphystatus6 ),
            .A_rxdata               (irxdata6    ),
            .A_rxdatak              (irxdatak6   ),
            .A_rxelecidle           (irxelecidle6),
            .A_rxstatus             (irxstatus6  ),
            .A_rxvalid              (irxvalid6   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity6:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown6 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl6   :1'b0),
            .A_txdata               ((NLANES>7)?txdata6    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak6   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx6:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle6:1'b0),

            .B_phystatus            (rp_phystatus6_ext ),
            .B_rxdata               (rp_rxdata6_ext    ),
            .B_rxdatak              (rp_rxdatak6_ext   ),
            .B_rxelecidle           (rp_rxelecidle6_ext),
            .B_rxpolarity           (rp_rxpolarity6_ext),
            .B_rxstatus             (rp_rxstatus6_ext  ),
            .B_rxvalid              (rp_rxvalid6_ext   ),
            .B_powerdown            (rp_powerdown6_ext ),
            .B_txcompl              (rp_txcompl6_ext   ),
            .B_txdata               (rp_txdata6_ext    ),
            .B_txdatak              (rp_txdatak6_ext   ),
            .B_txdetectrx           (rp_txdetectrx6_ext),
            .B_txelecidle           (rp_txelecidle6_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

      wire       iphystatus7 ;
      wire [7:0] irxdata7    ;
      wire       irxdatak7   ;
      wire       irxelecidle7;
      wire [2:0] irxstatus7  ;
      wire       irxvalid7   ;

      assign phystatus7 = (NLANES>7)?iphystatus7 :open_wire[0];
      assign rxdata7    = (NLANES>7)?irxdata7    :open_wire[7:0];
      assign rxdatak7   = (NLANES>7)?irxdatak7   :open_wire[0];
      assign rxelecidle7= (NLANES>7)?irxelecidle7:open_wire[0];
      assign rxstatus7  = (NLANES>7)?irxstatus7  :open_wire[2:0];
      assign rxvalid7   = (NLANES>7)?irxvalid7   :open_wire[0];

      altpcietb_pipe_phy # (
            .APIPE_WIDTH            ( 8),
            .BPIPE_WIDTH            ( 8),
            .LANE_NUM               ( 7)
                  ) lane7 (
            .A_rate                 (sim_pipe_rate[0]  ),
            .pclk_a                 (sim_pipe_pclk_in),
            .A_lane_conn            ((NLANES>7)?connected_bits[7] : 1'b0),
            .A_phystatus            (iphystatus7 ),
            .A_rxdata               (irxdata7    ),
            .A_rxdatak              (irxdatak7   ),
            .A_rxelecidle           (irxelecidle7),
            .A_rxstatus             (irxstatus7  ),
            .A_rxvalid              (irxvalid7   ),
            .A_rxpolarity           ((NLANES>7)?rxpolarity7:1'b0),
            .A_powerdown            ((NLANES>7)?powerdown7 :2'h0),
            .A_txcompl              ((NLANES>7)?txcompl7   :1'b0),
            .A_txdata               ((NLANES>7)?txdata7    :8'h0),
            .A_txdatak              ((NLANES>7)?txdatak7   :1'b0),
            .A_txdetectrx           ((NLANES>7)?txdetectrx7:1'b0),
            .A_txelecidle           ((NLANES>7)?txelecidle7:1'b0),

            .B_phystatus            (rp_phystatus7_ext ),
            .B_rxdata               (rp_rxdata7_ext    ),
            .B_rxdatak              (rp_rxdatak7_ext   ),
            .B_rxelecidle           (rp_rxelecidle7_ext),
            .B_rxpolarity           (rp_rxpolarity7_ext),
            .B_rxstatus             (rp_rxstatus7_ext  ),
            .B_rxvalid              (rp_rxvalid7_ext   ),
            .B_powerdown            (rp_powerdown7_ext ),
            .B_txcompl              (rp_txcompl7_ext   ),
            .B_txdata               (rp_txdata7_ext    ),
            .B_txdatak              (rp_txdatak7_ext   ),
            .B_txdetectrx           (rp_txdetectrx7_ext),
            .B_txelecidle           (rp_txelecidle7_ext),
            .B_lane_conn            (1'b1),
            .B_rate                 (rp_rate            ),
            .pclk_b                 (pclk_pipe_rp),
            .pipe_mode              (simu_mode_pipe),
            .resetn                 (npor)
             );

   assign pclk_pipe_rp       = (rp_rate == 1'b1         ) ?  sim_pipe_clk500_out : sim_pipe_clk250_out;

endmodule

