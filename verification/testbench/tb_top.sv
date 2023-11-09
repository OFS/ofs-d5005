// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description : TB Top which has DUT instances and other env instances.

    `timescale 1ps/1ps

`include "tb_pkg.svh"

module tb_top;
    ///** Include Util parms */
    //`include `SVC_SOURCE_MAP_SUITE_UTIL_V(pcie_svc,PCIE,latest,svc_util_parms)
    //`include `SVC_SOURCE_MAP_SUITE_MODEL_MODULE(pcie_svc,Include,latest,pciesvc_parms)
    //------------------------------------------------------------------------------
    // Serial interface signals
    //------------------------------------------------------------------------------
    logic [ofs_fim_pcie_pkg::PCIE_LANES-1:0] root0_tx_datap;
    logic [ofs_fim_pcie_pkg::PCIE_LANES-1:0] endpoint0_tx_datap;

    reg SYS_RefClk   = 0;
    reg PCIE_RefClk  = 0;
    reg ETH_RefClk   = 0;
    reg PCIE_RESET_N = 0;
    reg clk_hssi     = 0;

    wire [NUM_ETH_CHANNELS-1:0] qsfp1_lpbk_serial;

`ifndef INCLUDE_HSSI
    `AXI_IF          axi_if();
    axi_wrapper_if      axi_wrapper_if(DUT.clk_1x);
    axi_reset_if        axi_reset_if();
