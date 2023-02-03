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

// Stratix V Hard IP PIPE 32-bit interface
// Reference : PHY Interface for the PCI Express Architecture specification v2.00 and higher
//
module altpcietb_pipe32_hip_interface (
      output nop_out
);

// PIPE interface signals
reg [17:0]     currentcoeff0      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff1      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff2      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff3      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff4      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff5      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff6      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [17:0]     currentcoeff7      ;//  HIP output  : Used for G3 only - set coefficient  .
reg [2:0]      currentrxpreset0   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset1   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset2   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset3   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset4   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset5   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset6   ;//  HIP output  : Used for G3 only - set preset  .
reg [2:0]      currentrxpreset7   ;//  HIP output  : Used for G3 only - set preset  .
reg [1:0]      rate0              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate1              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate2              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate3              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate4              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate5              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate6              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [1:0]      rate7              ;//  HIP output  : Indicates G1/G2/G3 rate.
reg [2:0]      eidleinfersel0     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel1     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel2     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel3     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel4     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel5     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel6     ;//  HIP output  : Electrical IDLE infer.
reg [2:0]      eidleinfersel7     ;//  HIP output  : Electrical IDLE infer.

// interface with the PHY PCS Lane 0
reg [31:0]     txdata0            ;//  HIP output  : .
reg [3:0]      txdatak0           ;//  HIP output  : .
reg            txdetectrx0        ;//  HIP output  : .
reg            txelecidle0        ;//  HIP output  : .
reg            txcompl0           ;//  HIP output  : .
reg            rxpolarity0        ;//  HIP output  : .
reg [1:0]      powerdown0         ;//  HIP output  : .
reg            txdataskip0        ;//  HIP output  : .
reg            txblkst0           ;//  HIP output  : .
reg [1:0]      txsynchd0          ;//  HIP output  : .
reg            txdeemph0          ;//  HIP output  : .
reg [2:0]      txmargin0          ;//  HIP output  : .
reg            txswing0           ;//  HIP output  : .

reg  [31:0]    rxdata0            ;//  HIP input   : .
reg  [3:0]     rxdatak0           ;//  HIP input   : .
reg            rxvalid0           ;//  HIP input   : .
reg            phystatus0         ;//  HIP input   : .
reg            rxelecidle0        ;//  HIP input   : .
reg  [2:0]     rxstatus0          ;//  HIP input   : .
reg            rxdataskip0        ;//  HIP input   : .
reg            rxblkst0           ;//  HIP input   : .
reg  [1:0]     rxsynchd0          ;//  HIP input   : .

// interface with the PHY PCS Lane 1
reg [31:0]     txdata1            ;//  HIP output  : .
reg [3:0]      txdatak1           ;//  HIP output  : .
reg            txdetectrx1        ;//  HIP output  : .
reg            txelecidle1        ;//  HIP output  : .
reg            txcompl1           ;//  HIP output  : .
reg            rxpolarity1        ;//  HIP output  : .
reg [1:0]      powerdown1         ;//  HIP output  : .
reg            txdataskip1        ;//  HIP output  : .
reg            txblkst1           ;//  HIP output  : .
reg [1:0]      txsynchd1          ;//  HIP output  : .
reg            txdeemph1          ;//  HIP output  : .
reg [2:0]      txmargin1          ;//  HIP output  : .
reg            txswing1           ;//  HIP output  : .

reg  [31:0]    rxdata1            ;//  HIP input   : .
reg  [3:0]     rxdatak1           ;//  HIP input   : .
reg            rxvalid1           ;//  HIP input   : .
reg            phystatus1         ;//  HIP input   : .
reg            rxelecidle1        ;//  HIP input   : .
reg  [2:0]     rxstatus1          ;//  HIP input   : .
reg            rxdataskip1        ;//  HIP input   : .
reg            rxblkst1           ;//  HIP input   : .
reg  [1:0]     rxsynchd1          ;//  HIP input   : .

