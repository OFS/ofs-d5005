// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Wrapper for top level module of PCIe subsystem and AXI-S adapter
//              AND MSI-X table + PBA + logic + required interconnect
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;
import ofs_csr_pkg::*;

module pcie_wrapper 
       #(parameter                       PCIE_RANDOM_RDY   = 0     ) // For validation: Randomly deassert PCIE Tx, Rx ready 
        (                                                            //  
        input  logic                     fim_clk,
        input  logic                     fim_rst_n,
        input  logic                     ninit_done,
        input  logic                     npor,
        output logic                     reset_status, 
                                         
        // PCIe pins                     
        input  logic                     pin_pcie_ref_clk_p,
        input  logic                     pin_pcie_in_perst_n,        // connected to HIP
        input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
        output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,
                                         
        pcie_ss_axis_if.source           axi_st_rx_if,
        pcie_ss_axis_if.sink             axi_st_tx_if,
                                         
        ofs_fim_axi_lite_if.slave        csr_lite_if,
        ofs_fim_irq_axis_if.master       irq_if,
                                         
        output t_sideband_from_pcie      pcie_p2c_sideband,
        input  t_sideband_to_pcie        pcie_c2p_sideband
        );

//AXI EA Interface Related Parameters
localparam EA_CH         = 2;
localparam AXI_EA_DATA_W = 392;
localparam AXI_EA_USER_W = 22;

// AXI-M CSR interfaces
ofs_fim_axi_mmio_if csr_if();

// AXI-lite conversion
axi_lite2mmio axi_lite2mmio (
.clk    (fim_clk),
.rst_n  (fim_rst_n),
.lite_if(csr_lite_if),
.mmio_if(csr_if)
);

// AXIS PCIe channels - Rx path
ofs_fim_pcie_rxs_axis_if  pcie2adpt_rx_st();

pcie_ss_axis_if           adpt2mux_rx_st();
pcie_ss_axis_if           mux2adpt_rx_st();

ofs_fim_pcie_rxs_axis_if  adpt2adpt_rx_st();

// AXIS PCIe channels - Tx path
ofs_fim_pcie_txs_axis_if  adpt2fltr_tx_st();
ofs_fim_pcie_txs_axis_if  fltr2msix_tx_st();
ofs_fim_pcie_txs_axis_if  fltr2arb_tx_st();

ofs_fim_pcie_tx_axis_if   mmio2arb_tx_st();     // not used
ofs_fim_pcie_tx_axis_if   msix2arb_tx_st();
ofs_fim_pcie_txs_axis_if  arb2adpt_tx_st();

pcie_ss_axis_if           adpt2mux_tx_st();
pcie_ss_axis_if           mux2adpt_tx_st();

ofs_fim_pcie_txs_axis_if  adpt2pcie_tx_st();
ofs_fim_pcie_txs_axis_if  pcie_aligned_tx_st();

// AXIS MSIX response - not used
ofs_fim_afu_irq_rsp_axis_if #(.TDATA_WIDTH (4)) msix_rsp();

// AXIS PCIe channels - MuX
pcie_ss_axis_if           mux2bar_rx_st[4:0]();
pcie_ss_axis_if           bar2mux_tx_st[4:0]();

/////////////////////////////////////////////////////////////////
/////////////////////////// PCIE Top ////////////////////////////

// PCIe Interface (PCIe IP + Bridge)
pcie_top pcie_top (
   .fim_clk               (fim_clk),
   .fim_rst_n             (fim_rst_n),
   .ninit_done            (ninit_done),
   .npor                  (npor),
   .reset_status          (reset_status),
   
   .pin_pcie_ref_clk_p    (pin_pcie_ref_clk_p),
   .pin_pcie_in_perst_n   (pin_pcie_in_perst_n),   // connected to HIP
   .pin_pcie_rx_p         (pin_pcie_rx_p),
   .pin_pcie_tx_p         (pin_pcie_tx_p),

   .axis_rx_st            (pcie2adpt_rx_st),
   .axis_tx_st            (pcie_aligned_tx_st),

   .csr_if                (csr_if),
   .irq_if                (irq_if),
   
   .pcie_p2c_sideband     (pcie_p2c_sideband),
   .pcie_c2p_sideband     (pcie_c2p_sideband)
);



