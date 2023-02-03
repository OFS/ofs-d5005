// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// AXIS pipeline register 
//
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module axis_register 
#( 
    parameter MODE                 = 0, // 0: skid buffer 1: simple buffer 2: bypass,
    parameter TREADY_RST_VAL       = 0, // 0: tready deasserted during reset 
                                        // 1: tready asserted during reset
    parameter ENABLE_TKEEP         = 1,
    parameter ENABLE_TLAST         = 1,
    parameter ENABLE_TID           = 0,
    parameter ENABLE_TDEST         = 0,
    parameter ENABLE_TUSER         = 0,
   
    parameter TDATA_WIDTH          = 32,
    parameter TID_WIDTH            = 8,
    parameter TDEST_WIDTH          = 8,
    parameter TUSER_WIDTH          = 1,

    // --------------------------------------
    // Derived parameters
    // --------------------------------------
    parameter TKEEP_WIDTH = TDATA_WIDTH / 8
)(
    input                         clk,
    input                         rst_n,

    output                        s_tready,
    input                         s_tvalid,
    input   [TDATA_WIDTH-1:0]     s_tdata,
    input   [TKEEP_WIDTH-1:0]     s_tkeep, 
    input                         s_tlast, 
    input   [TID_WIDTH-1:0]       s_tid, 
    input   [TDEST_WIDTH-1:0]     s_tdest, 
    input   [TUSER_WIDTH-1:0]     s_tuser, 
    
    input                         m_tready,
    output                        m_tvalid,
    output  [TDATA_WIDTH-1:0]     m_tdata,
    output  [TKEEP_WIDTH-1:0]     m_tkeep, 
    output                        m_tlast, 
    output  [TID_WIDTH-1:0]       m_tid, 
    output  [TDEST_WIDTH-1:0]     m_tdest, 
    output  [TUSER_WIDTH-1:0]     m_tuser 

);

generate 
if (MODE == 0) begin 
    // --------------------------------------
    // skid buffer
    // --------------------------------------
    
    // Registers & signals
    reg                          s_tvalid_reg; 
    reg [TDATA_WIDTH-1:0]        s_tdata_reg;
    reg [TKEEP_WIDTH-1:0]        s_tkeep_reg;
    reg                          s_tlast_reg; 
    reg [TID_WIDTH-1:0]          s_tid_reg;  
    reg [TDEST_WIDTH-1:0]        s_tdest_reg;  
    reg [TUSER_WIDTH-1:0]        s_tuser_reg;

    reg                          s_tready_reg;
    reg                          s_tready_reg_dup;
    reg                          use_reg;

    reg                          m_tvalid_pre; 
    reg [TDATA_WIDTH-1:0]        m_tdata_pre;
    reg [TKEEP_WIDTH-1:0]        m_tkeep_pre;
    reg                          m_tlast_pre; 
    reg [TID_WIDTH-1:0]          m_tid_pre;  
    reg [TDEST_WIDTH-1:0]        m_tdest_pre;  
    reg [TUSER_WIDTH-1:0]        m_tuser_pre;

    reg                          m_tvalid_reg;
    reg [TDATA_WIDTH-1:0]        m_tdata_reg;
    reg [TKEEP_WIDTH-1:0]        m_tkeep_reg;
    reg                          m_tlast_reg; 
    reg [TID_WIDTH-1:0]          m_tid_reg;  
    reg [TDEST_WIDTH-1:0]        m_tdest_reg;  
    reg [TUSER_WIDTH-1:0]        m_tuser_reg;

    // --------------------------------------
    // Pipeline stage
    //
    // s_tready is delayed by one cycle, master will see tready assertions one cycle later.
    // Buffer the data when tready transitions from high->low
    //
    // This implementation buffers idle cycles should tready transition on such cycles. 
    //     i.e. It doesn't take in new data from s_* even though m_tvalid=0 or when m_tready=0
    // This is a potential cause for throughput loss.
    // Not buffering idle cycles costs logic on the tready path.
    // --------------------------------------
    logic s_tready_pre;     // MD - add declaration 12/8/2020
    
    assign s_tready_pre = (m_tready || ~m_tvalid);
 
    always @(posedge clk) begin
      if (~rst_n) begin
        s_tready_reg     <= (TREADY_RST_VAL == 0) ? 1'b0 : 1'b1;
        s_tready_reg_dup <= (TREADY_RST_VAL == 0) ? 1'b0 : 1'b1;
      end else begin
        s_tready_reg     <= s_tready_pre;
        s_tready_reg_dup <= s_tready_pre;
      end
    end
    
    // --------------------------------------
    // On the first cycle after reset, the pass-through
    // must not be used or downstream logic may sample
    // the same command twice because of the delay in
    // transmitting a rising tready.
    // --------------------------------------			    
    always @(posedge clk) begin
       if (~rst_n) begin
          use_reg <= 1'b1;
       end else if (s_tready_pre) begin
          // stop using the buffer when s_tready_pre is high (m_tready=1 or m_tvalid=0)
          use_reg <= 1'b0;
       end else if (~s_tready_pre && s_tready_reg) begin
          use_reg <= 1'b1;
       end
    end
    
    always @(posedge clk) begin
       if (~rst_n) begin
          s_tvalid_reg <= 1'b0;
       end else if (s_tready_reg_dup) begin
          s_tvalid_reg <= s_tvalid;
       end
    end

    always @(posedge clk) begin
       if (s_tready_reg_dup) begin
          s_tdata_reg  <= s_tdata;
          s_tkeep_reg  <= s_tkeep;
          s_tlast_reg  <= s_tlast;
          s_tid_reg    <= s_tid;
          s_tdest_reg  <= s_tdest;
          s_tuser_reg  <= s_tuser;
       end
    end
     
    always_comb begin
       if (use_reg) begin
          m_tvalid_pre = s_tvalid_reg;
          m_tdata_pre  = s_tdata_reg;
          m_tkeep_pre  = s_tkeep_reg;
          m_tlast_pre  = s_tlast_reg;
          m_tid_pre    = s_tid_reg; 
          m_tdest_pre  = s_tdest_reg;
          m_tuser_pre  = s_tuser_reg;
       end else begin
          m_tvalid_pre = s_tvalid;
          m_tdata_pre  = s_tdata;
          m_tkeep_pre  = s_tkeep;
          m_tlast_pre  = s_tlast;
          m_tid_pre    = s_tid;
          m_tdest_pre  = s_tdest;
          m_tuser_pre  = s_tuser;
       end
    end
     
    // --------------------------------------
    // Master-Slave Signal Pipeline Stage 
    // --------------------------------------
    always @(posedge clk) begin
       if (~rst_n) begin
          m_tvalid_reg <= 1'b0;
       end else if (s_tready_pre) begin
          m_tvalid_reg <= m_tvalid_pre;
       end
    end
    
    always @(posedge clk) begin
       if (s_tready_pre) begin
          m_tdata_reg  <= m_tdata_pre;
          m_tkeep_reg  <= m_tkeep_pre;
          m_tlast_reg  <= m_tlast_pre;
          m_tid_reg    <= m_tid_pre;
          m_tdest_reg  <= m_tdest_pre;
          m_tuser_reg  <= m_tuser_pre;
       end
    end

    // Output assignment
    assign m_tvalid = m_tvalid_reg;
    assign m_tdata  = m_tdata_reg;
    assign m_tkeep  = ENABLE_TKEEP ? m_tkeep_reg : '0;
    assign m_tlast  = ENABLE_TLAST ? m_tlast_reg : 1'b0;
    assign m_tid    = ENABLE_TID   ? m_tid_reg   : '0;
    assign m_tdest  = ENABLE_TDEST ? m_tdest_reg : '0;
    assign m_tuser  = ENABLE_TUSER ? m_tuser_reg : '0;
    assign s_tready = s_tready_reg;

