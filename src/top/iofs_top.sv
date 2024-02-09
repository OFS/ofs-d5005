// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// IOFS top wrapper

                   `include "fpga_defines.vh"
                    import   top_cfg_pkg::*          ; 
                    import   ofs_fim_cfg_pkg::*      ;
                    import   ofs_fim_if_pkg::*       ;
                    import   ofs_fim_pcie_pkg::*     ;
`ifdef INCLUDE_HSSI import   ofs_fim_eth_if_pkg::*   ;`endif

//-----------------------------------------------------------------------------
// Module ports
//-----------------------------------------------------------------------------

module iofs_top    (
                    input                                     SYS_RefClk                        ,// System Reference Clock (100MHz)
                    input                                     PCIE_RefClk                       ,// PCIe clock
                    input                                     PCIE_Rst_n                        ,// PCIe reset
                    input  [ofs_fim_pcie_pkg::PCIE_LANES-1:0] PCIE_Rx                           ,// PCIe RX interface
                    output [ofs_fim_pcie_pkg::PCIE_LANES-1:0] PCIE_Tx                           ,// PCIe TX interface 
                    output                                    SPI_sclk                          ,// SPI clock
                    output                                    SPI_cs_l                          ,// SPI chip select (active-low)
                    output                                    SPI_mosi                          ,// SPI data output
                    input                                     SPI_miso                          ,// SPI data input
                    
                    ofs_fim_emif_mem_if.emif                  ddr4_mem [NUM_MEM_CH-1:0]          // EMIF DDR4 x72 RDIMM (x8)

 `ifdef INCLUDE_HSSI                                                           ,
                    output                   qsfp_3v0_port_en                  ,// QSFP port controller enable             
                    input  wire              qsfp_3v0_port_int_n               ,// QSFP port controller interrupt driven pre-fetch
                    input                    qsfp0_644_53125_clk               ,// QSFP0 644.53125 Ethernet reference clock
                    input                    qsfp1_644_53125_clk               ,// QSFP1 644.53125 Ethernet reference clock
                    output [3:0]             qsfp0_tx_serial                   ,// QSFP0 TX serial data
                    input  [3:0]             qsfp0_rx_serial                   ,// QSFP0 RX serial data
                    output [3:0]             qsfp1_tx_serial                   ,// QSFP1 TX serial data
                    input  [3:0]             qsfp1_rx_serial                    // QSFP1 RX serial data
 `endif
                    );

//-----------------------------------------------------------------------------
// Internal signals
//-----------------------------------------------------------------------------

// clock signals
logic clk_1x;
logic clk_div2;
logic clk_100M;

// reset signals
logic pll_locked;
logic ninit_done;
logic npor;
logic pcie_reset_status;
logic rst_n_1x;
logic rst_n_div2;
logic rst_n_100M;
logic [3:0] pf0_flrst_n;
logic pwr_good_clk_n;


// PCIe sideband signals 
t_sideband_from_pcie  p2c_sideband;
t_sideband_to_pcie    c2p_sideband;

// AXI CSR interfaces
ofs_fim_axi_mmio_if #(
   .AWID_WIDTH   (ofs_fim_cfg_pkg::MMIO_TID_WIDTH),
   .AWADDR_WIDTH (ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH),
   .WDATA_WIDTH  (ofs_fim_cfg_pkg::MMIO_DATA_WIDTH),
   .ARID_WIDTH   (ofs_fim_cfg_pkg::MMIO_TID_WIDTH),
   .ARADDR_WIDTH (ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH),
   .RDATA_WIDTH  (ofs_fim_cfg_pkg::MMIO_DATA_WIDTH)
)
ext_csr_if [EXT_CSR_SLAVES-1:0]();

// AXI4-lite interfaces
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(19), .ARADDR_WIDTH(19)) bpf_apf_mst_if  ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(20), .ARADDR_WIDTH(20)) bpf_apf_slv_if  ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(20), .ARADDR_WIDTH(20)) bpf_fme_mst_if  ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_fme_slv_if  ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_pmci_slv_if ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_pcie_slv_if ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_emif_slv_if ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_hssi_slv_if ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_rsv_5_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_rsv_6_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16)) bpf_rsv_7_slv_if();

// AXIS IRQ interfaces
ofs_fim_irq_axis_if ext_fme_irq_if   [EXT_FME_IRQ_IFS-1:0]();

// AXIS PCIe channels (IOFS EA PCIe Subsystem)
ofs_fim_pcie_rxs_axis_if   pcie_rx_st();
ofs_fim_pcie_txs_axis_if   pcie_tx_st();

// AXIS PCIe Subsystem Interface
pcie_ss_axis_if pcie_ss_axis_rx_if(.clk (clk_1x), .rst_n(rst_n_1x));
pcie_ss_axis_if pcie_ss_axis_tx_if(.clk (clk_1x), .rst_n(rst_n_1x));

// AVST interface
ofs_fim_axi_lite_if m_afu_lite();
ofs_fim_axi_lite_if s_afu_lite();

//AFU EMIF AVMM IF
ofs_fim_emif_avmm_if  ddr4_avmm      [NUM_MEM_CH] ();


//-----------------------------------------------------------------------------
// Resets - Split for timing
// synthesis preserve_syn_only - Prevents removal of registers during synthesis. 
// This settings does not affect retiming or other optimizations in the Fitter.
//-----------------------------------------------------------------------------
logic rst_n_a_1x /* synthesis preserve_syn_only */ ;
logic rst_n_b_1x /* synthesis preserve_syn_only */ ;
logic rst_n_c_1x /* synthesis preserve_syn_only */ ;
logic rst_n_d_1x /* synthesis preserve_syn_only */ ;
logic rst_n_e_1x /* synthesis preserve_syn_only */ ;
logic rst_n_f_1x /* synthesis preserve_syn_only */ ;
logic rst_n_g_1x /* synthesis preserve_syn_only */ ;

always @ (posedge clk_1x)
begin
  rst_n_a_1x  <= rst_n_1x;
  rst_n_b_1x  <= rst_n_1x;
  rst_n_c_1x  <= rst_n_1x;
  rst_n_d_1x  <= rst_n_1x;
  rst_n_e_1x  <= rst_n_1x;
  rst_n_f_1x  <= rst_n_1x;
  rst_n_g_1x  <= rst_n_1x;
end

//-----------------------------------------------------------------------------
// Modules instances
//-----------------------------------------------------------------------------


//*******************************
//*******************************

  
wire  [7:0]                      tx_serial;
wire  [7:0]                      rx_serial;
wire                             ss_app_st_p0_rx_tvalid;
wire  [63:0]                     ss_app_st_p0_rx_tdata;
wire  [7:0]                      ss_app_st_p0_rx_tkeep;
wire                             ss_app_st_p0_rx_tlast;
wire  [1:0]                      ss_app_st_p0_rx_tuser_client;
ofs_fim_hssi_ss_tx_axis_if       hssi_ss_st_tx[MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_ss_rx_axis_if       hssi_ss_st_rx[MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_fc_if               hssi_fc[MAX_NUM_ETH_CHANNELS-1:0]();
logic [MAX_NUM_ETH_CHANNELS-1:0] hssi_clk_pll;

`ifdef INCLUDE_HSSI
// Enable QSFP port controller
assign qsfp_3v0_port_en          = 1'b1;
assign qsfp1_tx_serial           = tx_serial[3:0];
assign qsfp0_tx_serial           = tx_serial[7:4];
assign rx_serial                 = {qsfp0_rx_serial, qsfp1_rx_serial} ;

