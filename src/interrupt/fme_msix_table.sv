// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// FME_MSIX_TABLE
//   *Implments the MSI-X entry look up table for PF MSI-X inputs and implments the 
//    vfme_csr for VF interrupts. 
//   *Also implments the sclr for FME RW1C and negedge detection for FME RO regs
//-----------------------------------------------------------------------------
import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;

module fme_msix_table (
   input                             clk,
   input                             rst_n,  
   // dcp Interrupt signals 
   input                             i_intr_valid,
   input  [L_NUM_AFU_INTERRUPTS-1:0] i_intr_id, 
   input                             i_vintr_valid,
   input  [L_NUM_AFU_INTERRUPTS-1:0] i_vintr_id, 

   output logic [95:0]               o_msix_table_entry,
   output logic                      o_intr_val,
   output logic [L_NUM_AFU_INTERRUPTS:0] o_intr_id,

   output [NUM_AFU_INTERRUPTS -1:0]  pf_mask_vector,
   output [NUM_AFU_INTERRUPTS -3:0]  vf_mask_vector,
   // MSIX Table Entries
   input logic [63:0]                cr2out_msix_addr0, 
   input logic [63:0]                cr2out_msix_addr1, 
   input logic [63:0]                cr2out_msix_addr2, 
   input logic [63:0]                cr2out_msix_addr3,
   input logic [63:0]                cr2out_msix_addr4, 
   input logic [63:0]                cr2out_msix_addr5, 
   input logic [63:0]                cr2out_msix_addr6, 
   input logic [63:0]                cr2out_msix_addr7,
   input logic [63:0]                cr2out_msix_ctldat0, 
   input logic [63:0]                cr2out_msix_ctldat1,
   input logic [63:0]                cr2out_msix_ctldat2, 
   input logic [63:0]                cr2out_msix_ctldat3,
   input logic [63:0]                cr2out_msix_ctldat4, 
   input logic [63:0]                cr2out_msix_ctldat5, 
   input logic [63:0]                cr2out_msix_ctldat6, 
   input logic [63:0]                cr2out_msix_ctldat7, 
   // MSIX Virtual FME Signals
   input logic [63:0]                cr2out_msix_vaddr0, 
   input logic [63:0]                cr2out_msix_vaddr1, 
   input logic [63:0]                cr2out_msix_vaddr2, 
   input logic [63:0]                cr2out_msix_vaddr3,
   input logic [63:0]                cr2out_msix_vaddr4, 
   input logic [63:0]                cr2out_msix_vctldat0, 
   input logic [63:0]                cr2out_msix_vctldat1,
   input logic [63:0]                cr2out_msix_vctldat2, 
   input logic [63:0]                cr2out_msix_vctldat3,
   input logic [63:0]                cr2out_msix_vctldat4
);

   logic [95:0]   o_msix_vtable_entry, o_msix_ptable_entry;    
   logic i_intr_valid_sync, i_vintr_valid_sync;
   logic [L_NUM_AFU_INTERRUPTS-1:0] i_intr_id_sync, i_vintr_id_sync;
   logic vf_id_sel;

   //-----------------------------------------------------------------------------
   // MSI-X data selection
   //----------------------------------------------------------------------------- 
   //dcp:msix
   always @(posedge clk) begin 
      if (!rst_n) begin
         i_intr_valid_sync <= 0;
         i_intr_id_sync    <= 0;
         o_msix_ptable_entry <= 96'd0;
      end else begin
         case(i_intr_id)
            3'd0: o_msix_ptable_entry <= {cr2out_msix_ctldat0[31:0], cr2out_msix_addr0}; // afu - intr0
            3'd1: o_msix_ptable_entry <= {cr2out_msix_ctldat1[31:0], cr2out_msix_addr1}; // afu - intr1 
            3'd2: o_msix_ptable_entry <= {cr2out_msix_ctldat2[31:0], cr2out_msix_addr2}; // afu - intr2
            3'd3: o_msix_ptable_entry <= {cr2out_msix_ctldat3[31:0], cr2out_msix_addr3}; // afu - intr3 
            3'd4: o_msix_ptable_entry <= {cr2out_msix_ctldat4[31:0], cr2out_msix_addr4}; // port- intr4
            3'd6: o_msix_ptable_entry <= {cr2out_msix_ctldat6[31:0], cr2out_msix_addr6}; // FME - intr6
            default: o_msix_ptable_entry <= 96'd0;
         endcase
         i_intr_valid_sync <= i_intr_valid;
         i_intr_id_sync    <= i_intr_id; 
      end
   end 

   always @(posedge clk) begin
      if (!rst_n) begin
         vf_id_sel  <= 0;
         o_intr_id  <= 0; 
         o_intr_val <= 0;
         o_msix_table_entry <= 0;
      end else begin
         vf_id_sel  <= i_intr_valid && (i_intr_id !='h6);
         o_intr_id  <= {vf_id_sel, vf_id_sel ? i_vintr_id_sync : i_intr_id_sync}; 
         o_intr_val <= i_intr_valid_sync | i_vintr_valid_sync;
         o_msix_table_entry <= (i_vintr_valid_sync && (i_intr_id_sync !='h6)) ? o_msix_vtable_entry : o_msix_ptable_entry; 
      end
   end
   
   assign pf_mask_vector = {  cr2out_msix_ctldat6[32],
                              cr2out_msix_ctldat5[32],
                              cr2out_msix_ctldat4[32],
                              cr2out_msix_ctldat3[32],
                              cr2out_msix_ctldat2[32],
                              cr2out_msix_ctldat1[32],
                              cr2out_msix_ctldat0[32]
                           };
                           

   assign vf_mask_vector = {  cr2out_msix_vctldat4[32],
                              cr2out_msix_vctldat3[32],
                              cr2out_msix_vctldat2[32],
                              cr2out_msix_vctldat1[32],
                              cr2out_msix_vctldat0[32]
                           }; 
   always_ff @(posedge clk) begin 
      case(i_vintr_id)
         3'd0: o_msix_vtable_entry <= {cr2out_msix_vctldat0[31:0], cr2out_msix_vaddr0}; // afu - intr0
         3'd1: o_msix_vtable_entry <= {cr2out_msix_vctldat1[31:0], cr2out_msix_vaddr1}; // afu - intr1 
         3'd2: o_msix_vtable_entry <= {cr2out_msix_vctldat2[31:0], cr2out_msix_vaddr2}; // afu - intr2
         3'd3: o_msix_vtable_entry <= {cr2out_msix_vctldat3[31:0], cr2out_msix_vaddr3}; // afu - intr3 
         3'd4: o_msix_vtable_entry <= {cr2out_msix_vctldat4[31:0], cr2out_msix_vaddr4}; // port- intr4
         default:o_msix_vtable_entry <= 96'd0;
      endcase
      i_vintr_valid_sync <= i_vintr_valid;
      i_vintr_id_sync    <= i_vintr_id; 
   end 
endmodule
