// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

 module fast_bridge 
#(
  parameter DATA_WIDTH        = 32, // bit width of the AVMM data interface
  parameter EXTERNAL_PIPE_DEPTH = 1, // Specifies how many feed-forward (unstallable) pipe stages are placed outside this block.
  parameter INTERNAL_PIPE_DEPTH = 1, // Specifies how many feed-forward (unstallable) pipe stages to be placed inside this block.
  
  parameter FIFO_DEPTH = 32

)
(
  input                           clk,      // clock input
  input                           reset,      // reset input

  output                          s0_ready,
  input   [DATA_WIDTH-1:0]        s0_data,
  input                           s0_valid, 

  input                           m0_ready,
  output  [DATA_WIDTH-1:0]        m0_data,
  output                          m0_valid 
);

  localparam REQ_FIFO_ALMOST_FULL_THRES = 2*INTERNAL_PIPE_DEPTH + 2*EXTERNAL_PIPE_DEPTH + 2; 

  wire                  req_almost_full;
  wire [DATA_WIDTH-1:0] req_data_in;
  wire                  req_valid_in;
  
  reg                   req_valid_out;
  wire                  req_fifo_pop;
  wire                  req_fifo_empty;


pipe_hssi_ch #(
  .TDATA_WIDTH                  ( DATA_WIDTH ),
  .PL_DEPTH                     ( INTERNAL_PIPE_DEPTH)
)  pipe_inst (
   .clk        (clk),
   .rst_n      (~reset),

   .s_ready   (s0_ready),
   .s_data    (s0_data),
   .s_valid   (s0_valid), 

   .m_ready   (~req_almost_full),
   .m_data    (req_data_in),
   .m_valid   (req_valid_in) 
);


    acl_scfifo_wrapped #(
      .add_ram_output_register ( "ON"),
      .intended_device_family ("Stratix 10"),
      .lpm_numwords (FIFO_DEPTH),
      .lpm_showahead ( "OFF"),
      .lpm_type ( "scfifo"),
      .lpm_width (DATA_WIDTH),
      .lpm_widthu ($clog2(FIFO_DEPTH)),
      .overflow_checking ( "OFF"),
      .underflow_checking ( "ON"),
      .use_eab ( "ON"), 
      .almost_full_value(FIFO_DEPTH - REQ_FIFO_ALMOST_FULL_THRES),
      //.connect_clr_to_scfifo (1'b1),
      .enable_ecc ("FALSE")       
    ) fast_bridge_req_fifo (
      .clock (clk),
      .data (req_data_in),
      .wrreq (req_valid_in & s0_ready),
      .rdreq (req_fifo_pop),
      .usedw (),
      .empty (req_fifo_empty), 
      .full (),
      .q (m0_data),
      .almost_empty (),
      .almost_full (req_almost_full),
      .sclr (reset),
      .aclr (reset),
      .ecc_err_status()
    );

always @(posedge clk) begin
   if (reset)
      req_valid_out <= 1'b0;
   else if (m0_ready)
      req_valid_out <= req_fifo_pop;
   else
      req_valid_out <= req_valid_out;
end

assign req_fifo_pop = ~req_fifo_empty & m0_ready;
assign m0_valid = req_valid_out;


endmodule
