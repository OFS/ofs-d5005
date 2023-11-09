// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// AFU top wrapper
//

`ifdef INCLUDE_HE_HSSI 
    import   ofs_fim_eth_if_pkg::MAX_NUM_ETH_CHANNELS;
`endif

import top_cfg_pkg::*;

module afu_top(
    input refclk,
    input clk,
    input clk_div2,
    input clk_100,

    input rst_n,
    input pwr_good_clk_n,
    input rst_n_div2,
    input rst_n_100,
    input [NUM_PORT-1:0]  func_rst_n,
    output logic          pr_parity_error,
    
    ofs_fim_axi_lite_if.master  apf_bpf_slv_if,
    ofs_fim_axi_lite_if.slave   apf_bpf_mst_if,

    `ifdef INCLUDE_HE_HSSI  
      ofs_fim_hssi_ss_tx_axis_if.client       hssi_ss_st_tx [MAX_NUM_ETH_CHANNELS-1:0],
      ofs_fim_hssi_ss_rx_axis_if.client       hssi_ss_st_rx [MAX_NUM_ETH_CHANNELS-1:0],
      ofs_fim_hssi_fc_if.client               hssi_fc [MAX_NUM_ETH_CHANNELS-1:0],
      `ifdef INCLUDE_PTP
         ofs_fim_hssi_ptp_tx_tod_if.client     hssi_ptp_tx_tod [MAX_NUM_ETH_CHANNELS-1:0],
         ofs_fim_hssi_ptp_rx_tod_if.client     hssi_ptp_rx_tod [MAX_NUM_ETH_CHANNELS-1:0],
         ofs_fim_hssi_ptp_tx_egrts_if.client   hssi_ptp_tx_egrts [MAX_NUM_ETH_CHANNELS-1:0],
         ofs_fim_hssi_ptp_rx_ingrts_if.client  hssi_ptp_rx_ingrts [MAX_NUM_ETH_CHANNELS-1:0],
         input logic                           i_ehip_clk_806,
         input logic                           i_ehip_clk_403,
         input logic                           i_ehip_pll_locked,
      `endif
      input logic [MAX_NUM_ETH_CHANNELS-1:0] i_hssi_clk_pll,
    `endif

    pcie_ss_axis_if.sink       pcie_ss_axis_rx,
    pcie_ss_axis_if.source     pcie_ss_axis_tx,
    ofs_fim_emif_avmm_if.user  afu_mem_if [NUM_MEM_CH]
    
);                          
                            
//-------------------------------------
// Preserve clocks
//-------------------------------------

// Make sure all clocks are consumed, in case AFUs don't use them,
// to avoid Quartus problems.
    (* noprune *) logic clk_div2_q1, clk_div2_q2;

    always_ff @(posedge clk_div2) begin
        clk_div2_q1 <= clk_div2_q2;
        clk_div2_q2 <= !clk_div2_q1;
    end

//-------------------------------------
// Internal signals
//-------------------------------------

    pcie_ss_axis_if         ho2mx_rx_remap                  ();                    // AXI  stream interfaces
    pcie_ss_axis_if         mx2ho_tx_remap                  ();                    //             
    pcie_ss_axis_if         ho2mx_rx_port                   ();                    // AXI  stream interfaces
    pcie_ss_axis_if         mx2ho_tx_port                   ();                    //             
    pcie_ss_axis_if         mx2fn_rx_a_port   [NUM_PORT-1:0]();                    // A ports (PCIe SS RX traffic)
    pcie_ss_axis_if         mx2fn_rx_b_port   [NUM_PORT-1:0]();                    // B PF/VF AFU side (local write completions)
    pcie_ss_axis_if         fn2mx_tx_a_port   [NUM_PORT-1:0]();                    // A ports (first tree of AFU TX ports)
    pcie_ss_axis_if         fn2mx_tx_b_port   [NUM_PORT-1:0]();                    // B ports (second tree of AFU TX ports)

    pcie_ss_axis_if         mx2ho_tx_ab                  [2]();                    // Host side of both A and B PF/VF TX MUXes
    pcie_ss_axis_if         arb2ho_tx_port                  ();                    // A/B arbiter to local commit generator
    pcie_ss_axis_if         arb2mx_rx_b                     ();                    // A/B arbiter local write commits to AFU

    pcie_ss_axis_if         afu_rx_a_port     [PG_AFU_NUM_PORTS-1:0]();            // A AFU PCIe RX ports
    pcie_ss_axis_if         afu_rx_b_port     [PG_AFU_NUM_PORTS-1:0]();            // A AFU PCIe RX ports
    pcie_ss_axis_if         afu_tx_a_port     [PG_AFU_NUM_PORTS-1:0]();            // A AFU PCIe TX ports
    pcie_ss_axis_if         afu_tx_b_port     [PG_AFU_NUM_PORTS-1:0]();            // B AFU PCIe TX ports
    logic                   afu_rst_n         [PG_AFU_NUM_PORTS-1:0];              // Port-specific soft reset
                                                                                   // AXI4-lite interfaces

    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(20),.ARADDR_WIDTH(TOTAL_BAR_SIZE))apf_st2mm_mst_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_st2mm_slv_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_pgsk_slv_if  ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_achk_slv_if  ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_rsv_b_slv_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_rsv_c_slv_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_rsv_d_slv_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_rsv_e_slv_if ();//
    ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16),.ARADDR_WIDTH(           16)) apf_rsv_f_slv_if ();//
   
    logic [1:0] pf_vf_fifo_err;
    logic [1:0] pf_vf_fifo_perr;
    
    logic       sel_mmio_rsp;
    logic       read_flush_done;
    logic       port_softreset_n;
    logic       afu_softreset;
    logic       afu_softreset_dlyd;


    logic rstn_a /* synthesis preserve_syn_only */ ;
    logic rstn_b /* synthesis preserve_syn_only */ ;

