// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
// Customized version of Avalon-MM pipeline bridge IP for DCP local memory
// subsystem usage
// --------------------------------------
//
// Changes to improve timing
//    1. Updated burstcount and byteenable power-up value from high to low.
//       This will prevent synthesis from inserting inverters at the input and output
//       of the register.
//
//       Implication: No
//
//    2. Changed reset scheme to synchronous reset. Only control signals are reset.
//       Implication: No
//
//    3. Duplicated wr_waitrequest_reg to wr_waitrequest_reg_dup and have it
//       drives the enable port of buffer registers wr_reg_* which were
//       previously driven by wait_rise comb cell.
//       With this update, the buffer registers will sample new value when
//       wr_waitrequest_reg_dup is de-asserted and stop sampling when it is asserted. 
//
//       Implication: No
//    
//    4. Remove cmd_read and cmd_write from the enable path of CMD registers
//       to get rid of a comb cell that drives the enable port of CMD registers.
//       This requires the slave to not assert waitrequest in IDLE state (no
//       command) which is true for Arria 10 EMIF IP.
//
//       Implication: 
//          There will be 2 NOP cycles when CMD registers and buffer
//          registers have no read/write CMD right before slave waitrequest is asserted.
//          This is different from previous implementation in that the CMD registers and buffer registers
//          stop sampling new value when slave waitrequest is asserted.
//
//    5. Added CMD_PIPE_DEPTH option to control the pipeline stages for command datapath.
//       Added READDATA_PIPE_DEPTH option to control the pipeline stage for read resposne datapath
//
// --------------------------------------

