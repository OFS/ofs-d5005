// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------

`ifndef TB_PKG_SVH
`define TB_PKG_SVH

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "svt_uvm_util.svi"
    `include "svt_axi.uvm.pkg"

    import svt_uvm_pkg::*;
    import svt_axi_uvm_pkg::*;

    `define NUM_MASTERS 1
    `define NUM_SLAVES  1

    `define PCIE_RX tb_top.DUT.pcie_ss_axis_rx_if
    `define PCIE_TX tb_top.DUT.pcie_ss_axis_tx_if
    `define HE_HSSI_TRAFFIC_CTRL tb_top.DUT.afu_top.port_gasket.pr_slot.afu_main.he_hssi_top_inst.genblk2.eth_traffic_pcie_tlp_to_csr_inst.inst_eth_traffic_csr
    `define MSIX_TOP tb_top.DUT.pcie_wrapper.msix_top
    `define FME_CSR_TOP tb_top.DUT.fme_top.fme_io


     localparam RAS_ERROR_INJ_VERIF   = 20'h0_4068;  //Added to resolve part compile issue
     localparam RAS_NOFAT_ERROR_VERIF = 20'h0_4050;  //Added to resolve part compile issue

    `define PF0_BAR0     'h8000_0000
    //`define PF0_BAR0     'h8000_0000_0000_0000
    //`define PF0_VF0_BAR0 'h8008_0000
    //`define PF0_VF1_BAR0 'h8008_1000
    //`define PF0_VF2_BAR0 'h8008_2000
    
    // deprecated
    //`define PF1_BAR0     'h8008_0000
    //`define PF1_VF1_BAR0 'h8008_1000
    //`define PF1_VF2_BAR0 'h8008_2000

    // deprecated
    //`define HE_LB_BASE   `PF0_VF0_BAR0
    //`define HE_MEM_BASE  `PF0_VF1_BAR0
    //`define HE_HSSI_BASE `PF0_VF2_BAR0

    //`define FME_BASE     `PF0_BAR0+FME_BASE
    //`define PMCI_BASE    `PF0_BAR0+PMCI_BASE
    //`define PCIE_BASE    `PF0_BAR0+PCIE_BASE
    //`define HSSI_BASE    `PF0_BAR0+HSSI_BASE
    //`define EMIF_BASE    `PF0_BAR0+EMIF_BASE
    //`define RSV_5_BASE   `PF0_BAR0+RSV_5_BASE
    //`define RSV_6_BASE   `PF0_BAR0+RSV_6_BASE
    //`define RSV_7_BASE   `PF0_BAR0+RSV_7_BASE
    //`define ST2MM_BASE   `PF0_BAR0+ST2MM_BASE
    //`define PGSK_BASE    `PF0_BAR0+PGSK_BASE
    //`define ACHK_BASE    `PF0_BAR0+ACHK_BASE
    //`define RSV_b_BASE   `PF0_BAR0+RSV_b_BASE
    //`define RSV_c_BASE   `PF0_BAR0+RSV_c_BASE
    //`define RSV_d_BASE   `PF0_BAR0+RSV_d_BASE
    //`define RSV_e_BASE   `PF0_BAR0+RSV_e_BASE
    //`define RSV_f_BASE   `PF0_BAR0+RSV_f_BASE
    
    //`define PF1_BAR0     'h8080_0000
    //`define PF1_VF1_BAR0 'h9000_0000
    // dirty, assuming 4KB page size
    //`define PF1_VF2_BAR0 'h9000_1000

    `include "svt_axi_if.svi"
    `include "svt_axi_port_defines.svi"

    `include "svt_axi_system_env.sv"
    `include "tb_axis/cust_axi_system_configuration.sv"
    `include "tb_axis/axi_rd_mmio_acc_wrapper.sv"
    `include "axi_virtual_sequencer.sv"
    `include "tb_axis/axi_wrapper_if.svi"
    `include "axi_reset_if.svi"

    `include "svt_pcie_defines.svi"
    `include "svt_pcie_device_configuration.sv"
    `include "svt_pcie_device_agent.sv"
    `include "svt_pcie.uvm.pkg"
    import svt_pcie_uvm_pkg::*;
    //`include "pciesvc_device_serdes_x16_model_8g.v"

    `include "tb_config.svh"
    `include "virtual_sequencer.svh"
    `include "ral/ral.sv"
    `include "ral/reg2pcie.svh"
    `ifdef ENABLE_R1_COVERAGE
       `include "../../ofs-common/verification/common/coverage/ofs_coverage_interface.sv"
       `include "../../ofs-common/verification/common/coverage/ofs_cov_class.sv"
    `endif
    `include "tb_env.svh"
    `include "seq_lib.svh"
    `include "test_pkg.svh"

    //import test_pkg::*;

`endif // TB_PKG_SVH