//
// Macros for mapping port defintions to PF/VF resets. We use macros instead
// of functions to avoid problems with continuous assignment.
// Get the VF function level reset if VF is active for the function.
// If VF is not active, return a constant: not in reset.
`define GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE) ((VF_ACTIVE != 0) ? func_rst_n[VF+1] : 1'b1)

// Construct the full reset for a function, combining PF and VF resets.
`define GET_FUNC_RST_N(PF, VF, VF_ACTIVE) (func_rst_n[0] & `GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE))

//---------------------------------------------------------------------------------------

//                                  Modules instances
//---------------------------------------------------------------------------------------
// A reset stage is added to reduce timing impact on reset tree when PC was added
always @(posedge clk) begin
  rstn_a <= rst_n;
  rstn_b <= rst_n;
  afu_softreset_dlyd <= afu_softreset;
end

//
// The protocol checker expects TXREQ ports, which this FIM does not have.
// Create some dummy interfaces.
//
pcie_ss_axis_if
  #(
    .DATA_W (pcie_ss_hdr_pkg::HDR_WIDTH),
    .USER_W (ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
   )
  pcie_ss_axis_txreq_dummy(.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if
  #(
    .DATA_W (pcie_ss_hdr_pkg::HDR_WIDTH),
    .USER_W (ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
   )
  mx2ho_txreq_port_dummy(.clk(clk), .rst_n(rst_n));

assign pcie_ss_axis_txreq_dummy.tready = 1'b1;
assign mx2ho_txreq_port_dummy.tvalid = 1'b0;

afu_intf #( 
  .ENABLE (1'b1),
  .PCIE_EP_MAX_TAGS (ofs_fim_pcie_pkg::PCIE_EP_MAX_TAGS)
)
afu_intf_inst
(
  .clk                  ( clk                        ),
  .rst_n                ( rstn_a                     ),
  
  .clk_csr              ( clk                        ), // use normal clock for CSR clock in D5005
  .rst_n_csr            ( rstn_a                     ),  
  .pwr_good_csr_clk_n   ( pwr_good_clk_n             ), 

  .i_afu_softreset      ( afu_softreset_dlyd         ),

  .o_sel_mmio_rsp       ( sel_mmio_rsp               ),
  .o_read_flush_done    ( read_flush_done            ),
   
  .h2a_axis_rx          ( pcie_ss_axis_rx            ),
  .a2h_axis_tx          ( pcie_ss_axis_tx            ), 
  .a2h_axis_txreq       ( pcie_ss_axis_txreq_dummy   ),

  .afu_axis_rx          ( ho2mx_rx_port              ),
  .afu_axis_tx          ( mx2ho_tx_port              ),  
  .afu_axis_txreq       ( mx2ho_txreq_port_dummy     ),

  .csr_if               ( apf_achk_slv_if            )
);                   
                    
    // d5005 PCIe SS emulation does not indicate the dynamic extended tag
    // configuration. We assume the interface is configured for 8 bit tags.
    pcie_ss_axis_pkg::t_pcie_tag_mode tag_mode;
    always_comb
    begin
        tag_mode = '0;
        tag_mode.tag_8bit = 1'b1;
    end

    tag_remap    #(                                           //
                   .REMAP            (  1                  )  // Enable/Disable Tag Remap function 
                   )                                          //
    tag_remap     (                                           // 
                  .clk               ( clk                 ) ,// clock
                  .rst_n             ( rstn_b              ) ,// reset
                                                              //
                  .ho2mx_rx_port     ( ho2mx_rx_port       ) ,// axis interface to host (PCIE)
                  .mx2ho_tx_port     ( mx2ho_tx_port       ) ,// 
                  .ho2mx_rx_remap    ( ho2mx_rx_remap      ) ,// axis interface to pf_vf_mux
                  .mx2ho_tx_remap    ( mx2ho_tx_remap      ) ,//
                  .tag_mode          ( tag_mode            )  //
                  )                                          ;// 

 //
 // There are two independent TX PF/VF MUX trees, labeled "A" and "B".
 // Both an A and a B port are passed to each AFU. AFUs can either send
 // all requests to the primary A port or partition requests across
 // both A and B ports. A typical high-performance AFU will send
 // read requests to the B port and everything else to the A port,
 // giving the arbiter here freedom to keep both the host TX and RX
 // channels busy.
 //
 // Here, the A and B TX trees have been multiplexed down to a single
 // channel for A and another for B. The A/B multiplexer merges them
 // into a single TX stream that will be passed to the tag remapper.
 //
 pcie_ss_axis_mux #(
                   .NUM_CH           ( 2                   )
                   )
  mx2ho_tx_ab_mux
                  (
                  .clk               ( clk                 ),
                  .rst_n             ( rstn_b              ),

                  .sink              ( mx2ho_tx_ab         ),
                  .source            ( arb2ho_tx_port      )
                  );

 // Generate local commits for writes that have passed A/B MUX
 // arbitration. This way AFUs can know when writes on A and reads
 // on B have been committed to a fixed order.
 pcie_arb_local_commit local_commit
                  (
                  .clk               ( clk                 ),
                  .rst_n             ( rstn_b              ),

                  .sink              ( arb2ho_tx_port      ),
                  .source            ( mx2ho_tx_remap      ),
                  .commit            ( arb2mx_rx_b         )
                  );

 // Primary PF/VF MUX ("A" ports). Map individual TX A ports from
 // AFUs down to a single, merged A channel. The RX port from host
 // to FPGA is demultiplexed and individual connections are forwarded
 // to AFUs.
 pf_vf_mux_top  #(
                  .MUX_NAME("A"),
                   .NUM_PORT(top_cfg_pkg::NUM_PORT),
                  .NUM_RTABLE_ENTRIES(top_cfg_pkg::NUM_RTABLE_ENTRIES),
                  .PFVF_ROUTING_TABLE(top_cfg_pkg::PFVF_ROUTING_TABLE)
                  )
 pf_vf_mux_a     (
                  .clk               ( clk                 ),
                  .rst_n             ( rstn_b              ),

                  .ho2mx_rx_port     ( ho2mx_rx_remap      ),
                  .mx2ho_tx_port     ( mx2ho_tx_ab[0]      ),
                  .mx2fn_rx_port     ( mx2fn_rx_a_port     ),
                  .fn2mx_tx_port     ( fn2mx_tx_a_port     ),
                  .out_fifo_err      ( pf_vf_fifo_err[0]   ),
                  .out_fifo_perr     ( pf_vf_fifo_perr[0]  )
                  );

 // Secondary PF/VF MUX ("B" ports). Only TX is implemented, since a
 // single RX stream is sufficient. The RX input to the MUX is tied off.
 // AFU B TX ports are multiplexed into a single TX B channel that is
 // passed to the A/B MUX above.
 pf_vf_mux_top  #(
                  .MUX_NAME("B"),
                  .NUM_PORT(top_cfg_pkg::NUM_PORT),
                  .NUM_RTABLE_ENTRIES(top_cfg_pkg::NUM_RTABLE_ENTRIES),
                  .PFVF_ROUTING_TABLE(top_cfg_pkg::PFVF_ROUTING_TABLE)
                  )
 pf_vf_mux_b     (
                  .clk               ( clk                 ),
                  .rst_n             ( rstn_b              ),

                  .ho2mx_rx_port     ( arb2mx_rx_b         ),
                  .mx2ho_tx_port     ( mx2ho_tx_ab[1]      ),
                  .mx2fn_rx_port     ( mx2fn_rx_b_port     ),
                  .fn2mx_tx_port     ( fn2mx_tx_b_port     ),
                  .out_fifo_err      ( pf_vf_fifo_err[1]   ),
                  .out_fifo_perr     ( pf_vf_fifo_perr[1]  )
                  );


axis_axil_bridge #(
           .PF_NUM         (       CFG_PF                    ),
           .VF_NUM         (       CFG_VF                    ), 
           .VF_ACTIVE      (       CFG_VA                    ),
           .MM_ADDR_WIDTH  (       TOTAL_BAR_SIZE            )
          )                                                  
axis_axil_bridge (                                           
           .clk            (      clk                        ),
           .rst_n          (      rstn_b                     ),
           .flrst_n        (      `GET_FUNC_RST_N(CFG_PF,CFG_VF,CFG_VA)),
           .axis_rx_if     (      mx2fn_rx_a_port[CFG_PID]   ),
           .axis_tx_if     (      fn2mx_tx_a_port[CFG_PID]   ),
                                                             
           .axi_m_if       (      apf_st2mm_mst_if           ),
           .axi_s_if       (      apf_st2mm_slv_if           )
          );                                            
                                                             
// Configuration does not use the TX B port
assign fn2mx_tx_b_port[CFG_PID].tvalid = 1'b0;
assign mx2fn_rx_b_port[CFG_PID].tready = 1'b1;