/////////////////////////////////////////////////////////////////
/////////////////////////// PCIE MuX ////////////////////////////

// PCIE MuX: host <-> BAR0|5
pcie_mux_top                                                   
pcie_mux_top (                                                 
          .clk             (      fim_clk                    ) ,
          .rst_n           (      fim_rst_n                  ) ,
                                                                
          .ho2mx_rx_port   (      adpt2mux_rx_st             ) ,
          .mx2ho_tx_port   (      mux2adpt_tx_st             ) ,
          .mx2fn_rx_port   (      mux2bar_rx_st              ) ,
          .fn2mx_tx_port   (      bar2mux_tx_st              ) ,
          .out_fifo_err    (                                 ) ,
          .out_fifo_perr   (                                 )  
          );                                                                                                             
              
// Data path (VF = X, BAR = 0) to/from PCIE MuX
always_comb
begin
    mux2bar_rx_st[0].tready         = mux2adpt_rx_st.tready;    
    mux2adpt_rx_st.tvalid           = mux2bar_rx_st[0].tvalid;
    mux2adpt_rx_st.tlast            = mux2bar_rx_st[0].tlast;
    mux2adpt_rx_st.tuser_vendor     = mux2bar_rx_st[0].tuser_vendor;
    mux2adpt_rx_st.tdata            = mux2bar_rx_st[0].tdata;
    mux2adpt_rx_st.tkeep            = mux2bar_rx_st[0].tkeep;
    
    adpt2mux_tx_st.tready           = bar2mux_tx_st[0].tready;
    bar2mux_tx_st[0].tvalid         = adpt2mux_tx_st.tvalid;
    bar2mux_tx_st[0].tlast          = adpt2mux_tx_st.tlast;
    bar2mux_tx_st[0].tuser_vendor   = adpt2mux_tx_st.tuser_vendor;
    bar2mux_tx_st[0].tdata          = adpt2mux_tx_st.tdata;
    bar2mux_tx_st[0].tkeep          = adpt2mux_tx_st.tkeep;
end    
   
/////////////////////////////////////////////////////////////////
////////////////////////// MSI-X CSRs ///////////////////////////
logic   [6:0]                       inp2cr_msix_pba         [4:1];
logic   [31:0]                      inp2cr_msix_count_vector[4:1];

logic   [63:0]                      cr2out_msix_addr0   [4:1];
logic   [63:0]                      cr2out_msix_addr1   [4:1];
logic   [63:0]                      cr2out_msix_addr2   [4:1];
logic   [63:0]                      cr2out_msix_addr3   [4:1];
logic   [63:0]                      cr2out_msix_addr4   [4:1];
logic   [63:0]                      cr2out_msix_addr5   [4:1];
logic   [63:0]                      cr2out_msix_addr6   [4:1];
logic   [63:0]                      cr2out_msix_addr7   [4:1];
logic   [63:0]                      cr2out_msix_ctldat0 [4:1];
logic   [63:0]                      cr2out_msix_ctldat1 [4:1];
logic   [63:0]                      cr2out_msix_ctldat2 [4:1];
logic   [63:0]                      cr2out_msix_ctldat3 [4:1];
logic   [63:0]                      cr2out_msix_ctldat4 [4:1];
logic   [63:0]                      cr2out_msix_ctldat5 [4:1];
logic   [63:0]                      cr2out_msix_ctldat6 [4:1];
logic   [63:0]                      cr2out_msix_ctldat7 [4:1];
logic   [63:0]                      cr2out_msix_pba     [4:1];    

