// Copyright 2021 Intel Corporation
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
logic        coreclkout_hip;
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
assign avl_clk = coreclkout_hip;
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

integer i;
always_comb begin
   for (i=0; i<NUM_AVST_CH; i=i+1) begin
      avl_rx_st[i].valid     = rx_st_valid     [i];
      avl_rx_st[i].sop       = rx_st_sop       [i];
      avl_rx_st[i].eop       = rx_st_eop       [i];
      avl_rx_st[i].empty     = rx_st_empty     [i*AVST_EW+:AVST_EW];
      avl_rx_st[i].data      = rx_st_data      [i*AVST_DW+:AVST_DW];
      avl_rx_st[i].bar       = rx_st_bar       [i*3+:3];
      avl_rx_st[i].vf_active = rx_st_vf_active [i];
      avl_rx_st[i].pfn       = rx_st_func_num  [i*2+:ofs_fim_pcie_pkg::PF_WIDTH];
      avl_rx_st[i].vfn       = rx_st_vf_num    [i*11+:ofs_fim_pcie_pkg::VF_WIDTH];
      avl_rx_st[i].mmio_req  = 1'b0;

      tx_st_valid[i]          = avl_tx_st[i].valid;
      tx_st_sop[i]            = avl_tx_st[i].sop;
      tx_st_eop[i]            = avl_tx_st[i].eop;
      tx_st_vf_active[i]      = avl_tx_st[i].vf_active;
      tx_st_data[i*AVST_DW+:AVST_DW] = avl_tx_st[i].data;
   end  
end

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


//--------------
// PCIe HIP IP
//--------------
logic [66:0] hip_test_in;
// Set test_in[0]=1 to turn on diag_fast_link_mode to speed up simulation
assign hip_test_in = 67'h1;
// FME Interface

