// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// MSIX PBA Update Table
//    * Updates the PBA table based on the type of error received from the error vector
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;

module msix_pba_update (
   input                                   clk, 
   input                                   rst_n,
   // MSI-X  
   output logic [63:0]                     inp2cr_msix_pba,
   input        [63:0]                     cr2out_msix_pba, 

   input  [NUM_AFU_INTERRUPTS -1:0]        pf_irq_vector,
   input  [NUM_AFU_INTERRUPTS -3:0]        vf_irq_vector, 

   input  [NUM_AFU_INTERRUPTS -1:0]        pf_mask_vector,
   input  [NUM_AFU_INTERRUPTS -3:0]        vf_mask_vector,
   input  [NUM_AFU_INTERRUPTS -1:0]        pba_sclr, 
   
   input                                   pf_msix_mask,
   input                                   vf_msix_mask,

   output logic                            o_intr_valid,
   output logic [L_NUM_AFU_INTERRUPTS-1:0] o_intr_id,

   output logic                            o_vintr_valid, //to vFME
   output logic [L_NUM_AFU_INTERRUPTS-1:0] o_vintr_id,    //to vFME

   output logic [63:0]                     inp2cr_msix_vpba,
   input  [63:0]                           cr2out_msix_vpba
);
                        
   logic [NUM_AFU_INTERRUPTS -1:0]  pf_monitor_wire;
   logic [NUM_AFU_INTERRUPTS -1:0]  pf_priority_wire;
   logic [NUM_AFU_INTERRUPTS -1:0]  pf_irq_monitor;
   logic [NUM_AFU_INTERRUPTS -1:0]  pf_irq_sync1;
   logic [NUM_AFU_INTERRUPTS -1:0]  pf_irq_edge_vector; // detect falling edge
   logic [L_NUM_AFU_INTERRUPTS-1:0] o_intr_id_sync1,o_intr_id_sync2;  

   //PF space
   //Monitors when the inputs change or when irq occurs
   always_comb begin
      for (int i=0; i<NUM_AFU_INTERRUPTS; i=i+1) begin
         pf_monitor_wire[i] = ((cr2out_msix_pba[i] | pf_irq_vector[i]) & ~pba_sclr[i]) ;
      end
   end
   
   //Updates the pba table about the type of interupt occured. Interrupts are serviced based on priority table. 
   always_comb begin
      casez(pf_monitor_wire)
         7'b1??????:pf_priority_wire = 7'h40;
         7'b??1????:pf_priority_wire = 7'h10;
         7'b???1???:pf_priority_wire = 7'h08;
         7'b????1??:pf_priority_wire = 7'h04;
         7'b?????1?:pf_priority_wire = 7'h02;
         7'b??????1:pf_priority_wire = 7'h01;
         default   :pf_priority_wire = 7'h00;
      endcase
   end

   //Send interrupt vector if not masked
   always @(posedge clk) begin
      if(~rst_n) begin
         inp2cr_msix_pba <= 'b0;
         pf_irq_monitor  <= 'b0;
      end
      else begin
         for (int i=0; i<NUM_AFU_INTERRUPTS; i=i+1) begin
            // Assert IRQ for 2 CC due to FME CSR in-> out
            if(pf_mask_vector[i] || pf_msix_mask) begin
               inp2cr_msix_pba[i] <= pf_monitor_wire[i];
               pf_irq_monitor[i]  <= 'b0;
            end
            else begin
               inp2cr_msix_pba[i] <= (pba_sclr[i] | pf_priority_wire [i])?'b0: cr2out_msix_pba[i];
               pf_irq_monitor[i]  <= pf_monitor_wire[i];
            end
         end
      end
      inp2cr_msix_pba[63:7] <= 'b0;
   end
   
   //Edge detection for valid signal
   always@(posedge clk) begin 
      if (~rst_n) begin 
         pf_irq_sync1  <= 0;
      end else begin
         pf_irq_sync1  <= pf_irq_monitor;
      end
   end 
   
   always@(posedge clk) begin
      for(int i = 0; i < NUM_AFU_INTERRUPTS; i++)
         pf_irq_edge_vector[i] <= pf_irq_sync1[i] & ~pf_irq_monitor[i];   
      end
   
   //Output intr id & intr valid
   always @(posedge clk) begin
      if(~rst_n) begin
         o_intr_id       <= '0;
         o_intr_valid    <= '0;
         o_intr_id_sync1 <= '0;
         o_intr_id_sync2 <= '0;
      end
      else begin
         casez(pf_irq_monitor)
            7'b1??????: o_intr_id_sync1 <= 3'd6;
            7'b??1????: o_intr_id_sync1 <= 3'd4;
            7'b???1???: o_intr_id_sync1 <= 3'd3;
            7'b????1??: o_intr_id_sync1 <= 3'd2;
            7'b?????1?: o_intr_id_sync1 <= 3'd1;
            7'b??????1: o_intr_id_sync1 <= 3'd0;
            default   : o_intr_id_sync1 <= 3'd0;
         endcase
         o_intr_valid    <=   |pf_irq_edge_vector;
         o_intr_id_sync2 <=   o_intr_id_sync1;
         o_intr_id       <=   o_intr_id_sync2;
      end
   end

   logic [NUM_AFU_INTERRUPTS-3:0] vf_monitor_wire;
   logic [NUM_AFU_INTERRUPTS-3:0] vf_priority_wire;
   logic [NUM_AFU_INTERRUPTS-3:0] vf_irq_monitor;
   logic [NUM_AFU_INTERRUPTS-3:0] vf_irq_sync1;
   logic [NUM_AFU_INTERRUPTS-3:0] vf_irq_edge_vector; // detect falling edge
   logic [L_NUM_AFU_INTERRUPTS-1:0] o_vintr_id_sync1,o_vintr_id_sync2;
   
   //VF space
   //Monitors when the inputs change or when irq occurs
   always_comb begin
      for (int i=0; i<(NUM_AFU_INTERRUPTS-2); i=i+1) begin
         vf_monitor_wire[i] = ((cr2out_msix_vpba[i] | vf_irq_vector[i]) & ~pba_sclr[i]);
      end
   end
   
   //Updates the pba table about the type of interupt occured. Interrupts are serviced based on priority table.
   always_comb begin
      casez(vf_monitor_wire)
         5'b1????:vf_priority_wire = 5'h10;
         5'b?1???:vf_priority_wire = 5'h08;
         5'b??1??:vf_priority_wire = 5'h04;
         5'b???1?:vf_priority_wire = 5'h02;
         5'b????1:vf_priority_wire = 5'h01;
         default :vf_priority_wire = 5'h00;
      endcase
   end
 
   //Send interrupt vector if not masked
   always @(posedge clk) begin
      if(~rst_n) begin
         inp2cr_msix_vpba <= 'b0;
         vf_irq_monitor  <= 'b0;
      end
      else begin
         for (int i=0; i<(NUM_AFU_INTERRUPTS-2); i=i+1) begin
            // Assert IRQ for 2 CC due to FME CSR in-> out
            if(vf_mask_vector[i] || vf_msix_mask) begin
               inp2cr_msix_vpba[i] <= vf_monitor_wire[i];
               vf_irq_monitor[i]   <= 'b0;
            end
            else begin
               inp2cr_msix_vpba[i] <= (pba_sclr[i] | vf_priority_wire [i])?'b0: cr2out_msix_vpba[i];
               vf_irq_monitor[i]   <= vf_monitor_wire[i];
            end
         end
      end
      inp2cr_msix_vpba[63:7] <= 'b0;
   end

   //Edge detection for valid signal
   always@(posedge clk) begin 
      if (~rst_n) begin 
         vf_irq_sync1  <= 0;
      end else begin
         vf_irq_sync1  <= vf_irq_monitor;
      end
   end 
   
   always@(posedge clk) begin
      for(int i = 0; i < (NUM_AFU_INTERRUPTS-2); i++)
         vf_irq_edge_vector[i] <= vf_irq_sync1[i] & ~vf_irq_monitor[i];   
   end
   
   //Output intr id & intr valid
   always @(posedge clk) begin
      if(~rst_n) begin
         o_vintr_id       <= '0;
         o_vintr_id_sync1 <= '0;
         o_vintr_id_sync2 <= '0;
         o_vintr_valid    <= '0;
      end
      else begin
         casez(vf_irq_monitor)
            5'b1????: o_vintr_id_sync1 <= 3'd4;
            5'b?1???: o_vintr_id_sync1 <= 3'd3;
            5'b??1??: o_vintr_id_sync1 <= 3'd2;
            5'b???1?: o_vintr_id_sync1 <= 3'd1;
            5'b????1: o_vintr_id_sync1 <= 3'd0;
            default : o_vintr_id_sync1 <= 3'd0;
         endcase
         o_vintr_valid    <=  |vf_irq_edge_vector;
         o_vintr_id_sync2 <=  o_vintr_id_sync1;
         o_vintr_id       <=  o_vintr_id_sync2;
      end
   end
   endmodule