eth_ac_wrapper eth_ac_wrapper (
  .clk_csr                    (clk_1x),
  .rst_n_csr                  (rst_n_a_1x),
  .clk_100M                   (clk_100M),
  .rst_n_100M                 (rst_n_100M),
  .csr_lite_if                (bpf_hssi_slv_if),
  .hssi_ss_st_tx              (hssi_ss_st_tx),
  .hssi_ss_st_rx              (hssi_ss_st_rx),

  .hssi_fc                    (hssi_fc),

  .tx_serial                  (tx_serial),
  .tx_serial_n                (),
  .rx_serial                  (rx_serial),

  .subsystem_cold_rst_n       (rst_n_a_1x),
  .i_clk_ref                  ({qsfp0_644_53125_clk,qsfp1_644_53125_clk}),
  .o_hssi_clk_pll             (hssi_clk_pll)
);
  
`endif

//*******************************
// System PLL
//*******************************

 sys_pll 
 sys_pll(
         .rst                (ninit_done                ),
         .refclk             (SYS_RefClk                ),
         .locked             (pll_locked                ),
         .outclk_0           (clk_1x                    ),
         .outclk_1           (clk_div2                  ),
         .outclk_2           (clk_100M                  )
         );

//*******************************
// Reset controller
//*******************************
 rst_ctrl 
 rst_ctrl(
          .clk_1x             (clk_1x                   ),
          .clk_div2           (clk_div2                 ),
          .clk_100M           (clk_100M                 ),
          .pll_locked         (pll_locked               ),
          .pcie_reset_n       (PCIE_Rst_n               ),
          .pcie_reset_status  (pcie_reset_status        ),
                                                        
          .ninit_done         (ninit_done               ),
          .npor               (npor                     ),
          .pwr_good_clk_n     (pwr_good_clk_n           ),  // power good reset synchronous to clk_1x 
          .rst_n_1x           (rst_n_1x                 ),  // system reset synchronous to clk_1x
          .rst_n_div2         (rst_n_div2               ),  // system reset synchronous to clk_div2
          .rst_n_100M         (rst_n_100M               ),  // system reset synchronous to clk_100M
          
          .p2c_sideband       (p2c_sideband             ),
          .c2p_sideband       (c2p_sideband             ),
          .pf0_flrst_n        (pf0_flrst_n              ),
          .pf1_flrst_n        ()   
 ); 

//*******************************
// PCIe Subsystem
//*******************************

  pcie_wrapper #(.PCIE_RANDOM_RDY   (1)                         )
  pcie_wrapper  (
                .fim_clk            (clk_1x                     ),
                .fim_rst_n          (rst_n_b_1x                 ),
                .ninit_done         (ninit_done                 ),
                .npor               (npor                       ),
                .reset_status       (pcie_reset_status          ),                 
                .pin_pcie_ref_clk_p (PCIE_RefClk                ),
                .pin_pcie_in_perst_n(PCIE_Rst_n                 ),   // connected to HIP
                .pin_pcie_rx_p      (PCIE_Rx                    ),
                .pin_pcie_tx_p      (PCIE_Tx                    ),                
                .axi_st_rx_if       (pcie_ss_axis_rx_if         ),
                .axi_st_tx_if       (pcie_ss_axis_tx_if         ),
                .csr_lite_if        (bpf_pcie_slv_if            ),
                .irq_if             (ext_fme_irq_if[PCIE_CSR_ID]),
                .pcie_p2c_sideband  (p2c_sideband               ),
                .pcie_c2p_sideband  (c2p_sideband               )
                );


//*******************************
// PMCI Subsystem
//*******************************

  pmci_top 
  pmci_top( 
          .clk_1x              (clk_1x                  ),
          .clk_div2            (clk_div2                ),
          
          .rst_n_1x            (rst_n_c_1x   ),
          .rst_n_div2          (rst_n_div2              ),                          
                                    
          .csr_lite_if         (bpf_pmci_slv_if         ),
          .spi_miso            (SPI_miso                ),
          .spi_mosi            (SPI_mosi                ),
          .spi_s_clk           (SPI_sclk                ),
          .spi_cs_l            (SPI_cs_l                )
          );

//*******************************
// FME
//*******************************

  fme_top 
  fme_top(
          .clk               (clk_1x                    ),
          .rst_n             (rst_n_d_1x                ),
          .pwr_good_n        (ninit_done                ),
          
          .axi_lite_m_if     (bpf_fme_mst_if            ),
          .axi_lite_s_if     (bpf_fme_slv_if            )
         );

//*******************************
// AFU
//*******************************

  afu_top 
  afu_top(
         .refclk              (SYS_RefClk               ),
         .clk                 (clk_1x                   ),
         .clk_div2            (clk_div2                 ),
         .clk_100             (clk_100M                 ),

         .rst_n               (rst_n_e_1x               ),
         .pwr_good_clk_n      (pwr_good_clk_n           ), // power good reset synchronous to clk_1x
         .rst_n_div2          (rst_n_div2               ),
         .rst_n_100           (rst_n_100M               ),
         .func_rst_n          (pf0_flrst_n              ),   
                                 
         .apf_bpf_slv_if      (bpf_apf_mst_if           ), 
         .apf_bpf_mst_if      (bpf_apf_slv_if           ),  

         `ifdef INCLUDE_HE_HSSI
            .hssi_ss_st_tx          ( hssi_ss_st_tx      ),
            .hssi_ss_st_rx          ( hssi_ss_st_rx      ),
            .hssi_fc                ( hssi_fc            ),
            `ifdef INCLUDE_PTP
               .hssi_ptp_tx_tod     ( hssi_ptp_tx_tod    ),
               .hssi_ptp_rx_tod     ( hssi_ptp_rx_tod    ),
               .hssi_ptp_tx_egrts   ( hssi_ptp_tx_egrts  ),
               .hssi_ptp_rx_ingrts  ( hssi_ptp_rx_ingrts ),
            `endif
            .i_hssi_clk_pll         ( hssi_clk_pll        ),
         `endif

         .pcie_ss_axis_rx     (pcie_ss_axis_rx_if       ),
         .pcie_ss_axis_tx     (pcie_ss_axis_tx_if       ),
         .afu_mem_if          (ddr4_avmm                )
         );

//*******************************
// BPF
//*******************************

     bpf 
     bpf (
          .clk_clk              (clk_1x                 ),
          .rst_n_reset_n        (rst_n_f_1x   ),
          
          .bpf_apf_mst_awaddr   (bpf_apf_mst_if.awaddr  ),
          .bpf_apf_mst_awprot   (bpf_apf_mst_if.awprot  ),
          .bpf_apf_mst_awvalid  (bpf_apf_mst_if.awvalid ),
          .bpf_apf_mst_awready  (bpf_apf_mst_if.awready ),
          .bpf_apf_mst_wdata    (bpf_apf_mst_if.wdata   ),
          .bpf_apf_mst_wstrb    (bpf_apf_mst_if.wstrb   ),
          .bpf_apf_mst_wvalid   (bpf_apf_mst_if.wvalid  ),
          .bpf_apf_mst_wready   (bpf_apf_mst_if.wready  ),
          .bpf_apf_mst_bresp    (bpf_apf_mst_if.bresp   ),
          .bpf_apf_mst_bvalid   (bpf_apf_mst_if.bvalid  ),
          .bpf_apf_mst_bready   (bpf_apf_mst_if.bready  ),
          .bpf_apf_mst_araddr   (bpf_apf_mst_if.araddr  ),
          .bpf_apf_mst_arprot   (bpf_apf_mst_if.arprot  ),
          .bpf_apf_mst_arvalid  (bpf_apf_mst_if.arvalid ),
          .bpf_apf_mst_arready  (bpf_apf_mst_if.arready ),
          .bpf_apf_mst_rdata    (bpf_apf_mst_if.rdata   ),
          .bpf_apf_mst_rresp    (bpf_apf_mst_if.rresp   ),
          .bpf_apf_mst_rvalid   (bpf_apf_mst_if.rvalid  ),
          .bpf_apf_mst_rready   (bpf_apf_mst_if.rready  ),
          
          .bpf_fme_slv_awaddr   (bpf_fme_slv_if.awaddr  ),
          .bpf_fme_slv_awprot   (bpf_fme_slv_if.awprot  ),
          .bpf_fme_slv_awvalid  (bpf_fme_slv_if.awvalid ),
          .bpf_fme_slv_awready  (bpf_fme_slv_if.awready ),
          .bpf_fme_slv_wdata    (bpf_fme_slv_if.wdata   ),
          .bpf_fme_slv_wstrb    (bpf_fme_slv_if.wstrb   ),
          .bpf_fme_slv_wvalid   (bpf_fme_slv_if.wvalid  ),
          .bpf_fme_slv_wready   (bpf_fme_slv_if.wready  ),
          .bpf_fme_slv_bresp    (bpf_fme_slv_if.bresp   ),
          .bpf_fme_slv_bvalid   (bpf_fme_slv_if.bvalid  ),
          .bpf_fme_slv_bready   (bpf_fme_slv_if.bready  ),
          .bpf_fme_slv_araddr   (bpf_fme_slv_if.araddr  ),
          .bpf_fme_slv_arprot   (bpf_fme_slv_if.arprot  ),
          .bpf_fme_slv_arvalid  (bpf_fme_slv_if.arvalid ),
          .bpf_fme_slv_arready  (bpf_fme_slv_if.arready ),
          .bpf_fme_slv_rdata    (bpf_fme_slv_if.rdata   ),
          .bpf_fme_slv_rresp    (bpf_fme_slv_if.rresp   ),
          .bpf_fme_slv_rvalid   (bpf_fme_slv_if.rvalid  ),
          .bpf_fme_slv_rready   (bpf_fme_slv_if.rready  ),
          
          .bpf_pcie_slv_awaddr  (bpf_pcie_slv_if.awaddr ), 
          .bpf_pcie_slv_awprot  (bpf_pcie_slv_if.awprot ), 
          .bpf_pcie_slv_awvalid (bpf_pcie_slv_if.awvalid), 
          .bpf_pcie_slv_awready (bpf_pcie_slv_if.awready), 
          .bpf_pcie_slv_wdata   (bpf_pcie_slv_if.wdata  ), 
          .bpf_pcie_slv_wstrb   (bpf_pcie_slv_if.wstrb  ), 
          .bpf_pcie_slv_wvalid  (bpf_pcie_slv_if.wvalid ), 
          .bpf_pcie_slv_wready  (bpf_pcie_slv_if.wready ), 
          .bpf_pcie_slv_bresp   (bpf_pcie_slv_if.bresp  ), 
          .bpf_pcie_slv_bvalid  (bpf_pcie_slv_if.bvalid ), 
          .bpf_pcie_slv_bready  (bpf_pcie_slv_if.bready ), 
          .bpf_pcie_slv_araddr  (bpf_pcie_slv_if.araddr ), 
          .bpf_pcie_slv_arprot  (bpf_pcie_slv_if.arprot ), 
          .bpf_pcie_slv_arvalid (bpf_pcie_slv_if.arvalid), 
          .bpf_pcie_slv_arready (bpf_pcie_slv_if.arready), 
          .bpf_pcie_slv_rdata   (bpf_pcie_slv_if.rdata  ), 
          .bpf_pcie_slv_rresp   (bpf_pcie_slv_if.rresp  ), 
          .bpf_pcie_slv_rvalid  (bpf_pcie_slv_if.rvalid ), 
          .bpf_pcie_slv_rready  (bpf_pcie_slv_if.rready ), 
          
          .bpf_pmci_slv_awaddr  (bpf_pmci_slv_if.awaddr ),
          .bpf_pmci_slv_awprot  (bpf_pmci_slv_if.awprot ),
          .bpf_pmci_slv_awvalid (bpf_pmci_slv_if.awvalid),
          .bpf_pmci_slv_awready (bpf_pmci_slv_if.awready),
          .bpf_pmci_slv_wdata   (bpf_pmci_slv_if.wdata  ),
          .bpf_pmci_slv_wstrb   (bpf_pmci_slv_if.wstrb  ),
          .bpf_pmci_slv_wvalid  (bpf_pmci_slv_if.wvalid ),
          .bpf_pmci_slv_wready  (bpf_pmci_slv_if.wready ),
          .bpf_pmci_slv_bresp   (bpf_pmci_slv_if.bresp  ),
          .bpf_pmci_slv_bvalid  (bpf_pmci_slv_if.bvalid ),
          .bpf_pmci_slv_bready  (bpf_pmci_slv_if.bready ),
          .bpf_pmci_slv_araddr  (bpf_pmci_slv_if.araddr ),
          .bpf_pmci_slv_arprot  (bpf_pmci_slv_if.arprot ),
          .bpf_pmci_slv_arvalid (bpf_pmci_slv_if.arvalid),
          .bpf_pmci_slv_arready (bpf_pmci_slv_if.arready),
          .bpf_pmci_slv_rdata   (bpf_pmci_slv_if.rdata  ),
          .bpf_pmci_slv_rresp   (bpf_pmci_slv_if.rresp  ),
          .bpf_pmci_slv_rvalid  (bpf_pmci_slv_if.rvalid ),
          .bpf_pmci_slv_rready  (bpf_pmci_slv_if.rready ),
          
          .bpf_emif_slv_awaddr  (bpf_emif_slv_if.awaddr ),
          .bpf_emif_slv_awprot  (bpf_emif_slv_if.awprot ),
          .bpf_emif_slv_awvalid (bpf_emif_slv_if.awvalid),
          .bpf_emif_slv_awready (bpf_emif_slv_if.awready),
          .bpf_emif_slv_wdata   (bpf_emif_slv_if.wdata  ),
          .bpf_emif_slv_wstrb   (bpf_emif_slv_if.wstrb  ),
          .bpf_emif_slv_wvalid  (bpf_emif_slv_if.wvalid ),
          .bpf_emif_slv_wready  (bpf_emif_slv_if.wready ),
          .bpf_emif_slv_bresp   (bpf_emif_slv_if.bresp  ),
          .bpf_emif_slv_bvalid  (bpf_emif_slv_if.bvalid ),
          .bpf_emif_slv_bready  (bpf_emif_slv_if.bready ),
          .bpf_emif_slv_araddr  (bpf_emif_slv_if.araddr ),
          .bpf_emif_slv_arprot  (bpf_emif_slv_if.arprot ),
          .bpf_emif_slv_arvalid (bpf_emif_slv_if.arvalid),
          .bpf_emif_slv_arready (bpf_emif_slv_if.arready),
          .bpf_emif_slv_rdata   (bpf_emif_slv_if.rdata  ),
          .bpf_emif_slv_rresp   (bpf_emif_slv_if.rresp  ),
          .bpf_emif_slv_rvalid  (bpf_emif_slv_if.rvalid ),
          .bpf_emif_slv_rready  (bpf_emif_slv_if.rready ),
                    
          .bpf_hssi_slv_awaddr  (bpf_hssi_slv_if.awaddr ),
          .bpf_hssi_slv_awprot  (bpf_hssi_slv_if.awprot ),
          .bpf_hssi_slv_awvalid (bpf_hssi_slv_if.awvalid),
          .bpf_hssi_slv_awready (bpf_hssi_slv_if.awready),
          .bpf_hssi_slv_wdata   (bpf_hssi_slv_if.wdata  ),
          .bpf_hssi_slv_wstrb   (bpf_hssi_slv_if.wstrb  ),
          .bpf_hssi_slv_wvalid  (bpf_hssi_slv_if.wvalid ),
          .bpf_hssi_slv_wready  (bpf_hssi_slv_if.wready ),
          .bpf_hssi_slv_bresp   (bpf_hssi_slv_if.bresp  ),
          .bpf_hssi_slv_bvalid  (bpf_hssi_slv_if.bvalid ),
          .bpf_hssi_slv_bready  (bpf_hssi_slv_if.bready ),
          .bpf_hssi_slv_araddr  (bpf_hssi_slv_if.araddr ),
          .bpf_hssi_slv_arprot  (bpf_hssi_slv_if.arprot ),
          .bpf_hssi_slv_arvalid (bpf_hssi_slv_if.arvalid),
          .bpf_hssi_slv_arready (bpf_hssi_slv_if.arready),
          .bpf_hssi_slv_rdata   (bpf_hssi_slv_if.rdata  ),
          .bpf_hssi_slv_rresp   (bpf_hssi_slv_if.rresp  ),
          .bpf_hssi_slv_rvalid  (bpf_hssi_slv_if.rvalid ),
          .bpf_hssi_slv_rready  (bpf_hssi_slv_if.rready ),
                    
          .bpf_rsv_5_slv_awaddr (bpf_rsv_5_slv_if.awaddr ),
          .bpf_rsv_5_slv_awprot (bpf_rsv_5_slv_if.awprot ),
          .bpf_rsv_5_slv_awvalid(bpf_rsv_5_slv_if.awvalid),
          .bpf_rsv_5_slv_awready(bpf_rsv_5_slv_if.awready),
          .bpf_rsv_5_slv_wdata  (bpf_rsv_5_slv_if.wdata  ),
          .bpf_rsv_5_slv_wstrb  (bpf_rsv_5_slv_if.wstrb  ),
          .bpf_rsv_5_slv_wvalid (bpf_rsv_5_slv_if.wvalid ),
          .bpf_rsv_5_slv_wready (bpf_rsv_5_slv_if.wready ),
          .bpf_rsv_5_slv_bresp  (bpf_rsv_5_slv_if.bresp  ),
          .bpf_rsv_5_slv_bvalid (bpf_rsv_5_slv_if.bvalid ),
          .bpf_rsv_5_slv_bready (bpf_rsv_5_slv_if.bready ),
          .bpf_rsv_5_slv_araddr (bpf_rsv_5_slv_if.araddr ),
          .bpf_rsv_5_slv_arprot (bpf_rsv_5_slv_if.arprot ),
          .bpf_rsv_5_slv_arvalid(bpf_rsv_5_slv_if.arvalid),
          .bpf_rsv_5_slv_arready(bpf_rsv_5_slv_if.arready),
          .bpf_rsv_5_slv_rdata  (bpf_rsv_5_slv_if.rdata  ),
          .bpf_rsv_5_slv_rresp  (bpf_rsv_5_slv_if.rresp  ),
          .bpf_rsv_5_slv_rvalid (bpf_rsv_5_slv_if.rvalid ),
          .bpf_rsv_5_slv_rready (bpf_rsv_5_slv_if.rready ),
                    
          .bpf_rsv_6_slv_awaddr (bpf_rsv_6_slv_if.awaddr ),
          .bpf_rsv_6_slv_awprot (bpf_rsv_6_slv_if.awprot ),
          .bpf_rsv_6_slv_awvalid(bpf_rsv_6_slv_if.awvalid),
          .bpf_rsv_6_slv_awready(bpf_rsv_6_slv_if.awready),
          .bpf_rsv_6_slv_wdata  (bpf_rsv_6_slv_if.wdata  ),
          .bpf_rsv_6_slv_wstrb  (bpf_rsv_6_slv_if.wstrb  ),
          .bpf_rsv_6_slv_wvalid (bpf_rsv_6_slv_if.wvalid ),
          .bpf_rsv_6_slv_wready (bpf_rsv_6_slv_if.wready ),
          .bpf_rsv_6_slv_bresp  (bpf_rsv_6_slv_if.bresp  ),
          .bpf_rsv_6_slv_bvalid (bpf_rsv_6_slv_if.bvalid ),
          .bpf_rsv_6_slv_bready (bpf_rsv_6_slv_if.bready ),
          .bpf_rsv_6_slv_araddr (bpf_rsv_6_slv_if.araddr ),
          .bpf_rsv_6_slv_arprot (bpf_rsv_6_slv_if.arprot ),
          .bpf_rsv_6_slv_arvalid(bpf_rsv_6_slv_if.arvalid),
          .bpf_rsv_6_slv_arready(bpf_rsv_6_slv_if.arready),
          .bpf_rsv_6_slv_rdata  (bpf_rsv_6_slv_if.rdata  ),
          .bpf_rsv_6_slv_rresp  (bpf_rsv_6_slv_if.rresp  ),
          .bpf_rsv_6_slv_rvalid (bpf_rsv_6_slv_if.rvalid ),
          .bpf_rsv_6_slv_rready (bpf_rsv_6_slv_if.rready ),
                    
          .bpf_rsv_7_slv_awaddr (bpf_rsv_7_slv_if.awaddr ),
          .bpf_rsv_7_slv_awprot (bpf_rsv_7_slv_if.awprot ),
          .bpf_rsv_7_slv_awvalid(bpf_rsv_7_slv_if.awvalid),
          .bpf_rsv_7_slv_awready(bpf_rsv_7_slv_if.awready),
          .bpf_rsv_7_slv_wdata  (bpf_rsv_7_slv_if.wdata  ),
          .bpf_rsv_7_slv_wstrb  (bpf_rsv_7_slv_if.wstrb  ),
          .bpf_rsv_7_slv_wvalid (bpf_rsv_7_slv_if.wvalid ),
          .bpf_rsv_7_slv_wready (bpf_rsv_7_slv_if.wready ),
          .bpf_rsv_7_slv_bresp  (bpf_rsv_7_slv_if.bresp  ),
          .bpf_rsv_7_slv_bvalid (bpf_rsv_7_slv_if.bvalid ),
          .bpf_rsv_7_slv_bready (bpf_rsv_7_slv_if.bready ),
          .bpf_rsv_7_slv_araddr (bpf_rsv_7_slv_if.araddr ),
          .bpf_rsv_7_slv_arprot (bpf_rsv_7_slv_if.arprot ),
          .bpf_rsv_7_slv_arvalid(bpf_rsv_7_slv_if.arvalid),
          .bpf_rsv_7_slv_arready(bpf_rsv_7_slv_if.arready),
          .bpf_rsv_7_slv_rdata  (bpf_rsv_7_slv_if.rdata  ),
          .bpf_rsv_7_slv_rresp  (bpf_rsv_7_slv_if.rresp  ),
          .bpf_rsv_7_slv_rvalid (bpf_rsv_7_slv_if.rvalid ),
          .bpf_rsv_7_slv_rready (bpf_rsv_7_slv_if.rready ),
          
          .bpf_apf_slv_awaddr   (bpf_apf_slv_if.awaddr  ),
          .bpf_apf_slv_awprot   (bpf_apf_slv_if.awprot  ),
          .bpf_apf_slv_awvalid  (bpf_apf_slv_if.awvalid ),
          .bpf_apf_slv_awready  (bpf_apf_slv_if.awready ),
          .bpf_apf_slv_wdata    (bpf_apf_slv_if.wdata   ),
          .bpf_apf_slv_wstrb    (bpf_apf_slv_if.wstrb   ),
          .bpf_apf_slv_wvalid   (bpf_apf_slv_if.wvalid  ),
          .bpf_apf_slv_wready   (bpf_apf_slv_if.wready  ),
          .bpf_apf_slv_bresp    (bpf_apf_slv_if.bresp   ),
          .bpf_apf_slv_bvalid   (bpf_apf_slv_if.bvalid  ),
          .bpf_apf_slv_bready   (bpf_apf_slv_if.bready  ),
          .bpf_apf_slv_araddr   (bpf_apf_slv_if.araddr  ),
          .bpf_apf_slv_arprot   (bpf_apf_slv_if.arprot  ),
          .bpf_apf_slv_arvalid  (bpf_apf_slv_if.arvalid ),
          .bpf_apf_slv_arready  (bpf_apf_slv_if.arready ),
          .bpf_apf_slv_rdata    (bpf_apf_slv_if.rdata   ),
          .bpf_apf_slv_rresp    (bpf_apf_slv_if.rresp   ),
          .bpf_apf_slv_rvalid   (bpf_apf_slv_if.rvalid  ),
          .bpf_apf_slv_rready   (bpf_apf_slv_if.rready  ),
          
          .bpf_fme_mst_awaddr   (bpf_fme_mst_if.awaddr  ),
          .bpf_fme_mst_awprot   (bpf_fme_mst_if.awprot  ),
          .bpf_fme_mst_awvalid  (bpf_fme_mst_if.awvalid ),
          .bpf_fme_mst_awready  (bpf_fme_mst_if.awready ),
          .bpf_fme_mst_wdata    (bpf_fme_mst_if.wdata   ),
          .bpf_fme_mst_wstrb    (bpf_fme_mst_if.wstrb   ),
          .bpf_fme_mst_wvalid   (bpf_fme_mst_if.wvalid  ),
          .bpf_fme_mst_wready   (bpf_fme_mst_if.wready  ),
          .bpf_fme_mst_bresp    (bpf_fme_mst_if.bresp   ),
          .bpf_fme_mst_bvalid   (bpf_fme_mst_if.bvalid  ),
          .bpf_fme_mst_bready   (bpf_fme_mst_if.bready  ),
          .bpf_fme_mst_araddr   (bpf_fme_mst_if.araddr  ),
          .bpf_fme_mst_arprot   (bpf_fme_mst_if.arprot  ),
          .bpf_fme_mst_arvalid  (bpf_fme_mst_if.arvalid ),
          .bpf_fme_mst_arready  (bpf_fme_mst_if.arready ),
          .bpf_fme_mst_rdata    (bpf_fme_mst_if.rdata   ),
          .bpf_fme_mst_rresp    (bpf_fme_mst_if.rresp   ),
          .bpf_fme_mst_rvalid   (bpf_fme_mst_if.rvalid  ),
          .bpf_fme_mst_rready   (bpf_fme_mst_if.rready  ) 
          );

    // Reserved address response
    bpf_dummy_slv
    bpf_rsv_5_slv (
        .clk            (clk_1x),
        .dummy_slv_if   (bpf_rsv_5_slv_if)
    );

    bpf_dummy_slv
    bpf_rsv_6_slv (
        .clk            (clk_1x),
        .dummy_slv_if   (bpf_rsv_6_slv_if)
    );

    bpf_dummy_slv
    bpf_rsv_7_slv (
        .clk            (clk_1x),
        .dummy_slv_if   (bpf_rsv_7_slv_if)
    );
    
  `ifdef DEBUG_BPF

         reg  [25:0]    DEBUG_apf_mst_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_apf_mst_awprot      /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_apf_mst_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_apf_mst_arprot      /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_apf_mst_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_apf_mst_rresp       /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_apf_mst_bresp       /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_apf_mst_bready      /* synthesis noprune */       ;
                                                          
         reg  [25:0]    DEBUG_fme_slv_awaddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_fme_slv_awprot      /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_awvalid     /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_awready     /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_fme_slv_araddr      /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_fme_slv_arprot      /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_arvalid     /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_arready     /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_fme_slv_wstrb       /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_wvalid      /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_wready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_fme_slv_rresp       /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_rvalid      /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_rready      /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_fme_slv_bresp       /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_bvalid      /* synthesis noprune */       ;
         reg            DEBUG_fme_slv_bready      /* synthesis noprune */       ;
                                                                                
         reg  [25:0]    DEBUG_pcie_slv_awaddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pcie_slv_awprot     /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_awvalid    /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_awready    /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_pcie_slv_araddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pcie_slv_arprot     /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_arvalid    /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_arready    /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_pcie_slv_wstrb      /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_wvalid     /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_wready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pcie_slv_rresp      /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_rvalid     /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_rready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pcie_slv_bresp      /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_bvalid     /* synthesis noprune */       ;
         reg            DEBUG_pcie_slv_bready     /* synthesis noprune */       ;
                                                                                
         reg  [25:0]    DEBUG_pmci_slv_awaddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pmci_slv_awprot     /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_awvalid    /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_awready    /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_pmci_slv_araddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_pmci_slv_arprot     /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_arvalid    /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_arready    /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_pmci_slv_wstrb      /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_wvalid     /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_wready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pmci_slv_rresp      /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_rvalid     /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_rready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_pmci_slv_bresp      /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_bvalid     /* synthesis noprune */       ;
         reg            DEBUG_pmci_slv_bready     /* synthesis noprune */       ;
                                                                                 
         reg  [25:0]    DEBUG_emif_slv_awaddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_emif_slv_awprot     /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_awvalid    /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_awready    /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_emif_slv_araddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_emif_slv_arprot     /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_arvalid    /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_arready    /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_emif_slv_wstrb      /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_wvalid     /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_wready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_emif_slv_rresp      /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_rvalid     /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_rready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_emif_slv_bresp      /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_bvalid     /* synthesis noprune */       ;
         reg            DEBUG_emif_slv_bready     /* synthesis noprune */       ;
                                                                                
         reg  [25:0]    DEBUG_hssi_slv_awaddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_hssi_slv_awprot     /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_awvalid    /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_awready    /* synthesis noprune */       ;
         reg  [25:0]    DEBUG_hssi_slv_araddr     /* synthesis noprune */       ;
         reg  [ 2:0]    DEBUG_hssi_slv_arprot     /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_arvalid    /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_arready    /* synthesis noprune */       ;
         reg  [ 7:0]    DEBUG_hssi_slv_wstrb      /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_wvalid     /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_wready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_hssi_slv_rresp      /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_rvalid     /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_rready     /* synthesis noprune */       ;
         reg  [ 1:0]    DEBUG_hssi_slv_bresp      /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_bvalid     /* synthesis noprune */       ;
         reg            DEBUG_hssi_slv_bready     /* synthesis noprune */       ;

         reg            DEBUG_rsv_5_slv_wvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_5_slv_wready    /* synthesis noprune */       ;
         reg            DEBUG_rsv_5_slv_rvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_5_slv_rready    /* synthesis noprune */       ;
         reg            DEBUG_rsv_6_slv_wvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_6_slv_wready    /* synthesis noprune */       ;
         reg            DEBUG_rsv_6_slv_rvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_6_slv_rready    /* synthesis noprune */       ;
         reg            DEBUG_rsv_7_slv_wvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_7_slv_wready    /* synthesis noprune */       ;
         reg            DEBUG_rsv_7_slv_rvalid    /* synthesis noprune */       ;
         reg            DEBUG_rsv_7_slv_rready    /* synthesis noprune */       ;
                                                                                
         
      always @(posedge clk_1x) begin                            
    
         DEBUG_apf_mst_awaddr   <= bpf_apf_mst_if.awaddr  ;
         DEBUG_apf_mst_awprot   <= bpf_apf_mst_if.awprot  ;
         DEBUG_apf_mst_awvalid  <= bpf_apf_mst_if.awvalid ;
         DEBUG_apf_mst_awready  <= bpf_apf_mst_if.awready ;
         DEBUG_apf_mst_wstrb    <= bpf_apf_mst_if.wstrb   ;
         DEBUG_apf_mst_wvalid   <= bpf_apf_mst_if.wvalid  ;
         DEBUG_apf_mst_wready   <= bpf_apf_mst_if.wready  ;
         DEBUG_apf_mst_bresp    <= bpf_apf_mst_if.bresp   ;
         DEBUG_apf_mst_bvalid   <= bpf_apf_mst_if.bvalid  ;
         DEBUG_apf_mst_bready   <= bpf_apf_mst_if.bready  ;
         DEBUG_apf_mst_araddr   <= bpf_apf_mst_if.araddr  ;
         DEBUG_apf_mst_arprot   <= bpf_apf_mst_if.arprot  ;
         DEBUG_apf_mst_arvalid  <= bpf_apf_mst_if.arvalid ;
         DEBUG_apf_mst_arready  <= bpf_apf_mst_if.arready ;
         DEBUG_apf_mst_rresp    <= bpf_apf_mst_if.rresp   ;
         DEBUG_apf_mst_rvalid   <= bpf_apf_mst_if.rvalid  ;
         DEBUG_apf_mst_rready   <= bpf_apf_mst_if.rready  ;
                                                           
         DEBUG_fme_slv_awaddr   <= bpf_fme_slv_if.awaddr  ;
         DEBUG_fme_slv_awprot   <= bpf_fme_slv_if.awprot  ;
         DEBUG_fme_slv_awvalid  <= bpf_fme_slv_if.awvalid ;
         DEBUG_fme_slv_awready  <= bpf_fme_slv_if.awready ;
         DEBUG_fme_slv_wstrb    <= bpf_fme_slv_if.wstrb   ;
         DEBUG_fme_slv_wvalid   <= bpf_fme_slv_if.wvalid  ;
         DEBUG_fme_slv_wready   <= bpf_fme_slv_if.wready  ;
         DEBUG_fme_slv_bresp    <= bpf_fme_slv_if.bresp   ;
         DEBUG_fme_slv_bvalid   <= bpf_fme_slv_if.bvalid  ;
         DEBUG_fme_slv_bready   <= bpf_fme_slv_if.bready  ;
         DEBUG_fme_slv_araddr   <= bpf_fme_slv_if.araddr  ;
         DEBUG_fme_slv_arprot   <= bpf_fme_slv_if.arprot  ;
         DEBUG_fme_slv_arvalid  <= bpf_fme_slv_if.arvalid ;
         DEBUG_fme_slv_arready  <= bpf_fme_slv_if.arready ;
         DEBUG_fme_slv_rresp    <= bpf_fme_slv_if.rresp   ;
         DEBUG_fme_slv_rvalid   <= bpf_fme_slv_if.rvalid  ;
         DEBUG_fme_slv_rready   <= bpf_fme_slv_if.rready  ;
                                                          
         DEBUG_pcie_slv_awaddr  <= bpf_pcie_slv_if.awaddr ; 
         DEBUG_pcie_slv_awprot  <= bpf_pcie_slv_if.awprot ; 
         DEBUG_pcie_slv_awvalid <= bpf_pcie_slv_if.awvalid; 
         DEBUG_pcie_slv_awready <= bpf_pcie_slv_if.awready; 
         DEBUG_pcie_slv_wstrb   <= bpf_pcie_slv_if.wstrb  ; 
         DEBUG_pcie_slv_wvalid  <= bpf_pcie_slv_if.wvalid ; 
         DEBUG_pcie_slv_wready  <= bpf_pcie_slv_if.wready ; 
         DEBUG_pcie_slv_bresp   <= bpf_pcie_slv_if.bresp  ; 
         DEBUG_pcie_slv_bvalid  <= bpf_pcie_slv_if.bvalid ; 
         DEBUG_pcie_slv_bready  <= bpf_pcie_slv_if.bready ; 
         DEBUG_pcie_slv_araddr  <= bpf_pcie_slv_if.araddr ; 
         DEBUG_pcie_slv_arprot  <= bpf_pcie_slv_if.arprot ; 
         DEBUG_pcie_slv_arvalid <= bpf_pcie_slv_if.arvalid; 
         DEBUG_pcie_slv_arready <= bpf_pcie_slv_if.arready; 
         DEBUG_pcie_slv_rresp   <= bpf_pcie_slv_if.rresp  ; 
         DEBUG_pcie_slv_rvalid  <= bpf_pcie_slv_if.rvalid ; 
         DEBUG_pcie_slv_rready  <= bpf_pcie_slv_if.rready ; 
                                                          
         DEBUG_pmci_slv_awaddr  <= bpf_pmci_slv_if.awaddr ;
         DEBUG_pmci_slv_awprot  <= bpf_pmci_slv_if.awprot ;
         DEBUG_pmci_slv_awvalid <= bpf_pmci_slv_if.awvalid;
         DEBUG_pmci_slv_awready <= bpf_pmci_slv_if.awready;
         DEBUG_pmci_slv_wstrb   <= bpf_pmci_slv_if.wstrb  ;
         DEBUG_pmci_slv_wvalid  <= bpf_pmci_slv_if.wvalid ;
         DEBUG_pmci_slv_wready  <= bpf_pmci_slv_if.wready ;
         DEBUG_pmci_slv_bresp   <= bpf_pmci_slv_if.bresp  ;
         DEBUG_pmci_slv_bvalid  <= bpf_pmci_slv_if.bvalid ;
         DEBUG_pmci_slv_bready  <= bpf_pmci_slv_if.bready ;
         DEBUG_pmci_slv_araddr  <= bpf_pmci_slv_if.araddr ;
         DEBUG_pmci_slv_arprot  <= bpf_pmci_slv_if.arprot ;
         DEBUG_pmci_slv_arvalid <= bpf_pmci_slv_if.arvalid;
         DEBUG_pmci_slv_arready <= bpf_pmci_slv_if.arready;
         DEBUG_pmci_slv_rresp   <= bpf_pmci_slv_if.rresp  ;
         DEBUG_pmci_slv_rvalid  <= bpf_pmci_slv_if.rvalid ;
         DEBUG_pmci_slv_rready  <= bpf_pmci_slv_if.rready ;
                                                         
         DEBUG_emif_slv_awaddr  <= bpf_emif_slv_if.awaddr ;
         DEBUG_emif_slv_awprot  <= bpf_emif_slv_if.awprot ;
         DEBUG_emif_slv_awvalid <= bpf_emif_slv_if.awvalid;
         DEBUG_emif_slv_awready <= bpf_emif_slv_if.awready;
         DEBUG_emif_slv_wstrb   <= bpf_emif_slv_if.wstrb  ;
         DEBUG_emif_slv_wvalid  <= bpf_emif_slv_if.wvalid ;
         DEBUG_emif_slv_wready  <= bpf_emif_slv_if.wready ;
         DEBUG_emif_slv_bresp   <= bpf_emif_slv_if.bresp  ;
         DEBUG_emif_slv_bvalid  <= bpf_emif_slv_if.bvalid ;
         DEBUG_emif_slv_bready  <= bpf_emif_slv_if.bready ;
         DEBUG_emif_slv_araddr  <= bpf_emif_slv_if.araddr ;
         DEBUG_emif_slv_arprot  <= bpf_emif_slv_if.arprot ;
         DEBUG_emif_slv_arvalid <= bpf_emif_slv_if.arvalid;
         DEBUG_emif_slv_arready <= bpf_emif_slv_if.arready;
         DEBUG_emif_slv_rresp   <= bpf_emif_slv_if.rresp  ;
         DEBUG_emif_slv_rvalid  <= bpf_emif_slv_if.rvalid ;
         DEBUG_emif_slv_rready  <= bpf_emif_slv_if.rready ;
                                                         
         DEBUG_hssi_slv_awaddr  <= bpf_hssi_slv_if.awaddr ;
         DEBUG_hssi_slv_awprot  <= bpf_hssi_slv_if.awprot ;
         DEBUG_hssi_slv_awvalid <= bpf_hssi_slv_if.awvalid;
         DEBUG_hssi_slv_awready <= bpf_hssi_slv_if.awready;
         DEBUG_hssi_slv_wstrb   <= bpf_hssi_slv_if.wstrb  ;
         DEBUG_hssi_slv_wvalid  <= bpf_hssi_slv_if.wvalid ;
         DEBUG_hssi_slv_wready  <= bpf_hssi_slv_if.wready ;
         DEBUG_hssi_slv_bresp   <= bpf_hssi_slv_if.bresp  ;
         DEBUG_hssi_slv_bvalid  <= bpf_hssi_slv_if.bvalid ;
         DEBUG_hssi_slv_bready  <= bpf_hssi_slv_if.bready ;
         DEBUG_hssi_slv_araddr  <= bpf_hssi_slv_if.araddr ;
         DEBUG_hssi_slv_arprot  <= bpf_hssi_slv_if.arprot ;
         DEBUG_hssi_slv_arvalid <= bpf_hssi_slv_if.arvalid;
         DEBUG_hssi_slv_arready <= bpf_hssi_slv_if.arready;
         DEBUG_hssi_slv_rresp   <= bpf_hssi_slv_if.rresp  ;
         DEBUG_hssi_slv_rvalid  <= bpf_hssi_slv_if.rvalid ;
         DEBUG_hssi_slv_rready  <= bpf_hssi_slv_if.rready ;
         
         DEBUG_rsv_5_slv_wvalid <= bpf_rsv_5_slv_if.wvalid ;
         DEBUG_rsv_5_slv_wready <= bpf_rsv_5_slv_if.wready ;
         DEBUG_rsv_5_slv_rvalid <= bpf_rsv_5_slv_if.rvalid ;
         DEBUG_rsv_5_slv_rready <= bpf_rsv_5_slv_if.rready ;
         DEBUG_rsv_6_slv_wvalid <= bpf_rsv_6_slv_if.wvalid ;
         DEBUG_rsv_6_slv_wready <= bpf_rsv_6_slv_if.wready ;
         DEBUG_rsv_6_slv_rvalid <= bpf_rsv_6_slv_if.rvalid ;
         DEBUG_rsv_6_slv_rready <= bpf_rsv_6_slv_if.rready ;
         DEBUG_rsv_7_slv_wvalid <= bpf_rsv_7_slv_if.wvalid ;
         DEBUG_rsv_7_slv_wready <= bpf_rsv_7_slv_if.wready ;
         DEBUG_rsv_7_slv_rvalid <= bpf_rsv_7_slv_if.rvalid ;
         DEBUG_rsv_7_slv_rready <= bpf_rsv_7_slv_if.rready ;
     end
  `endif

/*    
always_comb
begin
    bpf_rsv_5_slv_if.awready         = 1;
    bpf_rsv_5_slv_if.wready          = 1;
    bpf_rsv_5_slv_if.bresp           = 0;
    bpf_rsv_5_slv_if.arready         = 1;
    bpf_rsv_5_slv_if.rdata           = 0;
    bpf_rsv_5_slv_if.rresp           = 0;
    
    bpf_rsv_6_slv_if.awready         = 1;
    bpf_rsv_6_slv_if.wready          = 1;
    bpf_rsv_6_slv_if.bresp           = 0;
    bpf_rsv_6_slv_if.arready         = 1;
    bpf_rsv_6_slv_if.rdata           = 0;
    bpf_rsv_6_slv_if.rresp           = 0;
    
    bpf_rsv_7_slv_if.awready         = 1;
    bpf_rsv_7_slv_if.wready          = 1;
    bpf_rsv_7_slv_if.bresp           = 0;
    bpf_rsv_7_slv_if.arready         = 1;
    bpf_rsv_7_slv_if.rdata           = 0;
    bpf_rsv_7_slv_if.rresp           = 0;
end

always_ff @ ( posedge clk_1x )
begin                              // DUMMY address response
    bpf_rsv_5_slv_if.bvalid         <= bpf_rsv_5_slv_if.awvalid;
    bpf_rsv_5_slv_if.rvalid         <= bpf_rsv_5_slv_if.arvalid;
    bpf_rsv_6_slv_if.bvalid         <= bpf_rsv_6_slv_if.awvalid;
    bpf_rsv_6_slv_if.rvalid         <= bpf_rsv_6_slv_if.arvalid;
    bpf_rsv_7_slv_if.bvalid         <= bpf_rsv_7_slv_if.awvalid;
    bpf_rsv_7_slv_if.rvalid         <= bpf_rsv_7_slv_if.arvalid;
end
*/

//*******************************
// Memory Subsystem
//*******************************
ofs_fim_axi_mmio_if     emif_csr_if();
ofs_fim_irq_axis_if     emif_fme_irq_if();

axi_lite2mmio axi_lite2mmio (
  .clk    (clk_1x),
  .rst_n  (rst_n_g_1x),
  .lite_if(bpf_emif_slv_if),
  .mmio_if(emif_csr_if)
);

emif_top #(
  .NUM_LOCAL_MEM_BANKS(NUM_MEM_CH)
)
emif_top_inst (
  .emif_rst_n (rst_n_g_1x),
  .afu_reset  (~rst_n_g_1x),
  .pr_freeze  (1'b0),

  // CSR interface
  .csr_if     (emif_csr_if),          //ofs_fim_axi_mmio_if.slave 

  // Interrupt interface
  .fme_irq_if (emif_fme_irq_if),  //ofs_fim_irq_axis_if.master

  // Avalon-MM interface for each EMIF.
  .ddr4_avmm  (ddr4_avmm),                     //ofs_fim_emif_avmm_if.emif ddr4_avmm [NUM_LOCAL_MEM_BANKS-1:0]

  // EMIF 4 Interfaces DDR4 x72 RDIMM (x8)
  .ddr4_mem   (ddr4_mem)            //ofs_fim_emif_mem_if.emif  ddr4_mem [NUM_LOCAL_MEM_BANKS-1:0]
);


endmodule
    
module bpf_dummy_slv (
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