`ifdef ERROR_INJ      

he_lb_err_top #(
         .PF_ID     ( HLB_PF ),
         .VF_ID     ( HLB_VF ),
         .VF_ACTIVE ( HLB_VA ),
         .SPLIT_RSP ( 1      )
          )
he_lb_err_inst(
         .clk       ( clk                           ),
         .rst_n      ( rstn_b & `GET_FUNC_RST_N(HLB_PF,HLB_VF,HLB_VA) ),
         .axi_rx_a_if( mx2fn_rx_a_port[HLB_PID]     ),
         .axi_rx_b_if( mx2fn_rx_b_port[HLB_PID]     ),
         .axi_tx_a_if( fn2mx_tx_a_port[HLB_PID]     ),
         .axi_tx_b_if( fn2mx_tx_b_port[HLB_PID]     )
         );
         
`else 
he_lb_top #(
         .PF_ID     ( HLB_PF ),
         .VF_ID     ( HLB_VF ),
         .VF_ACTIVE ( HLB_VA )
          )
he_lb_inst(
         .clk       ( clk                           ),
         .rst_n     ( rstn_b & `GET_FUNC_RST_N(HLB_PF,HLB_VF,HLB_VA) ),
         .axi_rx_a_if( mx2fn_rx_a_port[HLB_PID]     ),
         .axi_rx_b_if( mx2fn_rx_b_port[HLB_PID]     ),
         .axi_tx_a_if( fn2mx_tx_a_port[HLB_PID]     ),
         .axi_tx_b_if( fn2mx_tx_b_port[HLB_PID]     )
         );
`endif 

//----------------------------------------------------------------
// Port Gasket
//----------------------------------------------------------------

// Map the PF/VF association of AFU ports to the parameters that will be
// passed to the port gasket.
typedef pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[PG_AFU_NUM_PORTS-1:0] t_afu_pf_vf_map;
function automatic t_afu_pf_vf_map gen_afu_pf_vf_map();
    t_afu_pf_vf_map map;

    for (int p = 0; p < PG_AFU_NUM_PORTS; p = p + 1) begin
        map[p].pf_num = PG_AFU_PORTS_PF_NUM[p];
        map[p].vf_num = PG_AFU_PORTS_VF_NUM[p];
        map[p].vf_active = PG_AFU_PORTS_VF_ACTIVE[p];
    end

    return map;
endfunction // gen_afu_pf_vf_map

localparam pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[PG_AFU_NUM_PORTS-1:0] PORT_PF_VF_INFO =
    gen_afu_pf_vf_map();

//
// Map TLP ports from the PF/VF MUXes to the vector of ports that is
// passed through the port gasket to afu_main().
//
generate
    for (genvar p = 0; p < PG_AFU_NUM_PORTS; p = p + 1)
    begin : afp
        assign afu_rst_n[p] = `GET_FUNC_RST_N(PG_AFU_PORTS_PF_NUM[p],PG_AFU_PORTS_VF_NUM[p],PG_AFU_PORTS_VF_ACTIVE[p]);

        assign mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tready = afu_rx_a_port[p].tready;
        assign afu_rx_a_port[p].tvalid       = mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tvalid;
        assign afu_rx_a_port[p].tlast        = mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tlast;
        assign afu_rx_a_port[p].tuser_vendor = mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tuser_vendor;
        assign afu_rx_a_port[p].tdata        = mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tdata;
        assign afu_rx_a_port[p].tkeep        = mx2fn_rx_a_port[PG_AFU_MUX_PID[p]].tkeep;

        assign mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tready = afu_rx_b_port[p].tready;
        assign afu_rx_b_port[p].tvalid       = mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tvalid;
        assign afu_rx_b_port[p].tlast        = mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tlast;
        assign afu_rx_b_port[p].tuser_vendor = mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tuser_vendor;
        assign afu_rx_b_port[p].tdata        = mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tdata;
        assign afu_rx_b_port[p].tkeep        = mx2fn_rx_b_port[PG_AFU_MUX_PID[p]].tkeep;

        assign afu_tx_a_port[p].tready                   = fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tready;
        assign fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tvalid       = afu_tx_a_port[p].tvalid;
        assign fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tlast        = afu_tx_a_port[p].tlast;
        assign fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tuser_vendor = afu_tx_a_port[p].tuser_vendor;
        assign fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tdata        = afu_tx_a_port[p].tdata;
        assign fn2mx_tx_a_port[PG_AFU_MUX_PID[p]].tkeep        = afu_tx_a_port[p].tkeep;

        assign afu_tx_b_port[p].tready                 = fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tready;
        assign fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tvalid       = afu_tx_b_port[p].tvalid;
        assign fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tlast        = afu_tx_b_port[p].tlast;
        assign fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tuser_vendor = afu_tx_b_port[p].tuser_vendor;
        assign fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tdata        = afu_tx_b_port[p].tdata;
        assign fn2mx_tx_b_port[PG_AFU_MUX_PID[p]].tkeep        = afu_tx_b_port[p].tkeep;
    end
endgenerate
   