end else if (MODE == 1) begin 
   // --------------------------------------
   // Simple pipeline register with bubble cycle
   // --------------------------------------
   reg                          s_tvalid_reg; 
   reg                          s_tready_reg;
   reg                          m_tvalid_reg;
   reg [TDATA_WIDTH-1:0]        m_tdata_reg;
   reg [TKEEP_WIDTH-1:0]        m_tkeep_reg;
   reg                          m_tlast_reg; 
   reg [TID_WIDTH-1:0]          m_tid_reg;  
   reg [TDEST_WIDTH-1:0]        m_tdest_reg;  
   reg [TUSER_WIDTH-1:0]        m_tuser_reg;


   always @(posedge clk) begin
      if (~rst_n) begin
         s_tready_reg <= 1'b0;
         m_tvalid_reg <= 1'b0;
      end else begin
        if (s_tready_reg && s_tvalid) begin
           s_tready_reg <= 1'b0;
           m_tvalid_reg <= 1'b1;
        end else if (~s_tready_reg && (m_tready || ~m_tvalid)) begin
           s_tready_reg <= 1'b1;
           m_tvalid_reg <= 1'b0;
        end
      end
   end

   always @(posedge clk) begin
      if (s_tready_reg) begin
         m_tdata_reg  <= s_tdata;
         m_tkeep_reg  <= s_tkeep;
         m_tlast_reg  <= s_tlast;
         m_tid_reg    <= s_tid;
         m_tdest_reg  <= s_tdest;
         m_tuser_reg  <= s_tuser;
      end
   end
 
    // Output assignment
    assign m_tvalid = m_tvalid_reg;
    assign m_tdata  = m_tdata_reg;
    assign m_tkeep  = ENABLE_TKEEP ? m_tkeep_reg : '0;
    assign m_tlast  = ENABLE_TLAST ? m_tlast_reg : 1'b0;
    assign m_tid    = ENABLE_TID   ? m_tid_reg   : '0;
    assign m_tdest  = ENABLE_TDEST ? m_tdest_reg : '0;
    assign m_tuser  = ENABLE_TUSER ? m_tuser_reg : '0;
    assign s_tready = s_tready_reg;

end else begin 

   // --------------------------------------
   // bypass mode
   // --------------------------------------
   assign m_tvalid = s_tvalid;
   assign m_tdata  = s_tdata;
   assign m_tkeep  = ENABLE_TKEEP ? s_tkeep : '0;
   assign m_tlast  = ENABLE_TLAST ? s_tlast : 1'b0;
   assign m_tid    = ENABLE_TID   ? s_tid   : '0;
   assign m_tdest  = ENABLE_TDEST ? s_tdest : '0;
   assign m_tuser  = ENABLE_TUSER ? s_tuser : '0;
   assign s_tready = m_tready;
end
endgenerate

endmodule
