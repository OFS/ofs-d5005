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


`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express PIPE PHY connector
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_pipe_phy.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This function interconnects two PIPE MAC interfaces for a single lane.
// For now this uses a common PCLK for both interfaces, an enhancement woudl be
// to support separate PCLK's for each interface with the requisite elastic
// buffer.
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_pipe_phy (pclk_a, pclk_b, resetn, pipe_mode, A_lane_conn, B_lane_conn, A_txdata, A_txdatak, A_txdetectrx, A_txelecidle, A_txcompl, A_rxpolarity, A_powerdown, A_rxdata, A_rxdatak, A_rxvalid, A_phystatus, A_rxelecidle, A_rxstatus, B_txdata, B_txdatak, B_txdetectrx, B_txelecidle, B_txcompl, B_rxpolarity, B_powerdown, B_rxdata, B_rxdatak, B_rxvalid, B_phystatus, B_rxelecidle, B_rxstatus,B_rate,A_rate);

   parameter APIPE_WIDTH  = 16;
   parameter BPIPE_WIDTH  = 16;
   parameter LANE_NUM  = 0;
   parameter A_MAC_NAME  = "EP";
   parameter B_MAC_NAME  = "RP";
   // Latency should be 2 or greater
   parameter LATENCY = 23;
   input pclk_a;
   input pclk_b;
   input resetn;
   input pipe_mode;
   input A_lane_conn;
   input B_lane_conn;
input    A_rate;
input    B_rate;
   input[APIPE_WIDTH - 1:0] A_txdata;
   input[(APIPE_WIDTH / 8) - 1:0] A_txdatak;
   input A_txdetectrx;
   input A_txelecidle;
   input A_txcompl;
   input A_rxpolarity;
   input[1:0] A_powerdown;
   output[APIPE_WIDTH - 1:0] A_rxdata;
   wire[APIPE_WIDTH - 1:0] A_rxdata;
   output[(APIPE_WIDTH / 8) - 1:0] A_rxdatak;
   wire[(APIPE_WIDTH / 8) - 1:0] A_rxdatak;
   output A_rxvalid;
   wire A_rxvalid;
   output A_phystatus;
   wire A_phystatus;
   output A_rxelecidle;
   wire A_rxelecidle;
   output[2:0] A_rxstatus;
   wire[2:0] A_rxstatus;
   input[BPIPE_WIDTH - 1:0] B_txdata;
   input[(BPIPE_WIDTH / 8) - 1:0] B_txdatak;
   input B_txdetectrx;
   input B_txelecidle;
   input B_txcompl;
   input B_rxpolarity;
   input[1:0] B_powerdown;
   output[BPIPE_WIDTH - 1:0] B_rxdata;
   output[(BPIPE_WIDTH / 8) - 1:0] B_rxdatak;
   output B_rxvalid;
   wire[BPIPE_WIDTH - 1:0] B_rxdata_i;
   wire [(BPIPE_WIDTH / 8) - 1:0] B_rxdatak_i;
   wire B_rxvalid_i;
   output B_phystatus;
   wire B_phystatus;
   output B_rxelecidle;
   wire B_rxelecidle;
   output[2:0] B_rxstatus;
   wire[2:0] B_rxstatus;

   wire[APIPE_WIDTH - 1:0] A2B_data;
   wire[(APIPE_WIDTH / 8) - 1:0] A2B_datak;
   wire A2B_elecidle;

   wire[APIPE_WIDTH - 1:0] B2A_data;
   wire[(APIPE_WIDTH / 8) - 1:0] B2A_datak;
   wire B2A_elecidle;

   // For a 250MHz 8-Bit PIPE the fifo needs to be 2x the length for the same latency
   // Add latency on B side only because it is interface to RP which has a known
   // interface of 250Mhz SDR 8 bit
   localparam FIFO_LENGTH = LATENCY * (16/BPIPE_WIDTH);
   reg [FIFO_LENGTH * BPIPE_WIDTH - 1:0] B_txdata_shift;
   reg [FIFO_LENGTH * BPIPE_WIDTH - 1:0] B_rxdata_shift;
   reg[FIFO_LENGTH - 1:0] B_rxvalid_shift;
   reg[FIFO_LENGTH * (BPIPE_WIDTH / 8) - 1:0] B_txdatak_shift;
   reg[FIFO_LENGTH * (BPIPE_WIDTH / 8) - 1:0] B_rxdatak_shift;
   reg[FIFO_LENGTH - 1:0] B_txelecidle_shift;

   assign B_rxdata = B_rxdata_shift[FIFO_LENGTH * BPIPE_WIDTH - 1: (FIFO_LENGTH - 1) * BPIPE_WIDTH];
   assign B_rxdatak = B_rxdatak_shift[FIFO_LENGTH * (BPIPE_WIDTH/8) - 1: (FIFO_LENGTH - 1) * (BPIPE_WIDTH/8)];
   assign B_rxvalid = B_rxvalid_shift[FIFO_LENGTH-1];

// Shift register to add latency between the pipe to pipe connection.
// Length of the shift registers scales with the length of the desired latency.
   always @(negedge resetn or posedge pclk_b)
   begin
      if (resetn == 1'b0)
      begin
         B_rxdata_shift     <= {(FIFO_LENGTH *  BPIPE_WIDTH)   {1'b0}};
         B_rxdatak_shift    <= {(FIFO_LENGTH * (BPIPE_WIDTH/8)){1'b0}};
         B_rxvalid_shift    <= { FIFO_LENGTH                   {1'b0}};
         B_txdata_shift     <= {(FIFO_LENGTH *  BPIPE_WIDTH)   {1'b0}};
         B_txdatak_shift    <= {(FIFO_LENGTH * (BPIPE_WIDTH/8)){1'b0}};
         B_txelecidle_shift <= { FIFO_LENGTH                   {1'b1}};
      end
      else
      begin
         B_rxdata_shift     <= {    B_rxdata_shift[FIFO_LENGTH *  BPIPE_WIDTH    - 1:0], B_rxdata_i };
         B_rxdatak_shift    <= {   B_rxdatak_shift[FIFO_LENGTH * (BPIPE_WIDTH/8) - 1:0], B_rxdatak_i};
         B_rxvalid_shift <= {B_rxvalid_shift[FIFO_LENGTH - 1: 0], B_rxvalid_i};
         B_txdata_shift     <= {    B_txdata_shift[FIFO_LENGTH *  BPIPE_WIDTH    - 1:0], B_txdata };
         B_txdatak_shift    <= {   B_txdatak_shift[FIFO_LENGTH * (BPIPE_WIDTH/8) - 1:0], B_txdatak};
         B_txelecidle_shift <= {B_txelecidle_shift[FIFO_LENGTH - 1: 0], B_txelecidle};
      end
   end

   altpcietb_pipe_xtx2yrx #(APIPE_WIDTH, APIPE_WIDTH, LANE_NUM, A_MAC_NAME) A2B(
      .X_lane_conn(A_lane_conn),
      .Y_lane_conn(B_lane_conn),
      .pclk(pclk_a),
      .resetn(resetn),
      .pipe_mode(pipe_mode),
      .X_txdata(A_txdata),
      .X_txdatak(A_txdatak),
      .X_txdetectrx(A_txdetectrx),
      .X_rate(A_rate),
      .X_txelecidle(A_txelecidle),
      .X_txcompl(A_txcompl),
      .X_rxpolarity(A_rxpolarity),
      .X_powerdown(A_powerdown),
      .X_rxdata(A_rxdata),
      .X_rxdatak(A_rxdatak),
      .X_rxvalid(A_rxvalid),
      .X_phystatus(A_phystatus),
      .X_rxelecidle(A_rxelecidle),
      .X_rxstatus(A_rxstatus),
      .X2Y_data(A2B_data),
      .X2Y_datak(A2B_datak),
      .X2Y_elecidle(A2B_elecidle),
      .Y2X_data(B2A_data),
      .Y2X_datak(B2A_datak),
      .Y2X_elecidle(B2A_elecidle)
   );

   altpcietb_pipe_xtx2yrx #(BPIPE_WIDTH, APIPE_WIDTH, LANE_NUM, B_MAC_NAME) B2A(
      .X_lane_conn(B_lane_conn),
      .Y_lane_conn(A_lane_conn),
      .pclk(pclk_b),
      .resetn(resetn),
      .pipe_mode(pipe_mode),
      .X_txdata(B_txdata_shift[FIFO_LENGTH * BPIPE_WIDTH - 1: (FIFO_LENGTH - 1) * BPIPE_WIDTH]),
      .X_txdatak(B_txdatak_shift[FIFO_LENGTH * (BPIPE_WIDTH/8) - 1: (FIFO_LENGTH - 1) * (BPIPE_WIDTH/8)]),
      .X_txdetectrx(B_txdetectrx),
      .X_rate(B_rate),
      .X_txelecidle(B_txelecidle_shift[FIFO_LENGTH - 1]),
      .X_txcompl(B_txcompl),
      .X_rxpolarity(B_rxpolarity),
      .X_powerdown(B_powerdown),
      .X_rxdata(B_rxdata_i),
      .X_rxdatak(B_rxdatak_i),
      .X_rxvalid(B_rxvalid_i),
      .X_phystatus(B_phystatus),
      .X_rxelecidle(B_rxelecidle),
      .X_rxstatus(B_rxstatus),
      .X2Y_data(B2A_data),
      .X2Y_datak(B2A_datak),
      .X2Y_elecidle(B2A_elecidle),
      .Y2X_data(A2B_data),
      .Y2X_datak(A2B_datak),
      .Y2X_elecidle(A2B_elecidle)
   );
endmodule
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express PIPE PHY single direction connector
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_pipe_xtx2yrx.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This function provides a single direction connection from the "X" side
// transmitter to the "Y" side receiver.
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_pipe_xtx2yrx (X_lane_conn, Y_lane_conn, pclk, resetn, pipe_mode, X_txdata, X_txdatak, X_txdetectrx, X_txelecidle, X_txcompl, X_rxpolarity, X_powerdown, X_rxdata, X_rxdatak, X_rxvalid, X_phystatus, X_rxelecidle, X_rxstatus, X2Y_data, X2Y_datak, X2Y_elecidle, Y2X_data, Y2X_datak, Y2X_elecidle,X_rate);

parameter XPIPE_WIDTH  = 16;
parameter YPIPE_WIDTH  = 16;
parameter LANE_NUM  = 0;
parameter X_MAC_NAME  = "EP";

input     X_lane_conn;
input     Y_lane_conn;
input     pclk;
input     resetn;
input     pipe_mode;
input [XPIPE_WIDTH - 1:0] X_txdata;
input [(XPIPE_WIDTH / 8) - 1:0] X_txdatak;
input                           X_txdetectrx;
input                           X_txelecidle;
input                           X_txcompl;
input                           X_rate;
input                           X_rxpolarity;
input [1:0]                     X_powerdown;
output [XPIPE_WIDTH - 1:0]      X_rxdata;
reg [XPIPE_WIDTH - 1:0]         X_rxdata;
output [(XPIPE_WIDTH / 8) - 1:0] X_rxdatak;
reg [(XPIPE_WIDTH / 8) - 1:0]    X_rxdatak;
output                           X_rxvalid;
reg                              X_rxvalid;
output                           X_phystatus;
reg                              X_phystatus;
output                           X_rxelecidle;
reg                              X_rxelecidle;
output [2:0]                     X_rxstatus;
reg [2:0]                        X_rxstatus;
output [YPIPE_WIDTH - 1:0]       X2Y_data;
reg [YPIPE_WIDTH - 1:0]          X2Y_data;
output [(YPIPE_WIDTH / 8) - 1:0] X2Y_datak;
reg [(YPIPE_WIDTH / 8) - 1:0]    X2Y_datak;
output                           X2Y_elecidle;
reg                              X2Y_elecidle;
input [YPIPE_WIDTH - 1:0]        Y2X_data;
input [(YPIPE_WIDTH / 8) - 1:0]  Y2X_datak;
input                            Y2X_elecidle;

parameter [3:0]                  P0 = 0;
parameter [3:0]                  P0_ENT = 1;
parameter [3:0]                  P0s = 2;
parameter [3:0]                  P0s_ENT = 3;
parameter [3:0]                  P1 = 4;
parameter [3:0]                  P1_DET = 5;
parameter [3:0]                  P1_ENT = 10;
parameter [3:0]                  P2 = 11;
parameter [3:0]                  P2_ENT = 12;
parameter [3:0]                  NOT_IN_USE = 13;
reg [3:0]                        phy_state;
reg                              resetn_q1;
reg                              resetn_q2;
reg                              count;
reg                              sync;

reg [YPIPE_WIDTH - 1:0]          X_txdata_y;
reg [(YPIPE_WIDTH / 8) - 1:0]    X_txdatak_y;
reg [YPIPE_WIDTH - 1:0]          X_rxdata_y;
reg [YPIPE_WIDTH - 1:0]          X_rxdata_y_tmp;
reg [(YPIPE_WIDTH / 8) - 1:0]    X_rxdatak_y;
reg [7:0]                        X_txdata_tmp;
reg                              X_txdatak_tmp;
reg [3:0]                        detect_cnt;

reg                              dummy ;
reg                              X_rate_r;

initial
  begin
  phy_state <= P1;
  resetn_q1 <= 1'b0;
  resetn_q2 <= 1'b1;
  count <= 1'b0;
  sync <= 1'b0;
  end



//        -----------------------------------------------------------------------
//        -- The assumption of the logic below is that pclk will run 2x the speed
//        -- of the incoming data. The count signal needs to be 0 on the 1st
//        -- cycle and 1 on the 2nd cycle
//
//        -- Hdata16         BB  BB  DD  DD
//        -- Ldata16         AA  AA  CC  CC
//        -- count            0   1   0   1
//        -- data8                AA  BB  CC etc..
//
//        -----------------------------------------------------------------------

generate if (XPIPE_WIDTH < YPIPE_WIDTH) //  X(8) => Y (16)
  always @(pclk)
    begin : conversion_8to16
    if (pclk == 1'b1)
      begin
      X_rxdata_y_tmp <= X_rxdata_y;

      if (sync == 1'b1)
        begin
        count <= ~count ;
        end
      else if (sync == 1'b0 & (X_rxdata_y_tmp == X_rxdata_y) &
               ((X_rxdatak_y[0] == 1'b1) || (X_rxdatak_y[1] == 1'b1)))
        begin
        count <= 1'b0 ;
        sync <= 1'b1 ;
        end
      if (count == 1'b0)
        begin
        X_txdata_tmp <= X_txdata ;
        X_txdatak_tmp <= X_txdatak[0] ;
        X_rxdata <= X_rxdata_y[7:0] ;
        X_rxdatak <= X_rxdatak_y[0:0] ;
        end
      else
        begin
        X_txdata_y <= {X_txdata, X_txdata_tmp} ;
        X_txdatak_y <= {X_txdatak[0:0], X_txdatak_tmp} ;
        X_rxdata <= X_rxdata_y[15:8] ;
        X_rxdatak <= X_rxdatak_y[1:1] ;
        end
      end
    end
endgenerate

generate if (XPIPE_WIDTH == YPIPE_WIDTH) //  direct mapping

  always @(pclk)
    begin: direct_map
    X_txdata_y  <= X_txdata;
    X_txdatak_y <= X_txdatak;
    X_rxdata    <= X_rxdata_y;
    X_rxdatak   <= X_rxdatak_y;
    end
endgenerate

always @(pclk)
  begin : reset_pipeline
  if (pclk == 1'b1)
    begin
    resetn_q2 <= resetn_q1 ;
    resetn_q1 <= resetn ;
    end
  end



   always @(pclk)
   begin : main_ctrl
      if (pclk == 1'b1)
      begin
         if ((resetn == 1'b0) | (resetn_q1 == 1'b0) | (resetn_q2 == 1'b0) | (X_lane_conn == 1'b0))
         begin
            if ((resetn == 1'b0) & (resetn_q1 == 1'b0) & (resetn_q2 == 1'b0) & (X_lane_conn == 1'b1) & (pipe_mode == 1'b1))
            begin
               if (X_txdetectrx == 1'b1)
               begin
                  $display("ERROR: TxDetectRx/Loopback not deasserted while reset asserted");
               end
               if (X_txdetectrx == 1'b1)
               begin
                  $display("ERROR: TxDetectRx/Loopback not deasserted while reset asserted");
               end
               if (X_txelecidle == 1'b0)
               begin
                  $display("ERROR: TxElecIdle not asserted while reset asserted");
               end
               if (X_txcompl == 1'b1)
               begin
                  $display("ERROR: TxCompliance not deasserted while reset asserted");
               end
               if (X_rxpolarity == 1'b1)
               begin
                  $display("ERROR: RxPolarity not deasserted while reset asserted");
               end
               if ((X_powerdown == 2'b00) | (X_powerdown == 2'b01) | (X_powerdown == 2'b11))
               begin
                  $display("ERROR: Powerdown not P1 while reset asserted" );
               end
            end
            if (pipe_mode == 1'b1)
            begin
               phy_state <= P1_ENT ;
            end
            else
            begin
               phy_state <= NOT_IN_USE ;
            end
            if (X_lane_conn == 1'b1)
              X_phystatus <= 1'b1 ;
            else
              X_phystatus <= X_txdetectrx ;
            X_rxvalid <= 1'b0 ;
            X_rxelecidle <= 1'b1 ;
            X_rxstatus <= 3'b100 ;
         X_rate_r <= 1'b0;
            X2Y_elecidle <= 1'b1 ;
         end
         else
           begin
           X_rate_r <= X_rate;
            case (phy_state)
               P0, P0_ENT :
                        begin
                           X2Y_elecidle <= X_txelecidle ;
                           if (phy_state == P0_ENT)
                           begin
                              X_phystatus <= 1'b1 ;
                           end
                           else
                           begin
                           if (X_rate != X_rate_r)
                             X_phystatus <= 1'b1;
                          else
                            X_phystatus <= 1'b0;
                           end

                           case (X_powerdown)
                              2'b00 :
                                       begin
                                          phy_state <= P0 ;
                                       end
                              2'b01 :
                                       begin
                                          phy_state <= P0s_ENT ;
                                       end
                              2'b10 :
                                       begin
                                          phy_state <= P1_ENT ;
                                       end
                              2'b11 :
                                       begin
                                          phy_state <= P2_ENT ;
                                       end
                              default :
                                       begin
                                          $display("ERROR:Illegal value of powerdown in P0 state");
                                       end
                           endcase
                           X_rxelecidle <= Y2X_elecidle ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxstatus <= 3'b100 ;
                              X_rxvalid <= 1'b0 ;
                           end
                           else
                           begin
                              X_rxstatus <= 3'b000 ;
                              X_rxvalid <= 1'b1 ;
                           end
                        end
               P0s, P0s_ENT :
                        begin
                           X2Y_elecidle <= 1'b1 ;
                           if (X_txelecidle != 1'b1)
                           begin
                              $display("ERROR:Txelecidle not asserted in P0s state");
                           end
                           if (phy_state == P0s_ENT)
                           begin
                              X_phystatus <= 1'b1 ;
                           end
                           else
                           begin
                              X_phystatus <= 1'b0 ;
                           end
                           case (X_powerdown)
                              2'b00 :
                                       begin
                                          phy_state <= P0 ;
                                       end
                              2'b01 :
                                       begin
                                          phy_state <= P0s ;
                                       end
                              default :
                                       begin
                                          $display("ERROR: Illegal value of powerdown in P0 state");
                                       end
                           endcase
                           X_rxelecidle <= Y2X_elecidle ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxstatus <= 3'b100 ;
                              X_rxvalid <= 1'b0 ;
                           end
                           else
                           begin
                              X_rxstatus <= 3'b000 ;
                              X_rxvalid <= 1'b1 ;
                           end
                        end
               P1, P1_ENT :
                        begin
                           X2Y_elecidle <= 1'b1 ;
                           if (X_txelecidle != 1'b1)
                           begin
                             $display("ERROR: Txelecidle not asserted in P1 state");
                           end
                           if (phy_state == P1_ENT)
                           begin
                              X_phystatus <= 1'b1 ;
                           end
                           else
                           begin
                              X_phystatus <= 1'b0 ;
                           end
                           case (X_powerdown)
                              2'b00 :
                                       begin
                                          phy_state <= P0_ENT ;
                                       end
                              2'b10 :
                                       begin
                                          if (X_txdetectrx == 1'b1)
                                          begin
                                             phy_state <= P1_DET ;
                                          detect_cnt <= 4'h4;
                                          end
                                          else
                                          begin
                                             phy_state <= P1 ;
                                          end
                                       end
                              default :
                                       begin
                                          $display("ERROR:Illegal value of powerdown in P1 state");
                                       end
                           endcase
                           X_rxelecidle <= Y2X_elecidle ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxstatus <= 3'b100 ;
                              X_rxvalid <= 1'b0 ;
                           end
                           else
                           begin
                              X_rxstatus <= 3'b000 ;
                              X_rxvalid <= 1'b1 ;
                           end
                        end
            P1_DET :
                        begin
                           if (X_powerdown != 2'b10)
                           begin
                              $display("WARNING: Tried to move out of P1 state in middle of Rx Detect");
                           end

                        if (detect_cnt > 4'h0)
                          detect_cnt <= detect_cnt - 1;

                           if (detect_cnt == 4'h1)
                           begin
                              X_phystatus <= 1'b1 ;
                              if (Y_lane_conn == 1'b1)
                              begin
                                 X_rxstatus <= 3'b011 ;
                              end
                              else
                              begin
                                 if (Y2X_elecidle == 1'b1)
                                 begin
                                    X_rxstatus <= 3'b100 ;
                                 end
                                 else
                                 begin
                                    X_rxstatus <= 3'b000 ;
                                 end
                              end
                           end
                           else
                           begin
                              X_phystatus <= 1'b0 ;
                              X_rxstatus <= 3'b000 ;
                           end
                        if (X_txdetectrx == 1'b0)
                          phy_state <= P1;
                           X_rxelecidle <= Y2X_elecidle ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxvalid <= 1'b0 ;
                           end
                           else
                           begin
                              X_rxvalid <= 1'b1 ;
                           end
                        end
               P2, P2_ENT :
                        begin
                           if (phy_state == P2_ENT)
                           begin
                              X_phystatus <= 1'b1 ;
                           end
                           else
                           begin
                              X_phystatus <= 1'b0 ;
                           end
                           X_rxvalid <= 1'b0 ;
                           X_rxstatus <= 3'b100 ;
                           X_rxelecidle <= Y2X_elecidle ;
                           X2Y_elecidle <= X_txelecidle ;
                           case (X_powerdown)
                              2'b11 :
                                       begin
                                          phy_state <= P2 ;
                                       end
                              2'b10 :
                                       begin
                                          phy_state <= P1_ENT ;
                                       end
                              default :
                                       begin
                                          $display("ERROR:Illegal value of powerdown in P2 state, Lane");
                                       end
                           endcase
                        end
               NOT_IN_USE :
                        begin
                           X_phystatus <= 1'b0 ;
                           X_rxvalid <= 1'b0 ;
                           X_rxstatus <= 3'b100 ;
                           X_rxelecidle <= Y2X_elecidle ;
                           X2Y_elecidle <= X_txelecidle ;
                           phy_state <= NOT_IN_USE ;
                        end
            endcase
         end
      end
   end

   always @(pclk)
   begin : main_data
   if ((resetn == 1'b0) | (resetn_q1 == 1'b0) | (resetn_q2 == 1'b0) | (X_lane_conn == 1'b0))
     begin
            X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
            X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
            X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
            X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;

         end
         else
         begin
            case (phy_state)
               P0, P0_ENT :
                        begin
                           if (X_txelecidle == 1'b0)
                           begin
                              if (X_txdetectrx == 1'b1)
                              begin
                                 X2Y_data <= Y2X_data ;
                                 X2Y_datak <= Y2X_datak ;
                              end
                              else
                              begin
                                 X2Y_data <= X_txdata_y ;
                                 X2Y_datak <= X_txdatak_y ;
                              end
                           end
                           else
                           begin
                              X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
                              X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;
                           end
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                              X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           end
                           else
                           begin
                              X_rxdatak_y <= Y2X_datak ;
                              X_rxdata_y <= Y2X_data ;
                           end
                        end
               P0s, P0s_ENT :
                        begin
                           X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                              X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           end
                           else
                           begin
                              X_rxdatak_y <= Y2X_datak ;
                              X_rxdata_y <= Y2X_data ;
                           end
                        end
               P1, P1_ENT :
                        begin
                           X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                              X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           end
                           else
                           begin
                              X_rxdatak_y <= Y2X_datak ;
                              X_rxdata_y <= Y2X_data ;
                           end
                        end
            P1_DET :
                        begin
                           if (Y2X_elecidle == 1'b1)
                           begin
                              X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                              X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           end
                           else
                           begin
                              X_rxdatak_y <= Y2X_datak ;
                              X_rxdata_y <= Y2X_data ;
                           end
                        end
               P2, P2_ENT :
                        begin
                           X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
                        end
               NOT_IN_USE :
                        begin
                           X_rxdata_y <= {YPIPE_WIDTH{1'bz}} ;
                           X_rxdatak_y <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_datak <= {YPIPE_WIDTH{1'bz}} ;
                           X2Y_data <= {YPIPE_WIDTH{1'bz}} ;
                        end
            endcase
         end
   end
endmodule
