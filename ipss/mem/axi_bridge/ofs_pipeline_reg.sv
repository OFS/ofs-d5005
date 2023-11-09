// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Pipeline register for interface which implements valid-ready handshaking
// 
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module ofs_pipeline_reg 
#( 
    // Register mode for read address channel
    parameter REG_MODE = 0, // 0: skid buffer 1: simple buffer 2: bypass
    parameter WIDTH    = 8
)(
    input clk,
    input rst_n,

    // Slave interface
    output logic              s_ready,
    input  logic              s_valid,
    input  logic [WIDTH-1:0]  s_data,

    // Master interface
    input  logic              m_ready,
    output logic              m_valid,
    output logic [WIDTH-1:0]  m_data
);

generate
if (REG_MODE == 0) begin 
    // --------------------------------------
    // skid buffer
    // --------------------------------------
    // Registers & signals
    logic             s_valid_reg;
    logic [WIDTH-1:0] s_data_reg;
    logic             s_ready_reg;
    logic             s_ready_reg_dup;
    logic             use_reg;

    logic             m_valid_pre;
    logic [WIDTH-1:0] m_data_pre;
    logic             m_valid_reg;
    logic [WIDTH-1:0] m_data_reg;

    // --------------------------------------
    // Pipeline stage
    //
    // s_tready is delayed by one cycle, master will see tready assertions one cycle later.
    // Buffer the data when tready transitions from high->low
    //
    // This implementation buffers idle cycles should ready transition on such cycles. 
    //     i.e. It doesn't take in new data from s_* even though m_valid_reg=0 or when m_ready=0
    // This is a potential cause for throughput loss.
    // Not buffering idle cycles costs logic on the tready path.
    // --------------------------------------
    assign s_ready_pre = (m_ready || ~m_valid);
 
    always @(posedge clk) begin
      if (~rst_n) begin
        s_ready_reg     <=  1'b0;
        s_ready_reg_dup <=  1'b0;
      end else begin
        s_ready_reg     <=  s_ready_pre;
        s_ready_reg_dup <=  m_ready;
      end
    end
    
    // --------------------------------------
    // On the first cycle after reset, the pass-through
    // must not be used or downstream logic may sample
    // the same command twice because of the delay in
    // transmitting a rising ready.
    // --------------------------------------			    
    // Check whether to drive the output with buffer registers when output is ready
    always @(posedge clk) begin
       if (~rst_n) begin
          use_reg <= 1'b1;
       end else if (s_ready_pre) begin
          // stop using the buffer when s_ready_pre is high (m_ready=1 or m_valid=0)
          use_reg <= 1'b0;
       end else if (~m_ready && s_ready_reg) begin
          use_reg <= 1'b1;
       end
    end
    
    // Buffer registers    
    always @(posedge clk) begin
       if (~rst_n) s_valid_reg <= 1'b0;
       else if (s_ready_reg_dup) s_valid_reg <= s_valid;
    end
    
    always @(posedge clk) begin
       if (s_ready_reg_dup) s_data_reg <= s_data;
    end
   
   // Output selection (between buffer register and input)
   assign m_valid_pre = use_reg ? s_valid_reg : s_valid;
   assign m_data_pre  = use_reg ? s_data_reg  : s_data;
   
   // Register AXI signals
   always @(posedge clk) begin
      if (m_ready) m_data_reg <= m_data_pre;
   end
     
   // Generate ready and valid signals
   always @(posedge clk) begin
      if (~rst_n) m_valid_reg <= 1'b0;
      else if (m_ready) m_valid_reg <= m_valid_pre;
   end
   
   // Output assignment
   assign s_ready  =  s_ready_reg;
   assign m_valid  =  m_valid_reg;
   assign m_data   =  m_data_reg;

end else if (REG_MODE == 1) begin 

   // --------------------------------------
   // Simple pipeline register with bubble cycle
   // --------------------------------------
   logic             s_ready_reg;
   logic             m_valid_reg;
   logic [WIDTH-1:0] m_data_reg;

   // Generate ready and valid signals
   always @(posedge clk) begin
      if (~rst_n) begin
         s_ready_reg <= 1'b0;
         m_valid_reg <= 1'b0;
      end else begin
        if (s_ready_reg && s_valid) begin
           s_ready_reg <= 1'b0;
           m_valid_reg <= 1'b1;
        end else if (~s_ready_reg && m_ready) begin
           s_ready_reg <= 1'b1;
           m_valid_reg <= 1'b0;
        end
      end
   end

   // Register AXI signals
   always @(posedge clk) begin
      if (s_ready_reg) m_data_reg <=s_data;
   end

   // Output assignment
   assign s_ready  =  s_ready_reg;
   assign m_valid  =  m_valid_reg;
   assign m_data   =  m_data_reg;

end else begin 

   // --------------------------------------
   // bypass mode
   // --------------------------------------
    assign s_ready  =  m_ready;
    assign m_valid  =  s_valid;
    assign m_data   =  s_data;
end
endgenerate

endmodule