// interface with the PHY PCS Lane 2
reg [31:0]     txdata2            ;//  HIP output  : .
reg [3:0]      txdatak2           ;//  HIP output  : .
reg            txdetectrx2        ;//  HIP output  : .
reg            txelecidle2        ;//  HIP output  : .
reg            txcompl2           ;//  HIP output  : .
reg            rxpolarity2        ;//  HIP output  : .
reg [1:0]      powerdown2         ;//  HIP output  : .
reg            txdataskip2        ;//  HIP output  : .
reg            txblkst2           ;//  HIP output  : .
reg [1:0]      txsynchd2          ;//  HIP output  : .
reg            txdeemph2          ;//  HIP output  : .
reg [2:0]      txmargin2          ;//  HIP output  : .
reg            txswing2           ;//  HIP output  : .

reg  [31:0]    rxdata2            ;//  HIP input   : .
reg  [3:0]     rxdatak2           ;//  HIP input   : .
reg            rxvalid2           ;//  HIP input   : .
reg            phystatus2         ;//  HIP input   : .
reg            rxelecidle2        ;//  HIP input   : .
reg  [2:0]     rxstatus2          ;//  HIP input   : .
reg            rxdataskip2        ;//  HIP input   : .
reg            rxblkst2           ;//  HIP input   : .
reg  [1:0]     rxsynchd2          ;//  HIP input   : .

// interface with the PHY PCS Lane 3
reg [31:0]     txdata3            ;//  HIP output  : .
reg [3:0]      txdatak3           ;//  HIP output  : .
reg            txdetectrx3        ;//  HIP output  : .
reg            txelecidle3        ;//  HIP output  : .
reg            txcompl3           ;//  HIP output  : .
reg            rxpolarity3        ;//  HIP output  : .
reg [1:0]      powerdown3         ;//  HIP output  : .
reg            txdataskip3        ;//  HIP output  : .
reg            txblkst3           ;//  HIP output  : .
reg [1:0]      txsynchd3          ;//  HIP output  : .
reg            txdeemph3          ;//  HIP output  : .
reg [2:0]      txmargin3          ;//  HIP output  : .
reg            txswing3           ;//  HIP output  : .

reg  [31:0]    rxdata3            ;//  HIP input   : .
reg  [3:0]     rxdatak3           ;//  HIP input   : .
reg            rxvalid3           ;//  HIP input   : .
reg            phystatus3         ;//  HIP input   : .
reg            rxelecidle3        ;//  HIP input   : .
reg  [2:0]     rxstatus3          ;//  HIP input   : .
reg            rxdataskip3        ;//  HIP input   : .
reg            rxblkst3           ;//  HIP input   : .
reg  [1:0]     rxsynchd3          ;//  HIP input   : .

// interface with the PHY PCS Lane 4
reg [31:0]     txdata4            ;//  HIP output  : .
reg [3:0]      txdatak4           ;//  HIP output  : .
reg            txdetectrx4        ;//  HIP output  : .
reg            txelecidle4        ;//  HIP output  : .
reg            txcompl4           ;//  HIP output  : .
reg            rxpolarity4        ;//  HIP output  : .
reg [1:0]      powerdown4         ;//  HIP output  : .
reg            txdataskip4        ;//  HIP output  : .
reg            txblkst4           ;//  HIP output  : .
reg [1:0]      txsynchd4          ;//  HIP output  : .
reg            txdeemph4          ;//  HIP output  : .
reg [2:0]      txmargin4          ;//  HIP output  : .
reg            txswing4           ;//  HIP output  : .

reg  [31:0]    rxdata4            ;//  HIP input   : .
reg  [3:0]     rxdatak4           ;//  HIP input   : .
reg            rxvalid4           ;//  HIP input   : .
reg            phystatus4         ;//  HIP input   : .
reg            rxelecidle4        ;//  HIP input   : .
reg  [2:0]     rxstatus4          ;//  HIP input   : .
reg            rxdataskip4        ;//  HIP input   : .
reg            rxblkst4           ;//  HIP input   : .
reg  [1:0]     rxsynchd4          ;//  HIP input   : .

