// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// MSIX Bridge
//    * Receives the changes in the msix table entry and writes the interrut 
//      into a FIFO.
// 
//
//-----------------------------------------------------------------------------
import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;


module msix_fme_bridge (
   input                          clk,
   input                          rst_n,
   // MSI-X  
   output logic [63:0]            o_msix_addr,                
   output logic [31:0]            o_msix_data,             
   output logic                   o_msix_valid,             
   
   input  [95:0]                  i_msix_table_entry,
   input [L_NUM_AFU_INTERRUPTS:0] i_intr_id,          // from FME
   input                          msix_req_assert, 
   input  logic                   i_msix_st_tready
);

   localparam INTR_ID_WIDTH = 2;
   localparam ADDR_WIDTH = 64;
   localparam DATA_WIDTH = 32;
   localparam MSIX_FIFO_WIDTH = INTR_ID_WIDTH + ADDR_WIDTH + DATA_WIDTH;
   localparam CTL_SHDW_HBIT = 10;

   wire wfull, rempty;
   logic fme_msix_req, fifo_msix_req;
   logic [63:0] fifo_msix_addr;                
   logic [31:0] fifo_msix_data;  
   logic [L_NUM_AFU_INTERRUPTS:0] fifo_intr_id;
   logic fifo_msix_req_q;
   logic rdempty_q;
   
   assign fme_msix_req = ~wfull & msix_req_assert; 
   assign fifo_intr_id[L_NUM_AFU_INTERRUPTS-2:L_NUM_AFU_INTERRUPTS-3] = 'b0;

   fim_scfifo # ( 
   .USE_EAB("ON"),
   .DATA_WIDTH(MSIX_FIFO_WIDTH))
   msix_scfifo (
      .sclr   (~rst_n),
      .clk    (clk),
      .w_data ({i_intr_id[L_NUM_AFU_INTERRUPTS:L_NUM_AFU_INTERRUPTS-1], i_msix_table_entry[63:0], i_msix_table_entry[95:64]}),
      .w_req  (fme_msix_req),
      .w_full (wfull),
      .r_data ({fifo_intr_id[L_NUM_AFU_INTERRUPTS:L_NUM_AFU_INTERRUPTS-1], fifo_msix_addr, fifo_msix_data}),
      .r_req  (fifo_msix_req),
      .r_empty(rempty),
      .w_usedw(),
      .r_usedw(),
      .r_valid()
   );
   
   typedef enum logic {
      IDLE, 
      WR_INTR
   } fsm_state;
   
   fsm_state state, next_state; 
   
   assign fifo_msix_req = ~rdempty_q  & ~fifo_msix_req_q & (state==IDLE);  
   assign o_msix_valid =  (state == WR_INTR);

   always@(*) begin
      case(state)
         IDLE:
         if(fifo_msix_req_q) begin
            next_state = WR_INTR;
         end else begin
            next_state = IDLE;
         end
               
         WR_INTR: begin
            if(i_msix_st_tready) begin
               next_state = IDLE;
            end else begin
               next_state = WR_INTR;
            end
         end
                  
         default: begin
            next_state = IDLE;
         end
      endcase
   end 
   
   always @ (posedge clk) begin
      if(~rst_n) begin
         state <= IDLE;
      end else begin
         state <= next_state;
      end
   end
   
   always @(posedge clk) begin
      if(~rst_n) begin
         o_msix_addr       <= '0;                
         o_msix_data       <= '0;
         fifo_msix_req_q   <= 1'b0;
         rdempty_q         <= 1'b1;
      end else begin
         rdempty_q         <= rempty;
         fifo_msix_req_q   <= fifo_msix_req;
         case (state)
            IDLE: begin
               o_msix_addr        <= fifo_msix_addr;                
               o_msix_data        <= fifo_msix_data;
            end
                        
            WR_INTR: begin
               o_msix_addr        <= fifo_msix_addr;                
               o_msix_data        <= fifo_msix_data;
            end
               
            default: begin 
               o_msix_addr        <= fifo_msix_addr;                
               o_msix_data        <= fifo_msix_data;
            end
         endcase
      end
   end
   endmodule