port_gasket #( 
         .PG_NUM_PORTS(PG_AFU_NUM_PORTS),
         .PORT_PF_VF_INFO(PORT_PF_VF_INFO),
         .NUM_MEM_CH(NUM_MEM_CH),
         .END_OF_LIST    (1'b0),
         .NEXT_DFH_OFFSET(24'h01_0000)
         )
port_gasket(
        .refclk                         ( refclk                        ),
        .clk_2x                         ( clk                           ),
        .clk_1x                         ( clk_div2                      ),
        .clk_100                        ( clk_100                       ),
        .clk_div4                       ( clk                           ), //FUTURE_IMPROVEMENT

        .rst_n_2x                       ( rstn_b                        ),
        .rst_n_1x                       ( rst_n_div2                    ),
        .rst_n_100                      ( rst_n_100                     ),
        .port_rst_n                     ( afu_rst_n                     ),
        
        .i_sel_mmio_rsp                 ( sel_mmio_rsp                  ),
        .i_read_flush_done              ( read_flush_done               ),
        .o_port_softreset_n             ( port_softreset_n              ),
        .o_afu_softreset                ( afu_softreset                 ),
        .o_pr_parity_error              (pr_parity_error                ), // Partial Reconfiguration FIFO Parity Error Indication from PR Controller.

        .axi_tx_a_if                    ( afu_tx_a_port                 ),
        .axi_rx_a_if                    ( afu_rx_a_port                 ),
        .axi_tx_b_if                    ( afu_tx_b_port                 ),
        .axi_rx_b_if                    ( afu_rx_b_port                 ),

        `ifdef INCLUDE_HE_HSSI  
           .hssi_ss_st_tx                 ( hssi_ss_st_tx),
           .hssi_ss_st_rx                 ( hssi_ss_st_rx),
           .hssi_fc                       ( hssi_fc),
           `ifdef INCLUDE_PTP             
              .hssi_ptp_tx_tod            ( hssi_ptp_tx_tod               ),
              .hssi_ptp_rx_tod            ( hssi_ptp_rx_tod               ),
              .hssi_ptp_tx_egrts          ( hssi_ptp_tx_egrts             ),
              .hssi_ptp_rx_ingrts         ( hssi_ptp_rx_ingrts            ),
           `endif                         
           .i_hssi_clk_pll                (i_hssi_clk_pll                 ),
        `endif
        .axi_s_if                       ( apf_pgsk_slv_if               ),
        .afu_mem_if                     ( afu_mem_if                    )
);

// AFU Peripheral Fabric
apf apf(
       .clk_clk               (clk                         ),
       .rst_n_reset_n         (rstn_b ),
       
       .apf_st2mm_mst_awaddr  (apf_st2mm_mst_if.awaddr ),
       .apf_st2mm_mst_awprot  (apf_st2mm_mst_if.awprot ),
       .apf_st2mm_mst_awvalid (apf_st2mm_mst_if.awvalid),
       .apf_st2mm_mst_awready (apf_st2mm_mst_if.awready),
       .apf_st2mm_mst_wdata   (apf_st2mm_mst_if.wdata  ),
       .apf_st2mm_mst_wstrb   (apf_st2mm_mst_if.wstrb  ),
       .apf_st2mm_mst_wvalid  (apf_st2mm_mst_if.wvalid ),
       .apf_st2mm_mst_wready  (apf_st2mm_mst_if.wready ),
       .apf_st2mm_mst_bresp   (apf_st2mm_mst_if.bresp  ),
       .apf_st2mm_mst_bvalid  (apf_st2mm_mst_if.bvalid ),
       .apf_st2mm_mst_bready  (apf_st2mm_mst_if.bready ),
       .apf_st2mm_mst_araddr  (apf_st2mm_mst_if.araddr ),
       .apf_st2mm_mst_arprot  (apf_st2mm_mst_if.arprot ),
       .apf_st2mm_mst_arvalid (apf_st2mm_mst_if.arvalid),
       .apf_st2mm_mst_arready (apf_st2mm_mst_if.arready),
       .apf_st2mm_mst_rdata   (apf_st2mm_mst_if.rdata  ),
       .apf_st2mm_mst_rresp   (apf_st2mm_mst_if.rresp  ),
       .apf_st2mm_mst_rvalid  (apf_st2mm_mst_if.rvalid ),
       .apf_st2mm_mst_rready  (apf_st2mm_mst_if.rready ),
       
       .apf_st2mm_slv_awaddr  (apf_st2mm_slv_if.awaddr ),
       .apf_st2mm_slv_awprot  (apf_st2mm_slv_if.awprot ),
       .apf_st2mm_slv_awvalid (apf_st2mm_slv_if.awvalid),
       .apf_st2mm_slv_awready (apf_st2mm_slv_if.awready),
       .apf_st2mm_slv_wdata   (apf_st2mm_slv_if.wdata  ),
       .apf_st2mm_slv_wstrb   (apf_st2mm_slv_if.wstrb  ),
       .apf_st2mm_slv_wvalid  (apf_st2mm_slv_if.wvalid ),
       .apf_st2mm_slv_wready  (apf_st2mm_slv_if.wready ),
       .apf_st2mm_slv_bresp   (apf_st2mm_slv_if.bresp  ),
       .apf_st2mm_slv_bvalid  (apf_st2mm_slv_if.bvalid ),
       .apf_st2mm_slv_bready  (apf_st2mm_slv_if.bready ),
       .apf_st2mm_slv_araddr  (apf_st2mm_slv_if.araddr ),
       .apf_st2mm_slv_arprot  (apf_st2mm_slv_if.arprot ),
       .apf_st2mm_slv_arvalid (apf_st2mm_slv_if.arvalid),
       .apf_st2mm_slv_arready (apf_st2mm_slv_if.arready),
       .apf_st2mm_slv_rdata   (apf_st2mm_slv_if.rdata  ),
       .apf_st2mm_slv_rresp   (apf_st2mm_slv_if.rresp  ),
       .apf_st2mm_slv_rvalid  (apf_st2mm_slv_if.rvalid ),
       .apf_st2mm_slv_rready  (apf_st2mm_slv_if.rready ), 
       
       .apf_pgsk_slv_awaddr   (apf_pgsk_slv_if.awaddr  ),
       .apf_pgsk_slv_awprot   (apf_pgsk_slv_if.awprot  ),
       .apf_pgsk_slv_awvalid  (apf_pgsk_slv_if.awvalid ),
       .apf_pgsk_slv_awready  (apf_pgsk_slv_if.awready ),
       .apf_pgsk_slv_wdata    (apf_pgsk_slv_if.wdata   ),
       .apf_pgsk_slv_wstrb    (apf_pgsk_slv_if.wstrb   ),
       .apf_pgsk_slv_wvalid   (apf_pgsk_slv_if.wvalid  ),
       .apf_pgsk_slv_wready   (apf_pgsk_slv_if.wready  ),
       .apf_pgsk_slv_bresp    (apf_pgsk_slv_if.bresp   ),
       .apf_pgsk_slv_bvalid   (apf_pgsk_slv_if.bvalid  ),
       .apf_pgsk_slv_bready   (apf_pgsk_slv_if.bready  ),
       .apf_pgsk_slv_araddr   (apf_pgsk_slv_if.araddr  ),
       .apf_pgsk_slv_arprot   (apf_pgsk_slv_if.arprot  ),
       .apf_pgsk_slv_arvalid  (apf_pgsk_slv_if.arvalid ),
       .apf_pgsk_slv_arready  (apf_pgsk_slv_if.arready ),
       .apf_pgsk_slv_rdata    (apf_pgsk_slv_if.rdata   ),
       .apf_pgsk_slv_rresp    (apf_pgsk_slv_if.rresp   ),
       .apf_pgsk_slv_rvalid   (apf_pgsk_slv_if.rvalid  ),
       .apf_pgsk_slv_rready   (apf_pgsk_slv_if.rready  ),
       
       .apf_achk_slv_awaddr   (apf_achk_slv_if.awaddr  ),
       .apf_achk_slv_awprot   (apf_achk_slv_if.awprot  ),
       .apf_achk_slv_awvalid  (apf_achk_slv_if.awvalid ),
       .apf_achk_slv_awready  (apf_achk_slv_if.awready ),
       .apf_achk_slv_wdata    (apf_achk_slv_if.wdata   ),
       .apf_achk_slv_wstrb    (apf_achk_slv_if.wstrb   ),
       .apf_achk_slv_wvalid   (apf_achk_slv_if.wvalid  ),
       .apf_achk_slv_wready   (apf_achk_slv_if.wready  ),
       .apf_achk_slv_bresp    (apf_achk_slv_if.bresp   ),
       .apf_achk_slv_bvalid   (apf_achk_slv_if.bvalid  ),
       .apf_achk_slv_bready   (apf_achk_slv_if.bready  ),
       .apf_achk_slv_araddr   (apf_achk_slv_if.araddr  ),
       .apf_achk_slv_arprot   (apf_achk_slv_if.arprot  ),
       .apf_achk_slv_arvalid  (apf_achk_slv_if.arvalid ),
       .apf_achk_slv_arready  (apf_achk_slv_if.arready ),
       .apf_achk_slv_rdata    (apf_achk_slv_if.rdata   ),
       .apf_achk_slv_rresp    (apf_achk_slv_if.rresp   ),
       .apf_achk_slv_rvalid   (apf_achk_slv_if.rvalid  ),
       .apf_achk_slv_rready   (apf_achk_slv_if.rready  ),
       
       .apf_rsv_b_slv_awaddr  (apf_rsv_b_slv_if.awaddr ),
       .apf_rsv_b_slv_awprot  (apf_rsv_b_slv_if.awprot ),
       .apf_rsv_b_slv_awvalid (apf_rsv_b_slv_if.awvalid),
       .apf_rsv_b_slv_awready (apf_rsv_b_slv_if.awready),
       .apf_rsv_b_slv_wdata   (apf_rsv_b_slv_if.wdata  ),
       .apf_rsv_b_slv_wstrb   (apf_rsv_b_slv_if.wstrb  ),
       .apf_rsv_b_slv_wvalid  (apf_rsv_b_slv_if.wvalid ),
       .apf_rsv_b_slv_wready  (apf_rsv_b_slv_if.wready ),
       .apf_rsv_b_slv_bresp   (apf_rsv_b_slv_if.bresp  ),
       .apf_rsv_b_slv_bvalid  (apf_rsv_b_slv_if.bvalid ),
       .apf_rsv_b_slv_bready  (apf_rsv_b_slv_if.bready ),
       .apf_rsv_b_slv_araddr  (apf_rsv_b_slv_if.araddr ),
       .apf_rsv_b_slv_arprot  (apf_rsv_b_slv_if.arprot ),
       .apf_rsv_b_slv_arvalid (apf_rsv_b_slv_if.arvalid),
       .apf_rsv_b_slv_arready (apf_rsv_b_slv_if.arready),
       .apf_rsv_b_slv_rdata   (apf_rsv_b_slv_if.rdata  ),
       .apf_rsv_b_slv_rresp   (apf_rsv_b_slv_if.rresp  ),
       .apf_rsv_b_slv_rvalid  (apf_rsv_b_slv_if.rvalid ),
       .apf_rsv_b_slv_rready  (apf_rsv_b_slv_if.rready ),
       
       .apf_rsv_c_slv_awaddr  (apf_rsv_c_slv_if.awaddr ),
       .apf_rsv_c_slv_awprot  (apf_rsv_c_slv_if.awprot ),
       .apf_rsv_c_slv_awvalid (apf_rsv_c_slv_if.awvalid),
       .apf_rsv_c_slv_awready (apf_rsv_c_slv_if.awready),
       .apf_rsv_c_slv_wdata   (apf_rsv_c_slv_if.wdata  ),
       .apf_rsv_c_slv_wstrb   (apf_rsv_c_slv_if.wstrb  ),
       .apf_rsv_c_slv_wvalid  (apf_rsv_c_slv_if.wvalid ),
       .apf_rsv_c_slv_wready  (apf_rsv_c_slv_if.wready ),
       .apf_rsv_c_slv_bresp   (apf_rsv_c_slv_if.bresp  ),
       .apf_rsv_c_slv_bvalid  (apf_rsv_c_slv_if.bvalid ),
       .apf_rsv_c_slv_bready  (apf_rsv_c_slv_if.bready ),
       .apf_rsv_c_slv_araddr  (apf_rsv_c_slv_if.araddr ),
       .apf_rsv_c_slv_arprot  (apf_rsv_c_slv_if.arprot ),
       .apf_rsv_c_slv_arvalid (apf_rsv_c_slv_if.arvalid),
       .apf_rsv_c_slv_arready (apf_rsv_c_slv_if.arready),
       .apf_rsv_c_slv_rdata   (apf_rsv_c_slv_if.rdata  ),
       .apf_rsv_c_slv_rresp   (apf_rsv_c_slv_if.rresp  ),
       .apf_rsv_c_slv_rvalid  (apf_rsv_c_slv_if.rvalid ),
       .apf_rsv_c_slv_rready  (apf_rsv_c_slv_if.rready ),
       
       .apf_rsv_d_slv_awaddr  (apf_rsv_d_slv_if.awaddr ),
       .apf_rsv_d_slv_awprot  (apf_rsv_d_slv_if.awprot ),
       .apf_rsv_d_slv_awvalid (apf_rsv_d_slv_if.awvalid),
       .apf_rsv_d_slv_awready (apf_rsv_d_slv_if.awready),
       .apf_rsv_d_slv_wdata   (apf_rsv_d_slv_if.wdata  ),
       .apf_rsv_d_slv_wstrb   (apf_rsv_d_slv_if.wstrb  ),
       .apf_rsv_d_slv_wvalid  (apf_rsv_d_slv_if.wvalid ),
       .apf_rsv_d_slv_wready  (apf_rsv_d_slv_if.wready ),
       .apf_rsv_d_slv_bresp   (apf_rsv_d_slv_if.bresp  ),
       .apf_rsv_d_slv_bvalid  (apf_rsv_d_slv_if.bvalid ),
       .apf_rsv_d_slv_bready  (apf_rsv_d_slv_if.bready ),
       .apf_rsv_d_slv_araddr  (apf_rsv_d_slv_if.araddr ),
       .apf_rsv_d_slv_arprot  (apf_rsv_d_slv_if.arprot ),
       .apf_rsv_d_slv_arvalid (apf_rsv_d_slv_if.arvalid),
       .apf_rsv_d_slv_arready (apf_rsv_d_slv_if.arready),
       .apf_rsv_d_slv_rdata   (apf_rsv_d_slv_if.rdata  ),
       .apf_rsv_d_slv_rresp   (apf_rsv_d_slv_if.rresp  ),
       .apf_rsv_d_slv_rvalid  (apf_rsv_d_slv_if.rvalid ),
       .apf_rsv_d_slv_rready  (apf_rsv_d_slv_if.rready ),
       
       .apf_rsv_e_slv_awaddr  (apf_rsv_e_slv_if.awaddr ),
       .apf_rsv_e_slv_awprot  (apf_rsv_e_slv_if.awprot ),
       .apf_rsv_e_slv_awvalid (apf_rsv_e_slv_if.awvalid),
       .apf_rsv_e_slv_awready (apf_rsv_e_slv_if.awready),
       .apf_rsv_e_slv_wdata   (apf_rsv_e_slv_if.wdata  ),
       .apf_rsv_e_slv_wstrb   (apf_rsv_e_slv_if.wstrb  ),
       .apf_rsv_e_slv_wvalid  (apf_rsv_e_slv_if.wvalid ),
       .apf_rsv_e_slv_wready  (apf_rsv_e_slv_if.wready ),
       .apf_rsv_e_slv_bresp   (apf_rsv_e_slv_if.bresp  ),
       .apf_rsv_e_slv_bvalid  (apf_rsv_e_slv_if.bvalid ),
       .apf_rsv_e_slv_bready  (apf_rsv_e_slv_if.bready ),
       .apf_rsv_e_slv_araddr  (apf_rsv_e_slv_if.araddr ),
       .apf_rsv_e_slv_arprot  (apf_rsv_e_slv_if.arprot ),
       .apf_rsv_e_slv_arvalid (apf_rsv_e_slv_if.arvalid),
       .apf_rsv_e_slv_arready (apf_rsv_e_slv_if.arready),
       .apf_rsv_e_slv_rdata   (apf_rsv_e_slv_if.rdata  ),
       .apf_rsv_e_slv_rresp   (apf_rsv_e_slv_if.rresp  ),
       .apf_rsv_e_slv_rvalid  (apf_rsv_e_slv_if.rvalid ),
       .apf_rsv_e_slv_rready  (apf_rsv_e_slv_if.rready ),
       
       .apf_rsv_f_slv_awaddr  (apf_rsv_f_slv_if.awaddr ),
       .apf_rsv_f_slv_awprot  (apf_rsv_f_slv_if.awprot ),
       .apf_rsv_f_slv_awvalid (apf_rsv_f_slv_if.awvalid),
       .apf_rsv_f_slv_awready (apf_rsv_f_slv_if.awready),
       .apf_rsv_f_slv_wdata   (apf_rsv_f_slv_if.wdata  ),
       .apf_rsv_f_slv_wstrb   (apf_rsv_f_slv_if.wstrb  ),
       .apf_rsv_f_slv_wvalid  (apf_rsv_f_slv_if.wvalid ),
       .apf_rsv_f_slv_wready  (apf_rsv_f_slv_if.wready ),
       .apf_rsv_f_slv_bresp   (apf_rsv_f_slv_if.bresp  ),
       .apf_rsv_f_slv_bvalid  (apf_rsv_f_slv_if.bvalid ),
       .apf_rsv_f_slv_bready  (apf_rsv_f_slv_if.bready ),
       .apf_rsv_f_slv_araddr  (apf_rsv_f_slv_if.araddr ),
       .apf_rsv_f_slv_arprot  (apf_rsv_f_slv_if.arprot ),
       .apf_rsv_f_slv_arvalid (apf_rsv_f_slv_if.arvalid),
       .apf_rsv_f_slv_arready (apf_rsv_f_slv_if.arready),
       .apf_rsv_f_slv_rdata   (apf_rsv_f_slv_if.rdata  ),
       .apf_rsv_f_slv_rresp   (apf_rsv_f_slv_if.rresp  ),
       .apf_rsv_f_slv_rvalid  (apf_rsv_f_slv_if.rvalid ),
       .apf_rsv_f_slv_rready  (apf_rsv_f_slv_if.rready ),
       
       .apf_bpf_slv_awaddr    (apf_bpf_slv_if.awaddr   ),
       .apf_bpf_slv_awprot    (apf_bpf_slv_if.awprot   ),
       .apf_bpf_slv_awvalid   (apf_bpf_slv_if.awvalid  ),
       .apf_bpf_slv_awready   (apf_bpf_slv_if.awready  ),
       .apf_bpf_slv_wdata     (apf_bpf_slv_if.wdata    ),
       .apf_bpf_slv_wstrb     (apf_bpf_slv_if.wstrb    ),
       .apf_bpf_slv_wvalid    (apf_bpf_slv_if.wvalid   ),
       .apf_bpf_slv_wready    (apf_bpf_slv_if.wready   ),
       .apf_bpf_slv_bresp     (apf_bpf_slv_if.bresp    ),
       .apf_bpf_slv_bvalid    (apf_bpf_slv_if.bvalid   ),
       .apf_bpf_slv_bready    (apf_bpf_slv_if.bready   ),
       .apf_bpf_slv_araddr    (apf_bpf_slv_if.araddr   ),
       .apf_bpf_slv_arprot    (apf_bpf_slv_if.arprot   ),
       .apf_bpf_slv_arvalid   (apf_bpf_slv_if.arvalid  ),
       .apf_bpf_slv_arready   (apf_bpf_slv_if.arready  ),
       .apf_bpf_slv_rdata     (apf_bpf_slv_if.rdata    ),
       .apf_bpf_slv_rresp     (apf_bpf_slv_if.rresp    ),
       .apf_bpf_slv_rvalid    (apf_bpf_slv_if.rvalid   ),
       .apf_bpf_slv_rready    (apf_bpf_slv_if.rready   ),
       
       .apf_bpf_mst_awaddr    (apf_bpf_mst_if.awaddr   ),
       .apf_bpf_mst_awprot    (apf_bpf_mst_if.awprot   ),
       .apf_bpf_mst_awvalid   (apf_bpf_mst_if.awvalid  ),
       .apf_bpf_mst_awready   (apf_bpf_mst_if.awready  ),
       .apf_bpf_mst_wdata     (apf_bpf_mst_if.wdata    ),
       .apf_bpf_mst_wstrb     (apf_bpf_mst_if.wstrb    ),
       .apf_bpf_mst_wvalid    (apf_bpf_mst_if.wvalid   ),
       .apf_bpf_mst_wready    (apf_bpf_mst_if.wready   ),
       .apf_bpf_mst_bresp     (apf_bpf_mst_if.bresp    ),
       .apf_bpf_mst_bvalid    (apf_bpf_mst_if.bvalid   ),
       .apf_bpf_mst_bready    (apf_bpf_mst_if.bready   ),
       .apf_bpf_mst_araddr    (apf_bpf_mst_if.araddr   ),
       .apf_bpf_mst_arprot    (apf_bpf_mst_if.arprot   ),
       .apf_bpf_mst_arvalid   (apf_bpf_mst_if.arvalid  ),
       .apf_bpf_mst_arready   (apf_bpf_mst_if.arready  ),
       .apf_bpf_mst_rdata     (apf_bpf_mst_if.rdata    ),
       .apf_bpf_mst_rresp     (apf_bpf_mst_if.rresp    ),
       .apf_bpf_mst_rvalid    (apf_bpf_mst_if.rvalid   ),
       .apf_bpf_mst_rready    (apf_bpf_mst_if.rready   )
       );

    // Reserved address response
 /*   apf_dummy_slv
    apf_achk_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_achk_slv_if)
    );
*/
    apf_dummy_slv
    apf_rsv_b_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_rsv_b_slv_if)
    );
 
    apf_dummy_slv
    apf_rsv_c_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_rsv_c_slv_if)
    );

    apf_dummy_slv
    apf_rsv_d_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_rsv_d_slv_if)
    );

    apf_dummy_slv
    apf_rsv_e_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_rsv_e_slv_if)
    );

    apf_dummy_slv
    apf_rsv_f_slv (
        .clk            (clk),
        .dummy_slv_if   (apf_rsv_f_slv_if)
    );    