`timescale 1 ns / 1 ns
module custom_altera_avalon_mm_bridge
#(
    parameter DATA_WIDTH           = 32,
    parameter SYMBOL_WIDTH         = 8,
    parameter RESPONSE_WIDTH       = 2,
    parameter HDL_ADDR_WIDTH       = 10,
    parameter BURSTCOUNT_WIDTH     = 1,

    parameter CMD_PIPE_DEPTH = 1,          // Specifies how many feed-forward (unstallable) pipe stages are placed on the command path. Min value 1.
    parameter READDATA_PIPE_DEPTH = 1,     // Specifies how many stages of pipelining are placed on the readdata and readdatavalid. Min value 1.

    // --------------------------------------
    // Derived parameters
    // --------------------------------------
    parameter BYTEEN_WIDTH = DATA_WIDTH / SYMBOL_WIDTH
)
(
    input                         clk,
    input                         reset,

    output                        s0_waitrequest,
    output [DATA_WIDTH-1:0]       s0_readdata,
    output                        s0_readdatavalid,
    output [RESPONSE_WIDTH-1:0]   s0_response,
    input  [BURSTCOUNT_WIDTH-1:0] s0_burstcount,
    input  [DATA_WIDTH-1:0]       s0_writedata,
    input  [HDL_ADDR_WIDTH-1:0]   s0_address, 
    input                         s0_write, 
    input                         s0_read, 
    input  [BYTEEN_WIDTH-1:0]     s0_byteenable, 
    input                         s0_debugaccess,

    input                         m0_waitrequest,
    input  [DATA_WIDTH-1:0]       m0_readdata,
    input                         m0_readdatavalid,
    input  [RESPONSE_WIDTH-1:0]   m0_response,
    output [BURSTCOUNT_WIDTH-1:0] m0_burstcount,
    output [DATA_WIDTH-1:0]       m0_writedata,
    output [HDL_ADDR_WIDTH-1:0]   m0_address, 
    output                        m0_write, 
    output                        m0_read, 
    output [BYTEEN_WIDTH-1:0]     m0_byteenable,
    output                        m0_debugaccess
);
    // --------------------------------------
    // Registers & signals
    // --------------------------------------
                  wire cmd_waitrequest;
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1] [BURSTCOUNT_WIDTH-1:0]   cmd_burstcount;
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1] [DATA_WIDTH-1:0]         cmd_writedata;
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1] [HDL_ADDR_WIDTH-1:0]     cmd_address; 
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1]                          cmd_write;  
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1]                          cmd_read;  
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1] [BYTEEN_WIDTH-1:0]       cmd_byteenable;
(*dont_retime*)   reg [CMD_PIPE_DEPTH:1]                          cmd_debugaccess;

(*dont_retime*)    reg [BURSTCOUNT_WIDTH-1:0]   wr_burstcount;
(*dont_retime*)    reg [DATA_WIDTH-1:0]         wr_writedata;
(*dont_retime*)    reg [HDL_ADDR_WIDTH-1:0]     wr_address; 
(*dont_retime*)    reg                          wr_write;  
(*dont_retime*)    reg                          wr_read;  
(*dont_retime*)    reg [BYTEEN_WIDTH-1:0]       wr_byteenable;
(*dont_retime*)    reg                          wr_debugaccess;

(*dont_retime*)    reg [BURSTCOUNT_WIDTH-1:0]   wr_reg_burstcount;
(*dont_retime*)    reg [DATA_WIDTH-1:0]         wr_reg_writedata;
(*dont_retime*)    reg [HDL_ADDR_WIDTH-1:0]     wr_reg_address; 
(*dont_retime*)    reg                          wr_reg_write;  
(*dont_retime*)    reg                          wr_reg_read;  
(*dont_retime*)    reg [BYTEEN_WIDTH-1:0]       wr_reg_byteenable;
(*dont_retime*)    reg                          wr_reg_waitrequest;
(*dont_retime,dont_merge*)	 reg            wr_reg_waitrequest_dup;
(*dont_retime*)    reg                          wr_reg_debugaccess;

                   reg                          use_reg;
                   wire                         wait_rise;

                   reg [READDATA_PIPE_DEPTH:1] [DATA_WIDTH-1:0]         rsp_readdata;
(*dont_retime*)    reg [READDATA_PIPE_DEPTH:1]                          rsp_readdatavalid;
(*dont_retime*)    reg [READDATA_PIPE_DEPTH:1] [RESPONSE_WIDTH-1:0]     rsp_response;   
integer i;
    // --------------------------------------
    // Command pipeline
    //
    // Registers all command signals, including waitrequest
    // --------------------------------------
    // --------------------------------------
    // Waitrequest Pipeline Stage
    //
    // Output waitrequest is delayed by one cycle, which means
    // that a master will see waitrequest assertions one cycle 
    // too late.
    //
    // Solution: buffer the command when waitrequest transitions
    // from low->high. As an optimization, we can safely assume 
    // waitrequest is low by default because downstream logic
    // in the bridge ensures this.
    //
    // Note: this implementation buffers idle cycles should 
    // waitrequest transition on such cycles. This is a potential
    // cause for throughput loss, but ye olde pipeline bridge did
    // the same for years and no one complained. Not buffering idle
    // cycles costs logic on the waitrequest path.
    // --------------------------------------
    assign s0_waitrequest = wr_reg_waitrequest;
    assign wait_rise      = ~wr_reg_waitrequest & cmd_waitrequest;
 
    always @(posedge clk) begin
      if (reset) begin
        wr_reg_waitrequest     <= 1'b1;
        wr_reg_waitrequest_dup <= 1'b1;
      end else begin
        wr_reg_waitrequest     <= cmd_waitrequest;
        wr_reg_waitrequest_dup <= cmd_waitrequest;
      end
    end
    
    // --------------------------------------
    // Bit of trickiness here, deserving of a long comment.
    //
    // On the first cycle after reset, the pass-through
    // must not be used or downstream logic may sample
    // the same command twice because of the delay in
    // transmitting a falling waitrequest.
    //
    // Using the registered command works on the condition
    // that downstream logic deasserts waitrequest
    // immediately after reset, which is true of the 
    // next stage in this bridge.
    // --------------------------------------					 
    always @(posedge clk) begin
        if (~wr_reg_waitrequest_dup) begin
            wr_reg_writedata  <= s0_writedata;
            wr_reg_byteenable <= s0_byteenable;
            wr_reg_address    <= s0_address;
            wr_reg_write      <= s0_write;
            wr_reg_read       <= s0_read;
            wr_reg_burstcount <= s0_burstcount;
            wr_reg_debugaccess <= s0_debugaccess;
        end

        // stop using the buffer when waitrequest is low
        if (~cmd_waitrequest)
             use_reg <= 1'b0;
        else if (wait_rise) begin
            use_reg <= 1'b1;
        end     

        if (reset) begin
            use_reg            <= 1'b1;
            wr_reg_write       <= 1'b0;
            wr_reg_read        <= 1'b0;
            wr_reg_debugaccess <= 1'b0;
        end
    end
     
    always @* begin
        wr_burstcount  =  s0_burstcount;
        wr_writedata   =  s0_writedata;
        wr_address     =  s0_address;
        wr_write       =  s0_write;
        wr_read        =  s0_read;
        wr_byteenable  =  s0_byteenable;
        wr_debugaccess =  s0_debugaccess;
 
        if (use_reg) begin
            wr_burstcount  =  wr_reg_burstcount;
            wr_writedata   =  wr_reg_writedata;
            wr_address     =  wr_reg_address;
            wr_write       =  wr_reg_write;
            wr_read        =  wr_reg_read;
            wr_byteenable  =  wr_reg_byteenable;
            wr_debugaccess =  wr_reg_debugaccess;
        end
    end
     
    // --------------------------------------
    // Master-Slave Signal Pipeline Stage 
    //
    // cmd_waitrequest is deasserted during reset,
    // which is not spec-compliant, but is ok for an internal signal.
    // --------------------------------------
    assign cmd_waitrequest = m0_waitrequest;

    // First stage pipeline
    always @(posedge clk) begin
        if (~cmd_waitrequest) begin
            cmd_writedata[1]   <= wr_writedata;
            cmd_byteenable[1]  <= wr_byteenable;
            cmd_address[1]     <= wr_address;
            cmd_write[1]       <= wr_write;
            cmd_read[1]        <= wr_read;
            cmd_burstcount[1]  <= wr_burstcount;
            cmd_debugaccess[1] <= wr_debugaccess;
        end

        if (reset) begin
           cmd_write[1]       <= 1'b0;
           cmd_read[1]        <= 1'b0;
           cmd_debugaccess[1] <= 1'b0;
        end 
    end

    // Next-stage pipeline for CMD_PIPE_DEPTH > 1
    always @(posedge clk) begin
       for ( i=2; i<= CMD_PIPE_DEPTH; i=i+1) begin
          cmd_writedata  [i] <= cmd_writedata  [i-1];  
          cmd_byteenable [i] <= cmd_byteenable [i-1];
          cmd_address    [i] <= cmd_address    [i-1];
          cmd_write      [i] <= cmd_write      [i-1];
          cmd_read       [i] <= cmd_read       [i-1];
          cmd_burstcount [i] <= cmd_burstcount [i-1];
          cmd_debugaccess[i] <= cmd_debugaccess[i-1];
      end
    end

    assign m0_burstcount    = cmd_burstcount[CMD_PIPE_DEPTH];
    assign m0_writedata     = cmd_writedata[CMD_PIPE_DEPTH];
    assign m0_address       = cmd_address[CMD_PIPE_DEPTH];
    assign m0_write         = cmd_write[CMD_PIPE_DEPTH];
    assign m0_read          = cmd_read[CMD_PIPE_DEPTH];
    assign m0_byteenable    = cmd_byteenable[CMD_PIPE_DEPTH];
    assign m0_debugaccess   = cmd_debugaccess[CMD_PIPE_DEPTH];

    // --------------------------------------
    // Response pipeline
    //
    // Registers all response signals
    // --------------------------------------
    // First stage pipeline
    always @(posedge clk) begin
       rsp_readdatavalid[1] <= m0_readdatavalid;
       rsp_readdata[1]      <= m0_readdata;
       rsp_response[1]      <= m0_response;               
      
       if (reset) begin
          rsp_readdatavalid[1] <= 1'b0;
       end        
    end

    // Next stage pipeline for READDATA_PIPE_DEPTH > 1
    always @(posedge clk) begin
       for ( i=2; i<= READDATA_PIPE_DEPTH; i=i+1) begin
          rsp_readdatavalid[i] <= rsp_readdatavalid[i-1];
          rsp_readdata[i]      <= rsp_readdata[i-1];
          rsp_response[i]      <= rsp_response[i-1];
       end
    end

    assign s0_readdatavalid = rsp_readdatavalid[READDATA_PIPE_DEPTH];
    assign s0_readdata      = rsp_readdata[READDATA_PIPE_DEPTH];
    assign s0_response      = rsp_response[READDATA_PIPE_DEPTH];   

endmodule