genvar g;
generate
for ( g = 1 ; g < 5 ; g++ )
begin
    parameter MM_ADDR_WIDTH = 20;
    parameter MM_DATA_WIDTH = 64;
    
    parameter PF_NUM        = 0;
    parameter VF_NUM        = ( g > 1 ) ? g - 2 : 0;
    parameter VF_ACTIVE     = ( g > 1 ) ? 1     : 0;
    
    logic                               avmm_m2s_write;
    logic                               avmm_m2s_read;
    logic   [MM_ADDR_WIDTH-1:0]         avmm_m2s_address;
    logic   [MM_DATA_WIDTH-1:0]         avmm_m2s_writedata;
    logic   [(MM_DATA_WIDTH>>3)-1:0]    avmm_m2s_byteenable;

    logic                               avmm_s2m_waitrequest;
    logic                               avmm_s2m_writeresponsevalid;
    logic                               avmm_s2m_readdatavalid;
    logic   [MM_DATA_WIDTH-1:0]         avmm_s2m_readdata;

    logic                               tlp_rd_strb;
    logic   [9:0]                       tlp_rd_tag;
    logic   [13:0]                      tlp_rd_length;
    logic   [15:0]                      tlp_rd_req_id;
    logic   [23:0]                      tlp_rd_low_addr;

    axis_rx_mmio_bridge #(
        .AVMM_ADDR_WIDTH    (MM_ADDR_WIDTH), 
        .AVMM_DATA_WIDTH    (MM_DATA_WIDTH)
    )
    axis_rx_mmio_bridge (
        .clk                            (fim_clk),
        .rst_n                          (fim_rst_n),
        
        .axis_rx_if                     (mux2bar_rx_st[g]),
        
        .avmm_s2m_waitrequest           (avmm_s2m_waitrequest),
        .avmm_s2m_writeresponsevalid    (avmm_s2m_writeresponsevalid),
        .avmm_s2m_readdatavalid         (avmm_s2m_readdatavalid),
        
        .avmm_m2s_write                 (avmm_m2s_write),
        .avmm_m2s_read                  (avmm_m2s_read),
        .avmm_m2s_address               (avmm_m2s_address),
        .avmm_m2s_writedata             (avmm_m2s_writedata),
        .avmm_m2s_byteenable            (avmm_m2s_byteenable),
        
        .tlp_rd_strb                    (tlp_rd_strb),
        .tlp_rd_tag                     (tlp_rd_tag),
        .tlp_rd_length                  (tlp_rd_length),
        .tlp_rd_req_id                  (tlp_rd_req_id),
        .tlp_rd_low_addr                (tlp_rd_low_addr)
    );

    axis_tx_mmio_bridge #(
        .PF_NUM             (PF_NUM),
        .VF_NUM             (VF_NUM),
        .VF_ACTIVE          (VF_ACTIVE),
        .AVMM_DATA_WIDTH    (MM_DATA_WIDTH)
    )
    axis_tx_mmio_bridge (
        .clk                            (fim_clk),
        .rst_n                          (fim_rst_n),
        
        .axis_tx_if                     (bar2mux_tx_st[g]),
        .axis_tx_error                  ( ),
        
        .avmm_s2m_readdatavalid         (avmm_s2m_readdatavalid),
        .avmm_s2m_readdata              (avmm_s2m_readdata),

        .tlp_rd_strb                    (tlp_rd_strb),
        .tlp_rd_tag                     (tlp_rd_tag),
        .tlp_rd_length                  (tlp_rd_length),
        .tlp_rd_req_id                  (tlp_rd_req_id),
        .tlp_rd_low_addr                (tlp_rd_low_addr)
    );
    
    msix_csr #(
        .MM_ADDR_WIDTH    (MM_ADDR_WIDTH), 
        .MM_DATA_WIDTH    (MM_DATA_WIDTH)
    )
    msix_csr (
        .clk                            (fim_clk),
        .rst_n                          (fim_rst_n),
        
        .avmm_m2s_write                 (avmm_m2s_write),
        .avmm_m2s_read                  (avmm_m2s_read),
        .avmm_m2s_address               (avmm_m2s_address),
        .avmm_m2s_writedata             (avmm_m2s_writedata),
        .avmm_m2s_byteenable            (avmm_m2s_byteenable),
        
        .avmm_s2m_waitrequest           (avmm_s2m_waitrequest),
        .avmm_s2m_writeresponsevalid    (avmm_s2m_writeresponsevalid),
        .avmm_s2m_readdatavalid         (avmm_s2m_readdatavalid),
        .avmm_s2m_readdata              (avmm_s2m_readdata),
        
        .inp2cr_msix_pba                (inp2cr_msix_pba[g]),
        .inp2cr_msix_count_vector       (inp2cr_msix_count_vector[g]),
        
        .cr2out_msix_addr0              (cr2out_msix_addr0[g]),
        .cr2out_msix_addr1              (cr2out_msix_addr1[g]),
        .cr2out_msix_addr2              (cr2out_msix_addr2[g]),
        .cr2out_msix_addr3              (cr2out_msix_addr3[g]),
        .cr2out_msix_addr4              (cr2out_msix_addr4[g]),
        .cr2out_msix_addr5              (cr2out_msix_addr5[g]),
        .cr2out_msix_addr6              (cr2out_msix_addr6[g]),
        .cr2out_msix_addr7              (cr2out_msix_addr7[g]),
        
        .cr2out_msix_ctldat0            (cr2out_msix_ctldat0[g]),
        .cr2out_msix_ctldat1            (cr2out_msix_ctldat1[g]),
        .cr2out_msix_ctldat2            (cr2out_msix_ctldat2[g]),
        .cr2out_msix_ctldat3            (cr2out_msix_ctldat3[g]),
        .cr2out_msix_ctldat4            (cr2out_msix_ctldat4[g]),
        .cr2out_msix_ctldat5            (cr2out_msix_ctldat5[g]),
        .cr2out_msix_ctldat6            (cr2out_msix_ctldat6[g]),
        .cr2out_msix_ctldat7            (cr2out_msix_ctldat7[g]),
        
        .cr2out_msix_pba                (cr2out_msix_pba[g])
    );   
