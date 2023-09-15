// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Top level module of PCIe subsystem.
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module pcie_top (
   input  logic                    fim_clk,
   input  logic                    fim_rst_n,
   input  logic                    ninit_done,
   input  logic                    npor,
   output logic                    reset_status, 
   
   // PCIe pins
   input  logic                     pin_pcie_ref_clk_p,
   input  logic                     pin_pcie_in_perst_n,   // connected to HIP
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,

   ofs_fim_pcie_rxs_axis_if.master  axis_rx_st,
   ofs_fim_pcie_txs_axis_if.slave   axis_tx_st,

   ofs_fim_axi_mmio_if.slave        csr_if,
   ofs_fim_irq_axis_if.master       irq_if,

   output t_sideband_from_pcie      pcie_p2c_sideband,
   input  t_sideband_to_pcie        pcie_c2p_sideband
);

localparam TOTAL_AVST_EW = NUM_AVST_CH*AVST_EW;
localparam TOTAL_AVST_DW  = NUM_AVST_CH*AVST_DW;
localparam LTSSMSTATE_L0 = 6'h11;  

// Clock and reset
logic        avl_clk_enable;    // serdes pll locked
logic        avl_clk;

// Config and status
logic [1:0]  tl_cfg_func;//specifies the PF or VF to which tl_cfg* applies. (S10 only)
logic [3:0]  tl_cfg_add;
logic [31:0] tl_cfg_ctl;
logic        cfg_bd_done;

logic [5:0]  ltssmstate, ltssmstate_reg;
logic        ltssmstate_L0;
logic        hip_linkup;
logic        pcie_linkup;

// Error
logic        b2a_app_err_valid;
logic [31:0] b2a_app_err_hdr;        
logic [10:0] b2a_app_err_info;         
logic [1:0]  b2a_app_err_func_num;

// RX streaming interface
logic [NUM_AVST_CH-1:0]           rx_st_valid;
logic [NUM_AVST_CH-1:0]           rx_st_sop;
logic [NUM_AVST_CH-1:0]           rx_st_eop;
logic [NUM_AVST_CH*AVST_EW-1:0]   rx_st_empty;
logic [NUM_AVST_CH*AVST_DW-1:0]   rx_st_data;
logic [NUM_AVST_CH*3-1:0]         rx_st_bar;
logic [NUM_AVST_CH-1:0]           rx_st_vf_active;
logic [NUM_AVST_CH*2-1:0]         rx_st_func_num;
logic [NUM_AVST_CH*11-1:0]        rx_st_vf_num;

// TX streaming interface
logic [NUM_AVST_CH-1:0]           tx_st_valid;
logic [NUM_AVST_CH-1:0]           tx_st_sop;
logic [NUM_AVST_CH-1:0]           tx_st_eop;
logic [NUM_AVST_CH-1:0]           tx_st_err;
logic [NUM_AVST_CH-1:0]           tx_st_vf_active;
logic [NUM_AVST_CH*AVST_DW-1:0]   tx_st_data;

t_avst_rxs  avl_rx_st;
t_avst_txs  avl_tx_st;
logic       avl_rx_ready;
logic       avl_tx_ready;

logic                                  chk_rx_err;
logic                                  chk_rx_err_vf_act;
logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] chk_rx_err_pfn;
logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] chk_rx_err_vfn;
logic [31:0]                           chk_rx_err_code;

logic        ctl_shdw_update;
logic [1:0]  ctl_shdw_pf_num;
logic [10:0] ctl_shdw_vf_num;
logic        ctl_shdw_vf_active;
logic [6:0]  ctl_shdw_cfg;
logic        ctl_shdw_req_all;


t_sideband_from_pcie  p2f_sideband, pcie_p2f_sideband, pcie_p2msix_sideband;
t_sideband_to_pcie    f2p_sideband;

//-----------------------------------------------------------------------------

// Tie off unused signals
assign irq_if.tvalid = 1'b0;
assign tx_st_err = '0;