pcie_ep_g3x16 dut (
   .clr_st                    (/*Not used*/),

   // Config interface
   .tl_cfg_func               (tl_cfg_func),
   .tl_cfg_add                (tl_cfg_add),
   .tl_cfg_ctl                (tl_cfg_ctl),

   // Error interface
   .app_err_valid             (b2a_app_err_valid),
   .app_err_hdr               (b2a_app_err_hdr),
   .app_err_info              (b2a_app_err_info),
   .app_err_func_num          (b2a_app_err_func_num),

   // Control shadow signals
//   .ctl_shdw_update           (ctl_shdw_update),
//   .ctl_shdw_pf_num           (ctl_shdw_pf_num),
//   .ctl_shdw_vf_num           (ctl_shdw_vf_num),
//   .ctl_shdw_cfg              (ctl_shdw_cfg),
//   .ctl_shdw_vf_active        (ctl_shdw_vf_active),
//   .ctl_shdw_req_all          (ctl_shdw_req_all),
   
   .ctl_shdw_update           (),
   .ctl_shdw_pf_num           (),
   .ctl_shdw_vf_num           (),
   .ctl_shdw_cfg              (),
   .ctl_shdw_vf_active        (),
   .ctl_shdw_req_all          ('0),
   
   .coreclkout_hip            (coreclkout_hip),
   .currentspeed              (/*Not used*/),
   
   // FLR signals
   .flr_pf_done               (f2p_sideband.flr_completed_pf),
   .flr_pf_active             (p2f_sideband.flr_active_pf),
   .flr_rcvd_vf               (p2f_sideband.flr_rcvd_vf),
   .flr_rcvd_pf_num           (p2f_sideband.flr_rcvd_pf_num),
   .flr_rcvd_vf_num           (p2f_sideband.flr_rcvd_vf_num),
   .flr_completed_vf          (f2p_sideband.flr_completed_vf),
   .flr_completed_pf_num      (f2p_sideband.flr_completed_pf_num),
   .flr_completed_vf_num      (f2p_sideband.flr_completed_vf_num),
   
   // Simulation only parameters
   .test_in                   (hip_test_in),
//`ifndef SIM_MODE_PIPE32
//   .simu_mode_pipe            (1'b0),
//   .sim_pipe_pclk_in          (1'b0),
//`else
//   .simu_mode_pipe            (/* allow simulation setting */),
//   .sim_pipe_pclk_in          (/* allow simulation setting */),
//`endif		   
`ifndef SIM_SERIAL
   .simu_mode_pipe            (),
   .sim_pipe_pclk_in          (),
`else
   .simu_mode_pipe            (1'b0),
   .sim_pipe_pclk_in          (1'b0),
`endif // SIM_SERIAL
   .sim_pipe_rate             (/*Not used : sim-only*/),
   .sim_ltssmstate            (/*Not used*/),
   .txdata0                   (/*Not used : sim-only*/),
   .txdata1                   (/*Not used : sim-only*/),
   .txdata2                   (/*Not used : sim-only*/),
   .txdata3                   (/*Not used : sim-only*/),
   .txdata4                   (/*Not used : sim-only*/),
   .txdata5                   (/*Not used : sim-only*/),
   .txdata6                   (/*Not used : sim-only*/),
   .txdata7                   (/*Not used : sim-only*/),
   .txdatak0                  (/*Not used : sim-only*/),
   .txdatak1                  (/*Not used : sim-only*/),
   .txdatak2                  (/*Not used : sim-only*/),
   .txdatak3                  (/*Not used : sim-only*/),
   .txdatak4                  (/*Not used : sim-only*/),
   .txdatak5                  (/*Not used : sim-only*/),
   .txdatak6                  (/*Not used : sim-only*/),
   .txdatak7                  (/*Not used : sim-only*/),
   .txcompl0                  (/*Not used : sim-only*/),
   .txcompl1                  (/*Not used : sim-only*/),
   .txcompl2                  (/*Not used : sim-only*/),
   .txcompl3                  (/*Not used : sim-only*/),
   .txcompl4                  (/*Not used : sim-only*/),
   .txcompl5                  (/*Not used : sim-only*/),
   .txcompl6                  (/*Not used : sim-only*/),
   .txcompl7                  (/*Not used : sim-only*/),
   .txelecidle0               (/*Not used : sim-only*/),
   .txelecidle1               (/*Not used : sim-only*/),
   .txelecidle2               (/*Not used : sim-only*/),
   .txelecidle3               (/*Not used : sim-only*/),
   .txelecidle4               (/*Not used : sim-only*/),
   .txelecidle5               (/*Not used : sim-only*/),
   .txelecidle6               (/*Not used : sim-only*/),
   .txelecidle7               (/*Not used : sim-only*/),
   .txdetectrx0               (/*Not used : sim-only*/),
   .txdetectrx1               (/*Not used : sim-only*/),
   .txdetectrx2               (/*Not used : sim-only*/),
   .txdetectrx3               (/*Not used : sim-only*/),
   .txdetectrx4               (/*Not used : sim-only*/),
   .txdetectrx5               (/*Not used : sim-only*/),
   .txdetectrx6               (/*Not used : sim-only*/),
   .txdetectrx7               (/*Not used : sim-only*/),
   .powerdown0                (/*Not used : sim-only*/),
   .powerdown1                (/*Not used : sim-only*/),
   .powerdown2                (/*Not used : sim-only*/),
   .powerdown3                (/*Not used : sim-only*/),
   .powerdown4                (/*Not used : sim-only*/),
   .powerdown5                (/*Not used : sim-only*/),
   .powerdown6                (/*Not used : sim-only*/),
   .powerdown7                (/*Not used : sim-only*/),
   .txmargin0                 (/*Not used : sim-only*/),
   .txmargin1                 (/*Not used : sim-only*/),
   .txmargin2                 (/*Not used : sim-only*/),
   .txmargin3                 (/*Not used : sim-only*/),
   .txmargin4                 (/*Not used : sim-only*/),
   .txmargin5                 (/*Not used : sim-only*/),
   .txmargin6                 (/*Not used : sim-only*/),
   .txmargin7                 (/*Not used : sim-only*/),
   .txdeemph0                 (/*Not used : sim-only*/),
   .txdeemph1                 (/*Not used : sim-only*/),
   .txdeemph2                 (/*Not used : sim-only*/),
   .txdeemph3                 (/*Not used : sim-only*/),
   .txdeemph4                 (/*Not used : sim-only*/),
   .txdeemph5                 (/*Not used : sim-only*/),
   .txdeemph6                 (/*Not used : sim-only*/),
   .txdeemph7                 (/*Not used : sim-only*/),
   .txswing0                  (/*Not used : sim-only*/),
   .txswing1                  (/*Not used : sim-only*/),
   .txswing2                  (/*Not used : sim-only*/),
   .txswing3                  (/*Not used : sim-only*/),
   .txswing4                  (/*Not used : sim-only*/),
   .txswing5                  (/*Not used : sim-only*/),
   .txswing6                  (/*Not used : sim-only*/),
   .txswing7                  (/*Not used : sim-only*/),
   .txsynchd0                 (/*Not used : sim-only*/),
   .txsynchd1                 (/*Not used : sim-only*/),
   .txsynchd2                 (/*Not used : sim-only*/),
   .txsynchd3                 (/*Not used : sim-only*/),
   .txsynchd4                 (/*Not used : sim-only*/),
   .txsynchd5                 (/*Not used : sim-only*/),
   .txsynchd6                 (/*Not used : sim-only*/),
   .txsynchd7                 (/*Not used : sim-only*/),
   .txblkst0                  (/*Not used : sim-only*/),
   .txblkst1                  (/*Not used : sim-only*/),
   .txblkst2                  (/*Not used : sim-only*/),
   .txblkst3                  (/*Not used : sim-only*/),
   .txblkst4                  (/*Not used : sim-only*/),
   .txblkst5                  (/*Not used : sim-only*/),
   .txblkst6                  (/*Not used : sim-only*/),
   .txblkst7                  (/*Not used : sim-only*/),
   .txdataskip0               (/*Not used : sim-only*/),
   .txdataskip1               (/*Not used : sim-only*/),
   .txdataskip2               (/*Not used : sim-only*/),
   .txdataskip3               (/*Not used : sim-only*/),
   .txdataskip4               (/*Not used : sim-only*/),
   .txdataskip5               (/*Not used : sim-only*/),
   .txdataskip6               (/*Not used : sim-only*/),
   .txdataskip7               (/*Not used : sim-only*/),
   .rate0                     (/*Not used : sim-only*/),
   .rate1                     (/*Not used : sim-only*/),
   .rate2                     (/*Not used : sim-only*/),
   .rate3                     (/*Not used : sim-only*/),
   .rate4                     (/*Not used : sim-only*/),
   .rate5                     (/*Not used : sim-only*/),
   .rate6                     (/*Not used : sim-only*/),
   .rate7                     (/*Not used : sim-only*/),
   .rxpolarity0               (/*Not used : sim-only*/),
   .rxpolarity1               (/*Not used : sim-only*/),
   .rxpolarity2               (/*Not used : sim-only*/),
   .rxpolarity3               (/*Not used : sim-only*/),
   .rxpolarity4               (/*Not used : sim-only*/),
   .rxpolarity5               (/*Not used : sim-only*/),
   .rxpolarity6               (/*Not used : sim-only*/),
   .rxpolarity7               (/*Not used : sim-only*/),
   .currentrxpreset0          (/*Not used : sim-only*/),
   .currentrxpreset1          (/*Not used : sim-only*/),
   .currentrxpreset2          (/*Not used : sim-only*/),
   .currentrxpreset3          (/*Not used : sim-only*/),
   .currentrxpreset4          (/*Not used : sim-only*/),
   .currentrxpreset5          (/*Not used : sim-only*/),
   .currentrxpreset6          (/*Not used : sim-only*/),
   .currentrxpreset7          (/*Not used : sim-only*/),
   .currentcoeff0             (/*Not used : sim-only*/),
   .currentcoeff1             (/*Not used : sim-only*/),
   .currentcoeff2             (/*Not used : sim-only*/),
   .currentcoeff3             (/*Not used : sim-only*/),
   .currentcoeff4             (/*Not used : sim-only*/),
   .currentcoeff5             (/*Not used : sim-only*/),
   .currentcoeff6             (/*Not used : sim-only*/),
   .currentcoeff7             (/*Not used : sim-only*/),
   .rxeqeval0                 (/*Not used : sim-only*/),
   .rxeqeval1                 (/*Not used : sim-only*/),
   .rxeqeval2                 (/*Not used : sim-only*/),
   .rxeqeval3                 (/*Not used : sim-only*/),
   .rxeqeval4                 (/*Not used : sim-only*/),
   .rxeqeval5                 (/*Not used : sim-only*/),
   .rxeqeval6                 (/*Not used : sim-only*/),
   .rxeqeval7                 (/*Not used : sim-only*/),
   .rxeqinprogress0           (/*Not used : sim-only*/),
   .rxeqinprogress1           (/*Not used : sim-only*/),
   .rxeqinprogress2           (/*Not used : sim-only*/),
   .rxeqinprogress3           (/*Not used : sim-only*/),
   .rxeqinprogress4           (/*Not used : sim-only*/),
   .rxeqinprogress5           (/*Not used : sim-only*/),
   .rxeqinprogress6           (/*Not used : sim-only*/),
   .rxeqinprogress7           (/*Not used : sim-only*/),
   .invalidreq0               (/*Not used : sim-only*/),
   .invalidreq1               (/*Not used : sim-only*/),
   .invalidreq2               (/*Not used : sim-only*/),
   .invalidreq3               (/*Not used : sim-only*/),
   .invalidreq4               (/*Not used : sim-only*/),
   .invalidreq5               (/*Not used : sim-only*/),
   .invalidreq6               (/*Not used : sim-only*/),
   .invalidreq7               (/*Not used : sim-only*/),
   .rxdata0                   (/*Not used : sim-only*/),
   .rxdata1                   (/*Not used : sim-only*/),
   .rxdata2                   (/*Not used : sim-only*/),
   .rxdata3                   (/*Not used : sim-only*/),
   .rxdata4                   (/*Not used : sim-only*/),
   .rxdata5                   (/*Not used : sim-only*/),
   .rxdata6                   (/*Not used : sim-only*/),
   .rxdata7                   (/*Not used : sim-only*/),
   .rxdatak0                  (/*Not used : sim-only*/),
   .rxdatak1                  (/*Not used : sim-only*/),
   .rxdatak2                  (/*Not used : sim-only*/),
   .rxdatak3                  (/*Not used : sim-only*/),
   .rxdatak4                  (/*Not used : sim-only*/),
   .rxdatak5                  (/*Not used : sim-only*/),
   .rxdatak6                  (/*Not used : sim-only*/),
   .rxdatak7                  (/*Not used : sim-only*/),
   .phystatus0                (/*Not used : sim-only*/),
   .phystatus1                (/*Not used : sim-only*/),
   .phystatus2                (/*Not used : sim-only*/),
   .phystatus3                (/*Not used : sim-only*/),
   .phystatus4                (/*Not used : sim-only*/),
   .phystatus5                (/*Not used : sim-only*/),
   .phystatus6                (/*Not used : sim-only*/),
   .phystatus7                (/*Not used : sim-only*/),
   .rxvalid0                  (/*Not used : sim-only*/),
   .rxvalid1                  (/*Not used : sim-only*/),
   .rxvalid2                  (/*Not used : sim-only*/),
   .rxvalid3                  (/*Not used : sim-only*/),
   .rxvalid4                  (/*Not used : sim-only*/),
   .rxvalid5                  (/*Not used : sim-only*/),
   .rxvalid6                  (/*Not used : sim-only*/),
   .rxvalid7                  (/*Not used : sim-only*/),
   .rxstatus0                 (/*Not used : sim-only*/),
   .rxstatus1                 (/*Not used : sim-only*/),
   .rxstatus2                 (/*Not used : sim-only*/),
   .rxstatus3                 (/*Not used : sim-only*/),
   .rxstatus4                 (/*Not used : sim-only*/),
   .rxstatus5                 (/*Not used : sim-only*/),
   .rxstatus6                 (/*Not used : sim-only*/),
   .rxstatus7                 (/*Not used : sim-only*/),
   .rxelecidle0               (/*Not used : sim-only*/),
   .rxelecidle1               (/*Not used : sim-only*/),
   .rxelecidle2               (/*Not used : sim-only*/),
   .rxelecidle3               (/*Not used : sim-only*/),
   .rxelecidle4               (/*Not used : sim-only*/),
   .rxelecidle5               (/*Not used : sim-only*/),
   .rxelecidle6               (/*Not used : sim-only*/),
   .rxelecidle7               (/*Not used : sim-only*/),
   .rxsynchd0                 (/*Not used : sim-only*/),
   .rxsynchd1                 (/*Not used : sim-only*/),
   .rxsynchd2                 (/*Not used : sim-only*/),
   .rxsynchd3                 (/*Not used : sim-only*/),
   .rxsynchd4                 (/*Not used : sim-only*/),
   .rxsynchd5                 (/*Not used : sim-only*/),
   .rxsynchd6                 (/*Not used : sim-only*/),
   .rxsynchd7                 (/*Not used : sim-only*/),
   .rxblkst0                  (/*Not used : sim-only*/),
   .rxblkst1                  (/*Not used : sim-only*/),
   .rxblkst2                  (/*Not used : sim-only*/),
   .rxblkst3                  (/*Not used : sim-only*/),
   .rxblkst4                  (/*Not used : sim-only*/),
   .rxblkst5                  (/*Not used : sim-only*/),
   .rxblkst6                  (/*Not used : sim-only*/),
   .rxblkst7                  (/*Not used : sim-only*/),
   .rxdataskip0               (/*Not used : sim-only*/),
   .rxdataskip1               (/*Not used : sim-only*/),
   .rxdataskip2               (/*Not used : sim-only*/),
   .rxdataskip3               (/*Not used : sim-only*/),
   .rxdataskip4               (/*Not used : sim-only*/),
   .rxdataskip5               (/*Not used : sim-only*/),
   .rxdataskip6               (/*Not used : sim-only*/),
   .rxdataskip7               (/*Not used : sim-only*/),
   .dirfeedback0              (/*Not used : sim-only*/),
   .dirfeedback1              (/*Not used : sim-only*/),
   .dirfeedback2              (/*Not used : sim-only*/),
   .dirfeedback3              (/*Not used : sim-only*/),
   .dirfeedback4              (/*Not used : sim-only*/),
   .dirfeedback5              (/*Not used : sim-only*/),
   .dirfeedback6              (/*Not used : sim-only*/),
   .dirfeedback7              (/*Not used : sim-only*/),
   .sim_pipe_mask_tx_pll_lock (/*Not used : sim-only*/),
   
   .reset_status              (reset_status),
   .serdes_pll_locked         (avl_clk_enable),
   .pld_core_ready            (avl_clk_enable),
   .pld_clk_inuse             (/*Not used, use reset_status instead for S10*/),
   .testin_zero               (/*Not used*/),
   // PCIe pins
   .rx_in0                    (pin_pcie_rx_p[0]),
   .rx_in1                    (pin_pcie_rx_p[1]),
   .rx_in2                    (pin_pcie_rx_p[2]),
   .rx_in3                    (pin_pcie_rx_p[3]),
   .rx_in4                    (pin_pcie_rx_p[4]),
   .rx_in5                    (pin_pcie_rx_p[5]),
   .rx_in6                    (pin_pcie_rx_p[6]),
   .rx_in7                    (pin_pcie_rx_p[7]),
   .rx_in8                    (pin_pcie_rx_p[8]),
   .rx_in9                    (pin_pcie_rx_p[9]),
   .rx_in10                   (pin_pcie_rx_p[10]),
   .rx_in11                   (pin_pcie_rx_p[11]),
   .rx_in12                   (pin_pcie_rx_p[12]),
   .rx_in13                   (pin_pcie_rx_p[13]),
   .rx_in14                   (pin_pcie_rx_p[14]),
   .rx_in15                   (pin_pcie_rx_p[15]),
   .tx_out0                   (pin_pcie_tx_p[0]),
   .tx_out1                   (pin_pcie_tx_p[1]),
   .tx_out2                   (pin_pcie_tx_p[2]),
   .tx_out3                   (pin_pcie_tx_p[3]),
   .tx_out4                   (pin_pcie_tx_p[4]),
   .tx_out5                   (pin_pcie_tx_p[5]),
   .tx_out6                   (pin_pcie_tx_p[6]),
   .tx_out7                   (pin_pcie_tx_p[7]),
   .tx_out8                   (pin_pcie_tx_p[8]),
   .tx_out9                   (pin_pcie_tx_p[9]),
   .tx_out10                  (pin_pcie_tx_p[10]),
   .tx_out11                  (pin_pcie_tx_p[11]),
   .tx_out12                  (pin_pcie_tx_p[12]),
   .tx_out13                  (pin_pcie_tx_p[13]),
   .tx_out14                  (pin_pcie_tx_p[14]),
   .tx_out15                  (pin_pcie_tx_p[15]),
   .int_status                (/*Not used*/),
   .int_status_common         (/*Not used*/),
   .derr_cor_ext_rpl          (/*Not used*/),
   .derr_rpl                  (/*Not used*/),
   .derr_cor_ext_rcv          (/*Not used*/),
   .derr_uncor_ext_rcv        (/*Not used*/),
   .rx_par_err                (/*Not used*/),
   .tx_par_err                (/*Not used*/),
   .ltssmstate                (ltssmstate),
   .link_up                   (hip_linkup),
   .lane_act                  (/*Not used*/),
   // MSI interface
   .app_msi_req               ('0 /*Not used, tied to 0*/),
   .app_msi_ack               (/*Not used*/),
   .app_msi_tc                ('0 /*Not used, tied to 0*/),
   .app_msi_num               ('0 /*Not used, tied to 0*/),
   .app_int_sts               ('0 /*Not used, tied to 0*/),
   .app_msi_func_num          ('0 /*Not used, tied to 0*/),
   // PF/VF
   .rx_st_vf_active           (rx_st_vf_active),
   .rx_st_func_num            (rx_st_func_num),
   .rx_st_vf_num              (rx_st_vf_num),
   .tx_st_vf_active           (tx_st_vf_active),
   // Clock and reset
   .ninit_done                (ninit_done),
   .npor                      (npor),
   .pin_perst                 (pin_pcie_in_perst_n),
   .pm_linkst_in_l1           (/*Not used*/),
   .pm_linkst_in_l0s          (/*Not used*/),
   .pm_state                  (/*Not used*/),
   .pm_dstate                 (/*Not used*/),
   .apps_pm_xmt_pme           ('0 /*Not used, tied to 0*/),
   .apps_ready_entr_l23       ('0 /*Not used, tied to 0*/),
   .apps_pm_xmt_turnoff       ('0 /*Not used, tied to 0*/),
   .app_init_rst              ('0 /*Not used, tied to 0*/),
   .app_xfer_pending          ('0 /*Not used, tied to 0*/),
   .refclk                    (pin_pcie_ref_clk_p),
   // Rx streaming channels
   .rx_st_bar_range           (rx_st_bar),
   .rx_st_ready               (avl_rx_ready),
   .rx_st_sop                 (rx_st_sop),
   .rx_st_eop                 (rx_st_eop),
   .rx_st_data                (rx_st_data),
   .rx_st_valid               (rx_st_valid),
   .rx_st_empty               (rx_st_empty),
   // Credit interface
   .tx_cdts_type              (),
   .tx_data_cdts_consumed     (),
   .tx_hdr_cdts_consumed      (),
   .tx_cdts_data_value        (),
   .tx_cpld_cdts              (),
   .tx_pd_cdts                (),
   .tx_npd_cdts               (),
   .tx_cplh_cdts              (),
   .tx_ph_cdts                (),
   .tx_nph_cdts               (),
   // Tx streaming channels
   .tx_st_sop                 (tx_st_sop),
   .tx_st_eop                 (tx_st_eop),
   .tx_st_data                (tx_st_data),
   .tx_st_valid               (tx_st_valid),
   .tx_st_err                 (tx_st_err),
   .tx_st_ready               (avl_tx_ready)
);

endmodule