end
endgenerate
   
/////////////////////////////////////////////////////////////////
////////////////////////// MSI-X Logic //////////////////////////

// EA AXI channel arbiter for out-going TLPs from msix_top and AFU
pcie_tx_arbiter pcie_tx_arbiter 
(
    .clk              (fim_clk),
    .rst_n            (fim_rst_n),

    .i_afu_tx_st      (fltr2arb_tx_st),
    .i_msix_tx_st     (msix2arb_tx_st),
    .i_mmio_tx_st     (mmio2arb_tx_st),
    .o_pcie_tx_st     (arb2adpt_tx_st)
);

// No seperate MMIO channel - drive valid
assign mmio2arb_tx_st.tx.tvalid = 1'b0;

// Service FIM and AFU interrupt requests
msix_top msix_top (
    .clk                  (fim_clk),
    .rst_n                (fim_rst_n),
    .afu_softreset        (1'b0),

    .i_afu_msix_req       (fltr2msix_tx_st),
    .o_msix_tx_st         (msix2arb_tx_st),
    .o_msix_rsp           (msix_rsp),

    .inp2cr_msix_pba      (inp2cr_msix_pba[1]),  
    
    .cr2out_msix_addr0    (cr2out_msix_addr0[1]),
    .cr2out_msix_addr1    (cr2out_msix_addr1[1]),
    .cr2out_msix_addr2    (cr2out_msix_addr2[1]),
    .cr2out_msix_addr3    (cr2out_msix_addr3[1]),
    .cr2out_msix_addr4    (cr2out_msix_addr4[1]),
    .cr2out_msix_addr5    (cr2out_msix_addr5[1]),
    .cr2out_msix_addr6    (cr2out_msix_addr6[1]),
    .cr2out_msix_addr7    (cr2out_msix_addr7[1]),    
    .cr2out_msix_ctldat0  (cr2out_msix_ctldat0[1]),
    .cr2out_msix_ctldat1  (cr2out_msix_ctldat1[1]),
    .cr2out_msix_ctldat2  (cr2out_msix_ctldat2[1]),
    .cr2out_msix_ctldat3  (cr2out_msix_ctldat3[1]),
    .cr2out_msix_ctldat4  (cr2out_msix_ctldat4[1]),
    .cr2out_msix_ctldat5  (cr2out_msix_ctldat5[1]),
    .cr2out_msix_ctldat6  (cr2out_msix_ctldat6[1]),
    .cr2out_msix_ctldat7  (cr2out_msix_ctldat7[1]),
    .cr2out_msix_pba      (cr2out_msix_pba[1]),

    .inp2cr_msix_vpba      (inp2cr_msix_pba[3]),    
    
    .cr2out_msix_vaddr0    (cr2out_msix_addr0[3]),
    .cr2out_msix_vaddr1    (cr2out_msix_addr1[3]),
    .cr2out_msix_vaddr2    (cr2out_msix_addr2[3]),
    .cr2out_msix_vaddr3    (cr2out_msix_addr3[3]),
    .cr2out_msix_vaddr4    (cr2out_msix_addr4[3]),
    .cr2out_msix_vaddr5    (cr2out_msix_addr5[3]),
    .cr2out_msix_vaddr6    (cr2out_msix_addr6[3]),
    .cr2out_msix_vaddr7    (cr2out_msix_addr7[3]),    
    .cr2out_msix_vctldat0  (cr2out_msix_ctldat0[3]),
    .cr2out_msix_vctldat1  (cr2out_msix_ctldat1[3]),
    .cr2out_msix_vctldat2  (cr2out_msix_ctldat2[3]),
    .cr2out_msix_vctldat3  (cr2out_msix_ctldat3[3]),
    .cr2out_msix_vctldat4  (cr2out_msix_ctldat4[3]),
    .cr2out_msix_vctldat5  (cr2out_msix_ctldat5[3]),
    .cr2out_msix_vctldat6  (cr2out_msix_ctldat6[3]),
    .cr2out_msix_vctldat7  (cr2out_msix_ctldat7[3]),
    .cr2out_msix_vpba      (cr2out_msix_pba[3]),

    .i_pcie_p2c_sideband  (pcie_p2c_sideband)
);

// VF0, VF2 MSIX not used
assign inp2cr_msix_pba[2] = '0;
assign inp2cr_msix_pba[4] = '0;

// MSIX response is n/c - drive ready
assign msix_rsp.tready = 1'b1;

// Filter interrupt requests from AFU TLPs and route the requests to msix_top
msix_filter msix_filter (
      .i_afu_tx         (adpt2fltr_tx_st),
      .o_afu_tx         (fltr2arb_tx_st),
      .o_msix_tx        (fltr2msix_tx_st)
); 

/////////////////////////////////////////////////////////////////
////////////////////////// ADAPTER "A" //////////////////////////

// EA AXI RX Streaming Interface 
logic                     axi_ea_A_rx_tready;
logic                     axi_ea_A_rx_tvalid;
logic                     axi_ea_A_rx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_A_rx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_A_rx_tdata [EA_CH-1:0];

// EA AXI TX Streaming Interface 
logic                     axi_ea_A_tx_tready;
logic                     axi_ea_A_tx_tvalid;
logic                     axi_ea_A_tx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_A_tx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_A_tx_tdata [EA_CH-1:0];
logic                     axi_ea_rx_en = 1                       ;
logic                     axi_tx_st_en = 1                       ;
logic              [31:0] prbs = 32'h12345678                    ;

always @(posedge fim_clk)                                         // For Validation:  Generate random ready deassertions
         begin                                                    //
                        prbs    <= prbs << 1                     ;// random pattern generation (PRBS_32)
                        prbs[0] <= prbs[31] ^ prbs[28]           ;//
         end

always_comb
begin                                                             /* synthesis translate_off */                     
                        axi_ea_rx_en = 1 ;                        // default:  disable Rx random stall
                        axi_tx_st_en = 1 ;                        // default:  disable Tx random stall
    if (PCIE_RANDOM_RDY)                                          //       
        begin                                                     //
                        axi_ea_rx_en = prbs[ 3: 0]!=4'h5          // randomly stall Rx
                                     & prbs[ 3: 0]!=4'ha         ;//
                        axi_tx_st_en = prbs[31:28]!=4'h2          // randomly stall Tx
                                     & prbs[31:28]!=4'h4         ;//
        end                                                       /* synthesis translate_on */
                         
    pcie2adpt_rx_st.tready      = axi_ea_A_rx_tready        & axi_ea_rx_en;
    axi_ea_A_rx_tvalid          = pcie2adpt_rx_st.rx.tvalid & axi_ea_rx_en;
    axi_ea_A_rx_tlast           = pcie2adpt_rx_st.rx.tlast;
    axi_ea_A_rx_tuser[0]        = pcie2adpt_rx_st.rx.tuser[0];
    axi_ea_A_rx_tuser[1]        = pcie2adpt_rx_st.rx.tuser[1];
    axi_ea_A_rx_tdata[0]        = pcie2adpt_rx_st.rx.tdata[0];
    axi_ea_A_rx_tdata[1]        = pcie2adpt_rx_st.rx.tdata[1];
    adpt2pcie_tx_st.clk         = fim_clk;
    adpt2pcie_tx_st.rst_n       = fim_rst_n;
    axi_ea_A_tx_tready          = adpt2pcie_tx_st.tready & axi_tx_st_en;
    adpt2pcie_tx_st.tx.tvalid   = axi_ea_A_tx_tvalid     & axi_tx_st_en;
    adpt2pcie_tx_st.tx.tlast    = axi_ea_A_tx_tlast;
    adpt2pcie_tx_st.tx.tuser[0] = axi_ea_A_tx_tuser[0][2:0];
    adpt2pcie_tx_st.tx.tuser[1] = axi_ea_A_tx_tuser[1][2:0];
    adpt2pcie_tx_st.tx.tdata[0] = axi_ea_A_tx_tdata[0];
    adpt2pcie_tx_st.tx.tdata[1] = axi_ea_A_tx_tdata[1];
end

// Align the TX stream to ch0 for more efficient processing by the adapter.
pcie_ch0_align_tx pcie_ch0_align_tx (
   .clk                   (fim_clk),
   .rst_n                 (fim_rst_n),

   .axis_tx_st_in         (adpt2pcie_tx_st),
   .axis_tx_st_out        (pcie_aligned_tx_st)
);

// AXI ST EA <-> AXI ST PCIe SS
axi_s_adapter #( .PU_CPL(1), .UNIQUE_TAG_WA(0))
axi_s_adapter_A (
   .clk                   (fim_clk), 
   .resetb                (fim_rst_n),
   
   .axi_ea_rx_tready      (axi_ea_A_rx_tready),  
   .axi_ea_rx_tvalid      (axi_ea_A_rx_tvalid),     
   .axi_ea_rx_tlast       (axi_ea_A_rx_tlast),        
   .axi_ea_rx_tuser       (axi_ea_A_rx_tuser),        
   .axi_ea_rx_tdata       (axi_ea_A_rx_tdata),         
    
   .axi_ea_tx_tready      (axi_ea_A_tx_tready),       
   .axi_ea_tx_tvalid      (axi_ea_A_tx_tvalid),         
   .axi_ea_tx_tlast       (axi_ea_A_tx_tlast),         
   .axi_ea_tx_tuser       (axi_ea_A_tx_tuser),             
   .axi_ea_tx_tdata       (axi_ea_A_tx_tdata),           
                               
   .st_rx_tready          (adpt2mux_rx_st.tready),          
   .st_rx_tvalid          (adpt2mux_rx_st.tvalid),               
   .st_rx_tlast           (adpt2mux_rx_st.tlast),              
   .st_rx_tuser_vendor    (adpt2mux_rx_st.tuser_vendor),                   
   .st_rx_tdata           (adpt2mux_rx_st.tdata),                   
   .st_rx_tkeep           (adpt2mux_rx_st.tkeep),               
   
   .st_tx_tready          (mux2adpt_tx_st.tready),            
   .st_tx_tvalid          (mux2adpt_tx_st.tvalid),               
   .st_tx_tlast           (mux2adpt_tx_st.tlast),                
   .st_tx_tuser_vendor    (mux2adpt_tx_st.tuser_vendor),              
   .st_tx_tdata           (mux2adpt_tx_st.tdata),                 
   .st_tx_tkeep           (mux2adpt_tx_st.tkeep)               
);

/////////////////////////////////////////////////////////////////
////////////////////////// ADAPTER "B" //////////////////////////

// EA AXI RX Streaming Interface 
logic                     axi_ea_B_rx_tready;
logic                     axi_ea_B_rx_tvalid;
logic                     axi_ea_B_rx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_B_rx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_B_rx_tdata [EA_CH-1:0];

// EA AXI TX Streaming Interface 
logic                     axi_ea_B_tx_tready;
logic                     axi_ea_B_tx_tvalid;
logic                     axi_ea_B_tx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_B_tx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_B_tx_tdata [EA_CH-1:0];

// Connecting to/from AXI S Adapter
always_comb
begin
    arb2adpt_tx_st.tready       = axi_ea_B_rx_tready;
    axi_ea_B_rx_tvalid          = arb2adpt_tx_st.tx.tvalid;
    axi_ea_B_rx_tlast           = arb2adpt_tx_st.tx.tlast;
    axi_ea_B_rx_tuser[0]        = arb2adpt_tx_st.tx.tuser[0];
    axi_ea_B_rx_tuser[1]        = arb2adpt_tx_st.tx.tuser[1];
    axi_ea_B_rx_tdata[0]        = arb2adpt_tx_st.tx.tdata[0];
    axi_ea_B_rx_tdata[1]        = arb2adpt_tx_st.tx.tdata[1];

    adpt2adpt_rx_st.clk         = fim_clk;
    adpt2adpt_rx_st.rst_n       = fim_rst_n;

    axi_ea_B_tx_tready          = adpt2adpt_rx_st.tready;
    adpt2adpt_rx_st.rx.tvalid   = axi_ea_B_tx_tvalid;
    adpt2adpt_rx_st.rx.tlast    = axi_ea_B_tx_tlast;
    adpt2adpt_rx_st.rx.tuser[0] = axi_ea_B_tx_tuser[0][21:0];
    adpt2adpt_rx_st.rx.tuser[1] = axi_ea_B_tx_tuser[1][21:0];
    adpt2adpt_rx_st.rx.tdata[0] = axi_ea_B_tx_tdata[0];
    adpt2adpt_rx_st.rx.tdata[1] = axi_ea_B_tx_tdata[1];
end

// AXI ST EA <-> AXI ST PCIe SS
axi_s_adapter #( .PASSTHRU_MODE(1), .UNIQUE_TAG_WA(0))
axi_s_adapter_B (
   .clk                   (fim_clk), 
   .resetb                (fim_rst_n),
   
   .axi_ea_rx_tready      (axi_ea_B_rx_tready),  
   .axi_ea_rx_tvalid      (axi_ea_B_rx_tvalid),     
   .axi_ea_rx_tlast       (axi_ea_B_rx_tlast),        
   .axi_ea_rx_tuser       (axi_ea_B_rx_tuser),        
   .axi_ea_rx_tdata       (axi_ea_B_rx_tdata),         
    
   .axi_ea_tx_tready      (axi_ea_B_tx_tready),       
   .axi_ea_tx_tvalid      (axi_ea_B_tx_tvalid),         
   .axi_ea_tx_tlast       (axi_ea_B_tx_tlast),         
   .axi_ea_tx_tuser       (axi_ea_B_tx_tuser),             
   .axi_ea_tx_tdata       (axi_ea_B_tx_tdata),           
                               
   .st_rx_tready          (adpt2mux_tx_st.tready),          
   .st_rx_tvalid          (adpt2mux_tx_st.tvalid),               
   .st_rx_tlast           (adpt2mux_tx_st.tlast),              
   .st_rx_tuser_vendor    (adpt2mux_tx_st.tuser_vendor),                   
   .st_rx_tdata           (adpt2mux_tx_st.tdata),                   
   .st_rx_tkeep           (adpt2mux_tx_st.tkeep),               
   
   .st_tx_tready          (mux2adpt_rx_st.tready),            
   .st_tx_tvalid          (mux2adpt_rx_st.tvalid),               
   .st_tx_tlast           (mux2adpt_rx_st.tlast),                
   .st_tx_tuser_vendor    (mux2adpt_rx_st.tuser_vendor),              
   .st_tx_tdata           (mux2adpt_rx_st.tdata),                 
   .st_tx_tkeep           (mux2adpt_rx_st.tkeep)               
);

/////////////////////////////////////////////////////////////////
////////////////////////// ADAPTER "C" //////////////////////////

// EA AXI RX Streaming Interface 
logic                     axi_ea_C_rx_tready;
logic                     axi_ea_C_rx_tvalid;
logic                     axi_ea_C_rx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_C_rx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_C_rx_tdata [EA_CH-1:0];

// EA AXI TX Streaming Interface 
logic                     axi_ea_C_tx_tready;
logic                     axi_ea_C_tx_tvalid;
logic                     axi_ea_C_tx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_C_tx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_C_tx_tdata [EA_CH-1:0];

// Connecting to/from AXI S Adapter
always_comb
begin
    adpt2adpt_rx_st.tready      = axi_ea_C_rx_tready;
    axi_ea_C_rx_tvalid          = adpt2adpt_rx_st.rx.tvalid;
    axi_ea_C_rx_tlast           = adpt2adpt_rx_st.rx.tlast;
    axi_ea_C_rx_tuser[0]        = adpt2adpt_rx_st.rx.tuser[0];
    axi_ea_C_rx_tuser[1]        = adpt2adpt_rx_st.rx.tuser[1];
    axi_ea_C_rx_tdata[0]        = adpt2adpt_rx_st.rx.tdata[0];
    axi_ea_C_rx_tdata[1]        = adpt2adpt_rx_st.rx.tdata[1];

    adpt2fltr_tx_st.clk         = fim_clk;
    adpt2fltr_tx_st.rst_n       = fim_rst_n;

    axi_ea_C_tx_tready          = adpt2fltr_tx_st.tready;
    adpt2fltr_tx_st.tx.tvalid   = axi_ea_C_tx_tvalid;
    adpt2fltr_tx_st.tx.tlast    = axi_ea_C_tx_tlast;
    adpt2fltr_tx_st.tx.tuser[0] = axi_ea_C_tx_tuser[0][2:0];
    adpt2fltr_tx_st.tx.tuser[1] = axi_ea_C_tx_tuser[1][2:0];
    adpt2fltr_tx_st.tx.tdata[0] = axi_ea_C_tx_tdata[0];
    adpt2fltr_tx_st.tx.tdata[1] = axi_ea_C_tx_tdata[1];
end

// AXI ST EA <-> AXI ST PCIe SS
axi_s_adapter  
axi_s_adapter_C (
   .clk                   (fim_clk), 
   .resetb                (fim_rst_n),
   
   .axi_ea_rx_tready      (axi_ea_C_rx_tready),  
   .axi_ea_rx_tvalid      (axi_ea_C_rx_tvalid),     
   .axi_ea_rx_tlast       (axi_ea_C_rx_tlast),        
   .axi_ea_rx_tuser       (axi_ea_C_rx_tuser),        
   .axi_ea_rx_tdata       (axi_ea_C_rx_tdata),         
    
   .axi_ea_tx_tready      (axi_ea_C_tx_tready),       
   .axi_ea_tx_tvalid      (axi_ea_C_tx_tvalid),         
   .axi_ea_tx_tlast       (axi_ea_C_tx_tlast),         
   .axi_ea_tx_tuser       (axi_ea_C_tx_tuser),             
   .axi_ea_tx_tdata       (axi_ea_C_tx_tdata),           
                               
   .st_rx_tready          (axi_st_rx_if.tready),          
   .st_rx_tvalid          (axi_st_rx_if.tvalid),               
   .st_rx_tlast           (axi_st_rx_if.tlast),              
   .st_rx_tuser_vendor    (axi_st_rx_if.tuser_vendor),                   
   .st_rx_tdata           (axi_st_rx_if.tdata),                   
   .st_rx_tkeep           (axi_st_rx_if.tkeep),               
   
   .st_tx_tready          (axi_st_tx_if.tready),            
   .st_tx_tvalid          (axi_st_tx_if.tvalid),               
   .st_tx_tlast           (axi_st_tx_if.tlast),                
   .st_tx_tuser_vendor    (axi_st_tx_if.tuser_vendor),              
   .st_tx_tdata           (axi_st_tx_if.tdata),                 
   .st_tx_tkeep           (axi_st_tx_if.tkeep)               
);

endmodule
