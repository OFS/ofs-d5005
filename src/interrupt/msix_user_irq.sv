// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// MSIX User IRQ module
//    * This module handles user_irq generation
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;

module msix_user_irq (
   input               clk,
   input               rst_n,
   input  logic [3:0]  i_user_irq,
   input               i_afu_irq,
   input               i_afu_irq_valid,
   input               i_rsp_ack,
   input               i_msix_mask,
   input [3:0]         i_mask_vector,
   
   output              o_afu_msix_req_tready,
   output logic [3:0]  user_irq_out
);

   logic [3:0] user_irq, user_irq_sync, user_irq_edge;
   logic fifo_rd,fifo_wr;
   logic [3:0] fifo_out;
   logic fifo_full, fifo_empty, fifo_out_valid, w_ready;
   logic msix_ack;
   logic [3:0] mask_bit;

   localparam IRQ_WIDTH         = $size(i_user_irq);
   localparam DATA_WIDTH        = IRQ_WIDTH;
   
   //Back pressure logic to AFU
   assign o_afu_msix_req_tready = ~fifo_full;
   
   always_comb begin
      for (int irq=0; irq<IRQ_WIDTH; ++irq) begin
         mask_bit[irq] = ((user_irq[irq] && i_mask_vector[irq]) || i_msix_mask) ? 1'b1 : 1'b0;
      end 
   end
   
   assign msix_ack = (i_rsp_ack) ? 'b1: 'b0;

   typedef enum logic [1:0] {READ, ACK_WAIT, IDLE} fifo_state_t;
   fifo_state_t state, next_state;
   
   always_ff@(posedge clk) begin 
      if (~rst_n) begin
         state <= IDLE;
         fifo_out_valid <= 1'b0;
      end else begin 
         state          <= next_state;
         fifo_out_valid <= fifo_rd;
      end
   end

   always_comb begin 
      case(state)
         IDLE: 
         if (!fifo_empty) begin
            next_state = READ;
         end else begin
            next_state = IDLE;
         end

         READ:                      
         next_state = ACK_WAIT;

         ACK_WAIT:
         if(msix_ack || (|mask_bit)) begin
            next_state = IDLE;
         end else begin
            next_state = ACK_WAIT;
         end

         default: next_state = IDLE;
      endcase
   end 

   always_comb begin 
      fifo_wr = i_afu_irq & i_afu_irq_valid  & ~fifo_full & w_ready;
      fifo_rd = (state == READ);
   end 

   fim_scfifo # ( 
   .USE_EAB("ON"),
   .DATA_WIDTH(DATA_WIDTH))
   user_scfifo (
      .sclr    (~rst_n),
      .clk     (clk),
      .w_data  (i_user_irq),
      .w_req   (fifo_wr),
      .w_full  (fifo_full),
      .r_data  (fifo_out),
      .r_req   (fifo_rd),
      .r_empty (fifo_empty),
      .w_ready (w_ready),
      .w_usedw (),
      .r_usedw (),
      .r_valid ()
   );

   always_ff @(posedge clk) begin
      if(~rst_n) begin
         user_irq <= '0;
      end else if(fifo_out_valid) begin
         case(fifo_out)
            4'h0: user_irq <= 4'b0001;
            4'h1: user_irq <= 4'b0010;
            4'h2: user_irq <= 4'b0100;
            4'h3: user_irq <= 4'b1000;
         endcase
      end else 
         user_irq <= '0;
   end

   always_ff @(posedge clk) begin
      if(~rst_n) begin
         user_irq_sync <= '0;
      end else begin
         user_irq_sync <= user_irq;
      end
   end
   
   assign user_irq_edge[3] = user_irq_sync[3] & ~user_irq[3];
   assign user_irq_edge[2] = user_irq_sync[2] & ~user_irq[2];
   assign user_irq_edge[1] = user_irq_sync[1] & ~user_irq[1];
   assign user_irq_edge[0] = user_irq_sync[0] & ~user_irq[0];

   assign user_irq_out[3] = user_irq_edge[3] ^ user_irq[3];
   assign user_irq_out[2] = user_irq_edge[2] ^ user_irq[2];
   assign user_irq_out[1] = user_irq_edge[1] ^ user_irq[1];
   assign user_irq_out[0] = user_irq_edge[0] ^ user_irq[0];       
   
endmodule


