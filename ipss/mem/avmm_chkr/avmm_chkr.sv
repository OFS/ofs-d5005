// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// AVMM protocol checker
//
//-----------------------------------------------------------------------------

module avmm_chkr #(
   parameter ADDRESS_W    = 26,
   parameter DATA_W       = 512,
   parameter BYTEENABLE_W = DATA_W/8,
   parameter BURSTCOUNT_W = 7,
   parameter MAX_BURST    = 2**(BURSTCOUNT_W-1)

`ifdef SIM_MODE
   ,MAX_SIM_CLEAR = 'h1000
`endif
)(
   input  logic clk,
   input  logic rst_n,
   
   input  logic afu_reset,
   output logic emif_prt_error,

   input  logic ddr_clear_en,
   output logic ddr_clear_busy,
 
   // ------------------------------------------
   // Slave interface
   // ------------------------------------------
   input  logic                     avs_read,
   input  logic                     avs_write,
   output logic                     avs_waitrequest,
   input  logic [ADDRESS_W-1:0]     avs_address,
   input  logic [BYTEENABLE_W-1:0]  avs_byteenable,
   input  logic [BURSTCOUNT_W-1:0]  avs_burstcount,
   input  logic [DATA_W-1:0]        avs_writedata,
   output logic [DATA_W-1:0]        avs_readdata,
   output logic                     avs_readdatavalid,

   // ------------------------------------------
   // Master interface
   // ------------------------------------------
   output logic                     avm_read,
   output logic                     avm_write,
   output logic [ADDRESS_W-1:0]     avm_address,
   input  logic                     avm_waitrequest,
   output logic [BYTEENABLE_W-1:0]  avm_byteenable,
   output logic [BURSTCOUNT_W-1:0]  avm_burstcount,
   output logic [DATA_W-1:0]        avm_writedata,
   input  logic [DATA_W-1:0]        avm_readdata,
   input  logic                     avm_readdatavalid
 );

   logic [ADDRESS_W-1:0]    clear_count,clear_address;
   logic 		    start_error, burst_error;
   
   enum {
      IDLE_BIT,
      WBURST_BIT,
      WCOMPL_BIT,
      CLEAR_BIT,
      ERROR_BIT 
    } index;

   // fsm must be Mealy, avmm signals forwarded to emif depend on the current state of the input signals   
   (* altera_attribute = {"-name MAX_FANOUT 192"}*)
   enum logic [4:0] {
      IDLE   = 5'b1 << IDLE_BIT,
      WBURST = 5'b1 << WBURST_BIT,
      WCOMPL = 5'b1 << WCOMPL_BIT,
      CLEAR  = 5'b1 << CLEAR_BIT,
      ERROR  = 5'b1 << ERROR_BIT,
      XXX    = 'x
   } state, next;

   logic [BURSTCOUNT_W-1:0] wcompl_count;
   logic 		    error;
   logic 		    log_error;
   logic 		    log_clear;

   always_ff @(posedge clk) begin
      if(!rst_n) state <= IDLE;
      else       state <= next;
   end

   assign start_error = (avs_read & avs_write) | ((avs_read | avs_write) & (avs_burstcount == 0));
   assign error = (state[ERROR_BIT]) | (start_error & state[IDLE_BIT]) | (state[WBURST_BIT] & avs_read) | (log_error);
   
   
   // latch the error signal so the FSM can complete outstanding writes and transition to ERROR state when done
   always_ff @(posedge clk) begin
      if(!rst_n) log_error <= '0;
      else if (state[ERROR_BIT] | afu_reset) log_error <= '0;
      else log_error <= log_error | error;
   end

   // write burst completion counter
   always_ff @(posedge clk) begin
      if(!rst_n) wcompl_count <= '0;
      else if(state[IDLE_BIT]) wcompl_count <= avs_burstcount;
      else if(avm_write & !avm_waitrequest) wcompl_count <= wcompl_count - 7'b1; // use avm_write to capture cycles when a write is consumed by the emif
   end

   // error to PORT csr
   always_ff @(posedge clk) begin
      if(!rst_n) emif_prt_error <= '0;
      else       emif_prt_error <= error;
   end

   // busy signal to FME csr
   always_ff @(posedge clk) begin
      if(!rst_n) ddr_clear_busy <= '0;
      else       ddr_clear_busy <= state[CLEAR_BIT] | log_clear; // assert ddr_clear_busy during write completion
   end
   
  //***************************************************
  //************* Clearing Logic **********************
   // counter:
   // * count every beat sent
   // * subtract burst bits and use remaining top bits as avmm base address (note: emif is word addressed)


   // logical separation of clearing registers for better timing
  (* altera_attribute = {"-name MAX_FANOUT 64"}*)
  logic   clearing_addr = '0;
  (* altera_attribute = {"-name MAX_FANOUT 64"}*)
  logic   clearing_data = '0;   
  logic   clearing      = '0;       // When active, we are currently clearing.

  logic  last_clear_cond;
  logic   last_clear_r;   // Asserted during last clear write
  