`endif // INCLUDE_HSSI
    ofs_fim_emif_mem_if ddr4_mem[NUM_MEM_CH-1:0](); // EMIF DDR4 x72 RDIMM (x8)
//coverage interface
    `ifdef ENABLE_R1_COVERAGE
        coverage_intf  cov_intf();
	`endif

    `PCIE_DEV_AGNT_X16_8G_HDL root0(
        .reset        (~PCIE_RESET_N),
        .rx_datap_0   ( endpoint0_tx_datap[0]), // inputs
        .rx_datan_0   (~endpoint0_tx_datap[0]),
        .rx_datap_1   ( endpoint0_tx_datap[1]),
        .rx_datan_1   (~endpoint0_tx_datap[1]),
        .rx_datap_2   ( endpoint0_tx_datap[2]),
        .rx_datan_2   (~endpoint0_tx_datap[2]),
        .rx_datap_3   ( endpoint0_tx_datap[3]),
        .rx_datan_3   (~endpoint0_tx_datap[3]),
        .rx_datap_4   ( endpoint0_tx_datap[4]),
        .rx_datan_4   (~endpoint0_tx_datap[4]),
        .rx_datap_5   ( endpoint0_tx_datap[5]),
        .rx_datan_5   (~endpoint0_tx_datap[5]),
        .rx_datap_6   ( endpoint0_tx_datap[6]),
        .rx_datan_6   (~endpoint0_tx_datap[6]),
        .rx_datap_7   ( endpoint0_tx_datap[7]),
        .rx_datan_7   (~endpoint0_tx_datap[7]),
        .rx_datap_8   ( endpoint0_tx_datap[8]),
        .rx_datan_8   (~endpoint0_tx_datap[8]),
        .rx_datap_9   ( endpoint0_tx_datap[9]),
        .rx_datan_9   (~endpoint0_tx_datap[9]),
        .rx_datap_10  ( endpoint0_tx_datap[10]),
        .rx_datan_10  (~endpoint0_tx_datap[10]),
        .rx_datap_11  ( endpoint0_tx_datap[11]),
        .rx_datan_11  (~endpoint0_tx_datap[11]),
        .rx_datap_12  ( endpoint0_tx_datap[12]),
        .rx_datan_12  (~endpoint0_tx_datap[12]),
        .rx_datap_13  ( endpoint0_tx_datap[13]),
        .rx_datan_13  (~endpoint0_tx_datap[13]),
        .rx_datap_14  ( endpoint0_tx_datap[14]),
        .rx_datan_14  (~endpoint0_tx_datap[14]),
        .rx_datap_15  ( endpoint0_tx_datap[15]),
        .rx_datan_15  (~endpoint0_tx_datap[15]),

        .tx_datap_0   (root0_tx_datap[0]),  // outputs
        .tx_datap_1   (root0_tx_datap[1]),
        .tx_datap_2   (root0_tx_datap[2]),
        .tx_datap_3   (root0_tx_datap[3]),
        .tx_datap_4   (root0_tx_datap[4]),
        .tx_datap_5   (root0_tx_datap[5]),
        .tx_datap_6   (root0_tx_datap[6]),
        .tx_datap_7   (root0_tx_datap[7]),
        .tx_datap_8   (root0_tx_datap[8]),
        .tx_datap_9   (root0_tx_datap[9]),
        .tx_datap_10  (root0_tx_datap[10]),
        .tx_datap_11  (root0_tx_datap[11]),
        .tx_datap_12  (root0_tx_datap[12]),
        .tx_datap_13  (root0_tx_datap[13]),
        .tx_datap_14  (root0_tx_datap[14]),
        .tx_datap_15  (root0_tx_datap[15])
    );

    iofs_top DUT (
        .SYS_RefClk(SYS_RefClk),      // 100MHz

        //DDR4 Interface
        .ddr4_mem(ddr4_mem),      

        .PCIE_RefClk(PCIE_RefClk),
	    .PCIE_Rx(root0_tx_datap),
	    .PCIE_Tx(endpoint0_tx_datap),
        .PCIE_Rst_n(PCIE_RESET_N),

    `ifdef INCLUDE_HSSI
    .qsfp1_644_53125_clk     (ETH_RefClk),
    .qsfp1_tx_serial(qsfp1_lpbk_serial),
	.qsfp1_rx_serial(qsfp1_lpbk_serial),

    `endif // INCLUDE_HSSI
    
        // SPI Bridge pins...
        .SPI_sclk  (),
        .SPI_cs_l  (),
        .SPI_mosi  (),
        .SPI_miso  (1'b0)
    );



`ifndef INCLUDE_HSSI
    assign axi_wrapper_if.resetn = axi_reset_if.reset;
    assign axi_if.common_aclk = DUT.clk_1x;
    assign axi_if.master_if[0].aresetn = axi_reset_if.reset;
    assign axi_if.slave_if[0].aresetn = axi_reset_if.reset;
    assign axi_reset_if.clk = DUT.clk_1x;

    assign DUT.ss_app_st_p0_rx_tvalid       = axi_if.master_if[0].tvalid;
    assign DUT.ss_app_st_p0_rx_tdata        = axi_if.master_if[0].tdata;
    assign DUT.ss_app_st_p0_rx_tkeep        = axi_if.master_if[0].tkeep;
    assign DUT.ss_app_st_p0_rx_tlast        = axi_if.master_if[0].tlast;
    assign DUT.ss_app_st_p0_rx_tuser_client = axi_if.master_if[0].tuser;
    assign DUT.ss_app_st_p0_tx_tready       = axi_if.slave_if[0].tready;
    assign DUT.o_p0_rx_pfc                  = 0;
    assign DUT.o_p0_rx_pause                = 0;
    assign DUT.o_p0_clk_tx_div              = clk_hssi;
    
    assign axi_if.slave_if[0].tvalid = DUT.app_ss_st_p0_tx_tvalid;
    assign axi_if.slave_if[0].tdata  = DUT.app_ss_st_p0_tx_tdata;
    assign axi_if.slave_if[0].tkeep  = DUT.app_ss_st_p0_tx_tkeep;
    assign axi_if.slave_if[0].tlast  = DUT.app_ss_st_p0_tx_tlast;
    assign axi_if.slave_if[0].tuser  = DUT.app_ss_st_p0_tx_tuser_client;

    initial
        force axi_if.master_if[0].tready = 1;
`endif // INCLUDE_HSSI

    initial #10000
        PCIE_RESET_N = 1;
    always #5ns SYS_RefClk  = ~SYS_RefClk;
    always #5ns PCIE_RefClk = ~PCIE_RefClk;
    always #775ps ETH_RefClk = ~ETH_RefClk;
    always #3200ps clk_hssi = ~clk_hssi;

    initial begin
    `ifndef INCLUDE_HSSI
        uvm_config_db#(virtual `AXI_IF)::set(uvm_root::get(), "uvm_test_top.tb_env0.axi_system_env", "vif", axi_if);
	uvm_config_db#(virtual axi_wrapper_if)::set(uvm_root::get(), "uvm_test_top.tb_env0.axi_mmio_wrapper", "axi_wrapper_if", axi_wrapper_if);
	uvm_config_db#(virtual axi_reset_if.axi_reset_modport)::set(uvm_root::get(), "uvm_test_top.tb_env0.sequencer", "reset_mp", axi_reset_if.axi_reset_modport);
    `endif // INCLUDE_HSSI
    //coverage_interface     
    `ifdef ENABLE_R1_COVERAGE
      uvm_config_db#(virtual coverage_intf )::set(uvm_root::get(), "*", "cov_intf", cov_intf);
    `endif

    end

    initial
        run_test();

endmodule : tb_top