/*       
always_comb
begin
    apf_rsv_b_slv_if.awready         = 1;
    apf_rsv_b_slv_if.wready          = 1;
    apf_rsv_b_slv_if.bresp           = 0;
    apf_rsv_b_slv_if.arready         = 1;
    apf_rsv_b_slv_if.rdata           = 0;
    apf_rsv_b_slv_if.rresp           = 0;
    
    apf_rsv_c_slv_if.awready         = 1;
    apf_rsv_c_slv_if.wready          = 1;
    apf_rsv_c_slv_if.bresp           = 0;
    apf_rsv_c_slv_if.arready         = 1;
    apf_rsv_c_slv_if.rdata           = 0;
    apf_rsv_c_slv_if.rresp           = 0;
    
    apf_rsv_d_slv_if.awready         = 1;
    apf_rsv_d_slv_if.wready          = 1;
    apf_rsv_d_slv_if.bresp           = 0;
    apf_rsv_d_slv_if.arready         = 1;
    apf_rsv_d_slv_if.rdata           = 0;
    apf_rsv_d_slv_if.rresp           = 0;
    
    apf_rsv_e_slv_if.awready         = 1;
    apf_rsv_e_slv_if.wready          = 1;
    apf_rsv_e_slv_if.bresp           = 0;
    apf_rsv_e_slv_if.arready         = 1;
    apf_rsv_e_slv_if.rdata           = 0;
    apf_rsv_e_slv_if.rresp           = 0;
    
    apf_rsv_f_slv_if.awready         = 1;
    apf_rsv_f_slv_if.wready          = 1;
    apf_rsv_f_slv_if.bresp           = 0;
    apf_rsv_f_slv_if.arready         = 1;
    apf_rsv_f_slv_if.rdata           = 0;
    apf_rsv_f_slv_if.rresp           = 0;
    
end

always_ff @ ( posedge clk ) 
begin                              // DUMMY address response
    apf_rsv_b_slv_if.bvalid         <= apf_rsv_b_slv_if.awvalid;
    apf_rsv_b_slv_if.rvalid         <= apf_rsv_b_slv_if.arvalid;
    apf_rsv_c_slv_if.bvalid         <= apf_rsv_c_slv_if.awvalid;
    apf_rsv_c_slv_if.rvalid         <= apf_rsv_c_slv_if.arvalid;
    apf_rsv_d_slv_if.bvalid         <= apf_rsv_d_slv_if.awvalid;
    apf_rsv_d_slv_if.rvalid         <= apf_rsv_d_slv_if.arvalid;
    apf_rsv_e_slv_if.bvalid         <= apf_rsv_e_slv_if.awvalid;
    apf_rsv_e_slv_if.rvalid         <= apf_rsv_e_slv_if.arvalid;
    apf_rsv_f_slv_if.bvalid         <= apf_rsv_f_slv_if.awvalid;
    apf_rsv_f_slv_if.rvalid         <= apf_rsv_f_slv_if.arvalid;
end
*/
// ---------------------------------------------------------------------------
// Display Debug Messages
// ---------------------------------------------------------------------------
always @ (posedge clk)
begin
  `ifdef AFU_MSG

  /* synthesis translate_off */

  if(pcie_ss_axis_rx.tvalid & pcie_ss_axis_rx.tready)
    pcie_ss_pkg::display_cycle("AFU_TOP_RX", 1'b1, (rx_sop_init | rx_sop_valid), pcie_ss_axis_rx.tlast, pcie_ss_axis_rx.tdata);

  if(pcie_ss_axis_tx.tvalid & pcie_ss_axis_tx.tready)
    pcie_ss_pkg::display_cycle("AFU_TOP_TX", 1'b0, tx_sop_valid, pcie_ss_axis_tx.tlast, pcie_ss_axis_tx.tdata);

  /* synthesis translate_on */

  `endif //AFU_MSG

