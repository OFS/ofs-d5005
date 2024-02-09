// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// MSIX wrapper module
//    * Receive irq and generate appropriate interrupts
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;



module msix_wrapper (
   input                             clk,
   input                             rst_n, 
   // MSI-X to PCIe                            
   output [63:0]                     o_msix_addr,                
   output                            o_msix_valid,                
   output [31:0]                     o_msix_data,             
   
   input  [FIM_NUM_PF-1:0]           a2c_msix_en_pf,
   input  [FIM_NUM_PF-1:0]           a2c_msix_fn_mask_pf,

   input                             vf_msix_mask,
   
   //FME
   output                            o_intr_valid,
   output [L_NUM_AFU_INTERRUPTS-1:0] o_intr_id,    
   output                            o_vintr_valid, 
   output [L_NUM_AFU_INTERRUPTS-1:0] o_vintr_id,   
   input logic                       i_msix_st_tready,

   input  [95:0]                     i_msix_table_entry, 
   input  [L_NUM_AFU_INTERRUPTS:0]   i_intr_id, 
   input                             i_intr_val,

   input                             fme_irq,
   input                             port_irq_in,
   input   [3:0]                     user_irq, 
   input   [PORTS-1:0]               vf_active,

   input   [NUM_AFU_INTERRUPTS -1:0] pf_mask_vector, 
   input   [NUM_AFU_INTERRUPTS -3:0] vf_mask_vector,
   input   [NUM_AFU_INTERRUPTS -1:0] pba_sclr, 
   // PBA
   output  [63:0]                    inp2cr_msix_pba,
   input   [63:0]                    cr2out_msix_pba,
   output  [63:0]                    inp2cr_msix_vpba,
   input   [63:0]                    cr2out_msix_vpba
 );

   logic [NUM_AFU_INTERRUPTS-1:0]    pf_irq_vector; 
   logic [NUM_AFU_INTERRUPTS-3:0]    vf_irq_vector;

   //Port IRQ 
   logic [1:0] port_irq_sync, port_irq_pulse;
   logic port_irq_edge, port_irq_out;

   always@(posedge clk) begin
      if (~rst_n) begin
         port_irq_sync  <= '0;
         port_irq_pulse <= '0;
      end else begin
         port_irq_sync  <= {port_irq_sync[0],  port_irq_in};
         port_irq_pulse <= {port_irq_pulse[0], port_irq_edge};
      end
   end 

   assign port_irq_edge = ~port_irq_sync[1] & port_irq_sync[0];
   assign port_irq_out  = port_irq_pulse[1] ^ port_irq_pulse[0];

   //FME IRQ - *NEW*
   logic [1:0] fme_irq_sync, fme_irq_pulse;
   logic fme_irq_edge, fme_irq_out;

   always@(posedge clk) begin
      if (~rst_n) begin
         fme_irq_sync  <= '0;
         fme_irq_pulse <= '0;
      end else begin
         fme_irq_sync  <= {fme_irq_sync[0],  fme_irq};
         fme_irq_pulse <= {fme_irq_pulse[0], fme_irq_edge};
      end
   end 

   assign fme_irq_edge = ~fme_irq_sync[1] & fme_irq_sync[0];
   assign fme_irq_out  = fme_irq_pulse[1] ^ fme_irq_pulse[0];

   always_comb begin 
      pf_irq_vector[NUM_AFU_INTERRUPTS-1:NUM_AFU_INTERRUPTS-2] = {fme_irq_out, 1'b0};
      pf_irq_vector[4:0] = (vf_active[0]) ? '0 : {port_irq_out, user_irq};
      vf_irq_vector      = (vf_active[0]) ? {port_irq_out, user_irq} : '0;
   end   

   msix_fme_bridge msix_fme_bridge_inst( 
      .clk                     (clk), 
      .rst_n                   (rst_n),

      .o_msix_addr             (o_msix_addr),
      .o_msix_valid            (o_msix_valid),
      .o_msix_data             (o_msix_data),
      
      .i_msix_st_tready        (i_msix_st_tready),
      .i_msix_table_entry      (i_msix_table_entry),
      .i_intr_id               (i_intr_id),         
      .msix_req_assert         (i_intr_val)    
   );
   
   msix_pba_update  msix_pba(
      .clk                    (clk), 
      .rst_n                  (rst_n),

      .pf_irq_vector          (pf_irq_vector),
      .pf_mask_vector         (pf_mask_vector),
      .pf_msix_mask           (a2c_msix_fn_mask_pf),

      .vf_irq_vector          (vf_irq_vector), 
      .vf_mask_vector         (vf_mask_vector), 
      .vf_msix_mask           (vf_msix_mask),

      .inp2cr_msix_pba        (inp2cr_msix_pba),  
      .cr2out_msix_pba        (cr2out_msix_pba),  
      .inp2cr_msix_vpba       (inp2cr_msix_vpba), 
      .cr2out_msix_vpba       (cr2out_msix_vpba),

      .pba_sclr               (pba_sclr),
      .o_intr_valid           (o_intr_valid),
      .o_intr_id              (o_intr_id),     
      .o_vintr_valid          (o_vintr_valid), 
      .o_vintr_id             (o_vintr_id)
   );
   
endmodule