// interface with the PHY PCS Lane 5
reg [31:0]     txdata5            ;//  HIP output  : .
reg [3:0]      txdatak5           ;//  HIP output  : .
reg            txdetectrx5        ;//  HIP output  : .
reg            txelecidle5        ;//  HIP output  : .
reg            txcompl5           ;//  HIP output  : .
reg            rxpolarity5        ;//  HIP output  : .
reg [1:0]      powerdown5         ;//  HIP output  : .
reg            txdataskip5        ;//  HIP output  : .
reg            txblkst5           ;//  HIP output  : .
reg [1:0]      txsynchd5          ;//  HIP output  : .
reg            txdeemph5          ;//  HIP output  : .
reg [2:0]      txmargin5          ;//  HIP output  : .
reg            txswing5           ;//  HIP output  : .

reg  [31:0]    rxdata5            ;//  HIP input   : .
reg  [3:0]     rxdatak5           ;//  HIP input   : .
reg            rxvalid5           ;//  HIP input   : .
reg            phystatus5         ;//  HIP input   : .
reg            rxelecidle5        ;//  HIP input   : .
reg  [2:0]     rxstatus5          ;//  HIP input   : .
reg            rxdataskip5        ;//  HIP input   : .
reg            rxblkst5           ;//  HIP input   : .
reg  [1:0]     rxsynchd5          ;//  HIP input   : .

// interface with the PHY PCS Lane 6
reg [31:0]     txdata6            ;//  HIP output  : .
reg [3:0]      txdatak6           ;//  HIP output  : .
reg            txdetectrx6        ;//  HIP output  : .
reg            txelecidle6        ;//  HIP output  : .
reg            txcompl6           ;//  HIP output  : .
reg            rxpolarity6        ;//  HIP output  : .
reg [1:0]      powerdown6         ;//  HIP output  : .
reg            txdataskip6        ;//  HIP output  : .
reg            txblkst6           ;//  HIP output  : .
reg [1:0]      txsynchd6          ;//  HIP output  : .
reg            txdeemph6          ;//  HIP output  : .
reg [2:0]      txmargin6          ;//  HIP output  : .
reg            txswing6           ;//  HIP output  : .

reg  [31:0]    rxdata6            ;//  HIP input   : .
reg  [3:0]     rxdatak6           ;//  HIP input   : .
reg            rxvalid6           ;//  HIP input   : .
reg            phystatus6         ;//  HIP input   : .
reg            rxelecidle6        ;//  HIP input   : .
reg  [2:0]     rxstatus6          ;//  HIP input   : .
reg            rxdataskip6        ;//  HIP input   : .
reg            rxblkst6           ;//  HIP input   : .
reg  [1:0]     rxsynchd6          ;//  HIP input   : .

// interface with the PHY PCS Lane 7
reg [31:0]     txdata7            ;//  HIP output  : .
reg [3:0]      txdatak7           ;//  HIP output  : .
reg            txdetectrx7        ;//  HIP output  : .
reg            txelecidle7        ;//  HIP output  : .
reg            txcompl7           ;//  HIP output  : .
reg            rxpolarity7        ;//  HIP output  : .
reg [1:0]      powerdown7         ;//  HIP output  : .
reg            txdataskip7        ;//  HIP output  : .
reg            txblkst7           ;//  HIP output  : .
reg [1:0]      txsynchd7          ;//  HIP output  : .
reg            txdeemph7          ;//  HIP output  : .
reg [2:0]      txmargin7          ;//  HIP output  : .
reg            txswing7           ;//  HIP output  : .

reg  [31:0]    rxdata7            ;//  HIP input   : .
reg  [3:0]     rxdatak7           ;//  HIP input   : .
reg            rxvalid7           ;//  HIP input   : .
reg            phystatus7         ;//  HIP input   : .
reg            rxelecidle7        ;//  HIP input   : .
reg  [2:0]     rxstatus7          ;//  HIP input   : .
reg            rxdataskip7        ;//  HIP input   : .
reg            rxblkst7           ;//  HIP input   : .
reg  [1:0]     rxsynchd7          ;//  HIP input   : .

reg            pipe_pclk          ;

reg 	       mask_tx_pll_lock   ;//  HIP input  

assign nop_out = 1'b0; // no op


endmodule
