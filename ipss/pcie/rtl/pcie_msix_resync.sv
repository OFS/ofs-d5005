// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Module instantiates synchronizers for SHDW control
// signals between PCIE EP & CoreFIM. 
// 
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module pcie_msix_resync (
   
   input  logic                    fim_clk,
   input  logic                    fim_rst_n,

   input  logic                    avl_clk,
   input  logic                    avl_rst_n,

   // To PCIE Top <-> CoreFIM
   output t_sideband_from_pcie     pcie_p2msix_sideband,

   input  logic                    ctl_shdw_update,
   input  logic [1:0]              ctl_shdw_pf_num,
   input  logic [10:0]             ctl_shdw_vf_num,
   input  logic                    ctl_shdw_vf_active,
   input  logic [6:0]              ctl_shdw_cfg,
   output logic                    ctl_shdw_req_all
);
   t_sideband_from_pcie msix2p_sideband;
   
   localparam DATA_WIDTH = $bits(pcie_p2msix_sideband);
   logic vf0_msix_en;

   logic c2a_ctl_shdw_req_all;      // MD - add declaration 12/8/2020

   assign msix2p_sideband.cfg_ctl.max_payload_size    = '0;   
   assign msix2p_sideband.cfg_ctl.max_read_req_size   = '0;   
   assign msix2p_sideband.cfg_ctl.extended_tag_enable = '0;   
   assign msix2p_sideband.cfg_ctl.msix_enable         = '0;   
   assign msix2p_sideband.cfg_ctl.msix_pf_mask_en     = '0;
   assign msix2p_sideband.flr_active_pf               = '0;
   assign msix2p_sideband.flr_rcvd_vf                 = '0;
   assign msix2p_sideband.flr_rcvd_pf_num             = '0;
   assign msix2p_sideband.flr_rcvd_vf_num             = '0;
   assign msix2p_sideband.pcie_linkup                 = '0;
   assign msix2p_sideband.pcie_chk_rx_err_code        = '0;

   // Control Shadow Interface Query -------------------------------------
   // Check status of MSIX Cfg and Masking for PF/VF Config Regs in PCIe core
   // a2c_ctl_shdw_cfg[6:0]
   // [6]: enable field, bit 15 of ATX Ctrl reg
   // [5]: TPH Requester enable, bit 8 of TPH Requester Ctrl reg
   // [4:3]: TPH ST Mode select field, [1:0] TPH Requester Ctrl Reg
   // [2]: MSIX enable, bit 14 MSIX MSG Ctrl reg
   // [1]: MSIX fucntion mask bit, bit 14 MSIx Message Ctrl Reg
   // [0]: Bus master enable, bit 2 of PCI Cmd reg
   always @(posedge avl_clk) 
      if (~avl_rst_n) begin
         vf0_msix_en                           <= 1'b0;
         msix2p_sideband.cfg_ctl.vf0_msix_mask <= 1'b0;
      end 
      else if (ctl_shdw_update) begin 
         if (ctl_shdw_vf_active & ctl_shdw_vf_num==0) begin 
            vf0_msix_en                           <= ctl_shdw_cfg[2];
            msix2p_sideband.cfg_ctl.vf0_msix_mask <= ctl_shdw_cfg[1];
         end else begin
            vf0_msix_en                           <= 1'b0;
            msix2p_sideband.cfg_ctl.vf0_msix_mask <= 1'b0;
         end
      end

   assign c2a_ctl_shdw_req_all = 'b1;

   //Synchronizing sideband signals to fim_clk
   fim_resync # (
   .WIDTH(DATA_WIDTH),
   .NO_CUT(0)        )
   sync (
      .clk     (fim_clk), 
      .reset   (~fim_rst_n),  
      .d       (msix2p_sideband),  
      .q       (pcie_p2msix_sideband)
   );
   
endmodule


   
 





