// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Module instantiates CDC strobes, synchronizers, etc. for FLR control
// signals between PCIE EP & CoreFIM. 
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module pcie_flr_resync (
   input  logic                    avl_clk,
   input  logic                    avl_rst_n,

   input  logic                    fim_clk,
   input  logic                    fim_rst_n,
   
   // To/From PCIE Top <-> CoreFIM
   output t_sideband_from_pcie     pcie_p2f_sideband,
   input  t_sideband_to_pcie       pcie_c2p_sideband, 

   // To/From PCIE EP <-> PCIE Top 
   input   t_sideband_from_pcie    p2f_sideband,
   output  t_sideband_to_pcie      f2p_sideband
);


   //CDC Signals 
   logic  p2f_latched_ack, p2f_latched_valid, p2f_latched_valid_r; //PCIe to FLR Resync 
   logic  f2p_latched_vf_ack, f2p_latched_vf_valid, f2p_latched_vf_valid_q; //CoreFim to FLR Resync 
   logic  flr_completed_vf_strobe, flr_latched_vf_strobe_sync1, flr_latched_vf_strobe_sync2;

   t_sideband_from_pcie pcie_p2f_sb;
   t_sideband_to_pcie   pcie_f2p_sb;

   //------------------------
   // CDC into PCIE EP 
   //------------------------
   // VF FLR completion status
   fim_cross_handshake #(
      .WIDTH      (1+FIM_PF_WIDTH+FIM_VF_WIDTH)
   ) cfim_to_pcie_vf_hs(
      .din_clk    (fim_clk),
      .din_srst   (~fim_rst_n),
      .din        ({pcie_c2p_sideband.flr_completed_vf,
                    pcie_c2p_sideband.flr_completed_pf_num, 
		    pcie_c2p_sideband.flr_completed_vf_num
                  }),
      .din_valid  (pcie_c2p_sideband.flr_completed_vf), 
      .din_ack    (),
      .dout_clk   (avl_clk),
      .dout_srst  (~avl_rst_n),
      .dout_ack   (f2p_latched_vf_ack),
      .dout_valid (f2p_latched_vf_valid),
      .dout       ({pcie_f2p_sb.flr_completed_vf, 
                    pcie_f2p_sb.flr_completed_pf_num,
		    pcie_f2p_sb.flr_completed_vf_num
                    })
   );

   always_ff @(posedge avl_clk) begin
      f2p_latched_vf_valid_q      <= f2p_latched_vf_valid;
      flr_completed_vf_strobe     <= (~f2p_latched_vf_valid_q & f2p_latched_vf_valid);
      flr_latched_vf_strobe_sync1 <= flr_completed_vf_strobe;
      flr_latched_vf_strobe_sync2 <= flr_latched_vf_strobe_sync1;
   end 

   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n) begin
         f2p_latched_vf_ack <= 1'b0;
      end else begin 
         f2p_latched_vf_ack <= f2p_latched_vf_valid & flr_latched_vf_strobe_sync2;
      end 
   end 

   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n) begin 
         f2p_sideband.flr_completed_vf      <= 1'b0;
         f2p_sideband.flr_completed_pf_num  <= '0;
         f2p_sideband.flr_completed_vf_num  <= '0;
      end 
      else if (flr_latched_vf_strobe_sync2) begin 
	 f2p_sideband.flr_completed_vf      <= pcie_f2p_sb.flr_completed_vf;
         f2p_sideband.flr_completed_pf_num  <= pcie_f2p_sb.flr_completed_pf_num;
         f2p_sideband.flr_completed_vf_num  <= pcie_f2p_sb.flr_completed_vf_num;
      end 
      else begin 
	 f2p_sideband.flr_completed_vf      <= 1'b0;   
      end
   end 

   // PF FLR completion status
   fim_resync #(
       .SYNC_CHAIN_LENGTH (3),
       .WIDTH             (FIM_NUM_PF),
       .INIT_VALUE        (0),
       .NO_CUT            (1)
   ) pf_flr_sts_resync (
       .clk   (avl_clk),
       .reset (~avl_rst_n),
       .d     (pcie_c2p_sideband.flr_completed_pf),
       .q     (f2p_sideband.flr_completed_pf)
   );
    
   //---------------------
   // CDC into CoreFIM
   //---------------------
   // PF FLR
   fim_resync #(
       .SYNC_CHAIN_LENGTH (3),
       .WIDTH             (FIM_NUM_PF),
       .INIT_VALUE        (0),
       .NO_CUT            (1)
   ) pf_flr_resync (
       .clk   (fim_clk),
       .reset (~fim_rst_n),
       .d     (p2f_sideband.flr_active_pf),
       .q     (pcie_p2f_sideband.flr_active_pf)
   );

   // VF FLR
   fim_cross_handshake #(
      .WIDTH (1+FIM_PF_WIDTH+FIM_VF_WIDTH)
   ) pcie_to_cfim_hs (
      .din_clk       (avl_clk),
      .din_srst      (~avl_rst_n), 
      .din           ({p2f_sideband.flr_rcvd_vf, 
                       p2f_sideband.flr_rcvd_pf_num, 
                       p2f_sideband.flr_rcvd_vf_num
   	             }),  
      .din_valid     (p2f_sideband.flr_rcvd_vf),
      .din_ack       (),
      .dout_clk      (fim_clk),
      .dout_srst     (~fim_rst_n),
      .dout_ack      (p2f_latched_ack),
      .dout_valid    (p2f_latched_valid),
      .dout          ({pcie_p2f_sb.flr_rcvd_vf, 
                       pcie_p2f_sb.flr_rcvd_pf_num,
		       pcie_p2f_sb.flr_rcvd_vf_num
                     })
   );

   always_ff @(posedge fim_clk) begin 
      p2f_latched_valid_r <= p2f_latched_valid;
   end

   always_ff @(posedge fim_clk) begin
      if (~fim_rst_n) begin
         p2f_latched_ack <= 1'b0;
      end else begin 
         p2f_latched_ack <= p2f_latched_valid & ~p2f_latched_valid_r;
      end 
   end 

   always_ff @(posedge fim_clk) begin
      if (~fim_rst_n) begin 
         pcie_p2f_sideband.flr_rcvd_vf      <= 1'b0;
         pcie_p2f_sideband.flr_rcvd_pf_num  <= '0;
         pcie_p2f_sideband.flr_rcvd_vf_num  <= '0;
      end 
      else if (p2f_latched_valid) begin 
	 pcie_p2f_sideband.flr_rcvd_vf      <= pcie_p2f_sb.flr_rcvd_vf;
         pcie_p2f_sideband.flr_rcvd_pf_num  <= pcie_p2f_sb.flr_rcvd_pf_num;
         pcie_p2f_sideband.flr_rcvd_vf_num  <= pcie_p2f_sb.flr_rcvd_vf_num;
      end 
      else begin 
	 pcie_p2f_sideband.flr_rcvd_vf      <= 1'b0;  
      end
   end 

endmodule