end
  `ifdef DEBUG_APF

         reg  [25:0]    DEBUG_st2mm_mst_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_st2mm_mst_awprot      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_st2mm_mst_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_st2mm_mst_arprot      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_st2mm_mst_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_st2mm_mst_rresp       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_st2mm_mst_bresp       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_mst_bready      /* synthesis noprune */       ;
                                                          
         reg  [25:0]    DEBUG_st2mm_slv_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_st2mm_slv_awprot      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_st2mm_slv_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_st2mm_slv_arprot      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_st2mm_slv_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_st2mm_slv_rresp       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_st2mm_slv_bresp       /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_st2mm_slv_bready      /* synthesis noprune */       ;
                                                          
         reg  [25:0]    DEBUG_bpf_slv_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_bpf_slv_awprot      /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_bpf_slv_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_bpf_slv_arprot      /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_bpf_slv_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_bpf_slv_rresp       /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_bpf_slv_bresp       /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_bpf_slv_bready      /* synthesis noprune */       ;
                                                          
         reg  [25:0]    DEBUG_pgsk_slv_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pgsk_slv_awprot      /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_pgsk_slv_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pgsk_slv_arprot      /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_pgsk_slv_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pgsk_slv_rresp       /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pgsk_slv_bresp       /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_pgsk_slv_bready      /* synthesis noprune */       ;
                                                          
         reg  [25:0]    DEBUG_achk_slv_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_achk_slv_awprot      /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_achk_slv_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_achk_slv_arprot      /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_achk_slv_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_achk_slv_rresp       /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_achk_slv_bresp       /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_achk_slv_bready      /* synthesis noprune */       ;
                                                          
         reg            DEBUG_rsv_b_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_b_slv_wready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_b_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_b_slv_rready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_c_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_c_slv_wready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_c_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_c_slv_rready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_d_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_d_slv_wready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_d_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_d_slv_rready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_e_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_e_slv_wready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_e_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_e_slv_rready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_f_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_f_slv_wready      /* synthesis noprune */       ;
         reg            DEBUG_rsv_f_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_rsv_f_slv_rready      /* synthesis noprune */       ;

         always @ (posedge clk)
         begin
             DEBUG_st2mm_mst_awaddr     <=   apf_st2mm_mst_if.awaddr             ;
             DEBUG_st2mm_mst_awprot     <=   apf_st2mm_mst_if.awprot             ;
             DEBUG_st2mm_mst_awvalid    <=   apf_st2mm_mst_if.awvalid            ;
             DEBUG_st2mm_mst_awready    <=   apf_st2mm_mst_if.awready            ;
             DEBUG_st2mm_mst_araddr     <=   apf_st2mm_mst_if.araddr             ;
             DEBUG_st2mm_mst_arprot     <=   apf_st2mm_mst_if.arprot             ;
             DEBUG_st2mm_mst_arvalid    <=   apf_st2mm_mst_if.arvalid            ;
             DEBUG_st2mm_mst_arready    <=   apf_st2mm_mst_if.arready            ;
             DEBUG_st2mm_mst_wstrb      <=   apf_st2mm_mst_if.wstrb              ;
             DEBUG_st2mm_mst_wvalid     <=   apf_st2mm_mst_if.wvalid             ;
             DEBUG_st2mm_mst_wready     <=   apf_st2mm_mst_if.wready             ;
             DEBUG_st2mm_mst_rresp      <=   apf_st2mm_mst_if.rresp              ;
             DEBUG_st2mm_mst_rvalid     <=   apf_st2mm_mst_if.rvalid             ;
             DEBUG_st2mm_mst_rready     <=   apf_st2mm_mst_if.rready             ;
             DEBUG_st2mm_mst_bresp      <=   apf_st2mm_mst_if.bresp              ;
             DEBUG_st2mm_mst_bvalid     <=   apf_st2mm_mst_if.bvalid             ;
             DEBUG_st2mm_mst_bready     <=   apf_st2mm_mst_if.bready             ;
                                                                                 
             DEBUG_st2mm_slv_awaddr     <=   apf_st2mm_slv_if.awaddr             ;
             DEBUG_st2mm_slv_awprot     <=   apf_st2mm_slv_if.awprot             ;
             DEBUG_st2mm_slv_awvalid    <=   apf_st2mm_slv_if.awvalid            ;
             DEBUG_st2mm_slv_awready    <=   apf_st2mm_slv_if.awready            ;
             DEBUG_st2mm_slv_araddr     <=   apf_st2mm_slv_if.araddr             ;
             DEBUG_st2mm_slv_arprot     <=   apf_st2mm_slv_if.arprot             ;
             DEBUG_st2mm_slv_arvalid    <=   apf_st2mm_slv_if.arvalid            ;
             DEBUG_st2mm_slv_arready    <=   apf_st2mm_slv_if.arready            ;
             DEBUG_st2mm_slv_wstrb      <=   apf_st2mm_slv_if.wstrb              ;
             DEBUG_st2mm_slv_wvalid     <=   apf_st2mm_slv_if.wvalid             ;
             DEBUG_st2mm_slv_wready     <=   apf_st2mm_slv_if.wready             ;
             DEBUG_st2mm_slv_rresp      <=   apf_st2mm_slv_if.rresp              ;
             DEBUG_st2mm_slv_rvalid     <=   apf_st2mm_slv_if.rvalid             ;
             DEBUG_st2mm_slv_rready     <=   apf_st2mm_slv_if.rready             ;
             DEBUG_st2mm_slv_bresp      <=   apf_st2mm_slv_if.bresp              ;
             DEBUG_st2mm_slv_bvalid     <=   apf_st2mm_slv_if.bvalid             ;
             DEBUG_st2mm_slv_bready     <=   apf_st2mm_slv_if.bready             ;
                                                                                 
             DEBUG_bpf_slv_awaddr       <=   apf_bpf_slv_if.awaddr             ;
             DEBUG_bpf_slv_awprot       <=   apf_bpf_slv_if.awprot             ;
             DEBUG_bpf_slv_awvalid      <=   apf_bpf_slv_if.awvalid            ;
             DEBUG_bpf_slv_awready      <=   apf_bpf_slv_if.awready            ;
             DEBUG_bpf_slv_araddr       <=   apf_bpf_slv_if.araddr             ;
             DEBUG_bpf_slv_arprot       <=   apf_bpf_slv_if.arprot             ;
             DEBUG_bpf_slv_arvalid      <=   apf_bpf_slv_if.arvalid            ;
             DEBUG_bpf_slv_arready      <=   apf_bpf_slv_if.arready            ;
             DEBUG_bpf_slv_wstrb        <=   apf_bpf_slv_if.wstrb              ;
             DEBUG_bpf_slv_wvalid       <=   apf_bpf_slv_if.wvalid             ;
             DEBUG_bpf_slv_wready       <=   apf_bpf_slv_if.wready             ;
             DEBUG_bpf_slv_rresp        <=   apf_bpf_slv_if.rresp              ;
             DEBUG_bpf_slv_rvalid       <=   apf_bpf_slv_if.rvalid             ;
             DEBUG_bpf_slv_rready       <=   apf_bpf_slv_if.rready             ;
             DEBUG_bpf_slv_bresp        <=   apf_bpf_slv_if.bresp              ;
             DEBUG_bpf_slv_bvalid       <=   apf_bpf_slv_if.bvalid             ;
             DEBUG_bpf_slv_bready       <=   apf_bpf_slv_if.bready             ;
                                                                                 
             DEBUG_pgsk_slv_awaddr      <=   apf_pgsk_slv_if.awaddr             ;
             DEBUG_pgsk_slv_awprot      <=   apf_pgsk_slv_if.awprot             ;
             DEBUG_pgsk_slv_awvalid     <=   apf_pgsk_slv_if.awvalid            ;
             DEBUG_pgsk_slv_awready     <=   apf_pgsk_slv_if.awready            ;
             DEBUG_pgsk_slv_araddr      <=   apf_pgsk_slv_if.araddr             ;
             DEBUG_pgsk_slv_arprot      <=   apf_pgsk_slv_if.arprot             ;
             DEBUG_pgsk_slv_arvalid     <=   apf_pgsk_slv_if.arvalid            ;
             DEBUG_pgsk_slv_arready     <=   apf_pgsk_slv_if.arready            ;
             DEBUG_pgsk_slv_wstrb       <=   apf_pgsk_slv_if.wstrb              ;
             DEBUG_pgsk_slv_wvalid      <=   apf_pgsk_slv_if.wvalid             ;
             DEBUG_pgsk_slv_wready      <=   apf_pgsk_slv_if.wready             ;
             DEBUG_pgsk_slv_rresp       <=   apf_pgsk_slv_if.rresp              ;
             DEBUG_pgsk_slv_rvalid      <=   apf_pgsk_slv_if.rvalid             ;
             DEBUG_pgsk_slv_rready      <=   apf_pgsk_slv_if.rready             ;
             DEBUG_pgsk_slv_bresp       <=   apf_pgsk_slv_if.bresp              ;
             DEBUG_pgsk_slv_bvalid      <=   apf_pgsk_slv_if.bvalid             ;
             DEBUG_pgsk_slv_bready      <=   apf_pgsk_slv_if.bready             ;
                                                                                 
             DEBUG_achk_slv_awaddr      <=   apf_achk_slv_if.awaddr             ;
             DEBUG_achk_slv_awprot      <=   apf_achk_slv_if.awprot             ;
             DEBUG_achk_slv_awvalid     <=   apf_achk_slv_if.awvalid            ;
             DEBUG_achk_slv_awready     <=   apf_achk_slv_if.awready            ;
             DEBUG_achk_slv_araddr      <=   apf_achk_slv_if.araddr             ;
             DEBUG_achk_slv_arprot      <=   apf_achk_slv_if.arprot             ;
             DEBUG_achk_slv_arvalid     <=   apf_achk_slv_if.arvalid            ;
             DEBUG_achk_slv_arready     <=   apf_achk_slv_if.arready            ;
             DEBUG_achk_slv_wstrb       <=   apf_achk_slv_if.wstrb              ;
             DEBUG_achk_slv_wvalid      <=   apf_achk_slv_if.wvalid             ;
             DEBUG_achk_slv_wready      <=   apf_achk_slv_if.wready             ;
             DEBUG_achk_slv_rresp       <=   apf_achk_slv_if.rresp              ;
             DEBUG_achk_slv_rvalid      <=   apf_achk_slv_if.rvalid             ;
             DEBUG_achk_slv_rready      <=   apf_achk_slv_if.rready             ;
             DEBUG_achk_slv_bresp       <=   apf_achk_slv_if.bresp              ;
             DEBUG_achk_slv_bvalid      <=   apf_achk_slv_if.bvalid             ;
             DEBUG_achk_slv_bready      <=   apf_achk_slv_if.bready             ;
                                                                                 
             DEBUG_rsv_b_slv_wvalid     <=   apf_rsv_b_slv_if.wvalid             ;
             DEBUG_rsv_b_slv_wready     <=   apf_rsv_b_slv_if.wready             ;
             DEBUG_rsv_b_slv_rvalid     <=   apf_rsv_b_slv_if.rvalid             ;
             DEBUG_rsv_b_slv_rready     <=   apf_rsv_b_slv_if.rready             ;
             DEBUG_rsv_c_slv_wvalid     <=   apf_rsv_c_slv_if.wvalid             ;
             DEBUG_rsv_c_slv_wready     <=   apf_rsv_c_slv_if.wready             ;
             DEBUG_rsv_c_slv_rvalid     <=   apf_rsv_c_slv_if.rvalid             ;
             DEBUG_rsv_c_slv_rready     <=   apf_rsv_c_slv_if.rready             ;
             DEBUG_rsv_d_slv_wvalid     <=   apf_rsv_d_slv_if.wvalid             ;
             DEBUG_rsv_d_slv_wready     <=   apf_rsv_d_slv_if.wready             ;
             DEBUG_rsv_d_slv_rvalid     <=   apf_rsv_d_slv_if.rvalid             ;
             DEBUG_rsv_d_slv_rready     <=   apf_rsv_d_slv_if.rready             ;
             DEBUG_rsv_e_slv_wvalid     <=   apf_rsv_e_slv_if.wvalid             ;
             DEBUG_rsv_e_slv_wready     <=   apf_rsv_e_slv_if.wready             ;
             DEBUG_rsv_e_slv_rvalid     <=   apf_rsv_e_slv_if.rvalid             ;
             DEBUG_rsv_e_slv_rready     <=   apf_rsv_e_slv_if.rready             ;
             DEBUG_rsv_f_slv_wvalid     <=   apf_rsv_f_slv_if.wvalid             ;
             DEBUG_rsv_f_slv_wready     <=   apf_rsv_f_slv_if.wready             ;
             DEBUG_rsv_f_slv_rvalid     <=   apf_rsv_f_slv_if.rvalid             ;
             DEBUG_rsv_f_slv_rready     <=   apf_rsv_f_slv_if.rready             ;
         end

  `endif             
endmodule
    
module apf_dummy_slv (
    input                       clk,
    ofs_fim_axi_lite_if.slave   dummy_slv_if
);
    
    always_comb
    begin
        dummy_slv_if.awready         = 1;
        dummy_slv_if.wready          = 1;
        dummy_slv_if.bresp           = 0;
        dummy_slv_if.arready         = 1;
        dummy_slv_if.rdata           = 0;
        dummy_slv_if.rresp           = 0;
    end  

    always_ff @ ( posedge clk )
    begin                              // DUMMY address response
        dummy_slv_if.bvalid         <= dummy_slv_if.awvalid;
        dummy_slv_if.rvalid         <= dummy_slv_if.arvalid;
    end     
    
endmodule