// Clock
assign ltssmstate_L0 = (ltssmstate_reg == LTSSMSTATE_L0);

always_ff @(posedge avl_clk) begin : linkup_proc
   if (reset_status) begin
      pcie_linkup <= 1'b0;
      ltssmstate_reg <= 'b0;
   end
   else begin
      ltssmstate_reg <= ltssmstate;
   
      if (cfg_bd_done & ltssmstate_L0 & hip_linkup) begin
         pcie_linkup <= 1'b1;
      end else begin
         pcie_linkup <= 1'b0;
      end
   end
end : linkup_proc

// Device control register configurations
always_ff @(posedge avl_clk) begin : cfg_ctl_proc
   if (reset_status) begin
      cfg_bd_done <= 1'b0;
   end
   else begin
      if (ltssmstate_L0) begin
         cfg_bd_done <= 1'b1;
         
         if (tl_cfg_func == 2'h0) begin
            case (tl_cfg_add)
               4'h0 : begin
                  pcie_p2c_sideband.cfg_ctl.max_payload_size    <= tl_cfg_ctl[2:0];
                  pcie_p2c_sideband.cfg_ctl.max_read_req_size   <= tl_cfg_ctl[5:3];
                  pcie_p2c_sideband.cfg_ctl.extended_tag_enable <= tl_cfg_ctl[6];
               end

               4'h6 : begin
                  //read capability register status bits
                  pcie_p2c_sideband.cfg_ctl.msix_enable <= tl_cfg_ctl[5];
                  pcie_p2c_sideband.cfg_ctl.msix_pf_mask_en  <= tl_cfg_ctl[6]; 
               end                      
            endcase
         end
      end
   end
end : cfg_ctl_proc


// PCIe bridge AVST <-> AXIS
pcie_bridge pcie_bridge (
   .fim_clk               (fim_clk),
   .fim_rst_n             (fim_rst_n),

   .avl_clk               (avl_clk),
   .avl_rst_n             (~reset_status),

   .avl_rx_ready          (avl_rx_ready),
   .avl_rx_st             (avl_rx_st),
   .avl_tx_ready          (avl_tx_ready),
   .avl_tx_st             (avl_tx_st),

   .fim_axis_rx_st        (axis_rx_st),
   .fim_axis_tx_st        (axis_tx_st),

   .b2a_app_err_valid     (b2a_app_err_valid),
   .b2a_app_err_hdr       (b2a_app_err_hdr),
   .b2a_app_err_info      (b2a_app_err_info),
   .b2a_app_err_func_num  (b2a_app_err_func_num),

   .chk_rx_err            (chk_rx_err),
   .chk_rx_err_vf_act     (chk_rx_err_vf_act),
   .chk_rx_err_pfn        (chk_rx_err_pfn),
   .chk_rx_err_vfn        (chk_rx_err_vfn),
   .chk_rx_err_code       (chk_rx_err_code)
);

// CSRs
pcie_csr pcie_csr (
   .csr_if              (csr_if),

   // CSR input signals
   .avl_clk             (avl_clk),
   .i_pcie_linkup       (pcie_linkup),
   .i_chk_rx_err        (chk_rx_err),
   .i_chk_rx_err_vf_act (chk_rx_err_vf_act),
   .i_chk_rx_err_pfn    (chk_rx_err_pfn),
   .i_chk_rx_err_vfn    (chk_rx_err_vfn),
   .i_chk_rx_err_code   (chk_rx_err_code),

   // CSR output signals
   .o_pcie_linkup       (pcie_p2c_sideband.pcie_linkup),
   .o_chk_rx_err_code   (pcie_p2c_sideband.pcie_chk_rx_err_code)
);

pcie_flr_resync pcie_flr_resync (
   .avl_clk             (avl_clk), 
   .avl_rst_n           (~reset_status),

   .fim_clk             (fim_clk),
   .fim_rst_n           (fim_rst_n),

   .p2f_sideband        (p2f_sideband),
   .f2p_sideband        (f2p_sideband), 

   .pcie_p2f_sideband   (pcie_p2f_sideband),
   .pcie_c2p_sideband   (pcie_c2p_sideband)

);

always_comb begin 
   pcie_p2c_sideband.flr_active_pf         = pcie_p2f_sideband.flr_active_pf;
   pcie_p2c_sideband.flr_rcvd_vf           = pcie_p2f_sideband.flr_rcvd_vf;
   pcie_p2c_sideband.flr_rcvd_pf_num       = pcie_p2f_sideband.flr_rcvd_pf_num;
   pcie_p2c_sideband.flr_rcvd_vf_num       = pcie_p2f_sideband.flr_rcvd_vf_num;
   pcie_p2c_sideband.cfg_ctl.vf0_msix_mask = pcie_p2msix_sideband.cfg_ctl.vf0_msix_mask;
end 

pcie_msix_resync pcie_msix_resync (
   .avl_clk                (avl_clk),
   .avl_rst_n              (~reset_status),
   
   .fim_clk                (fim_clk),
   .fim_rst_n              (fim_rst_n),

   .pcie_p2msix_sideband   (pcie_p2msix_sideband),

   .ctl_shdw_update        (ctl_shdw_update),
   .ctl_shdw_pf_num        (ctl_shdw_pf_num),
   .ctl_shdw_vf_num        (ctl_shdw_vf_num),
   .ctl_shdw_cfg           (ctl_shdw_cfg),
   .ctl_shdw_vf_active     (ctl_shdw_vf_active),
   .ctl_shdw_req_all       (ctl_shdw_req_all)
);


//-----------------------
// Main test driver and logger module
//-----------------------
tester tester (
   .avl_clk                (avl_clk),
   .avl_rst_n              (~reset_status),
   .fim_clk                (fim_clk),
   .fim_rst_n              (fim_rst_n),

   //--------------------------------------
   // To PCIE bridge 
   //--------------------------------------
   // Raw RX TLP
   .o_avl_rx_st            (avl_rx_st),
   .i_avl_rx_ready         (avl_rx_ready),
   .i_avl_tx_st            (avl_tx_st),
   .o_avl_tx_ready         (avl_tx_ready),
   
   // Error reporting to PCIe IP
   .i_b2a_app_err_valid    (b2a_app_err_valid),
   .i_b2a_app_err_hdr      (b2a_app_err_hdr),
   .i_b2a_app_err_info     (b2a_app_err_info),
   .i_b2a_app_err_func_num (b2a_app_err_func_num),

   // Error reporting to PCIe feature CSR
   .i_chk_rx_err           (chk_rx_err),
   .i_chk_rx_err_vf_act    (chk_rx_err_vf_act),
   .i_chk_rx_err_pfn       (chk_rx_err_pfn),
   .i_chk_rx_err_vfn       (chk_rx_err_vfn),
   .i_chk_rx_err_code      (chk_rx_err_code),

   .i_pcie_p2c_sideband    (pcie_p2c_sideband),
   .i_flr_pf_done          (f2p_sideband.flr_completed_pf),
   .o_flr_pf_active        (p2f_sideband.flr_active_pf),
   .o_flr_rcvd_vf          (p2f_sideband.flr_rcvd_vf),
   .o_flr_rcvd_pf_num      (p2f_sideband.flr_rcvd_pf_num),
   .o_flr_rcvd_vf_num      (p2f_sideband.flr_rcvd_vf_num),
   .i_flr_completed_vf     (f2p_sideband.flr_completed_vf),
   .i_flr_completed_pf_num (f2p_sideband.flr_completed_pf_num),
   .i_flr_completed_vf_num (f2p_sideband.flr_completed_vf_num)
);


//-----------------------
// Tie off unused interface
//-----------------------
initial begin
   avl_clk = 1'b0;
   reset_status = 1'b1;
   wait (~pin_pcie_in_perst_n);
   wait (pin_pcie_in_perst_n);

   #10000ps;
   reset_status = 1'b0;
end

always #1250ps avl_clk = ~avl_clk; // 400 MHz

endmodule