`ifdef SIM_MODE   // SIM_MODE use a smaller count
   assign  last_clear_cond = (clear_count == MAX_SIM_CLEAR-2) && !avm_waitrequest;
`else            // Not in sim mode, Assert last_clear_r when it will be all 1's on the next clock cycle
   assign  last_clear_cond = &{clear_count[ADDRESS_W-1:1],~clear_count[0],~avm_waitrequest};
`endif

   // Latch the ddr_clear_en incoming signal and hold until we get to the clear state
   always_ff @(posedge clk) begin
      if(!rst_n)                  log_clear <= '0;
      else if (state[CLEAR_BIT])  log_clear <= '0;
      else                        log_clear <= log_clear | ddr_clear_en;
   end
  
  // last_clear_r is a flag that inicates this clock cycle is the last clearing write (if it's accepted)
  always_ff @(posedge clk) begin
    if(state[IDLE_BIT])       last_clear_r <= 1'b0;
    else if (last_clear_cond) last_clear_r <= 1'b1;
  end

  always_ff @(posedge clk) begin
    if(!clearing)             clear_count <= '0;
    else if(!avm_waitrequest) clear_count <= clear_count + 'd1;
  end
   
  always_ff @(posedge clk) begin
    if(state[IDLE_BIT]) begin
       clearing       <= log_clear; // 1st clock cycle in the clear state
       clearing_data  <= log_clear; 
       clearing_addr  <= log_clear; 
    end else if(last_clear_r & ~avm_waitrequest)  begin
       clearing       <= '0; // Last write
       clearing_data  <= '0; // Last write
       clearing_addr  <= '0; // Last write
    end
  end 
    
  // ******** End Clearing Logic *************
  //******************************************
  
  //***************************
  //****** State Machine ******
   always_comb begin
      next = XXX;
      unique case (1'b1)
  state[IDLE_BIT]: begin
     if(log_clear) next = CLEAR;
     else if (start_error) begin
        next = ERROR;
     end
     else if ((avs_write & (avs_burstcount > 1)) & ~avm_waitrequest) next = WBURST;
     else next = IDLE;
  end
  // Write burst state. We exit on an error (read during write) or when the write completes, or when a clear command or reset preempts
  state[WBURST_BIT]: begin
     if (avs_read) begin  // If a read occurs during write, we'll still let this write through but we'll flag an error and move to completion
                                      next = WCOMPL;
     end
     else if (!avm_waitrequest & avs_write & (wcompl_count == 2) & !log_clear)      next = IDLE;    // Write burst is ending
     else if (log_clear | afu_reset)  next = WCOMPL;  // Preempted by clear or reset
     else                             next = WBURST;  // Continue bursting
  end
  // Write completion state. We get here from the burst state
  state[WCOMPL_BIT]: begin
     if (wcompl_count == 2) begin
        if(log_error) next = ERROR;
        else next = IDLE;
     end
     else next = WCOMPL;
  end
  // Clear state. We got here from the IDLE state
  state[CLEAR_BIT]:
    begin
       if(~clearing)  next = IDLE;  // Clearing starts the same cycle we get here and ends one clock cycle before we leave
      else            next = CLEAR;
    end

  state[ERROR_BIT]:
    begin
       if(afu_reset & !start_error) next = IDLE;
       else next = ERROR;
    end
      endcase // case (1'b1)
   end // always_comb begin

  //******** End State Machine **********
  //*************************************
   
   assign clear_address = { clear_count[ADDRESS_W-1 : BURSTCOUNT_W-1] , {(BURSTCOUNT_W-1){1'b0}} };
   
   // command
   assign avm_write      = clearing | state[WCOMPL_BIT] | (avs_write & ~error & ~log_clear & ~state[CLEAR_BIT]) ; 

   assign avm_read       = avs_read  & ~start_error & state[IDLE_BIT]; // only allow reads through during idle

   assign avm_byteenable = clearing      ? '1 : avs_byteenable;
   assign avm_writedata  = clearing_data ? '0 : avs_writedata;
   assign avm_burstcount = clearing      ? MAX_BURST : avs_burstcount;
   assign avm_address    = clearing_addr ? clear_address : avs_address;
   
   // response
   assign avs_waitrequest   = avm_waitrequest | (state[CLEAR_BIT]) | (state[WCOMPL_BIT]) | (state[ERROR_BIT]);
   assign avs_readdata      = avm_readdata;
   assign avs_readdatavalid = avm_readdatavalid;

endmodule // avmm_chkr
