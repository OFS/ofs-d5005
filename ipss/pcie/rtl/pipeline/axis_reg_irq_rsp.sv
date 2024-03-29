// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// AXIS IRQ response pipeline register
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;

`timescale 1 ps / 1 ps
module axis_reg_irq_rsp 
#(
    parameter NUM_PIPELINES  = 1, // 1-N 
    parameter MODE           = 0, // 0: skid buffer 1: simple buffer 2: bypass
    parameter TREADY_RST_VAL = 0  // 0: de-assert tready during reset 1: assert tready during reset
)(
   input  logic           s_if_clk,
   input  logic           s_if_rst_n,
   input t_axis_irq_rsp   s_if,
   output logic           s_if_tready,
   
   output logic           m_if_clk,
   output logic           m_if_rst_n,
   output t_axis_irq_rsp  m_if,
   input  logic           m_if_tready
);

localparam TDATA_WIDTH = IRQ_RSP_DW;

// synthesis traslate_off
initial begin
   if (NUM_PIPELINES < 1) begin
      $display("%m: Error: AXIS pipeline length: %0d less than 1.", NUM_PIPELINES);      
   end
end
// synthesis trasnslate_on

t_axis_irq_rsp [NUM_PIPELINES-1:0] pipe_s_if;
logic [NUM_PIPELINES-1:0]          s_tready;

t_axis_irq_rsp [NUM_PIPELINES-1:0] pipe_m_if;
logic [NUM_PIPELINES-1:0]          m_tready;

// Connect s_if to the slave interface on the first pipeline
assign s_if_tready = s_tready[0]; 

// Connect m_if to the master interface on the last pipeline
assign m_if_clk   = s_if_clk;
assign m_if_rst_n = s_if_rst_n;
assign m_if       = pipe_m_if[NUM_PIPELINES-1];

genvar ig;
generate 
   for (ig=0; ig <NUM_PIPELINES; ig=ig+1) begin : pipe
      if (ig == 0) 
         assign pipe_s_if[ig] = s_if;
      else 
         assign pipe_s_if[ig] = pipe_m_if[ig-1];

      if (ig == NUM_PIPELINES-1)
         assign m_tready[ig]  = m_if_tready;
      else
         assign m_tready[ig] = s_tready[ig+1];

      ofs_fim_axis_register #(
         .MODE           (MODE),
         .TREADY_RST_VAL (TREADY_RST_VAL),
         .ENABLE_TKEEP   (0),
         .ENABLE_TLAST   (0),
         .ENABLE_TID     (0),
         .ENABLE_TDEST   (0),
         .ENABLE_TUSER   (0),
         .TDATA_WIDTH    (TDATA_WIDTH)
      ) axis_pipe (
         .clk      (s_if_clk),
         .rst_n    (s_if_rst_n),
         // Slave interface
         .s_tready (s_tready[ig]),
         .s_tvalid (pipe_s_if[ig].tvalid),
         .s_tdata  (pipe_s_if[ig].tdata),
         // Master interface
         .m_tready (m_tready[ig]),
         .m_tvalid (pipe_m_if[ig].tvalid),
         .m_tdata  (pipe_m_if[ig].tdata)
      );
   end // axis_pipe
endgenerate

endmodule
