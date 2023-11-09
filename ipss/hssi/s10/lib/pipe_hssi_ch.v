// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description: hssi avst pipeline register
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module pipe_hssi_ch 
#( 
   parameter MODE                 = 0, // 0: skid buffer 1: simple buffer 2: simple buffer (bubble) 3: bypass
   parameter TREADY_RST_VAL       = 0, // 0: tready deasserted during reset 
                                        // 1: tready asserted during reset
   parameter ENABLE_TKEEP         = 0,
   parameter ENABLE_TLAST         = 0,
   parameter ENABLE_TID           = 0,
   parameter ENABLE_TDEST         = 0,
   parameter ENABLE_TUSER         = 0,

   parameter TDATA_WIDTH          = 512,
   parameter TID_WIDTH            = 8,
   parameter TDEST_WIDTH          = 8,
   parameter TUSER_WIDTH          = 10,

   parameter PL_DEPTH = 1

)(
   input  logic                       clk,
   input  logic                       rst_n,

   output logic                       s_ready,
   input  logic                       s_valid,
   input  logic [TDATA_WIDTH-1:0]     s_data,

   input  logic                       m_ready,
   output logic                       m_valid,
   output logic [TDATA_WIDTH-1:0]     m_data

);

   reg    [PL_DEPTH:0]                      pipe_ready;
   reg    [PL_DEPTH:0][TDATA_WIDTH-1:0]     pipe_data;
   reg    [PL_DEPTH:0]                      pipe_valid;

always_comb begin

   s_ready              = pipe_ready[0];
   pipe_data[0]         = s_data;
   pipe_valid[0]        = s_valid;

   m_valid              = pipe_valid[PL_DEPTH];
   m_data               = pipe_data[PL_DEPTH];
   pipe_ready[PL_DEPTH] = m_ready;
end

genvar n;
generate
   for(n=0; n<PL_DEPTH; n=n+1) begin : axis_pl_stage
      axis_register #( 
         .MODE           ( MODE           ),
         .TREADY_RST_VAL ( TREADY_RST_VAL ),
         .ENABLE_TKEEP   ( ENABLE_TKEEP   ),
         .ENABLE_TLAST   ( ENABLE_TLAST   ),
         .ENABLE_TID     ( ENABLE_TID     ),
         .ENABLE_TDEST   ( ENABLE_TDEST   ),
         .ENABLE_TUSER   ( ENABLE_TUSER   ),
         .TDATA_WIDTH    ( TDATA_WIDTH    ),
         .TID_WIDTH      ( TID_WIDTH      ),
         .TDEST_WIDTH    ( TDEST_WIDTH    ),
         .TUSER_WIDTH    ( TUSER_WIDTH    )

      ) axis_reg_inst (
        .clk       (clk),
        .rst_n     (rst_n),

        .s_tready  (pipe_ready[n]),
        .s_tvalid  (pipe_valid[n]),
        .s_tdata   (pipe_data[n]),
        .s_tkeep   (),
        .s_tlast   (),
        .s_tid     (),
        .s_tdest   (),
        .s_tuser   (),

        .m_tready  (pipe_ready[n+1]),
        .m_tvalid  (pipe_valid[n+1]),
        .m_tdata   (pipe_data[n+1]),
        .m_tkeep   (),
        .m_tlast   (),
        .m_tid     (),
        .m_tdest   (), 
        .m_tuser   ()
      );
   end // for (n=0; n<PL_DEPTH; n=n+1)
endgenerate


endmodule
