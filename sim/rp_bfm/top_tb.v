// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

`timescale 1 ps / 1 ps
module top_tb ();

	wire         dut_pcie_tb_refclk_clk;                                                // DUT_pcie_tb:refclk -> pcie_example_design_inst:refclk_clk
	wire  [66:0] dut_pcie_tb_hip_ctrl_test_in;                                          // DUT_pcie_tb:test_in -> pcie_example_design_inst:hip_ctrl_test_in
	wire         dut_pcie_tb_hip_ctrl_simu_mode_pipe;                                   // DUT_pcie_tb:simu_mode_pipe -> pcie_example_design_inst:hip_ctrl_simu_mode_pipe
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity4;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity4 -> DUT_pcie_tb:rxpolarity4
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity5;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity5 -> DUT_pcie_tb:rxpolarity5
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity2;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity2 -> DUT_pcie_tb:rxpolarity2
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity3;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity3 -> DUT_pcie_tb:rxpolarity3
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity0;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity0 -> DUT_pcie_tb:rxpolarity0
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity1;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity1 -> DUT_pcie_tb:rxpolarity1
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress10;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress10 -> DUT_pcie_tb:rxeqinprogress10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress14;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress14 -> DUT_pcie_tb:rxeqinprogress14
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress13;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress13 -> DUT_pcie_tb:rxeqinprogress13
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress12;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress12 -> DUT_pcie_tb:rxeqinprogress12
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress11;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress11 -> DUT_pcie_tb:rxeqinprogress11
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress15;               // pcie_example_design_inst:pipe_sim_only_rxeqinprogress15 -> DUT_pcie_tb:rxeqinprogress15
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph7;                      // pcie_example_design_inst:pipe_sim_only_txdeemph7 -> DUT_pcie_tb:txdeemph7
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph8;                      // pcie_example_design_inst:pipe_sim_only_txdeemph8 -> DUT_pcie_tb:txdeemph8
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph5;                      // pcie_example_design_inst:pipe_sim_only_txdeemph5 -> DUT_pcie_tb:txdeemph5
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph6;                      // pcie_example_design_inst:pipe_sim_only_txdeemph6 -> DUT_pcie_tb:txdeemph6
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph9;                      // pcie_example_design_inst:pipe_sim_only_txdeemph9 -> DUT_pcie_tb:txdeemph9
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph0;                      // pcie_example_design_inst:pipe_sim_only_txdeemph0 -> DUT_pcie_tb:txdeemph0
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph3;                      // pcie_example_design_inst:pipe_sim_only_txdeemph3 -> DUT_pcie_tb:txdeemph3
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph4;                      // pcie_example_design_inst:pipe_sim_only_txdeemph4 -> DUT_pcie_tb:txdeemph4
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph1;                      // pcie_example_design_inst:pipe_sim_only_txdeemph1 -> DUT_pcie_tb:txdeemph1
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph2;                      // pcie_example_design_inst:pipe_sim_only_txdeemph2 -> DUT_pcie_tb:txdeemph2
	wire         dut_pcie_tb_hip_pipe_rxdataskip10;                                     // DUT_pcie_tb:rxdataskip10 -> pcie_example_design_inst:pipe_sim_only_rxdataskip10
	wire         dut_pcie_tb_hip_pipe_rxdataskip11;                                     // DUT_pcie_tb:rxdataskip11 -> pcie_example_design_inst:pipe_sim_only_rxdataskip11
	wire         dut_pcie_tb_hip_pipe_rxdataskip12;                                     // DUT_pcie_tb:rxdataskip12 -> pcie_example_design_inst:pipe_sim_only_rxdataskip12
	wire         dut_pcie_tb_hip_pipe_rxdataskip13;                                     // DUT_pcie_tb:rxdataskip13 -> pcie_example_design_inst:pipe_sim_only_rxdataskip13
	wire         dut_pcie_tb_hip_pipe_rxdataskip14;                                     // DUT_pcie_tb:rxdataskip14 -> pcie_example_design_inst:pipe_sim_only_rxdataskip14
	wire         dut_pcie_tb_hip_pipe_rxdataskip15;                                     // DUT_pcie_tb:rxdataskip15 -> pcie_example_design_inst:pipe_sim_only_rxdataskip15
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd12;                                       // DUT_pcie_tb:rxsynchd12 -> pcie_example_design_inst:pipe_sim_only_rxsynchd12
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip10;                   // pcie_example_design_inst:pipe_sim_only_txdataskip10 -> DUT_pcie_tb:txdataskip10
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd13;                                       // DUT_pcie_tb:rxsynchd13 -> pcie_example_design_inst:pipe_sim_only_rxsynchd13
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip11;                   // pcie_example_design_inst:pipe_sim_only_txdataskip11 -> DUT_pcie_tb:txdataskip11
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd10;                                       // DUT_pcie_tb:rxsynchd10 -> pcie_example_design_inst:pipe_sim_only_rxsynchd10
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip12;                   // pcie_example_design_inst:pipe_sim_only_txdataskip12 -> DUT_pcie_tb:txdataskip12
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd11;                                       // DUT_pcie_tb:rxsynchd11 -> pcie_example_design_inst:pipe_sim_only_rxsynchd11
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip13;                   // pcie_example_design_inst:pipe_sim_only_txdataskip13 -> DUT_pcie_tb:txdataskip13
	wire         dut_pcie_tb_hip_pipe_rxvalid5;                                         // DUT_pcie_tb:rxvalid5 -> pcie_example_design_inst:pipe_sim_only_rxvalid5
	wire         dut_pcie_tb_hip_pipe_rxelecidle12;                                     // DUT_pcie_tb:rxelecidle12 -> pcie_example_design_inst:pipe_sim_only_rxelecidle12
	wire         dut_pcie_tb_hip_pipe_rxvalid4;                                         // DUT_pcie_tb:rxvalid4 -> pcie_example_design_inst:pipe_sim_only_rxvalid4
	wire         dut_pcie_tb_hip_pipe_rxelecidle13;                                     // DUT_pcie_tb:rxelecidle13 -> pcie_example_design_inst:pipe_sim_only_rxelecidle13
	wire         dut_pcie_tb_hip_pipe_rxvalid3;                                         // DUT_pcie_tb:rxvalid3 -> pcie_example_design_inst:pipe_sim_only_rxvalid3
	wire         dut_pcie_tb_hip_pipe_rxelecidle14;                                     // DUT_pcie_tb:rxelecidle14 -> pcie_example_design_inst:pipe_sim_only_rxelecidle14
	wire         dut_pcie_tb_hip_pipe_rxvalid2;                                         // DUT_pcie_tb:rxvalid2 -> pcie_example_design_inst:pipe_sim_only_rxvalid2
	wire         dut_pcie_tb_hip_pipe_rxelecidle15;                                     // DUT_pcie_tb:rxelecidle15 -> pcie_example_design_inst:pipe_sim_only_rxelecidle15
	wire         dut_pcie_tb_hip_pipe_rxvalid1;                                         // DUT_pcie_tb:rxvalid1 -> pcie_example_design_inst:pipe_sim_only_rxvalid1
	wire         dut_pcie_tb_hip_pipe_rxvalid0;                                         // DUT_pcie_tb:rxvalid0 -> pcie_example_design_inst:pipe_sim_only_rxvalid0
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip14;                   // pcie_example_design_inst:pipe_sim_only_txdataskip14 -> DUT_pcie_tb:txdataskip14
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip15;                   // pcie_example_design_inst:pipe_sim_only_txdataskip15 -> DUT_pcie_tb:txdataskip15
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown15;                    // pcie_example_design_inst:pipe_sim_only_powerdown15 -> DUT_pcie_tb:powerdown15
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown14;                    // pcie_example_design_inst:pipe_sim_only_powerdown14 -> DUT_pcie_tb:powerdown14
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown13;                    // pcie_example_design_inst:pipe_sim_only_powerdown13 -> DUT_pcie_tb:powerdown13
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown12;                    // pcie_example_design_inst:pipe_sim_only_powerdown12 -> DUT_pcie_tb:powerdown12
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown11;                    // pcie_example_design_inst:pipe_sim_only_powerdown11 -> DUT_pcie_tb:powerdown11
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown10;                    // pcie_example_design_inst:pipe_sim_only_powerdown10 -> DUT_pcie_tb:powerdown10
	wire         pcie_example_design_inst_pipe_sim_only_txswing9;                       // pcie_example_design_inst:pipe_sim_only_txswing9 -> DUT_pcie_tb:txswing9
	wire         pcie_example_design_inst_pipe_sim_only_txswing8;                       // pcie_example_design_inst:pipe_sim_only_txswing8 -> DUT_pcie_tb:txswing8
	wire         pcie_example_design_inst_pipe_sim_only_txswing7;                       // pcie_example_design_inst:pipe_sim_only_txswing7 -> DUT_pcie_tb:txswing7
	wire         pcie_example_design_inst_pipe_sim_only_txswing6;                       // pcie_example_design_inst:pipe_sim_only_txswing6 -> DUT_pcie_tb:txswing6
	wire         pcie_example_design_inst_pipe_sim_only_txswing5;                       // pcie_example_design_inst:pipe_sim_only_txswing5 -> DUT_pcie_tb:txswing5
	wire         dut_pcie_tb_hip_pipe_rxvalid9;                                         // DUT_pcie_tb:rxvalid9 -> pcie_example_design_inst:pipe_sim_only_rxvalid9
	wire         pcie_example_design_inst_pipe_sim_only_txswing4;                       // pcie_example_design_inst:pipe_sim_only_txswing4 -> DUT_pcie_tb:txswing4
	wire         dut_pcie_tb_hip_pipe_rxvalid8;                                         // DUT_pcie_tb:rxvalid8 -> pcie_example_design_inst:pipe_sim_only_rxvalid8
	wire         pcie_example_design_inst_pipe_sim_only_txswing3;                       // pcie_example_design_inst:pipe_sim_only_txswing3 -> DUT_pcie_tb:txswing3
	wire         dut_pcie_tb_hip_pipe_rxvalid7;                                         // DUT_pcie_tb:rxvalid7 -> pcie_example_design_inst:pipe_sim_only_rxvalid7
	wire         dut_pcie_tb_hip_pipe_rxelecidle10;                                     // DUT_pcie_tb:rxelecidle10 -> pcie_example_design_inst:pipe_sim_only_rxelecidle10
	wire         pcie_example_design_inst_pipe_sim_only_txswing2;                       // pcie_example_design_inst:pipe_sim_only_txswing2 -> DUT_pcie_tb:txswing2
	wire         dut_pcie_tb_hip_pipe_rxvalid6;                                         // DUT_pcie_tb:rxvalid6 -> pcie_example_design_inst:pipe_sim_only_rxvalid6
	wire         dut_pcie_tb_hip_pipe_rxelecidle11;                                     // DUT_pcie_tb:rxelecidle11 -> pcie_example_design_inst:pipe_sim_only_rxelecidle11
	wire         pcie_example_design_inst_pipe_sim_only_txswing1;                       // pcie_example_design_inst:pipe_sim_only_txswing1 -> DUT_pcie_tb:txswing1
	wire         pcie_example_design_inst_pipe_sim_only_txswing0;                       // pcie_example_design_inst:pipe_sim_only_txswing0 -> DUT_pcie_tb:txswing0
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd14;                                       // DUT_pcie_tb:rxsynchd14 -> pcie_example_design_inst:pipe_sim_only_rxsynchd14
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd15;                                       // DUT_pcie_tb:rxsynchd15 -> pcie_example_design_inst:pipe_sim_only_rxsynchd15
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak12;                                        // DUT_pcie_tb:rxdatak12 -> pcie_example_design_inst:pipe_sim_only_rxdatak12
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak13;                                        // DUT_pcie_tb:rxdatak13 -> pcie_example_design_inst:pipe_sim_only_rxdatak13
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak14;                                        // DUT_pcie_tb:rxdatak14 -> pcie_example_design_inst:pipe_sim_only_rxdatak14
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak15;                                        // DUT_pcie_tb:rxdatak15 -> pcie_example_design_inst:pipe_sim_only_rxdatak15
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak10;                                        // DUT_pcie_tb:rxdatak10 -> pcie_example_design_inst:pipe_sim_only_rxdatak10
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak11;                                        // DUT_pcie_tb:rxdatak11 -> pcie_example_design_inst:pipe_sim_only_rxdatak11
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata10;                       // pcie_example_design_inst:pipe_sim_only_txdata10 -> DUT_pcie_tb:txdata10
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata12;                       // pcie_example_design_inst:pipe_sim_only_txdata12 -> DUT_pcie_tb:txdata12
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata11;                       // pcie_example_design_inst:pipe_sim_only_txdata11 -> DUT_pcie_tb:txdata11
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata14;                       // pcie_example_design_inst:pipe_sim_only_txdata14 -> DUT_pcie_tb:txdata14
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata13;                       // pcie_example_design_inst:pipe_sim_only_txdata13 -> DUT_pcie_tb:txdata13
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata15;                       // pcie_example_design_inst:pipe_sim_only_txdata15 -> DUT_pcie_tb:txdata15
	wire         dut_pcie_tb_hip_pipe_rxelecidle9;                                      // DUT_pcie_tb:rxelecidle9 -> pcie_example_design_inst:pipe_sim_only_rxelecidle9
	wire         dut_pcie_tb_hip_pipe_rxelecidle8;                                      // DUT_pcie_tb:rxelecidle8 -> pcie_example_design_inst:pipe_sim_only_rxelecidle8
	wire         dut_pcie_tb_hip_pipe_rxelecidle7;                                      // DUT_pcie_tb:rxelecidle7 -> pcie_example_design_inst:pipe_sim_only_rxelecidle7
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress2;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress2 -> DUT_pcie_tb:rxeqinprogress2
	wire         dut_pcie_tb_hip_pipe_rxelecidle6;                                      // DUT_pcie_tb:rxelecidle6 -> pcie_example_design_inst:pipe_sim_only_rxelecidle6
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin14;                     // pcie_example_design_inst:pipe_sim_only_txmargin14 -> DUT_pcie_tb:txmargin14
	wire         pcie_example_design_inst_pipe_sim_only_txblkst12;                      // pcie_example_design_inst:pipe_sim_only_txblkst12 -> DUT_pcie_tb:txblkst12
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress3;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress3 -> DUT_pcie_tb:rxeqinprogress3
	wire         dut_pcie_tb_hip_pipe_rxelecidle5;                                      // DUT_pcie_tb:rxelecidle5 -> pcie_example_design_inst:pipe_sim_only_rxelecidle5
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin13;                     // pcie_example_design_inst:pipe_sim_only_txmargin13 -> DUT_pcie_tb:txmargin13
	wire         pcie_example_design_inst_pipe_sim_only_txblkst11;                      // pcie_example_design_inst:pipe_sim_only_txblkst11 -> DUT_pcie_tb:txblkst11
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress0;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress0 -> DUT_pcie_tb:rxeqinprogress0
	wire         dut_pcie_tb_hip_pipe_rxelecidle4;                                      // DUT_pcie_tb:rxelecidle4 -> pcie_example_design_inst:pipe_sim_only_rxelecidle4
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle15;                   // pcie_example_design_inst:pipe_sim_only_txelecidle15 -> DUT_pcie_tb:txelecidle15
	wire         pcie_example_design_inst_pipe_sim_only_txblkst10;                      // pcie_example_design_inst:pipe_sim_only_txblkst10 -> DUT_pcie_tb:txblkst10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress1;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress1 -> DUT_pcie_tb:rxeqinprogress1
	wire         dut_pcie_tb_hip_pipe_rxelecidle3;                                      // DUT_pcie_tb:rxelecidle3 -> pcie_example_design_inst:pipe_sim_only_rxelecidle3
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle14;                   // pcie_example_design_inst:pipe_sim_only_txelecidle14 -> DUT_pcie_tb:txelecidle14
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin15;                     // pcie_example_design_inst:pipe_sim_only_txmargin15 -> DUT_pcie_tb:txmargin15
	wire         dut_pcie_tb_hip_pipe_rxelecidle2;                                      // DUT_pcie_tb:rxelecidle2 -> pcie_example_design_inst:pipe_sim_only_rxelecidle2
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin10;                     // pcie_example_design_inst:pipe_sim_only_txmargin10 -> DUT_pcie_tb:txmargin10
	wire         dut_pcie_tb_hip_pipe_rxelecidle1;                                      // DUT_pcie_tb:rxelecidle1 -> pcie_example_design_inst:pipe_sim_only_rxelecidle1
	wire         dut_pcie_tb_hip_pipe_rxelecidle0;                                      // DUT_pcie_tb:rxelecidle0 -> pcie_example_design_inst:pipe_sim_only_rxelecidle0
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin12;                     // pcie_example_design_inst:pipe_sim_only_txmargin12 -> DUT_pcie_tb:txmargin12
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin11;                     // pcie_example_design_inst:pipe_sim_only_txmargin11 -> DUT_pcie_tb:txmargin11
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd7;                                        // DUT_pcie_tb:rxsynchd7 -> pcie_example_design_inst:pipe_sim_only_rxsynchd7
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd8;                                        // DUT_pcie_tb:rxsynchd8 -> pcie_example_design_inst:pipe_sim_only_rxsynchd8
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd5;                                        // DUT_pcie_tb:rxsynchd5 -> pcie_example_design_inst:pipe_sim_only_rxsynchd5
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress8;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress8 -> DUT_pcie_tb:rxeqinprogress8
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd6;                                        // DUT_pcie_tb:rxsynchd6 -> pcie_example_design_inst:pipe_sim_only_rxsynchd6
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress9;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress9 -> DUT_pcie_tb:rxeqinprogress9
	wire         pcie_example_design_inst_pipe_sim_only_txcompl9;                       // pcie_example_design_inst:pipe_sim_only_txcompl9 -> DUT_pcie_tb:txcompl9
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress6;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress6 -> DUT_pcie_tb:rxeqinprogress6
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress7;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress7 -> DUT_pcie_tb:rxeqinprogress7
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress4;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress4 -> DUT_pcie_tb:rxeqinprogress4
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd9;                                        // DUT_pcie_tb:rxsynchd9 -> pcie_example_design_inst:pipe_sim_only_rxsynchd9
	wire         pcie_example_design_inst_pipe_sim_only_rxeqinprogress5;                // pcie_example_design_inst:pipe_sim_only_rxeqinprogress5 -> DUT_pcie_tb:rxeqinprogress5
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd0;                                        // DUT_pcie_tb:rxsynchd0 -> pcie_example_design_inst:pipe_sim_only_rxsynchd0
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd3;                                        // DUT_pcie_tb:rxsynchd3 -> pcie_example_design_inst:pipe_sim_only_rxsynchd3
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd4;                                        // DUT_pcie_tb:rxsynchd4 -> pcie_example_design_inst:pipe_sim_only_rxsynchd4
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd1;                                        // DUT_pcie_tb:rxsynchd1 -> pcie_example_design_inst:pipe_sim_only_rxsynchd1
	wire   [1:0] dut_pcie_tb_hip_pipe_rxsynchd2;                                        // DUT_pcie_tb:rxsynchd2 -> pcie_example_design_inst:pipe_sim_only_rxsynchd2
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate4;                          // pcie_example_design_inst:pipe_sim_only_rate4 -> DUT_pcie_tb:rate4
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate5;                          // pcie_example_design_inst:pipe_sim_only_rate5 -> DUT_pcie_tb:rate5
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate6;                          // pcie_example_design_inst:pipe_sim_only_rate6 -> DUT_pcie_tb:rate6
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate7;                          // pcie_example_design_inst:pipe_sim_only_rate7 -> DUT_pcie_tb:rate7
	wire         pcie_example_design_inst_pipe_sim_only_txcompl0;                       // pcie_example_design_inst:pipe_sim_only_txcompl0 -> DUT_pcie_tb:txcompl0
	wire         dut_pcie_tb_hip_pipe_rxblkst0;                                         // DUT_pcie_tb:rxblkst0 -> pcie_example_design_inst:pipe_sim_only_rxblkst0
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate0;                          // pcie_example_design_inst:pipe_sim_only_rate0 -> DUT_pcie_tb:rate0
	wire         dut_pcie_tb_hip_pipe_rxblkst1;                                         // DUT_pcie_tb:rxblkst1 -> pcie_example_design_inst:pipe_sim_only_rxblkst1
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate1;                          // pcie_example_design_inst:pipe_sim_only_rate1 -> DUT_pcie_tb:rate1
	wire         dut_pcie_tb_hip_pipe_rxblkst2;                                         // DUT_pcie_tb:rxblkst2 -> pcie_example_design_inst:pipe_sim_only_rxblkst2
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate2;                          // pcie_example_design_inst:pipe_sim_only_rate2 -> DUT_pcie_tb:rate2
	wire         dut_pcie_tb_hip_pipe_rxblkst3;                                         // DUT_pcie_tb:rxblkst3 -> pcie_example_design_inst:pipe_sim_only_rxblkst3
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate3;                          // pcie_example_design_inst:pipe_sim_only_rate3 -> DUT_pcie_tb:rate3
	wire         pcie_example_design_inst_pipe_sim_only_txcompl4;                       // pcie_example_design_inst:pipe_sim_only_txcompl4 -> DUT_pcie_tb:txcompl4
	wire         dut_pcie_tb_hip_pipe_rxblkst4;                                         // DUT_pcie_tb:rxblkst4 -> pcie_example_design_inst:pipe_sim_only_rxblkst4
	wire         pcie_example_design_inst_pipe_sim_only_txcompl3;                       // pcie_example_design_inst:pipe_sim_only_txcompl3 -> DUT_pcie_tb:txcompl3
	wire         dut_pcie_tb_hip_pipe_rxblkst5;                                         // DUT_pcie_tb:rxblkst5 -> pcie_example_design_inst:pipe_sim_only_rxblkst5
	wire         pcie_example_design_inst_pipe_sim_only_txcompl2;                       // pcie_example_design_inst:pipe_sim_only_txcompl2 -> DUT_pcie_tb:txcompl2
	wire         dut_pcie_tb_hip_pipe_rxblkst6;                                         // DUT_pcie_tb:rxblkst6 -> pcie_example_design_inst:pipe_sim_only_rxblkst6
	wire         pcie_example_design_inst_pipe_sim_only_txcompl1;                       // pcie_example_design_inst:pipe_sim_only_txcompl1 -> DUT_pcie_tb:txcompl1
	wire         dut_pcie_tb_hip_pipe_rxblkst7;                                         // DUT_pcie_tb:rxblkst7 -> pcie_example_design_inst:pipe_sim_only_rxblkst7
	wire         pcie_example_design_inst_pipe_sim_only_txcompl8;                       // pcie_example_design_inst:pipe_sim_only_txcompl8 -> DUT_pcie_tb:txcompl8
	wire         dut_pcie_tb_hip_pipe_rxblkst8;                                         // DUT_pcie_tb:rxblkst8 -> pcie_example_design_inst:pipe_sim_only_rxblkst8
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate8;                          // pcie_example_design_inst:pipe_sim_only_rate8 -> DUT_pcie_tb:rate8
	wire         pcie_example_design_inst_pipe_sim_only_txcompl7;                       // pcie_example_design_inst:pipe_sim_only_txcompl7 -> DUT_pcie_tb:txcompl7
	wire         dut_pcie_tb_hip_pipe_rxblkst9;                                         // DUT_pcie_tb:rxblkst9 -> pcie_example_design_inst:pipe_sim_only_rxblkst9
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate9;                          // pcie_example_design_inst:pipe_sim_only_rate9 -> DUT_pcie_tb:rate9
	wire         pcie_example_design_inst_pipe_sim_only_txcompl6;                       // pcie_example_design_inst:pipe_sim_only_txcompl6 -> DUT_pcie_tb:txcompl6
	wire         pcie_example_design_inst_pipe_sim_only_txcompl5;                       // pcie_example_design_inst:pipe_sim_only_txcompl5 -> DUT_pcie_tb:txcompl5
	wire         pcie_example_design_inst_pipe_sim_only_txblkst15;                      // pcie_example_design_inst:pipe_sim_only_txblkst15 -> DUT_pcie_tb:txblkst15
	wire         pcie_example_design_inst_pipe_sim_only_txblkst14;                      // pcie_example_design_inst:pipe_sim_only_txblkst14 -> DUT_pcie_tb:txblkst14
	wire         pcie_example_design_inst_pipe_sim_only_txblkst13;                      // pcie_example_design_inst:pipe_sim_only_txblkst13 -> DUT_pcie_tb:txblkst13
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity15;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity15 -> DUT_pcie_tb:rxpolarity15
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity14;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity14 -> DUT_pcie_tb:rxpolarity14
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity13;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity13 -> DUT_pcie_tb:rxpolarity13
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity12;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity12 -> DUT_pcie_tb:rxpolarity12
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity11;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity11 -> DUT_pcie_tb:rxpolarity11
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity10;                   // pcie_example_design_inst:pipe_sim_only_rxpolarity10 -> DUT_pcie_tb:rxpolarity10
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback1;                                     // DUT_pcie_tb:dirfeedback1 -> pcie_example_design_inst:pipe_sim_only_dirfeedback1
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback0;                                     // DUT_pcie_tb:dirfeedback0 -> pcie_example_design_inst:pipe_sim_only_dirfeedback0
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback7;                                     // DUT_pcie_tb:dirfeedback7 -> pcie_example_design_inst:pipe_sim_only_dirfeedback7
	wire   [5:0] pcie_example_design_inst_pipe_sim_only_sim_ltssmstate;                 // pcie_example_design_inst:pipe_sim_only_sim_ltssmstate -> DUT_pcie_tb:sim_ltssmstate
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback6;                                     // DUT_pcie_tb:dirfeedback6 -> pcie_example_design_inst:pipe_sim_only_dirfeedback6
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback9;                                     // DUT_pcie_tb:dirfeedback9 -> pcie_example_design_inst:pipe_sim_only_dirfeedback9
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback8;                                     // DUT_pcie_tb:dirfeedback8 -> pcie_example_design_inst:pipe_sim_only_dirfeedback8
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback3;                                     // DUT_pcie_tb:dirfeedback3 -> pcie_example_design_inst:pipe_sim_only_dirfeedback3
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback2;                                     // DUT_pcie_tb:dirfeedback2 -> pcie_example_design_inst:pipe_sim_only_dirfeedback2
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback5;                                     // DUT_pcie_tb:dirfeedback5 -> pcie_example_design_inst:pipe_sim_only_dirfeedback5
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback4;                                     // DUT_pcie_tb:dirfeedback4 -> pcie_example_design_inst:pipe_sim_only_dirfeedback4
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle13;                   // pcie_example_design_inst:pipe_sim_only_txelecidle13 -> DUT_pcie_tb:txelecidle13
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle12;                   // pcie_example_design_inst:pipe_sim_only_txelecidle12 -> DUT_pcie_tb:txelecidle12
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle11;                   // pcie_example_design_inst:pipe_sim_only_txelecidle11 -> DUT_pcie_tb:txelecidle11
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle10;                   // pcie_example_design_inst:pipe_sim_only_txelecidle10 -> DUT_pcie_tb:txelecidle10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval3;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval3 -> DUT_pcie_tb:rxeqeval3
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval2;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval2 -> DUT_pcie_tb:rxeqeval2
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset10;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset10 -> DUT_pcie_tb:currentrxpreset10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval5;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval5 -> DUT_pcie_tb:rxeqeval5
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset11;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset11 -> DUT_pcie_tb:currentrxpreset11
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval4;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval4 -> DUT_pcie_tb:rxeqeval4
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset12;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset12 -> DUT_pcie_tb:currentrxpreset12
	wire         dut_pcie_tb_hip_pipe_phystatus0;                                       // DUT_pcie_tb:phystatus0 -> pcie_example_design_inst:pipe_sim_only_phystatus0
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval1;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval1 -> DUT_pcie_tb:rxeqeval1
	wire         dut_pcie_tb_hip_pipe_phystatus1;                                       // DUT_pcie_tb:phystatus1 -> pcie_example_design_inst:pipe_sim_only_phystatus1
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval0;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval0 -> DUT_pcie_tb:rxeqeval0
	wire         dut_pcie_tb_hip_pipe_phystatus2;                                       // DUT_pcie_tb:phystatus2 -> pcie_example_design_inst:pipe_sim_only_phystatus2
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval7;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval7 -> DUT_pcie_tb:rxeqeval7
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval6;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval6 -> DUT_pcie_tb:rxeqeval6
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval9;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval9 -> DUT_pcie_tb:rxeqeval9
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval8;                      // pcie_example_design_inst:pipe_sim_only_rxeqeval8 -> DUT_pcie_tb:rxeqeval8
	wire         dut_pcie_tb_hip_pipe_phystatus3;                                       // DUT_pcie_tb:phystatus3 -> pcie_example_design_inst:pipe_sim_only_phystatus3
	wire         dut_pcie_tb_hip_pipe_phystatus4;                                       // DUT_pcie_tb:phystatus4 -> pcie_example_design_inst:pipe_sim_only_phystatus4
	wire         dut_pcie_tb_hip_pipe_phystatus5;                                       // DUT_pcie_tb:phystatus5 -> pcie_example_design_inst:pipe_sim_only_phystatus5
	wire         dut_pcie_tb_hip_pipe_phystatus6;                                       // DUT_pcie_tb:phystatus6 -> pcie_example_design_inst:pipe_sim_only_phystatus6
	wire         dut_pcie_tb_hip_pipe_phystatus7;                                       // DUT_pcie_tb:phystatus7 -> pcie_example_design_inst:pipe_sim_only_phystatus7
	wire         dut_pcie_tb_hip_pipe_phystatus8;                                       // DUT_pcie_tb:phystatus8 -> pcie_example_design_inst:pipe_sim_only_phystatus8
	wire         dut_pcie_tb_hip_pipe_phystatus9;                                       // DUT_pcie_tb:phystatus9 -> pcie_example_design_inst:pipe_sim_only_phystatus9
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle5;                    // pcie_example_design_inst:pipe_sim_only_txelecidle5 -> DUT_pcie_tb:txelecidle5
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle6;                    // pcie_example_design_inst:pipe_sim_only_txelecidle6 -> DUT_pcie_tb:txelecidle6
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle7;                    // pcie_example_design_inst:pipe_sim_only_txelecidle7 -> DUT_pcie_tb:txelecidle7
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle8;                    // pcie_example_design_inst:pipe_sim_only_txelecidle8 -> DUT_pcie_tb:txelecidle8
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle9;                    // pcie_example_design_inst:pipe_sim_only_txelecidle9 -> DUT_pcie_tb:txelecidle9
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle0;                    // pcie_example_design_inst:pipe_sim_only_txelecidle0 -> DUT_pcie_tb:txelecidle0
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle1;                    // pcie_example_design_inst:pipe_sim_only_txelecidle1 -> DUT_pcie_tb:txelecidle1
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle2;                    // pcie_example_design_inst:pipe_sim_only_txelecidle2 -> DUT_pcie_tb:txelecidle2
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle3;                    // pcie_example_design_inst:pipe_sim_only_txelecidle3 -> DUT_pcie_tb:txelecidle3
	wire         pcie_example_design_inst_pipe_sim_only_txelecidle4;                    // pcie_example_design_inst:pipe_sim_only_txelecidle4 -> DUT_pcie_tb:txelecidle4
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx2;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx2 -> DUT_pcie_tb:txdetectrx2
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx1;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx1 -> DUT_pcie_tb:txdetectrx1
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx4;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx4 -> DUT_pcie_tb:txdetectrx4
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx3;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx3 -> DUT_pcie_tb:txdetectrx3
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx0;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx0 -> DUT_pcie_tb:txdetectrx0
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx9;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx9 -> DUT_pcie_tb:txdetectrx9
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx6;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx6 -> DUT_pcie_tb:txdetectrx6
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx5;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx5 -> DUT_pcie_tb:txdetectrx5
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx8;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx8 -> DUT_pcie_tb:txdetectrx8
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx7;                    // pcie_example_design_inst:pipe_sim_only_txdetectrx7 -> DUT_pcie_tb:txdetectrx7
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset13;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset13 -> DUT_pcie_tb:currentrxpreset13
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset14;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset14 -> DUT_pcie_tb:currentrxpreset14
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset15;              // pcie_example_design_inst:pipe_sim_only_currentrxpreset15 -> DUT_pcie_tb:currentrxpreset15
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff10;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff10 -> DUT_pcie_tb:currentcoeff10
	wire         dut_pcie_tb_hip_pipe_rxdataskip0;                                      // DUT_pcie_tb:rxdataskip0 -> pcie_example_design_inst:pipe_sim_only_rxdataskip0
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd13;                     // pcie_example_design_inst:pipe_sim_only_txsynchd13 -> DUT_pcie_tb:txsynchd13
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd12;                     // pcie_example_design_inst:pipe_sim_only_txsynchd12 -> DUT_pcie_tb:txsynchd12
	wire         dut_pcie_tb_hip_pipe_rxdataskip2;                                      // DUT_pcie_tb:rxdataskip2 -> pcie_example_design_inst:pipe_sim_only_rxdataskip2
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd15;                     // pcie_example_design_inst:pipe_sim_only_txsynchd15 -> DUT_pcie_tb:txsynchd15
	wire         dut_pcie_tb_hip_pipe_rxdataskip1;                                      // DUT_pcie_tb:rxdataskip1 -> pcie_example_design_inst:pipe_sim_only_rxdataskip1
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd14;                     // pcie_example_design_inst:pipe_sim_only_txsynchd14 -> DUT_pcie_tb:txsynchd14
	wire         dut_pcie_tb_hip_pipe_rxdataskip4;                                      // DUT_pcie_tb:rxdataskip4 -> pcie_example_design_inst:pipe_sim_only_rxdataskip4
	wire         dut_pcie_tb_hip_pipe_rxdataskip3;                                      // DUT_pcie_tb:rxdataskip3 -> pcie_example_design_inst:pipe_sim_only_rxdataskip3
	wire         dut_pcie_tb_hip_pipe_rxdataskip6;                                      // DUT_pcie_tb:rxdataskip6 -> pcie_example_design_inst:pipe_sim_only_rxdataskip6
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd11;                     // pcie_example_design_inst:pipe_sim_only_txsynchd11 -> DUT_pcie_tb:txsynchd11
	wire         dut_pcie_tb_hip_pipe_rxdataskip5;                                      // DUT_pcie_tb:rxdataskip5 -> pcie_example_design_inst:pipe_sim_only_rxdataskip5
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd10;                     // pcie_example_design_inst:pipe_sim_only_txsynchd10 -> DUT_pcie_tb:txsynchd10
	wire         dut_pcie_tb_hip_pipe_rxdataskip8;                                      // DUT_pcie_tb:rxdataskip8 -> pcie_example_design_inst:pipe_sim_only_rxdataskip8
	wire         dut_pcie_tb_hip_pipe_rxdataskip7;                                      // DUT_pcie_tb:rxdataskip7 -> pcie_example_design_inst:pipe_sim_only_rxdataskip7
	wire         dut_pcie_tb_hip_pipe_rxdataskip9;                                      // DUT_pcie_tb:rxdataskip9 -> pcie_example_design_inst:pipe_sim_only_rxdataskip9
	wire         pcie_example_design_inst_pipe_sim_only_txcompl14;                      // pcie_example_design_inst:pipe_sim_only_txcompl14 -> DUT_pcie_tb:txcompl14
	wire         pcie_example_design_inst_pipe_sim_only_txcompl15;                      // pcie_example_design_inst:pipe_sim_only_txcompl15 -> DUT_pcie_tb:txcompl15
	wire         pcie_example_design_inst_pipe_sim_only_txcompl12;                      // pcie_example_design_inst:pipe_sim_only_txcompl12 -> DUT_pcie_tb:txcompl12
	wire         pcie_example_design_inst_pipe_sim_only_txcompl13;                      // pcie_example_design_inst:pipe_sim_only_txcompl13 -> DUT_pcie_tb:txcompl13
	wire         pcie_example_design_inst_pipe_sim_only_txcompl10;                      // pcie_example_design_inst:pipe_sim_only_txcompl10 -> DUT_pcie_tb:txcompl10
	wire         pcie_example_design_inst_pipe_sim_only_txcompl11;                      // pcie_example_design_inst:pipe_sim_only_txcompl11 -> DUT_pcie_tb:txcompl11
	wire         dut_pcie_tb_hip_pipe_sim_pipe_pclk_in;                                 // DUT_pcie_tb:sim_pipe_pclk_in -> pcie_example_design_inst:pipe_sim_only_sim_pipe_pclk_in
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_sim_pipe_rate;                  // pcie_example_design_inst:pipe_sim_only_sim_pipe_rate -> DUT_pcie_tb:sim_pipe_rate
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx10;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx10 -> DUT_pcie_tb:txdetectrx10
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx11;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx11 -> DUT_pcie_tb:txdetectrx11
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx12;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx12 -> DUT_pcie_tb:txdetectrx12
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx13;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx13 -> DUT_pcie_tb:txdetectrx13
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak10;                      // pcie_example_design_inst:pipe_sim_only_txdatak10 -> DUT_pcie_tb:txdatak10
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak11;                      // pcie_example_design_inst:pipe_sim_only_txdatak11 -> DUT_pcie_tb:txdatak11
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak12;                      // pcie_example_design_inst:pipe_sim_only_txdatak12 -> DUT_pcie_tb:txdatak12
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak13;                      // pcie_example_design_inst:pipe_sim_only_txdatak13 -> DUT_pcie_tb:txdatak13
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip8;                    // pcie_example_design_inst:pipe_sim_only_txdataskip8 -> DUT_pcie_tb:txdataskip8
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip7;                    // pcie_example_design_inst:pipe_sim_only_txdataskip7 -> DUT_pcie_tb:txdataskip7
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip6;                    // pcie_example_design_inst:pipe_sim_only_txdataskip6 -> DUT_pcie_tb:txdataskip6
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip5;                    // pcie_example_design_inst:pipe_sim_only_txdataskip5 -> DUT_pcie_tb:txdataskip5
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip9;                    // pcie_example_design_inst:pipe_sim_only_txdataskip9 -> DUT_pcie_tb:txdataskip9
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip0;                    // pcie_example_design_inst:pipe_sim_only_txdataskip0 -> DUT_pcie_tb:txdataskip0
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx14;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx14 -> DUT_pcie_tb:txdetectrx14
	wire         pcie_example_design_inst_pipe_sim_only_txdetectrx15;                   // pcie_example_design_inst:pipe_sim_only_txdetectrx15 -> DUT_pcie_tb:txdetectrx15
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip4;                    // pcie_example_design_inst:pipe_sim_only_txdataskip4 -> DUT_pcie_tb:txdataskip4
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip3;                    // pcie_example_design_inst:pipe_sim_only_txdataskip3 -> DUT_pcie_tb:txdataskip3
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip2;                    // pcie_example_design_inst:pipe_sim_only_txdataskip2 -> DUT_pcie_tb:txdataskip2
	wire         pcie_example_design_inst_pipe_sim_only_txdataskip1;                    // pcie_example_design_inst:pipe_sim_only_txdataskip1 -> DUT_pcie_tb:txdataskip1
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff15;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff15 -> DUT_pcie_tb:currentcoeff15
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak2;                                         // DUT_pcie_tb:rxdatak2 -> pcie_example_design_inst:pipe_sim_only_rxdatak2
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak14;                      // pcie_example_design_inst:pipe_sim_only_txdatak14 -> DUT_pcie_tb:txdatak14
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff12;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff12 -> DUT_pcie_tb:currentcoeff12
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak1;                                         // DUT_pcie_tb:rxdatak1 -> pcie_example_design_inst:pipe_sim_only_rxdatak1
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak15;                      // pcie_example_design_inst:pipe_sim_only_txdatak15 -> DUT_pcie_tb:txdatak15
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff11;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff11 -> DUT_pcie_tb:currentcoeff11
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak0;                                         // DUT_pcie_tb:rxdatak0 -> pcie_example_design_inst:pipe_sim_only_rxdatak0
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff14;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff14 -> DUT_pcie_tb:currentcoeff14
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff13;                 // pcie_example_design_inst:pipe_sim_only_currentcoeff13 -> DUT_pcie_tb:currentcoeff13
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak6;                                         // DUT_pcie_tb:rxdatak6 -> pcie_example_design_inst:pipe_sim_only_rxdatak6
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak5;                                         // DUT_pcie_tb:rxdatak5 -> pcie_example_design_inst:pipe_sim_only_rxdatak5
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak4;                                         // DUT_pcie_tb:rxdatak4 -> pcie_example_design_inst:pipe_sim_only_rxdatak4
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak3;                                         // DUT_pcie_tb:rxdatak3 -> pcie_example_design_inst:pipe_sim_only_rxdatak3
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak9;                                         // DUT_pcie_tb:rxdatak9 -> pcie_example_design_inst:pipe_sim_only_rxdatak9
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak8;                                         // DUT_pcie_tb:rxdatak8 -> pcie_example_design_inst:pipe_sim_only_rxdatak8
	wire   [3:0] dut_pcie_tb_hip_pipe_rxdatak7;                                         // DUT_pcie_tb:rxdatak7 -> pcie_example_design_inst:pipe_sim_only_rxdatak7
	wire         dut_pcie_tb_hip_pipe_rxblkst13;                                        // DUT_pcie_tb:rxblkst13 -> pcie_example_design_inst:pipe_sim_only_rxblkst13
	wire         dut_pcie_tb_hip_pipe_rxblkst14;                                        // DUT_pcie_tb:rxblkst14 -> pcie_example_design_inst:pipe_sim_only_rxblkst14
	wire         dut_pcie_tb_hip_pipe_rxblkst11;                                        // DUT_pcie_tb:rxblkst11 -> pcie_example_design_inst:pipe_sim_only_rxblkst11
	wire         dut_pcie_tb_hip_pipe_rxblkst12;                                        // DUT_pcie_tb:rxblkst12 -> pcie_example_design_inst:pipe_sim_only_rxblkst12
	wire         dut_pcie_tb_hip_pipe_rxblkst10;                                        // DUT_pcie_tb:rxblkst10 -> pcie_example_design_inst:pipe_sim_only_rxblkst10
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff7;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff7 -> DUT_pcie_tb:currentcoeff7
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff6;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff6 -> DUT_pcie_tb:currentcoeff6
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff5;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff5 -> DUT_pcie_tb:currentcoeff5
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff4;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff4 -> DUT_pcie_tb:currentcoeff4
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff3;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff3 -> DUT_pcie_tb:currentcoeff3
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff2;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff2 -> DUT_pcie_tb:currentcoeff2
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff1;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff1 -> DUT_pcie_tb:currentcoeff1
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff0;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff0 -> DUT_pcie_tb:currentcoeff0
	wire         dut_pcie_tb_hip_pipe_rxblkst15;                                        // DUT_pcie_tb:rxblkst15 -> pcie_example_design_inst:pipe_sim_only_rxblkst15
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff9;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff9 -> DUT_pcie_tb:currentcoeff9
	wire  [17:0] pcie_example_design_inst_pipe_sim_only_currentcoeff8;                  // pcie_example_design_inst:pipe_sim_only_currentcoeff8 -> DUT_pcie_tb:currentcoeff8
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus10;                                       // DUT_pcie_tb:rxstatus10 -> pcie_example_design_inst:pipe_sim_only_rxstatus10
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus13;                                       // DUT_pcie_tb:rxstatus13 -> pcie_example_design_inst:pipe_sim_only_rxstatus13
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus14;                                       // DUT_pcie_tb:rxstatus14 -> pcie_example_design_inst:pipe_sim_only_rxstatus14
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus11;                                       // DUT_pcie_tb:rxstatus11 -> pcie_example_design_inst:pipe_sim_only_rxstatus11
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus12;                                       // DUT_pcie_tb:rxstatus12 -> pcie_example_design_inst:pipe_sim_only_rxstatus12
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus15;                                       // DUT_pcie_tb:rxstatus15 -> pcie_example_design_inst:pipe_sim_only_rxstatus15
	wire         dut_pcie_tb_hip_pipe_phystatus14;                                      // DUT_pcie_tb:phystatus14 -> pcie_example_design_inst:pipe_sim_only_phystatus14
	wire         dut_pcie_tb_hip_pipe_phystatus15;                                      // DUT_pcie_tb:phystatus15 -> pcie_example_design_inst:pipe_sim_only_phystatus15
	wire         dut_pcie_tb_hip_pipe_phystatus12;                                      // DUT_pcie_tb:phystatus12 -> pcie_example_design_inst:pipe_sim_only_phystatus12
	wire         dut_pcie_tb_hip_pipe_phystatus13;                                      // DUT_pcie_tb:phystatus13 -> pcie_example_design_inst:pipe_sim_only_phystatus13
	wire         dut_pcie_tb_hip_pipe_phystatus10;                                      // DUT_pcie_tb:phystatus10 -> pcie_example_design_inst:pipe_sim_only_phystatus10
	wire         dut_pcie_tb_hip_pipe_phystatus11;                                      // DUT_pcie_tb:phystatus11 -> pcie_example_design_inst:pipe_sim_only_phystatus11
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval10;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval10 -> DUT_pcie_tb:rxeqeval10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval12;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval12 -> DUT_pcie_tb:rxeqeval12
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate10;                         // pcie_example_design_inst:pipe_sim_only_rate10 -> DUT_pcie_tb:rate10
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval11;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval11 -> DUT_pcie_tb:rxeqeval11
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq8;                    // pcie_example_design_inst:pipe_sim_only_invalidreq8 -> DUT_pcie_tb:invalidreq8
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq7;                    // pcie_example_design_inst:pipe_sim_only_invalidreq7 -> DUT_pcie_tb:invalidreq7
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq9;                    // pcie_example_design_inst:pipe_sim_only_invalidreq9 -> DUT_pcie_tb:invalidreq9
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq4;                    // pcie_example_design_inst:pipe_sim_only_invalidreq4 -> DUT_pcie_tb:invalidreq4
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq3;                    // pcie_example_design_inst:pipe_sim_only_invalidreq3 -> DUT_pcie_tb:invalidreq3
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq6;                    // pcie_example_design_inst:pipe_sim_only_invalidreq6 -> DUT_pcie_tb:invalidreq6
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq5;                    // pcie_example_design_inst:pipe_sim_only_invalidreq5 -> DUT_pcie_tb:invalidreq5
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq0;                    // pcie_example_design_inst:pipe_sim_only_invalidreq0 -> DUT_pcie_tb:invalidreq0
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval14;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval14 -> DUT_pcie_tb:rxeqeval14
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval13;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval13 -> DUT_pcie_tb:rxeqeval13
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq2;                    // pcie_example_design_inst:pipe_sim_only_invalidreq2 -> DUT_pcie_tb:invalidreq2
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq1;                    // pcie_example_design_inst:pipe_sim_only_invalidreq1 -> DUT_pcie_tb:invalidreq1
	wire         pcie_example_design_inst_pipe_sim_only_rxeqeval15;                     // pcie_example_design_inst:pipe_sim_only_rxeqeval15 -> DUT_pcie_tb:rxeqeval15
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata5;                        // pcie_example_design_inst:pipe_sim_only_txdata5 -> DUT_pcie_tb:txdata5
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata4;                        // pcie_example_design_inst:pipe_sim_only_txdata4 -> DUT_pcie_tb:txdata4
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata3;                        // pcie_example_design_inst:pipe_sim_only_txdata3 -> DUT_pcie_tb:txdata3
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata2;                        // pcie_example_design_inst:pipe_sim_only_txdata2 -> DUT_pcie_tb:txdata2
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata1;                        // pcie_example_design_inst:pipe_sim_only_txdata1 -> DUT_pcie_tb:txdata1
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata0;                        // pcie_example_design_inst:pipe_sim_only_txdata0 -> DUT_pcie_tb:txdata0
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata9;                        // pcie_example_design_inst:pipe_sim_only_txdata9 -> DUT_pcie_tb:txdata9
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata8;                        // pcie_example_design_inst:pipe_sim_only_txdata8 -> DUT_pcie_tb:txdata8
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata7;                        // pcie_example_design_inst:pipe_sim_only_txdata7 -> DUT_pcie_tb:txdata7
	wire  [31:0] pcie_example_design_inst_pipe_sim_only_txdata6;                        // pcie_example_design_inst:pipe_sim_only_txdata6 -> DUT_pcie_tb:txdata6
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate15;                         // pcie_example_design_inst:pipe_sim_only_rate15 -> DUT_pcie_tb:rate15
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate12;                         // pcie_example_design_inst:pipe_sim_only_rate12 -> DUT_pcie_tb:rate12
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate11;                         // pcie_example_design_inst:pipe_sim_only_rate11 -> DUT_pcie_tb:rate11
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate14;                         // pcie_example_design_inst:pipe_sim_only_rate14 -> DUT_pcie_tb:rate14
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_rate13;                         // pcie_example_design_inst:pipe_sim_only_rate13 -> DUT_pcie_tb:rate13
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback13;                                    // DUT_pcie_tb:dirfeedback13 -> pcie_example_design_inst:pipe_sim_only_dirfeedback13
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback14;                                    // DUT_pcie_tb:dirfeedback14 -> pcie_example_design_inst:pipe_sim_only_dirfeedback14
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback15;                                    // DUT_pcie_tb:dirfeedback15 -> pcie_example_design_inst:pipe_sim_only_dirfeedback15
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback10;                                    // DUT_pcie_tb:dirfeedback10 -> pcie_example_design_inst:pipe_sim_only_dirfeedback10
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback11;                                    // DUT_pcie_tb:dirfeedback11 -> pcie_example_design_inst:pipe_sim_only_dirfeedback11
	wire   [5:0] dut_pcie_tb_hip_pipe_dirfeedback12;                                    // DUT_pcie_tb:dirfeedback12 -> pcie_example_design_inst:pipe_sim_only_dirfeedback12
	wire         pcie_example_design_inst_pipe_sim_only_txblkst1;                       // pcie_example_design_inst:pipe_sim_only_txblkst1 -> DUT_pcie_tb:txblkst1
	wire         pcie_example_design_inst_pipe_sim_only_txblkst0;                       // pcie_example_design_inst:pipe_sim_only_txblkst0 -> DUT_pcie_tb:txblkst0
	wire         pcie_example_design_inst_pipe_sim_only_txblkst5;                       // pcie_example_design_inst:pipe_sim_only_txblkst5 -> DUT_pcie_tb:txblkst5
	wire         pcie_example_design_inst_pipe_sim_only_txblkst4;                       // pcie_example_design_inst:pipe_sim_only_txblkst4 -> DUT_pcie_tb:txblkst4
	wire         pcie_example_design_inst_pipe_sim_only_txblkst3;                       // pcie_example_design_inst:pipe_sim_only_txblkst3 -> DUT_pcie_tb:txblkst3
	wire         pcie_example_design_inst_pipe_sim_only_txblkst2;                       // pcie_example_design_inst:pipe_sim_only_txblkst2 -> DUT_pcie_tb:txblkst2
	wire         pcie_example_design_inst_pipe_sim_only_txblkst9;                       // pcie_example_design_inst:pipe_sim_only_txblkst9 -> DUT_pcie_tb:txblkst9
	wire         pcie_example_design_inst_pipe_sim_only_txblkst8;                       // pcie_example_design_inst:pipe_sim_only_txblkst8 -> DUT_pcie_tb:txblkst8
	wire         pcie_example_design_inst_pipe_sim_only_txblkst7;                       // pcie_example_design_inst:pipe_sim_only_txblkst7 -> DUT_pcie_tb:txblkst7
	wire         pcie_example_design_inst_pipe_sim_only_txblkst6;                       // pcie_example_design_inst:pipe_sim_only_txblkst6 -> DUT_pcie_tb:txblkst6
	wire         dut_pcie_tb_hip_pipe_sim_pipe_mask_tx_pll_lock;                        // DUT_pcie_tb:sim_pipe_mask_tx_pll_lock -> pcie_example_design_inst:pipe_sim_only_sim_pipe_mask_tx_pll_lock
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown3;                     // pcie_example_design_inst:pipe_sim_only_powerdown3 -> DUT_pcie_tb:powerdown3
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown4;                     // pcie_example_design_inst:pipe_sim_only_powerdown4 -> DUT_pcie_tb:powerdown4
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown5;                     // pcie_example_design_inst:pipe_sim_only_powerdown5 -> DUT_pcie_tb:powerdown5
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown6;                     // pcie_example_design_inst:pipe_sim_only_powerdown6 -> DUT_pcie_tb:powerdown6
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown0;                     // pcie_example_design_inst:pipe_sim_only_powerdown0 -> DUT_pcie_tb:powerdown0
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown1;                     // pcie_example_design_inst:pipe_sim_only_powerdown1 -> DUT_pcie_tb:powerdown1
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown2;                     // pcie_example_design_inst:pipe_sim_only_powerdown2 -> DUT_pcie_tb:powerdown2
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata10;                                         // DUT_pcie_tb:rxdata10 -> pcie_example_design_inst:pipe_sim_only_rxdata10
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata14;                                         // DUT_pcie_tb:rxdata14 -> pcie_example_design_inst:pipe_sim_only_rxdata14
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata13;                                         // DUT_pcie_tb:rxdata13 -> pcie_example_design_inst:pipe_sim_only_rxdata13
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata12;                                         // DUT_pcie_tb:rxdata12 -> pcie_example_design_inst:pipe_sim_only_rxdata12
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus8;                                        // DUT_pcie_tb:rxstatus8 -> pcie_example_design_inst:pipe_sim_only_rxstatus8
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata11;                                         // DUT_pcie_tb:rxdata11 -> pcie_example_design_inst:pipe_sim_only_rxdata11
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus9;                                        // DUT_pcie_tb:rxstatus9 -> pcie_example_design_inst:pipe_sim_only_rxstatus9
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata15;                                         // DUT_pcie_tb:rxdata15 -> pcie_example_design_inst:pipe_sim_only_rxdata15
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown7;                     // pcie_example_design_inst:pipe_sim_only_powerdown7 -> DUT_pcie_tb:powerdown7
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown8;                     // pcie_example_design_inst:pipe_sim_only_powerdown8 -> DUT_pcie_tb:powerdown8
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_powerdown9;                     // pcie_example_design_inst:pipe_sim_only_powerdown9 -> DUT_pcie_tb:powerdown9
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd2;                      // pcie_example_design_inst:pipe_sim_only_txsynchd2 -> DUT_pcie_tb:txsynchd2
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd1;                      // pcie_example_design_inst:pipe_sim_only_txsynchd1 -> DUT_pcie_tb:txsynchd1
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd0;                      // pcie_example_design_inst:pipe_sim_only_txsynchd0 -> DUT_pcie_tb:txsynchd0
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus2;                                        // DUT_pcie_tb:rxstatus2 -> pcie_example_design_inst:pipe_sim_only_rxstatus2
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd6;                      // pcie_example_design_inst:pipe_sim_only_txsynchd6 -> DUT_pcie_tb:txsynchd6
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus3;                                        // DUT_pcie_tb:rxstatus3 -> pcie_example_design_inst:pipe_sim_only_rxstatus3
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd5;                      // pcie_example_design_inst:pipe_sim_only_txsynchd5 -> DUT_pcie_tb:txsynchd5
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus0;                                        // DUT_pcie_tb:rxstatus0 -> pcie_example_design_inst:pipe_sim_only_rxstatus0
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd4;                      // pcie_example_design_inst:pipe_sim_only_txsynchd4 -> DUT_pcie_tb:txsynchd4
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus1;                                        // DUT_pcie_tb:rxstatus1 -> pcie_example_design_inst:pipe_sim_only_rxstatus1
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd3;                      // pcie_example_design_inst:pipe_sim_only_txsynchd3 -> DUT_pcie_tb:txsynchd3
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus6;                                        // DUT_pcie_tb:rxstatus6 -> pcie_example_design_inst:pipe_sim_only_rxstatus6
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus7;                                        // DUT_pcie_tb:rxstatus7 -> pcie_example_design_inst:pipe_sim_only_rxstatus7
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd9;                      // pcie_example_design_inst:pipe_sim_only_txsynchd9 -> DUT_pcie_tb:txsynchd9
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus4;                                        // DUT_pcie_tb:rxstatus4 -> pcie_example_design_inst:pipe_sim_only_rxstatus4
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd8;                      // pcie_example_design_inst:pipe_sim_only_txsynchd8 -> DUT_pcie_tb:txsynchd8
	wire   [2:0] dut_pcie_tb_hip_pipe_rxstatus5;                                        // DUT_pcie_tb:rxstatus5 -> pcie_example_design_inst:pipe_sim_only_rxstatus5
	wire   [1:0] pcie_example_design_inst_pipe_sim_only_txsynchd7;                      // pcie_example_design_inst:pipe_sim_only_txsynchd7 -> DUT_pcie_tb:txsynchd7
	wire         pcie_example_design_inst_pipe_sim_only_txswing15;                      // pcie_example_design_inst:pipe_sim_only_txswing15 -> DUT_pcie_tb:txswing15
	wire         pcie_example_design_inst_pipe_sim_only_txswing14;                      // pcie_example_design_inst:pipe_sim_only_txswing14 -> DUT_pcie_tb:txswing14
	wire         pcie_example_design_inst_pipe_sim_only_txswing13;                      // pcie_example_design_inst:pipe_sim_only_txswing13 -> DUT_pcie_tb:txswing13
	wire         pcie_example_design_inst_pipe_sim_only_txswing12;                      // pcie_example_design_inst:pipe_sim_only_txswing12 -> DUT_pcie_tb:txswing12
	wire         pcie_example_design_inst_pipe_sim_only_txswing11;                      // pcie_example_design_inst:pipe_sim_only_txswing11 -> DUT_pcie_tb:txswing11
	wire         pcie_example_design_inst_pipe_sim_only_txswing10;                      // pcie_example_design_inst:pipe_sim_only_txswing10 -> DUT_pcie_tb:txswing10
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset7;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset7 -> DUT_pcie_tb:currentrxpreset7
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset6;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset6 -> DUT_pcie_tb:currentrxpreset6
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset9;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset9 -> DUT_pcie_tb:currentrxpreset9
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset8;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset8 -> DUT_pcie_tb:currentrxpreset8
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset3;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset3 -> DUT_pcie_tb:currentrxpreset3
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset2;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset2 -> DUT_pcie_tb:currentrxpreset2
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset5;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset5 -> DUT_pcie_tb:currentrxpreset5
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset4;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset4 -> DUT_pcie_tb:currentrxpreset4
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin1;                      // pcie_example_design_inst:pipe_sim_only_txmargin1 -> DUT_pcie_tb:txmargin1
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin0;                      // pcie_example_design_inst:pipe_sim_only_txmargin0 -> DUT_pcie_tb:txmargin0
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset1;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset1 -> DUT_pcie_tb:currentrxpreset1
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_currentrxpreset0;               // pcie_example_design_inst:pipe_sim_only_currentrxpreset0 -> DUT_pcie_tb:currentrxpreset0
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph10;                     // pcie_example_design_inst:pipe_sim_only_txdeemph10 -> DUT_pcie_tb:txdeemph10
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph11;                     // pcie_example_design_inst:pipe_sim_only_txdeemph11 -> DUT_pcie_tb:txdeemph11
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph12;                     // pcie_example_design_inst:pipe_sim_only_txdeemph12 -> DUT_pcie_tb:txdeemph12
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata8;                                          // DUT_pcie_tb:rxdata8 -> pcie_example_design_inst:pipe_sim_only_rxdata8
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph13;                     // pcie_example_design_inst:pipe_sim_only_txdeemph13 -> DUT_pcie_tb:txdeemph13
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata9;                                          // DUT_pcie_tb:rxdata9 -> pcie_example_design_inst:pipe_sim_only_rxdata9
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata2;                                          // DUT_pcie_tb:rxdata2 -> pcie_example_design_inst:pipe_sim_only_rxdata2
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata3;                                          // DUT_pcie_tb:rxdata3 -> pcie_example_design_inst:pipe_sim_only_rxdata3
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata0;                                          // DUT_pcie_tb:rxdata0 -> pcie_example_design_inst:pipe_sim_only_rxdata0
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata1;                                          // DUT_pcie_tb:rxdata1 -> pcie_example_design_inst:pipe_sim_only_rxdata1
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata6;                                          // DUT_pcie_tb:rxdata6 -> pcie_example_design_inst:pipe_sim_only_rxdata6
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph14;                     // pcie_example_design_inst:pipe_sim_only_txdeemph14 -> DUT_pcie_tb:txdeemph14
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata7;                                          // DUT_pcie_tb:rxdata7 -> pcie_example_design_inst:pipe_sim_only_rxdata7
	wire         pcie_example_design_inst_pipe_sim_only_txdeemph15;                     // pcie_example_design_inst:pipe_sim_only_txdeemph15 -> DUT_pcie_tb:txdeemph15
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata4;                                          // DUT_pcie_tb:rxdata4 -> pcie_example_design_inst:pipe_sim_only_rxdata4
	wire  [31:0] dut_pcie_tb_hip_pipe_rxdata5;                                          // DUT_pcie_tb:rxdata5 -> pcie_example_design_inst:pipe_sim_only_rxdata5
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin5;                      // pcie_example_design_inst:pipe_sim_only_txmargin5 -> DUT_pcie_tb:txmargin5
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin4;                      // pcie_example_design_inst:pipe_sim_only_txmargin4 -> DUT_pcie_tb:txmargin4
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin3;                      // pcie_example_design_inst:pipe_sim_only_txmargin3 -> DUT_pcie_tb:txmargin3
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin2;                      // pcie_example_design_inst:pipe_sim_only_txmargin2 -> DUT_pcie_tb:txmargin2
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin9;                      // pcie_example_design_inst:pipe_sim_only_txmargin9 -> DUT_pcie_tb:txmargin9
	wire         dut_pcie_tb_hip_pipe_rxvalid15;                                        // DUT_pcie_tb:rxvalid15 -> pcie_example_design_inst:pipe_sim_only_rxvalid15
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin8;                      // pcie_example_design_inst:pipe_sim_only_txmargin8 -> DUT_pcie_tb:txmargin8
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin7;                      // pcie_example_design_inst:pipe_sim_only_txmargin7 -> DUT_pcie_tb:txmargin7
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq11;                   // pcie_example_design_inst:pipe_sim_only_invalidreq11 -> DUT_pcie_tb:invalidreq11
	wire         dut_pcie_tb_hip_pipe_rxvalid13;                                        // DUT_pcie_tb:rxvalid13 -> pcie_example_design_inst:pipe_sim_only_rxvalid13
	wire   [2:0] pcie_example_design_inst_pipe_sim_only_txmargin6;                      // pcie_example_design_inst:pipe_sim_only_txmargin6 -> DUT_pcie_tb:txmargin6
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq10;                   // pcie_example_design_inst:pipe_sim_only_invalidreq10 -> DUT_pcie_tb:invalidreq10
	wire         dut_pcie_tb_hip_pipe_rxvalid14;                                        // DUT_pcie_tb:rxvalid14 -> pcie_example_design_inst:pipe_sim_only_rxvalid14
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq13;                   // pcie_example_design_inst:pipe_sim_only_invalidreq13 -> DUT_pcie_tb:invalidreq13
	wire         dut_pcie_tb_hip_pipe_rxvalid11;                                        // DUT_pcie_tb:rxvalid11 -> pcie_example_design_inst:pipe_sim_only_rxvalid11
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq12;                   // pcie_example_design_inst:pipe_sim_only_invalidreq12 -> DUT_pcie_tb:invalidreq12
	wire         dut_pcie_tb_hip_pipe_rxvalid12;                                        // DUT_pcie_tb:rxvalid12 -> pcie_example_design_inst:pipe_sim_only_rxvalid12
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq15;                   // pcie_example_design_inst:pipe_sim_only_invalidreq15 -> DUT_pcie_tb:invalidreq15
	wire         pcie_example_design_inst_pipe_sim_only_invalidreq14;                   // pcie_example_design_inst:pipe_sim_only_invalidreq14 -> DUT_pcie_tb:invalidreq14
	wire         dut_pcie_tb_hip_pipe_rxvalid10;                                        // DUT_pcie_tb:rxvalid10 -> pcie_example_design_inst:pipe_sim_only_rxvalid10
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak2;                       // pcie_example_design_inst:pipe_sim_only_txdatak2 -> DUT_pcie_tb:txdatak2
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak1;                       // pcie_example_design_inst:pipe_sim_only_txdatak1 -> DUT_pcie_tb:txdatak1
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak4;                       // pcie_example_design_inst:pipe_sim_only_txdatak4 -> DUT_pcie_tb:txdatak4
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak3;                       // pcie_example_design_inst:pipe_sim_only_txdatak3 -> DUT_pcie_tb:txdatak3
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity8;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity8 -> DUT_pcie_tb:rxpolarity8
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity9;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity9 -> DUT_pcie_tb:rxpolarity9
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity6;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity6 -> DUT_pcie_tb:rxpolarity6
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak0;                       // pcie_example_design_inst:pipe_sim_only_txdatak0 -> DUT_pcie_tb:txdatak0
	wire         pcie_example_design_inst_pipe_sim_only_rxpolarity7;                    // pcie_example_design_inst:pipe_sim_only_rxpolarity7 -> DUT_pcie_tb:rxpolarity7
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak9;                       // pcie_example_design_inst:pipe_sim_only_txdatak9 -> DUT_pcie_tb:txdatak9
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak6;                       // pcie_example_design_inst:pipe_sim_only_txdatak6 -> DUT_pcie_tb:txdatak6
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak5;                       // pcie_example_design_inst:pipe_sim_only_txdatak5 -> DUT_pcie_tb:txdatak5
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak8;                       // pcie_example_design_inst:pipe_sim_only_txdatak8 -> DUT_pcie_tb:txdatak8
	wire   [3:0] pcie_example_design_inst_pipe_sim_only_txdatak7;                       // pcie_example_design_inst:pipe_sim_only_txdatak7 -> DUT_pcie_tb:txdatak7
	wire         pcie_example_design_inst_xcvr_tx_out9;                                 // pcie_example_design_inst:xcvr_tx_out9 -> DUT_pcie_tb:tx_out9
	wire         pcie_example_design_inst_xcvr_tx_out8;                                 // pcie_example_design_inst:xcvr_tx_out8 -> DUT_pcie_tb:tx_out8
	wire         pcie_example_design_inst_xcvr_tx_out7;                                 // pcie_example_design_inst:xcvr_tx_out7 -> DUT_pcie_tb:tx_out7
	wire         pcie_example_design_inst_xcvr_tx_out6;                                 // pcie_example_design_inst:xcvr_tx_out6 -> DUT_pcie_tb:tx_out6
	wire         pcie_example_design_inst_xcvr_tx_out5;                                 // pcie_example_design_inst:xcvr_tx_out5 -> DUT_pcie_tb:tx_out5
	wire         pcie_example_design_inst_xcvr_tx_out4;                                 // pcie_example_design_inst:xcvr_tx_out4 -> DUT_pcie_tb:tx_out4
	wire         pcie_example_design_inst_xcvr_tx_out3;                                 // pcie_example_design_inst:xcvr_tx_out3 -> DUT_pcie_tb:tx_out3
	wire         pcie_example_design_inst_xcvr_tx_out11;                                // pcie_example_design_inst:xcvr_tx_out11 -> DUT_pcie_tb:tx_out11
	wire         pcie_example_design_inst_xcvr_tx_out10;                                // pcie_example_design_inst:xcvr_tx_out10 -> DUT_pcie_tb:tx_out10
	wire         pcie_example_design_inst_xcvr_tx_out15;                                // pcie_example_design_inst:xcvr_tx_out15 -> DUT_pcie_tb:tx_out15
	wire         pcie_example_design_inst_xcvr_tx_out14;                                // pcie_example_design_inst:xcvr_tx_out14 -> DUT_pcie_tb:tx_out14
	wire         pcie_example_design_inst_xcvr_tx_out13;                                // pcie_example_design_inst:xcvr_tx_out13 -> DUT_pcie_tb:tx_out13
	wire         pcie_example_design_inst_xcvr_tx_out12;                                // pcie_example_design_inst:xcvr_tx_out12 -> DUT_pcie_tb:tx_out12
	wire         dut_pcie_tb_hip_serial_rx_in13;                                        // DUT_pcie_tb:rx_in13 -> pcie_example_design_inst:xcvr_rx_in13
	wire         dut_pcie_tb_hip_serial_rx_in14;                                        // DUT_pcie_tb:rx_in14 -> pcie_example_design_inst:xcvr_rx_in14
	wire         dut_pcie_tb_hip_serial_rx_in15;                                        // DUT_pcie_tb:rx_in15 -> pcie_example_design_inst:xcvr_rx_in15
	wire         dut_pcie_tb_hip_serial_rx_in0;                                         // DUT_pcie_tb:rx_in0 -> pcie_example_design_inst:xcvr_rx_in0
	wire         dut_pcie_tb_hip_serial_rx_in1;                                         // DUT_pcie_tb:rx_in1 -> pcie_example_design_inst:xcvr_rx_in1
	wire         dut_pcie_tb_hip_serial_rx_in2;                                         // DUT_pcie_tb:rx_in2 -> pcie_example_design_inst:xcvr_rx_in2
	wire         dut_pcie_tb_hip_serial_rx_in3;                                         // DUT_pcie_tb:rx_in3 -> pcie_example_design_inst:xcvr_rx_in3
	wire         dut_pcie_tb_hip_serial_rx_in10;                                        // DUT_pcie_tb:rx_in10 -> pcie_example_design_inst:xcvr_rx_in10
	wire         dut_pcie_tb_hip_serial_rx_in4;                                         // DUT_pcie_tb:rx_in4 -> pcie_example_design_inst:xcvr_rx_in4
	wire         dut_pcie_tb_hip_serial_rx_in11;                                        // DUT_pcie_tb:rx_in11 -> pcie_example_design_inst:xcvr_rx_in11
	wire         dut_pcie_tb_hip_serial_rx_in5;                                         // DUT_pcie_tb:rx_in5 -> pcie_example_design_inst:xcvr_rx_in5
	wire         dut_pcie_tb_hip_serial_rx_in12;                                        // DUT_pcie_tb:rx_in12 -> pcie_example_design_inst:xcvr_rx_in12
	wire         dut_pcie_tb_hip_serial_rx_in6;                                         // DUT_pcie_tb:rx_in6 -> pcie_example_design_inst:xcvr_rx_in6
	wire         dut_pcie_tb_hip_serial_rx_in7;                                         // DUT_pcie_tb:rx_in7 -> pcie_example_design_inst:xcvr_rx_in7
	wire         dut_pcie_tb_hip_serial_rx_in8;                                         // DUT_pcie_tb:rx_in8 -> pcie_example_design_inst:xcvr_rx_in8
	wire         dut_pcie_tb_hip_serial_rx_in9;                                         // DUT_pcie_tb:rx_in9 -> pcie_example_design_inst:xcvr_rx_in9
	wire         pcie_example_design_inst_xcvr_tx_out2;                                 // pcie_example_design_inst:xcvr_tx_out2 -> DUT_pcie_tb:tx_out2
	wire         pcie_example_design_inst_xcvr_tx_out1;                                 // pcie_example_design_inst:xcvr_tx_out1 -> DUT_pcie_tb:tx_out1
	wire         pcie_example_design_inst_xcvr_tx_out0;                                 // pcie_example_design_inst:xcvr_tx_out0 -> DUT_pcie_tb:tx_out0
	wire         dut_pcie_tb_npor_npor;                                                 // DUT_pcie_tb:npor -> pcie_example_design_inst:pcie_rstn_npor
	wire         dut_pcie_tb_npor_pin_perst;                                            // DUT_pcie_tb:pin_perst -> pcie_example_design_inst:pcie_rstn_pin_perst

        /* Added for DCP */
        reg SYS_REFCLK = 0;
        reg PCIE_REFCLK = 0;
        reg ETH_RefClk = 0;
        reg DDR4_Refclk = 0;
        reg Reset_n = 0;
        wire [15:0] PCIE_RX;
        wire [15:0] PCIE_TX;
        reg PCIE_RESET_N = 0;
// HSSI serial data for loopback
   localparam NUM_CHANNELS = 1;
   wire	[NUM_CHANNELS-1:0] tx_serial_data_loopback;
   wire	[NUM_CHANNELS-1:0] rx_serial_data_loopback;

	DUT_pcie_tb_ip dut_pcie_tb (
		.rx_in0                    (PCIE_RX[0]),                   //  output,   width = 1, hip_serial.rx_in0
		.rx_in1                    (PCIE_RX[1]),                   //  output,   width = 1,           .rx_in1
		.rx_in2                    (PCIE_RX[2]),                   //  output,   width = 1,           .rx_in2
		.rx_in3                    (PCIE_RX[3]),                   //  output,   width = 1,           .rx_in3
		.rx_in4                    (PCIE_RX[4]),                   //  output,   width = 1,           .rx_in4
		.rx_in5                    (PCIE_RX[5]),                   //  output,   width = 1,           .rx_in5
		.rx_in6                    (PCIE_RX[6]),                   //  output,   width = 1,           .rx_in6
		.rx_in7                    (PCIE_RX[7]),                   //  output,   width = 1,           .rx_in7
		.rx_in8                    (PCIE_RX[8]),                   //  output,   width = 1,           .rx_in8
		.rx_in9                    (PCIE_RX[9]),                   //  output,   width = 1,           .rx_in9
		.rx_in10                   (PCIE_RX[10]),                  //  output,   width = 1,           .rx_in10
		.rx_in11                   (PCIE_RX[11]),                  //  output,   width = 1,           .rx_in11
		.rx_in12                   (PCIE_RX[12]),                  //  output,   width = 1,           .rx_in12
		.rx_in13                   (PCIE_RX[13]),                  //  output,   width = 1,           .rx_in13
		.rx_in14                   (PCIE_RX[14]),                  //  output,   width = 1,           .rx_in14
		.rx_in15                   (PCIE_RX[15]),                  //  output,   width = 1,           .rx_in15
                .tx_out0                   (PCIE_TX[0]),                   //   input,   width = 1,           .tx_out0
		.tx_out1                   (PCIE_TX[1]),                   //   input,   width = 1,           .tx_out1
		.tx_out2                   (PCIE_TX[2]),                   //   input,   width = 1,           .tx_out2
		.tx_out3                   (PCIE_TX[3]),                   //   input,   width = 1,           .tx_out3
		.tx_out4                   (PCIE_TX[4]),                   //   input,   width = 1,           .tx_out4
		.tx_out5                   (PCIE_TX[5]),                   //   input,   width = 1,           .tx_out5
		.tx_out6                   (PCIE_TX[6]),                   //   input,   width = 1,           .tx_out6
		.tx_out7                   (PCIE_TX[7]),                   //   input,   width = 1,           .tx_out7
		.tx_out8                   (PCIE_TX[8]),                   //   input,   width = 1,           .tx_out8
		.tx_out9                   (PCIE_TX[9]),                   //   input,   width = 1,           .tx_out9
		.tx_out10                  (PCIE_TX[10]),                  //   input,   width = 1,           .tx_out10
		.tx_out11                  (PCIE_TX[11]),                  //   input,   width = 1,           .tx_out11
		.tx_out12                  (PCIE_TX[12]),                  //   input,   width = 1,           .tx_out12
		.tx_out13                  (PCIE_TX[13]),                  //   input,   width = 1,           .tx_out13
		.tx_out14                  (PCIE_TX[14]),                  //   input,   width = 1,           .tx_out14
		.tx_out15                  (PCIE_TX[15]),                  //   input,   width = 1,           .tx_out15
                .refclk                    (dut_pcie_tb_refclk_clk),                                   //  output,   width = 1,     refclk.clk
		.sim_pipe_pclk_in          (dut_pcie_tb_hip_pipe_sim_pipe_pclk_in),                    //  output,   width = 1,   hip_pipe.sim_pipe_pclk_in
		.sim_pipe_mask_tx_pll_lock (dut_pcie_tb_hip_pipe_sim_pipe_mask_tx_pll_lock),           //  output,   width = 1,           .sim_pipe_mask_tx_pll_lock
		.sim_pipe_rate             (pcie_example_design_inst_pipe_sim_only_sim_pipe_rate),     //   input,   width = 2,           .sim_pipe_rate
		.sim_ltssmstate            (pcie_example_design_inst_pipe_sim_only_sim_ltssmstate),    //   input,   width = 6,           .sim_ltssmstate
		.dirfeedback0              (dut_pcie_tb_hip_pipe_dirfeedback0),                        //  output,   width = 6,           .dirfeedback0
		.dirfeedback1              (dut_pcie_tb_hip_pipe_dirfeedback1),                        //  output,   width = 6,           .dirfeedback1
		.dirfeedback2              (dut_pcie_tb_hip_pipe_dirfeedback2),                        //  output,   width = 6,           .dirfeedback2
		.dirfeedback3              (dut_pcie_tb_hip_pipe_dirfeedback3),                        //  output,   width = 6,           .dirfeedback3
		.dirfeedback4              (dut_pcie_tb_hip_pipe_dirfeedback4),                        //  output,   width = 6,           .dirfeedback4
		.dirfeedback5              (dut_pcie_tb_hip_pipe_dirfeedback5),                        //  output,   width = 6,           .dirfeedback5
		.dirfeedback6              (dut_pcie_tb_hip_pipe_dirfeedback6),                        //  output,   width = 6,           .dirfeedback6
		.dirfeedback7              (dut_pcie_tb_hip_pipe_dirfeedback7),                        //  output,   width = 6,           .dirfeedback7
		.rxeqeval0                 (pcie_example_design_inst_pipe_sim_only_rxeqeval0),         //   input,   width = 1,           .rxeqeval0
		.rxeqeval1                 (pcie_example_design_inst_pipe_sim_only_rxeqeval1),         //   input,   width = 1,           .rxeqeval1
		.rxeqeval2                 (pcie_example_design_inst_pipe_sim_only_rxeqeval2),         //   input,   width = 1,           .rxeqeval2
		.rxeqeval3                 (pcie_example_design_inst_pipe_sim_only_rxeqeval3),         //   input,   width = 1,           .rxeqeval3
		.rxeqeval4                 (pcie_example_design_inst_pipe_sim_only_rxeqeval4),         //   input,   width = 1,           .rxeqeval4
		.rxeqeval5                 (pcie_example_design_inst_pipe_sim_only_rxeqeval5),         //   input,   width = 1,           .rxeqeval5
		.rxeqeval6                 (pcie_example_design_inst_pipe_sim_only_rxeqeval6),         //   input,   width = 1,           .rxeqeval6
		.rxeqeval7                 (pcie_example_design_inst_pipe_sim_only_rxeqeval7),         //   input,   width = 1,           .rxeqeval7
		.rxeqinprogress0           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress0),   //   input,   width = 1,           .rxeqinprogress0
		.rxeqinprogress1           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress1),   //   input,   width = 1,           .rxeqinprogress1
		.rxeqinprogress2           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress2),   //   input,   width = 1,           .rxeqinprogress2
		.rxeqinprogress3           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress3),   //   input,   width = 1,           .rxeqinprogress3
		.rxeqinprogress4           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress4),   //   input,   width = 1,           .rxeqinprogress4
		.rxeqinprogress5           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress5),   //   input,   width = 1,           .rxeqinprogress5
		.rxeqinprogress6           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress6),   //   input,   width = 1,           .rxeqinprogress6
		.rxeqinprogress7           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress7),   //   input,   width = 1,           .rxeqinprogress7
		.invalidreq0               (pcie_example_design_inst_pipe_sim_only_invalidreq0),       //   input,   width = 1,           .invalidreq0
		.invalidreq1               (pcie_example_design_inst_pipe_sim_only_invalidreq1),       //   input,   width = 1,           .invalidreq1
		.invalidreq2               (pcie_example_design_inst_pipe_sim_only_invalidreq2),       //   input,   width = 1,           .invalidreq2
		.invalidreq3               (pcie_example_design_inst_pipe_sim_only_invalidreq3),       //   input,   width = 1,           .invalidreq3
		.invalidreq4               (pcie_example_design_inst_pipe_sim_only_invalidreq4),       //   input,   width = 1,           .invalidreq4
		.invalidreq5               (pcie_example_design_inst_pipe_sim_only_invalidreq5),       //   input,   width = 1,           .invalidreq5
		.invalidreq6               (pcie_example_design_inst_pipe_sim_only_invalidreq6),       //   input,   width = 1,           .invalidreq6
		.invalidreq7               (pcie_example_design_inst_pipe_sim_only_invalidreq7),       //   input,   width = 1,           .invalidreq7
		.powerdown0                (pcie_example_design_inst_pipe_sim_only_powerdown0),        //   input,   width = 2,           .powerdown0
		.powerdown1                (pcie_example_design_inst_pipe_sim_only_powerdown1),        //   input,   width = 2,           .powerdown1
		.powerdown2                (pcie_example_design_inst_pipe_sim_only_powerdown2),        //   input,   width = 2,           .powerdown2
		.powerdown3                (pcie_example_design_inst_pipe_sim_only_powerdown3),        //   input,   width = 2,           .powerdown3
		.powerdown4                (pcie_example_design_inst_pipe_sim_only_powerdown4),        //   input,   width = 2,           .powerdown4
		.powerdown5                (pcie_example_design_inst_pipe_sim_only_powerdown5),        //   input,   width = 2,           .powerdown5
		.powerdown6                (pcie_example_design_inst_pipe_sim_only_powerdown6),        //   input,   width = 2,           .powerdown6
		.powerdown7                (pcie_example_design_inst_pipe_sim_only_powerdown7),        //   input,   width = 2,           .powerdown7
		.rxpolarity0               (pcie_example_design_inst_pipe_sim_only_rxpolarity0),       //   input,   width = 1,           .rxpolarity0
		.rxpolarity1               (pcie_example_design_inst_pipe_sim_only_rxpolarity1),       //   input,   width = 1,           .rxpolarity1
		.rxpolarity2               (pcie_example_design_inst_pipe_sim_only_rxpolarity2),       //   input,   width = 1,           .rxpolarity2
		.rxpolarity3               (pcie_example_design_inst_pipe_sim_only_rxpolarity3),       //   input,   width = 1,           .rxpolarity3
		.rxpolarity4               (pcie_example_design_inst_pipe_sim_only_rxpolarity4),       //   input,   width = 1,           .rxpolarity4
		.rxpolarity5               (pcie_example_design_inst_pipe_sim_only_rxpolarity5),       //   input,   width = 1,           .rxpolarity5
		.rxpolarity6               (pcie_example_design_inst_pipe_sim_only_rxpolarity6),       //   input,   width = 1,           .rxpolarity6
		.rxpolarity7               (pcie_example_design_inst_pipe_sim_only_rxpolarity7),       //   input,   width = 1,           .rxpolarity7
		.txcompl0                  (pcie_example_design_inst_pipe_sim_only_txcompl0),          //   input,   width = 1,           .txcompl0
		.txcompl1                  (pcie_example_design_inst_pipe_sim_only_txcompl1),          //   input,   width = 1,           .txcompl1
		.txcompl2                  (pcie_example_design_inst_pipe_sim_only_txcompl2),          //   input,   width = 1,           .txcompl2
		.txcompl3                  (pcie_example_design_inst_pipe_sim_only_txcompl3),          //   input,   width = 1,           .txcompl3
		.txcompl4                  (pcie_example_design_inst_pipe_sim_only_txcompl4),          //   input,   width = 1,           .txcompl4
		.txcompl5                  (pcie_example_design_inst_pipe_sim_only_txcompl5),          //   input,   width = 1,           .txcompl5
		.txcompl6                  (pcie_example_design_inst_pipe_sim_only_txcompl6),          //   input,   width = 1,           .txcompl6
		.txcompl7                  (pcie_example_design_inst_pipe_sim_only_txcompl7),          //   input,   width = 1,           .txcompl7
		.txdata0                   (pcie_example_design_inst_pipe_sim_only_txdata0),           //   input,  width = 32,           .txdata0
		.txdata1                   (pcie_example_design_inst_pipe_sim_only_txdata1),           //   input,  width = 32,           .txdata1
		.txdata2                   (pcie_example_design_inst_pipe_sim_only_txdata2),           //   input,  width = 32,           .txdata2
		.txdata3                   (pcie_example_design_inst_pipe_sim_only_txdata3),           //   input,  width = 32,           .txdata3
		.txdata4                   (pcie_example_design_inst_pipe_sim_only_txdata4),           //   input,  width = 32,           .txdata4
		.txdata5                   (pcie_example_design_inst_pipe_sim_only_txdata5),           //   input,  width = 32,           .txdata5
		.txdata6                   (pcie_example_design_inst_pipe_sim_only_txdata6),           //   input,  width = 32,           .txdata6
		.txdata7                   (pcie_example_design_inst_pipe_sim_only_txdata7),           //   input,  width = 32,           .txdata7
		.txdatak0                  (pcie_example_design_inst_pipe_sim_only_txdatak0),          //   input,   width = 4,           .txdatak0
		.txdatak1                  (pcie_example_design_inst_pipe_sim_only_txdatak1),          //   input,   width = 4,           .txdatak1
		.txdatak2                  (pcie_example_design_inst_pipe_sim_only_txdatak2),          //   input,   width = 4,           .txdatak2
		.txdatak3                  (pcie_example_design_inst_pipe_sim_only_txdatak3),          //   input,   width = 4,           .txdatak3
		.txdatak4                  (pcie_example_design_inst_pipe_sim_only_txdatak4),          //   input,   width = 4,           .txdatak4
		.txdatak5                  (pcie_example_design_inst_pipe_sim_only_txdatak5),          //   input,   width = 4,           .txdatak5
		.txdatak6                  (pcie_example_design_inst_pipe_sim_only_txdatak6),          //   input,   width = 4,           .txdatak6
		.txdatak7                  (pcie_example_design_inst_pipe_sim_only_txdatak7),          //   input,   width = 4,           .txdatak7
		.txdetectrx0               (pcie_example_design_inst_pipe_sim_only_txdetectrx0),       //   input,   width = 1,           .txdetectrx0
		.txdetectrx1               (pcie_example_design_inst_pipe_sim_only_txdetectrx1),       //   input,   width = 1,           .txdetectrx1
		.txdetectrx2               (pcie_example_design_inst_pipe_sim_only_txdetectrx2),       //   input,   width = 1,           .txdetectrx2
		.txdetectrx3               (pcie_example_design_inst_pipe_sim_only_txdetectrx3),       //   input,   width = 1,           .txdetectrx3
		.txdetectrx4               (pcie_example_design_inst_pipe_sim_only_txdetectrx4),       //   input,   width = 1,           .txdetectrx4
		.txdetectrx5               (pcie_example_design_inst_pipe_sim_only_txdetectrx5),       //   input,   width = 1,           .txdetectrx5
		.txdetectrx6               (pcie_example_design_inst_pipe_sim_only_txdetectrx6),       //   input,   width = 1,           .txdetectrx6
		.txdetectrx7               (pcie_example_design_inst_pipe_sim_only_txdetectrx7),       //   input,   width = 1,           .txdetectrx7
		.txelecidle0               (pcie_example_design_inst_pipe_sim_only_txelecidle0),       //   input,   width = 1,           .txelecidle0
		.txelecidle1               (pcie_example_design_inst_pipe_sim_only_txelecidle1),       //   input,   width = 1,           .txelecidle1
		.txelecidle2               (pcie_example_design_inst_pipe_sim_only_txelecidle2),       //   input,   width = 1,           .txelecidle2
		.txelecidle3               (pcie_example_design_inst_pipe_sim_only_txelecidle3),       //   input,   width = 1,           .txelecidle3
		.txelecidle4               (pcie_example_design_inst_pipe_sim_only_txelecidle4),       //   input,   width = 1,           .txelecidle4
		.txelecidle5               (pcie_example_design_inst_pipe_sim_only_txelecidle5),       //   input,   width = 1,           .txelecidle5
		.txelecidle6               (pcie_example_design_inst_pipe_sim_only_txelecidle6),       //   input,   width = 1,           .txelecidle6
		.txelecidle7               (pcie_example_design_inst_pipe_sim_only_txelecidle7),       //   input,   width = 1,           .txelecidle7
		.txdeemph0                 (pcie_example_design_inst_pipe_sim_only_txdeemph0),         //   input,   width = 1,           .txdeemph0
		.txdeemph1                 (pcie_example_design_inst_pipe_sim_only_txdeemph1),         //   input,   width = 1,           .txdeemph1
		.txdeemph2                 (pcie_example_design_inst_pipe_sim_only_txdeemph2),         //   input,   width = 1,           .txdeemph2
		.txdeemph3                 (pcie_example_design_inst_pipe_sim_only_txdeemph3),         //   input,   width = 1,           .txdeemph3
		.txdeemph4                 (pcie_example_design_inst_pipe_sim_only_txdeemph4),         //   input,   width = 1,           .txdeemph4
		.txdeemph5                 (pcie_example_design_inst_pipe_sim_only_txdeemph5),         //   input,   width = 1,           .txdeemph5
		.txdeemph6                 (pcie_example_design_inst_pipe_sim_only_txdeemph6),         //   input,   width = 1,           .txdeemph6
		.txdeemph7                 (pcie_example_design_inst_pipe_sim_only_txdeemph7),         //   input,   width = 1,           .txdeemph7
		.txmargin0                 (pcie_example_design_inst_pipe_sim_only_txmargin0),         //   input,   width = 3,           .txmargin0
		.txmargin1                 (pcie_example_design_inst_pipe_sim_only_txmargin1),         //   input,   width = 3,           .txmargin1
		.txmargin2                 (pcie_example_design_inst_pipe_sim_only_txmargin2),         //   input,   width = 3,           .txmargin2
		.txmargin3                 (pcie_example_design_inst_pipe_sim_only_txmargin3),         //   input,   width = 3,           .txmargin3
		.txmargin4                 (pcie_example_design_inst_pipe_sim_only_txmargin4),         //   input,   width = 3,           .txmargin4
		.txmargin5                 (pcie_example_design_inst_pipe_sim_only_txmargin5),         //   input,   width = 3,           .txmargin5
		.txmargin6                 (pcie_example_design_inst_pipe_sim_only_txmargin6),         //   input,   width = 3,           .txmargin6
		.txmargin7                 (pcie_example_design_inst_pipe_sim_only_txmargin7),         //   input,   width = 3,           .txmargin7
		.txswing0                  (pcie_example_design_inst_pipe_sim_only_txswing0),          //   input,   width = 1,           .txswing0
		.txswing1                  (pcie_example_design_inst_pipe_sim_only_txswing1),          //   input,   width = 1,           .txswing1
		.txswing2                  (pcie_example_design_inst_pipe_sim_only_txswing2),          //   input,   width = 1,           .txswing2
		.txswing3                  (pcie_example_design_inst_pipe_sim_only_txswing3),          //   input,   width = 1,           .txswing3
		.txswing4                  (pcie_example_design_inst_pipe_sim_only_txswing4),          //   input,   width = 1,           .txswing4
		.txswing5                  (pcie_example_design_inst_pipe_sim_only_txswing5),          //   input,   width = 1,           .txswing5
		.txswing6                  (pcie_example_design_inst_pipe_sim_only_txswing6),          //   input,   width = 1,           .txswing6
		.txswing7                  (pcie_example_design_inst_pipe_sim_only_txswing7),          //   input,   width = 1,           .txswing7
		.phystatus0                (dut_pcie_tb_hip_pipe_phystatus0),                          //  output,   width = 1,           .phystatus0
		.phystatus1                (dut_pcie_tb_hip_pipe_phystatus1),                          //  output,   width = 1,           .phystatus1
		.phystatus2                (dut_pcie_tb_hip_pipe_phystatus2),                          //  output,   width = 1,           .phystatus2
		.phystatus3                (dut_pcie_tb_hip_pipe_phystatus3),                          //  output,   width = 1,           .phystatus3
		.phystatus4                (dut_pcie_tb_hip_pipe_phystatus4),                          //  output,   width = 1,           .phystatus4
		.phystatus5                (dut_pcie_tb_hip_pipe_phystatus5),                          //  output,   width = 1,           .phystatus5
		.phystatus6                (dut_pcie_tb_hip_pipe_phystatus6),                          //  output,   width = 1,           .phystatus6
		.phystatus7                (dut_pcie_tb_hip_pipe_phystatus7),                          //  output,   width = 1,           .phystatus7
		.rxdata0                   (dut_pcie_tb_hip_pipe_rxdata0),                             //  output,  width = 32,           .rxdata0
		.rxdata1                   (dut_pcie_tb_hip_pipe_rxdata1),                             //  output,  width = 32,           .rxdata1
		.rxdata2                   (dut_pcie_tb_hip_pipe_rxdata2),                             //  output,  width = 32,           .rxdata2
		.rxdata3                   (dut_pcie_tb_hip_pipe_rxdata3),                             //  output,  width = 32,           .rxdata3
		.rxdata4                   (dut_pcie_tb_hip_pipe_rxdata4),                             //  output,  width = 32,           .rxdata4
		.rxdata5                   (dut_pcie_tb_hip_pipe_rxdata5),                             //  output,  width = 32,           .rxdata5
		.rxdata6                   (dut_pcie_tb_hip_pipe_rxdata6),                             //  output,  width = 32,           .rxdata6
		.rxdata7                   (dut_pcie_tb_hip_pipe_rxdata7),                             //  output,  width = 32,           .rxdata7
		.rxdatak0                  (dut_pcie_tb_hip_pipe_rxdatak0),                            //  output,   width = 4,           .rxdatak0
		.rxdatak1                  (dut_pcie_tb_hip_pipe_rxdatak1),                            //  output,   width = 4,           .rxdatak1
		.rxdatak2                  (dut_pcie_tb_hip_pipe_rxdatak2),                            //  output,   width = 4,           .rxdatak2
		.rxdatak3                  (dut_pcie_tb_hip_pipe_rxdatak3),                            //  output,   width = 4,           .rxdatak3
		.rxdatak4                  (dut_pcie_tb_hip_pipe_rxdatak4),                            //  output,   width = 4,           .rxdatak4
		.rxdatak5                  (dut_pcie_tb_hip_pipe_rxdatak5),                            //  output,   width = 4,           .rxdatak5
		.rxdatak6                  (dut_pcie_tb_hip_pipe_rxdatak6),                            //  output,   width = 4,           .rxdatak6
		.rxdatak7                  (dut_pcie_tb_hip_pipe_rxdatak7),                            //  output,   width = 4,           .rxdatak7
		.rxelecidle0               (dut_pcie_tb_hip_pipe_rxelecidle0),                         //  output,   width = 1,           .rxelecidle0
		.rxelecidle1               (dut_pcie_tb_hip_pipe_rxelecidle1),                         //  output,   width = 1,           .rxelecidle1
		.rxelecidle2               (dut_pcie_tb_hip_pipe_rxelecidle2),                         //  output,   width = 1,           .rxelecidle2
		.rxelecidle3               (dut_pcie_tb_hip_pipe_rxelecidle3),                         //  output,   width = 1,           .rxelecidle3
		.rxelecidle4               (dut_pcie_tb_hip_pipe_rxelecidle4),                         //  output,   width = 1,           .rxelecidle4
		.rxelecidle5               (dut_pcie_tb_hip_pipe_rxelecidle5),                         //  output,   width = 1,           .rxelecidle5
		.rxelecidle6               (dut_pcie_tb_hip_pipe_rxelecidle6),                         //  output,   width = 1,           .rxelecidle6
		.rxelecidle7               (dut_pcie_tb_hip_pipe_rxelecidle7),                         //  output,   width = 1,           .rxelecidle7
		.rxstatus0                 (dut_pcie_tb_hip_pipe_rxstatus0),                           //  output,   width = 3,           .rxstatus0
		.rxstatus1                 (dut_pcie_tb_hip_pipe_rxstatus1),                           //  output,   width = 3,           .rxstatus1
		.rxstatus2                 (dut_pcie_tb_hip_pipe_rxstatus2),                           //  output,   width = 3,           .rxstatus2
		.rxstatus3                 (dut_pcie_tb_hip_pipe_rxstatus3),                           //  output,   width = 3,           .rxstatus3
		.rxstatus4                 (dut_pcie_tb_hip_pipe_rxstatus4),                           //  output,   width = 3,           .rxstatus4
		.rxstatus5                 (dut_pcie_tb_hip_pipe_rxstatus5),                           //  output,   width = 3,           .rxstatus5
		.rxstatus6                 (dut_pcie_tb_hip_pipe_rxstatus6),                           //  output,   width = 3,           .rxstatus6
		.rxstatus7                 (dut_pcie_tb_hip_pipe_rxstatus7),                           //  output,   width = 3,           .rxstatus7
		.rxvalid0                  (dut_pcie_tb_hip_pipe_rxvalid0),                            //  output,   width = 1,           .rxvalid0
		.rxvalid1                  (dut_pcie_tb_hip_pipe_rxvalid1),                            //  output,   width = 1,           .rxvalid1
		.rxvalid2                  (dut_pcie_tb_hip_pipe_rxvalid2),                            //  output,   width = 1,           .rxvalid2
		.rxvalid3                  (dut_pcie_tb_hip_pipe_rxvalid3),                            //  output,   width = 1,           .rxvalid3
		.rxvalid4                  (dut_pcie_tb_hip_pipe_rxvalid4),                            //  output,   width = 1,           .rxvalid4
		.rxvalid5                  (dut_pcie_tb_hip_pipe_rxvalid5),                            //  output,   width = 1,           .rxvalid5
		.rxvalid6                  (dut_pcie_tb_hip_pipe_rxvalid6),                            //  output,   width = 1,           .rxvalid6
		.rxvalid7                  (dut_pcie_tb_hip_pipe_rxvalid7),                            //  output,   width = 1,           .rxvalid7
		.rxdataskip0               (dut_pcie_tb_hip_pipe_rxdataskip0),                         //  output,   width = 1,           .rxdataskip0
		.rxdataskip1               (dut_pcie_tb_hip_pipe_rxdataskip1),                         //  output,   width = 1,           .rxdataskip1
		.rxdataskip2               (dut_pcie_tb_hip_pipe_rxdataskip2),                         //  output,   width = 1,           .rxdataskip2
		.rxdataskip3               (dut_pcie_tb_hip_pipe_rxdataskip3),                         //  output,   width = 1,           .rxdataskip3
		.rxdataskip4               (dut_pcie_tb_hip_pipe_rxdataskip4),                         //  output,   width = 1,           .rxdataskip4
		.rxdataskip5               (dut_pcie_tb_hip_pipe_rxdataskip5),                         //  output,   width = 1,           .rxdataskip5
		.rxdataskip6               (dut_pcie_tb_hip_pipe_rxdataskip6),                         //  output,   width = 1,           .rxdataskip6
		.rxdataskip7               (dut_pcie_tb_hip_pipe_rxdataskip7),                         //  output,   width = 1,           .rxdataskip7
		.rxblkst0                  (dut_pcie_tb_hip_pipe_rxblkst0),                            //  output,   width = 1,           .rxblkst0
		.rxblkst1                  (dut_pcie_tb_hip_pipe_rxblkst1),                            //  output,   width = 1,           .rxblkst1
		.rxblkst2                  (dut_pcie_tb_hip_pipe_rxblkst2),                            //  output,   width = 1,           .rxblkst2
		.rxblkst3                  (dut_pcie_tb_hip_pipe_rxblkst3),                            //  output,   width = 1,           .rxblkst3
		.rxblkst4                  (dut_pcie_tb_hip_pipe_rxblkst4),                            //  output,   width = 1,           .rxblkst4
		.rxblkst5                  (dut_pcie_tb_hip_pipe_rxblkst5),                            //  output,   width = 1,           .rxblkst5
		.rxblkst6                  (dut_pcie_tb_hip_pipe_rxblkst6),                            //  output,   width = 1,           .rxblkst6
		.rxblkst7                  (dut_pcie_tb_hip_pipe_rxblkst7),                            //  output,   width = 1,           .rxblkst7
		.rxsynchd0                 (dut_pcie_tb_hip_pipe_rxsynchd0),                           //  output,   width = 2,           .rxsynchd0
		.rxsynchd1                 (dut_pcie_tb_hip_pipe_rxsynchd1),                           //  output,   width = 2,           .rxsynchd1
		.rxsynchd2                 (dut_pcie_tb_hip_pipe_rxsynchd2),                           //  output,   width = 2,           .rxsynchd2
		.rxsynchd3                 (dut_pcie_tb_hip_pipe_rxsynchd3),                           //  output,   width = 2,           .rxsynchd3
		.rxsynchd4                 (dut_pcie_tb_hip_pipe_rxsynchd4),                           //  output,   width = 2,           .rxsynchd4
		.rxsynchd5                 (dut_pcie_tb_hip_pipe_rxsynchd5),                           //  output,   width = 2,           .rxsynchd5
		.rxsynchd6                 (dut_pcie_tb_hip_pipe_rxsynchd6),                           //  output,   width = 2,           .rxsynchd6
		.rxsynchd7                 (dut_pcie_tb_hip_pipe_rxsynchd7),                           //  output,   width = 2,           .rxsynchd7
		.currentcoeff0             (pcie_example_design_inst_pipe_sim_only_currentcoeff0),     //   input,  width = 18,           .currentcoeff0
		.currentcoeff1             (pcie_example_design_inst_pipe_sim_only_currentcoeff1),     //   input,  width = 18,           .currentcoeff1
		.currentcoeff2             (pcie_example_design_inst_pipe_sim_only_currentcoeff2),     //   input,  width = 18,           .currentcoeff2
		.currentcoeff3             (pcie_example_design_inst_pipe_sim_only_currentcoeff3),     //   input,  width = 18,           .currentcoeff3
		.currentcoeff4             (pcie_example_design_inst_pipe_sim_only_currentcoeff4),     //   input,  width = 18,           .currentcoeff4
		.currentcoeff5             (pcie_example_design_inst_pipe_sim_only_currentcoeff5),     //   input,  width = 18,           .currentcoeff5
		.currentcoeff6             (pcie_example_design_inst_pipe_sim_only_currentcoeff6),     //   input,  width = 18,           .currentcoeff6
		.currentcoeff7             (pcie_example_design_inst_pipe_sim_only_currentcoeff7),     //   input,  width = 18,           .currentcoeff7
		.currentrxpreset0          (pcie_example_design_inst_pipe_sim_only_currentrxpreset0),  //   input,   width = 3,           .currentrxpreset0
		.currentrxpreset1          (pcie_example_design_inst_pipe_sim_only_currentrxpreset1),  //   input,   width = 3,           .currentrxpreset1
		.currentrxpreset2          (pcie_example_design_inst_pipe_sim_only_currentrxpreset2),  //   input,   width = 3,           .currentrxpreset2
		.currentrxpreset3          (pcie_example_design_inst_pipe_sim_only_currentrxpreset3),  //   input,   width = 3,           .currentrxpreset3
		.currentrxpreset4          (pcie_example_design_inst_pipe_sim_only_currentrxpreset4),  //   input,   width = 3,           .currentrxpreset4
		.currentrxpreset5          (pcie_example_design_inst_pipe_sim_only_currentrxpreset5),  //   input,   width = 3,           .currentrxpreset5
		.currentrxpreset6          (pcie_example_design_inst_pipe_sim_only_currentrxpreset6),  //   input,   width = 3,           .currentrxpreset6
		.currentrxpreset7          (pcie_example_design_inst_pipe_sim_only_currentrxpreset7),  //   input,   width = 3,           .currentrxpreset7
		.txsynchd0                 (pcie_example_design_inst_pipe_sim_only_txsynchd0),         //   input,   width = 2,           .txsynchd0
		.txsynchd1                 (pcie_example_design_inst_pipe_sim_only_txsynchd1),         //   input,   width = 2,           .txsynchd1
		.txsynchd2                 (pcie_example_design_inst_pipe_sim_only_txsynchd2),         //   input,   width = 2,           .txsynchd2
		.txsynchd3                 (pcie_example_design_inst_pipe_sim_only_txsynchd3),         //   input,   width = 2,           .txsynchd3
		.txsynchd4                 (pcie_example_design_inst_pipe_sim_only_txsynchd4),         //   input,   width = 2,           .txsynchd4
		.txsynchd5                 (pcie_example_design_inst_pipe_sim_only_txsynchd5),         //   input,   width = 2,           .txsynchd5
		.txsynchd6                 (pcie_example_design_inst_pipe_sim_only_txsynchd6),         //   input,   width = 2,           .txsynchd6
		.txsynchd7                 (pcie_example_design_inst_pipe_sim_only_txsynchd7),         //   input,   width = 2,           .txsynchd7
		.txblkst0                  (pcie_example_design_inst_pipe_sim_only_txblkst0),          //   input,   width = 1,           .txblkst0
		.txblkst1                  (pcie_example_design_inst_pipe_sim_only_txblkst1),          //   input,   width = 1,           .txblkst1
		.txblkst2                  (pcie_example_design_inst_pipe_sim_only_txblkst2),          //   input,   width = 1,           .txblkst2
		.txblkst3                  (pcie_example_design_inst_pipe_sim_only_txblkst3),          //   input,   width = 1,           .txblkst3
		.txblkst4                  (pcie_example_design_inst_pipe_sim_only_txblkst4),          //   input,   width = 1,           .txblkst4
		.txblkst5                  (pcie_example_design_inst_pipe_sim_only_txblkst5),          //   input,   width = 1,           .txblkst5
		.txblkst6                  (pcie_example_design_inst_pipe_sim_only_txblkst6),          //   input,   width = 1,           .txblkst6
		.txblkst7                  (pcie_example_design_inst_pipe_sim_only_txblkst7),          //   input,   width = 1,           .txblkst7
		.txdataskip0               (pcie_example_design_inst_pipe_sim_only_txdataskip0),       //   input,   width = 1,           .txdataskip0
		.txdataskip1               (pcie_example_design_inst_pipe_sim_only_txdataskip1),       //   input,   width = 1,           .txdataskip1
		.txdataskip2               (pcie_example_design_inst_pipe_sim_only_txdataskip2),       //   input,   width = 1,           .txdataskip2
		.txdataskip3               (pcie_example_design_inst_pipe_sim_only_txdataskip3),       //   input,   width = 1,           .txdataskip3
		.txdataskip4               (pcie_example_design_inst_pipe_sim_only_txdataskip4),       //   input,   width = 1,           .txdataskip4
		.txdataskip5               (pcie_example_design_inst_pipe_sim_only_txdataskip5),       //   input,   width = 1,           .txdataskip5
		.txdataskip6               (pcie_example_design_inst_pipe_sim_only_txdataskip6),       //   input,   width = 1,           .txdataskip6
		.txdataskip7               (pcie_example_design_inst_pipe_sim_only_txdataskip7),       //   input,   width = 1,           .txdataskip7
		.rate0                     (pcie_example_design_inst_pipe_sim_only_rate0),             //   input,   width = 2,           .rate0
		.rate1                     (pcie_example_design_inst_pipe_sim_only_rate1),             //   input,   width = 2,           .rate1
		.rate2                     (pcie_example_design_inst_pipe_sim_only_rate2),             //   input,   width = 2,           .rate2
		.rate3                     (pcie_example_design_inst_pipe_sim_only_rate3),             //   input,   width = 2,           .rate3
		.rate4                     (pcie_example_design_inst_pipe_sim_only_rate4),             //   input,   width = 2,           .rate4
		.rate5                     (pcie_example_design_inst_pipe_sim_only_rate5),             //   input,   width = 2,           .rate5
		.rate6                     (pcie_example_design_inst_pipe_sim_only_rate6),             //   input,   width = 2,           .rate6
		.rate7                     (pcie_example_design_inst_pipe_sim_only_rate7),             //   input,   width = 2,           .rate7
		.dirfeedback8              (dut_pcie_tb_hip_pipe_dirfeedback8),                        //  output,   width = 6,           .dirfeedback8
		.dirfeedback9              (dut_pcie_tb_hip_pipe_dirfeedback9),                        //  output,   width = 6,           .dirfeedback9
		.dirfeedback10             (dut_pcie_tb_hip_pipe_dirfeedback10),                       //  output,   width = 6,           .dirfeedback10
		.dirfeedback11             (dut_pcie_tb_hip_pipe_dirfeedback11),                       //  output,   width = 6,           .dirfeedback11
		.dirfeedback12             (dut_pcie_tb_hip_pipe_dirfeedback12),                       //  output,   width = 6,           .dirfeedback12
		.dirfeedback13             (dut_pcie_tb_hip_pipe_dirfeedback13),                       //  output,   width = 6,           .dirfeedback13
		.dirfeedback14             (dut_pcie_tb_hip_pipe_dirfeedback14),                       //  output,   width = 6,           .dirfeedback14
		.dirfeedback15             (dut_pcie_tb_hip_pipe_dirfeedback15),                       //  output,   width = 6,           .dirfeedback15
		.rxeqeval8                 (pcie_example_design_inst_pipe_sim_only_rxeqeval8),         //   input,   width = 1,           .rxeqeval8
		.rxeqeval9                 (pcie_example_design_inst_pipe_sim_only_rxeqeval9),         //   input,   width = 1,           .rxeqeval9
		.rxeqeval10                (pcie_example_design_inst_pipe_sim_only_rxeqeval10),        //   input,   width = 1,           .rxeqeval10
		.rxeqeval11                (pcie_example_design_inst_pipe_sim_only_rxeqeval11),        //   input,   width = 1,           .rxeqeval11
		.rxeqeval12                (pcie_example_design_inst_pipe_sim_only_rxeqeval12),        //   input,   width = 1,           .rxeqeval12
		.rxeqeval13                (pcie_example_design_inst_pipe_sim_only_rxeqeval13),        //   input,   width = 1,           .rxeqeval13
		.rxeqeval14                (pcie_example_design_inst_pipe_sim_only_rxeqeval14),        //   input,   width = 1,           .rxeqeval14
		.rxeqeval15                (pcie_example_design_inst_pipe_sim_only_rxeqeval15),        //   input,   width = 1,           .rxeqeval15
		.rxeqinprogress8           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress8),   //   input,   width = 1,           .rxeqinprogress8
		.rxeqinprogress9           (pcie_example_design_inst_pipe_sim_only_rxeqinprogress9),   //   input,   width = 1,           .rxeqinprogress9
		.rxeqinprogress10          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress10),  //   input,   width = 1,           .rxeqinprogress10
		.rxeqinprogress11          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress11),  //   input,   width = 1,           .rxeqinprogress11
		.rxeqinprogress12          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress12),  //   input,   width = 1,           .rxeqinprogress12
		.rxeqinprogress13          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress13),  //   input,   width = 1,           .rxeqinprogress13
		.rxeqinprogress14          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress14),  //   input,   width = 1,           .rxeqinprogress14
		.rxeqinprogress15          (pcie_example_design_inst_pipe_sim_only_rxeqinprogress15),  //   input,   width = 1,           .rxeqinprogress15
		.invalidreq8               (pcie_example_design_inst_pipe_sim_only_invalidreq8),       //   input,   width = 1,           .invalidreq8
		.invalidreq9               (pcie_example_design_inst_pipe_sim_only_invalidreq9),       //   input,   width = 1,           .invalidreq9
		.invalidreq10              (pcie_example_design_inst_pipe_sim_only_invalidreq10),      //   input,   width = 1,           .invalidreq10
		.invalidreq11              (pcie_example_design_inst_pipe_sim_only_invalidreq11),      //   input,   width = 1,           .invalidreq11
		.invalidreq12              (pcie_example_design_inst_pipe_sim_only_invalidreq12),      //   input,   width = 1,           .invalidreq12
		.invalidreq13              (pcie_example_design_inst_pipe_sim_only_invalidreq13),      //   input,   width = 1,           .invalidreq13
		.invalidreq14              (pcie_example_design_inst_pipe_sim_only_invalidreq14),      //   input,   width = 1,           .invalidreq14
		.invalidreq15              (pcie_example_design_inst_pipe_sim_only_invalidreq15),      //   input,   width = 1,           .invalidreq15
		.powerdown8                (pcie_example_design_inst_pipe_sim_only_powerdown8),        //   input,   width = 2,           .powerdown8
		.powerdown9                (pcie_example_design_inst_pipe_sim_only_powerdown9),        //   input,   width = 2,           .powerdown9
		.powerdown10               (pcie_example_design_inst_pipe_sim_only_powerdown10),       //   input,   width = 2,           .powerdown10
		.powerdown11               (pcie_example_design_inst_pipe_sim_only_powerdown11),       //   input,   width = 2,           .powerdown11
		.powerdown12               (pcie_example_design_inst_pipe_sim_only_powerdown12),       //   input,   width = 2,           .powerdown12
		.powerdown13               (pcie_example_design_inst_pipe_sim_only_powerdown13),       //   input,   width = 2,           .powerdown13
		.powerdown14               (pcie_example_design_inst_pipe_sim_only_powerdown14),       //   input,   width = 2,           .powerdown14
		.powerdown15               (pcie_example_design_inst_pipe_sim_only_powerdown15),       //   input,   width = 2,           .powerdown15
		.rxpolarity8               (pcie_example_design_inst_pipe_sim_only_rxpolarity8),       //   input,   width = 1,           .rxpolarity8
		.rxpolarity9               (pcie_example_design_inst_pipe_sim_only_rxpolarity9),       //   input,   width = 1,           .rxpolarity9
		.rxpolarity10              (pcie_example_design_inst_pipe_sim_only_rxpolarity10),      //   input,   width = 1,           .rxpolarity10
		.rxpolarity11              (pcie_example_design_inst_pipe_sim_only_rxpolarity11),      //   input,   width = 1,           .rxpolarity11
		.rxpolarity12              (pcie_example_design_inst_pipe_sim_only_rxpolarity12),      //   input,   width = 1,           .rxpolarity12
		.rxpolarity13              (pcie_example_design_inst_pipe_sim_only_rxpolarity13),      //   input,   width = 1,           .rxpolarity13
		.rxpolarity14              (pcie_example_design_inst_pipe_sim_only_rxpolarity14),      //   input,   width = 1,           .rxpolarity14
		.rxpolarity15              (pcie_example_design_inst_pipe_sim_only_rxpolarity15),      //   input,   width = 1,           .rxpolarity15
		.txcompl8                  (pcie_example_design_inst_pipe_sim_only_txcompl8),          //   input,   width = 1,           .txcompl8
		.txcompl9                  (pcie_example_design_inst_pipe_sim_only_txcompl9),          //   input,   width = 1,           .txcompl9
		.txcompl10                 (pcie_example_design_inst_pipe_sim_only_txcompl10),         //   input,   width = 1,           .txcompl10
		.txcompl11                 (pcie_example_design_inst_pipe_sim_only_txcompl11),         //   input,   width = 1,           .txcompl11
		.txcompl12                 (pcie_example_design_inst_pipe_sim_only_txcompl12),         //   input,   width = 1,           .txcompl12
		.txcompl13                 (pcie_example_design_inst_pipe_sim_only_txcompl13),         //   input,   width = 1,           .txcompl13
		.txcompl14                 (pcie_example_design_inst_pipe_sim_only_txcompl14),         //   input,   width = 1,           .txcompl14
		.txcompl15                 (pcie_example_design_inst_pipe_sim_only_txcompl15),         //   input,   width = 1,           .txcompl15
		.txdata8                   (pcie_example_design_inst_pipe_sim_only_txdata8),           //   input,  width = 32,           .txdata8
		.txdata9                   (pcie_example_design_inst_pipe_sim_only_txdata9),           //   input,  width = 32,           .txdata9
		.txdata10                  (pcie_example_design_inst_pipe_sim_only_txdata10),          //   input,  width = 32,           .txdata10
		.txdata11                  (pcie_example_design_inst_pipe_sim_only_txdata11),          //   input,  width = 32,           .txdata11
		.txdata12                  (pcie_example_design_inst_pipe_sim_only_txdata12),          //   input,  width = 32,           .txdata12
		.txdata13                  (pcie_example_design_inst_pipe_sim_only_txdata13),          //   input,  width = 32,           .txdata13
		.txdata14                  (pcie_example_design_inst_pipe_sim_only_txdata14),          //   input,  width = 32,           .txdata14
		.txdata15                  (pcie_example_design_inst_pipe_sim_only_txdata15),          //   input,  width = 32,           .txdata15
		.txdatak8                  (pcie_example_design_inst_pipe_sim_only_txdatak8),          //   input,   width = 4,           .txdatak8
		.txdatak9                  (pcie_example_design_inst_pipe_sim_only_txdatak9),          //   input,   width = 4,           .txdatak9
		.txdatak10                 (pcie_example_design_inst_pipe_sim_only_txdatak10),         //   input,   width = 4,           .txdatak10
		.txdatak11                 (pcie_example_design_inst_pipe_sim_only_txdatak11),         //   input,   width = 4,           .txdatak11
		.txdatak12                 (pcie_example_design_inst_pipe_sim_only_txdatak12),         //   input,   width = 4,           .txdatak12
		.txdatak13                 (pcie_example_design_inst_pipe_sim_only_txdatak13),         //   input,   width = 4,           .txdatak13
		.txdatak14                 (pcie_example_design_inst_pipe_sim_only_txdatak14),         //   input,   width = 4,           .txdatak14
		.txdatak15                 (pcie_example_design_inst_pipe_sim_only_txdatak15),         //   input,   width = 4,           .txdatak15
		.txdetectrx8               (pcie_example_design_inst_pipe_sim_only_txdetectrx8),       //   input,   width = 1,           .txdetectrx8
		.txdetectrx9               (pcie_example_design_inst_pipe_sim_only_txdetectrx9),       //   input,   width = 1,           .txdetectrx9
		.txdetectrx10              (pcie_example_design_inst_pipe_sim_only_txdetectrx10),      //   input,   width = 1,           .txdetectrx10
		.txdetectrx11              (pcie_example_design_inst_pipe_sim_only_txdetectrx11),      //   input,   width = 1,           .txdetectrx11
		.txdetectrx12              (pcie_example_design_inst_pipe_sim_only_txdetectrx12),      //   input,   width = 1,           .txdetectrx12
		.txdetectrx13              (pcie_example_design_inst_pipe_sim_only_txdetectrx13),      //   input,   width = 1,           .txdetectrx13
		.txdetectrx14              (pcie_example_design_inst_pipe_sim_only_txdetectrx14),      //   input,   width = 1,           .txdetectrx14
		.txdetectrx15              (pcie_example_design_inst_pipe_sim_only_txdetectrx15),      //   input,   width = 1,           .txdetectrx15
		.txelecidle8               (pcie_example_design_inst_pipe_sim_only_txelecidle8),       //   input,   width = 1,           .txelecidle8
		.txelecidle9               (pcie_example_design_inst_pipe_sim_only_txelecidle9),       //   input,   width = 1,           .txelecidle9
		.txelecidle10              (pcie_example_design_inst_pipe_sim_only_txelecidle10),      //   input,   width = 1,           .txelecidle10
		.txelecidle11              (pcie_example_design_inst_pipe_sim_only_txelecidle11),      //   input,   width = 1,           .txelecidle11
		.txelecidle12              (pcie_example_design_inst_pipe_sim_only_txelecidle12),      //   input,   width = 1,           .txelecidle12
		.txelecidle13              (pcie_example_design_inst_pipe_sim_only_txelecidle13),      //   input,   width = 1,           .txelecidle13
		.txelecidle14              (pcie_example_design_inst_pipe_sim_only_txelecidle14),      //   input,   width = 1,           .txelecidle14
		.txelecidle15              (pcie_example_design_inst_pipe_sim_only_txelecidle15),      //   input,   width = 1,           .txelecidle15
		.txdeemph8                 (pcie_example_design_inst_pipe_sim_only_txdeemph8),         //   input,   width = 1,           .txdeemph8
		.txdeemph9                 (pcie_example_design_inst_pipe_sim_only_txdeemph9),         //   input,   width = 1,           .txdeemph9
		.txdeemph10                (pcie_example_design_inst_pipe_sim_only_txdeemph10),        //   input,   width = 1,           .txdeemph10
		.txdeemph11                (pcie_example_design_inst_pipe_sim_only_txdeemph11),        //   input,   width = 1,           .txdeemph11
		.txdeemph12                (pcie_example_design_inst_pipe_sim_only_txdeemph12),        //   input,   width = 1,           .txdeemph12
		.txdeemph13                (pcie_example_design_inst_pipe_sim_only_txdeemph13),        //   input,   width = 1,           .txdeemph13
		.txdeemph14                (pcie_example_design_inst_pipe_sim_only_txdeemph14),        //   input,   width = 1,           .txdeemph14
		.txdeemph15                (pcie_example_design_inst_pipe_sim_only_txdeemph15),        //   input,   width = 1,           .txdeemph15
		.txmargin8                 (pcie_example_design_inst_pipe_sim_only_txmargin8),         //   input,   width = 3,           .txmargin8
		.txmargin9                 (pcie_example_design_inst_pipe_sim_only_txmargin9),         //   input,   width = 3,           .txmargin9
		.txmargin10                (pcie_example_design_inst_pipe_sim_only_txmargin10),        //   input,   width = 3,           .txmargin10
		.txmargin11                (pcie_example_design_inst_pipe_sim_only_txmargin11),        //   input,   width = 3,           .txmargin11
		.txmargin12                (pcie_example_design_inst_pipe_sim_only_txmargin12),        //   input,   width = 3,           .txmargin12
		.txmargin13                (pcie_example_design_inst_pipe_sim_only_txmargin13),        //   input,   width = 3,           .txmargin13
		.txmargin14                (pcie_example_design_inst_pipe_sim_only_txmargin14),        //   input,   width = 3,           .txmargin14
		.txmargin15                (pcie_example_design_inst_pipe_sim_only_txmargin15),        //   input,   width = 3,           .txmargin15
		.txswing8                  (pcie_example_design_inst_pipe_sim_only_txswing8),          //   input,   width = 1,           .txswing8
		.txswing9                  (pcie_example_design_inst_pipe_sim_only_txswing9),          //   input,   width = 1,           .txswing9
		.txswing10                 (pcie_example_design_inst_pipe_sim_only_txswing10),         //   input,   width = 1,           .txswing10
		.txswing11                 (pcie_example_design_inst_pipe_sim_only_txswing11),         //   input,   width = 1,           .txswing11
		.txswing12                 (pcie_example_design_inst_pipe_sim_only_txswing12),         //   input,   width = 1,           .txswing12
		.txswing13                 (pcie_example_design_inst_pipe_sim_only_txswing13),         //   input,   width = 1,           .txswing13
		.txswing14                 (pcie_example_design_inst_pipe_sim_only_txswing14),         //   input,   width = 1,           .txswing14
		.txswing15                 (pcie_example_design_inst_pipe_sim_only_txswing15),         //   input,   width = 1,           .txswing15
		.phystatus8                (dut_pcie_tb_hip_pipe_phystatus8),                          //  output,   width = 1,           .phystatus8
		.phystatus9                (dut_pcie_tb_hip_pipe_phystatus9),                          //  output,   width = 1,           .phystatus9
		.phystatus10               (dut_pcie_tb_hip_pipe_phystatus10),                         //  output,   width = 1,           .phystatus10
		.phystatus11               (dut_pcie_tb_hip_pipe_phystatus11),                         //  output,   width = 1,           .phystatus11
		.phystatus12               (dut_pcie_tb_hip_pipe_phystatus12),                         //  output,   width = 1,           .phystatus12
		.phystatus13               (dut_pcie_tb_hip_pipe_phystatus13),                         //  output,   width = 1,           .phystatus13
		.phystatus14               (dut_pcie_tb_hip_pipe_phystatus14),                         //  output,   width = 1,           .phystatus14
		.phystatus15               (dut_pcie_tb_hip_pipe_phystatus15),                         //  output,   width = 1,           .phystatus15
		.rxdata8                   (dut_pcie_tb_hip_pipe_rxdata8),                             //  output,  width = 32,           .rxdata8
		.rxdata9                   (dut_pcie_tb_hip_pipe_rxdata9),                             //  output,  width = 32,           .rxdata9
		.rxdata10                  (dut_pcie_tb_hip_pipe_rxdata10),                            //  output,  width = 32,           .rxdata10
		.rxdata11                  (dut_pcie_tb_hip_pipe_rxdata11),                            //  output,  width = 32,           .rxdata11
		.rxdata12                  (dut_pcie_tb_hip_pipe_rxdata12),                            //  output,  width = 32,           .rxdata12
		.rxdata13                  (dut_pcie_tb_hip_pipe_rxdata13),                            //  output,  width = 32,           .rxdata13
		.rxdata14                  (dut_pcie_tb_hip_pipe_rxdata14),                            //  output,  width = 32,           .rxdata14
		.rxdata15                  (dut_pcie_tb_hip_pipe_rxdata15),                            //  output,  width = 32,           .rxdata15
		.rxdatak8                  (dut_pcie_tb_hip_pipe_rxdatak8),                            //  output,   width = 4,           .rxdatak8
		.rxdatak9                  (dut_pcie_tb_hip_pipe_rxdatak9),                            //  output,   width = 4,           .rxdatak9
		.rxdatak10                 (dut_pcie_tb_hip_pipe_rxdatak10),                           //  output,   width = 4,           .rxdatak10
		.rxdatak11                 (dut_pcie_tb_hip_pipe_rxdatak11),                           //  output,   width = 4,           .rxdatak11
		.rxdatak12                 (dut_pcie_tb_hip_pipe_rxdatak12),                           //  output,   width = 4,           .rxdatak12
		.rxdatak13                 (dut_pcie_tb_hip_pipe_rxdatak13),                           //  output,   width = 4,           .rxdatak13
		.rxdatak14                 (dut_pcie_tb_hip_pipe_rxdatak14),                           //  output,   width = 4,           .rxdatak14
		.rxdatak15                 (dut_pcie_tb_hip_pipe_rxdatak15),                           //  output,   width = 4,           .rxdatak15
		.rxelecidle8               (dut_pcie_tb_hip_pipe_rxelecidle8),                         //  output,   width = 1,           .rxelecidle8
		.rxelecidle9               (dut_pcie_tb_hip_pipe_rxelecidle9),                         //  output,   width = 1,           .rxelecidle9
		.rxelecidle10              (dut_pcie_tb_hip_pipe_rxelecidle10),                        //  output,   width = 1,           .rxelecidle10
		.rxelecidle11              (dut_pcie_tb_hip_pipe_rxelecidle11),                        //  output,   width = 1,           .rxelecidle11
		.rxelecidle12              (dut_pcie_tb_hip_pipe_rxelecidle12),                        //  output,   width = 1,           .rxelecidle12
		.rxelecidle13              (dut_pcie_tb_hip_pipe_rxelecidle13),                        //  output,   width = 1,           .rxelecidle13
		.rxelecidle14              (dut_pcie_tb_hip_pipe_rxelecidle14),                        //  output,   width = 1,           .rxelecidle14
		.rxelecidle15              (dut_pcie_tb_hip_pipe_rxelecidle15),                        //  output,   width = 1,           .rxelecidle15
		.rxstatus8                 (dut_pcie_tb_hip_pipe_rxstatus8),                           //  output,   width = 3,           .rxstatus8
		.rxstatus9                 (dut_pcie_tb_hip_pipe_rxstatus9),                           //  output,   width = 3,           .rxstatus9
		.rxstatus10                (dut_pcie_tb_hip_pipe_rxstatus10),                          //  output,   width = 3,           .rxstatus10
		.rxstatus11                (dut_pcie_tb_hip_pipe_rxstatus11),                          //  output,   width = 3,           .rxstatus11
		.rxstatus12                (dut_pcie_tb_hip_pipe_rxstatus12),                          //  output,   width = 3,           .rxstatus12
		.rxstatus13                (dut_pcie_tb_hip_pipe_rxstatus13),                          //  output,   width = 3,           .rxstatus13
		.rxstatus14                (dut_pcie_tb_hip_pipe_rxstatus14),                          //  output,   width = 3,           .rxstatus14
		.rxstatus15                (dut_pcie_tb_hip_pipe_rxstatus15),                          //  output,   width = 3,           .rxstatus15
		.rxvalid8                  (dut_pcie_tb_hip_pipe_rxvalid8),                            //  output,   width = 1,           .rxvalid8
		.rxvalid9                  (dut_pcie_tb_hip_pipe_rxvalid9),                            //  output,   width = 1,           .rxvalid9
		.rxvalid10                 (dut_pcie_tb_hip_pipe_rxvalid10),                           //  output,   width = 1,           .rxvalid10
		.rxvalid11                 (dut_pcie_tb_hip_pipe_rxvalid11),                           //  output,   width = 1,           .rxvalid11
		.rxvalid12                 (dut_pcie_tb_hip_pipe_rxvalid12),                           //  output,   width = 1,           .rxvalid12
		.rxvalid13                 (dut_pcie_tb_hip_pipe_rxvalid13),                           //  output,   width = 1,           .rxvalid13
		.rxvalid14                 (dut_pcie_tb_hip_pipe_rxvalid14),                           //  output,   width = 1,           .rxvalid14
		.rxvalid15                 (dut_pcie_tb_hip_pipe_rxvalid15),                           //  output,   width = 1,           .rxvalid15
		.rxdataskip8               (dut_pcie_tb_hip_pipe_rxdataskip8),                         //  output,   width = 1,           .rxdataskip8
		.rxdataskip9               (dut_pcie_tb_hip_pipe_rxdataskip9),                         //  output,   width = 1,           .rxdataskip9
		.rxdataskip10              (dut_pcie_tb_hip_pipe_rxdataskip10),                        //  output,   width = 1,           .rxdataskip10
		.rxdataskip11              (dut_pcie_tb_hip_pipe_rxdataskip11),                        //  output,   width = 1,           .rxdataskip11
		.rxdataskip12              (dut_pcie_tb_hip_pipe_rxdataskip12),                        //  output,   width = 1,           .rxdataskip12
		.rxdataskip13              (dut_pcie_tb_hip_pipe_rxdataskip13),                        //  output,   width = 1,           .rxdataskip13
		.rxdataskip14              (dut_pcie_tb_hip_pipe_rxdataskip14),                        //  output,   width = 1,           .rxdataskip14
		.rxdataskip15              (dut_pcie_tb_hip_pipe_rxdataskip15),                        //  output,   width = 1,           .rxdataskip15
		.rxblkst8                  (dut_pcie_tb_hip_pipe_rxblkst8),                            //  output,   width = 1,           .rxblkst8
		.rxblkst9                  (dut_pcie_tb_hip_pipe_rxblkst9),                            //  output,   width = 1,           .rxblkst9
		.rxblkst10                 (dut_pcie_tb_hip_pipe_rxblkst10),                           //  output,   width = 1,           .rxblkst10
		.rxblkst11                 (dut_pcie_tb_hip_pipe_rxblkst11),                           //  output,   width = 1,           .rxblkst11
		.rxblkst12                 (dut_pcie_tb_hip_pipe_rxblkst12),                           //  output,   width = 1,           .rxblkst12
		.rxblkst13                 (dut_pcie_tb_hip_pipe_rxblkst13),                           //  output,   width = 1,           .rxblkst13
		.rxblkst14                 (dut_pcie_tb_hip_pipe_rxblkst14),                           //  output,   width = 1,           .rxblkst14
		.rxblkst15                 (dut_pcie_tb_hip_pipe_rxblkst15),                           //  output,   width = 1,           .rxblkst15
		.rxsynchd8                 (dut_pcie_tb_hip_pipe_rxsynchd8),                           //  output,   width = 2,           .rxsynchd8
		.rxsynchd9                 (dut_pcie_tb_hip_pipe_rxsynchd9),                           //  output,   width = 2,           .rxsynchd9
		.rxsynchd10                (dut_pcie_tb_hip_pipe_rxsynchd10),                          //  output,   width = 2,           .rxsynchd10
		.rxsynchd11                (dut_pcie_tb_hip_pipe_rxsynchd11),                          //  output,   width = 2,           .rxsynchd11
		.rxsynchd12                (dut_pcie_tb_hip_pipe_rxsynchd12),                          //  output,   width = 2,           .rxsynchd12
		.rxsynchd13                (dut_pcie_tb_hip_pipe_rxsynchd13),                          //  output,   width = 2,           .rxsynchd13
		.rxsynchd14                (dut_pcie_tb_hip_pipe_rxsynchd14),                          //  output,   width = 2,           .rxsynchd14
		.rxsynchd15                (dut_pcie_tb_hip_pipe_rxsynchd15),                          //  output,   width = 2,           .rxsynchd15
		.currentcoeff8             (pcie_example_design_inst_pipe_sim_only_currentcoeff8),     //   input,  width = 18,           .currentcoeff8
		.currentcoeff9             (pcie_example_design_inst_pipe_sim_only_currentcoeff9),     //   input,  width = 18,           .currentcoeff9
		.currentcoeff10            (pcie_example_design_inst_pipe_sim_only_currentcoeff10),    //   input,  width = 18,           .currentcoeff10
		.currentcoeff11            (pcie_example_design_inst_pipe_sim_only_currentcoeff11),    //   input,  width = 18,           .currentcoeff11
		.currentcoeff12            (pcie_example_design_inst_pipe_sim_only_currentcoeff12),    //   input,  width = 18,           .currentcoeff12
		.currentcoeff13            (pcie_example_design_inst_pipe_sim_only_currentcoeff13),    //   input,  width = 18,           .currentcoeff13
		.currentcoeff14            (pcie_example_design_inst_pipe_sim_only_currentcoeff14),    //   input,  width = 18,           .currentcoeff14
		.currentcoeff15            (pcie_example_design_inst_pipe_sim_only_currentcoeff15),    //   input,  width = 18,           .currentcoeff15
		.currentrxpreset8          (pcie_example_design_inst_pipe_sim_only_currentrxpreset8),  //   input,   width = 3,           .currentrxpreset8
		.currentrxpreset9          (pcie_example_design_inst_pipe_sim_only_currentrxpreset9),  //   input,   width = 3,           .currentrxpreset9
		.currentrxpreset10         (pcie_example_design_inst_pipe_sim_only_currentrxpreset10), //   input,   width = 3,           .currentrxpreset10
		.currentrxpreset11         (pcie_example_design_inst_pipe_sim_only_currentrxpreset11), //   input,   width = 3,           .currentrxpreset11
		.currentrxpreset12         (pcie_example_design_inst_pipe_sim_only_currentrxpreset12), //   input,   width = 3,           .currentrxpreset12
		.currentrxpreset13         (pcie_example_design_inst_pipe_sim_only_currentrxpreset13), //   input,   width = 3,           .currentrxpreset13
		.currentrxpreset14         (pcie_example_design_inst_pipe_sim_only_currentrxpreset14), //   input,   width = 3,           .currentrxpreset14
		.currentrxpreset15         (pcie_example_design_inst_pipe_sim_only_currentrxpreset15), //   input,   width = 3,           .currentrxpreset15
		.txsynchd8                 (pcie_example_design_inst_pipe_sim_only_txsynchd8),         //   input,   width = 2,           .txsynchd8
		.txsynchd9                 (pcie_example_design_inst_pipe_sim_only_txsynchd9),         //   input,   width = 2,           .txsynchd9
		.txsynchd10                (pcie_example_design_inst_pipe_sim_only_txsynchd10),        //   input,   width = 2,           .txsynchd10
		.txsynchd11                (pcie_example_design_inst_pipe_sim_only_txsynchd11),        //   input,   width = 2,           .txsynchd11
		.txsynchd12                (pcie_example_design_inst_pipe_sim_only_txsynchd12),        //   input,   width = 2,           .txsynchd12
		.txsynchd13                (pcie_example_design_inst_pipe_sim_only_txsynchd13),        //   input,   width = 2,           .txsynchd13
		.txsynchd14                (pcie_example_design_inst_pipe_sim_only_txsynchd14),        //   input,   width = 2,           .txsynchd14
		.txsynchd15                (pcie_example_design_inst_pipe_sim_only_txsynchd15),        //   input,   width = 2,           .txsynchd15
		.txblkst8                  (pcie_example_design_inst_pipe_sim_only_txblkst8),          //   input,   width = 1,           .txblkst8
		.txblkst9                  (pcie_example_design_inst_pipe_sim_only_txblkst9),          //   input,   width = 1,           .txblkst9
		.txblkst10                 (pcie_example_design_inst_pipe_sim_only_txblkst10),         //   input,   width = 1,           .txblkst10
		.txblkst11                 (pcie_example_design_inst_pipe_sim_only_txblkst11),         //   input,   width = 1,           .txblkst11
		.txblkst12                 (pcie_example_design_inst_pipe_sim_only_txblkst12),         //   input,   width = 1,           .txblkst12
		.txblkst13                 (pcie_example_design_inst_pipe_sim_only_txblkst13),         //   input,   width = 1,           .txblkst13
		.txblkst14                 (pcie_example_design_inst_pipe_sim_only_txblkst14),         //   input,   width = 1,           .txblkst14
		.txblkst15                 (pcie_example_design_inst_pipe_sim_only_txblkst15),         //   input,   width = 1,           .txblkst15
		.txdataskip8               (pcie_example_design_inst_pipe_sim_only_txdataskip8),       //   input,   width = 1,           .txdataskip8
		.txdataskip9               (pcie_example_design_inst_pipe_sim_only_txdataskip9),       //   input,   width = 1,           .txdataskip9
		.txdataskip10              (pcie_example_design_inst_pipe_sim_only_txdataskip10),      //   input,   width = 1,           .txdataskip10
		.txdataskip11              (pcie_example_design_inst_pipe_sim_only_txdataskip11),      //   input,   width = 1,           .txdataskip11
		.txdataskip12              (pcie_example_design_inst_pipe_sim_only_txdataskip12),      //   input,   width = 1,           .txdataskip12
		.txdataskip13              (pcie_example_design_inst_pipe_sim_only_txdataskip13),      //   input,   width = 1,           .txdataskip13
		.txdataskip14              (pcie_example_design_inst_pipe_sim_only_txdataskip14),      //   input,   width = 1,           .txdataskip14
		.txdataskip15              (pcie_example_design_inst_pipe_sim_only_txdataskip15),      //   input,   width = 1,           .txdataskip15
		.rate8                     (pcie_example_design_inst_pipe_sim_only_rate8),             //   input,   width = 2,           .rate8
		.rate9                     (pcie_example_design_inst_pipe_sim_only_rate9),             //   input,   width = 2,           .rate9
		.rate10                    (pcie_example_design_inst_pipe_sim_only_rate10),            //   input,   width = 2,           .rate10
		.rate11                    (pcie_example_design_inst_pipe_sim_only_rate11),            //   input,   width = 2,           .rate11
		.rate12                    (pcie_example_design_inst_pipe_sim_only_rate12),            //   input,   width = 2,           .rate12
		.rate13                    (pcie_example_design_inst_pipe_sim_only_rate13),            //   input,   width = 2,           .rate13
		.rate14                    (pcie_example_design_inst_pipe_sim_only_rate14),            //   input,   width = 2,           .rate14
		.rate15                    (pcie_example_design_inst_pipe_sim_only_rate15),            //   input,   width = 2,           .rate15
		.test_in                   (dut_pcie_tb_hip_ctrl_test_in),                             //  output,  width = 67,   hip_ctrl.test_in
		.simu_mode_pipe            (dut_pcie_tb_hip_ctrl_simu_mode_pipe),                      //  output,   width = 1,           .simu_mode_pipe
		.npor                      (dut_pcie_tb_npor_npor),                                    //  output,   width = 1,       npor.npor
		.pin_perst                 (dut_pcie_tb_npor_pin_perst)                                //  output,   width = 1,           .pin_perst
	);


/* Added for DCP */
//for vcs
initial 
begin
`ifdef VCS_S10  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon;
   `endif 
`endif
end        

`ifdef INCLUDE_DDR4
   ofs_fim_emif_mem_if ddr4_mem [1:0] (); //added by ashish
   //ofs_fim_emif_mem_if ddr4_mem [3:0] ();
`endif

initial #10000 PCIE_RESET_N = 1;
always #5000 SYS_REFCLK = ~SYS_REFCLK; // 100MHz
always #5000 PCIE_REFCLK = ~PCIE_REFCLK; // 100MHz
// always #1600 ETH_RefClk = ~ETH_RefClk; // 3125.. MHz
always #775 ETH_RefClk = ~ETH_RefClk; // 322.265.. MHz
always #1875 DDR4_Refclk = ~DDR4_Refclk; // 266.666.. Mhz

iofs_top DUT (
  // .SYS_REFCLK   (SYS_REFCLK),
 //  .PCIE_REFCLK  (PCIE_REFCLK),
 //  .PCIE_RESET_N (PCIE_RESET_N),
   .SYS_RefClk   (SYS_REFCLK),
   .PCIE_RefClk  (PCIE_REFCLK),
   .PCIE_Rst_n (PCIE_RESET_N),
`ifdef INCLUDE_HSSI
   .qsfp1_644_53125_clk     (ETH_RefClk),
   .qsfp1_rx_serial (rx_serial_data_loopback),
   .qsfp1_tx_serial (tx_serial_data_loopback),
   .qsfp_3v0_port_en (),
 `endif
`ifdef INCLUDE_DDR4
   .ddr4_mem     (ddr4_mem),
`endif
 //  .PCIE_RX      (PCIE_RX),
 //  .PCIE_TX      (PCIE_TX),
   //.SPI_SCLK     (),
   //.SPI_CS_L     (),
   //.SPI_MOSI     (),
   //.SPI_MISO     (1'b0)
   .PCIE_Rx      (PCIE_RX),
   .PCIE_Tx      (PCIE_TX),
   .SPI_sclk     (),
   .SPI_cs_l     (),
   .SPI_mosi     (),
   .SPI_miso     (1'b0)
);
// HSSI serial loopback
`ifdef INCLUDE_HSSI
    if (NUM_CHANNELS >1)
    begin
        //perform circle looopback ,for example: NUM_CHANNELS = 4
		// tx_serial_data[0] = rx_serial_data[1]= serial_data_loopback[0]
		// tx_serial_data[1] = rx_serial_data[2]= serial_data_loopback[1]    ---> tx_serial_data = serial_data_loopback
		// tx_serial_data[2] = rx_serial_data[3]= serial_data_loopback[2]         rx_serial_data = {serial_data_loopback[NUM_CHANNELS-2:0], serial_data_loopback[NUM_CHANNELS-1]}
		// tx_serial_data[3] = rx_serial_data[0]= serial_data_loopback[3] 
		  
		assign rx_serial_data_loopback = {tx_serial_data_loopback[NUM_CHANNELS-2:0], tx_serial_data_loopback[NUM_CHANNELS-1]};
    end
    else
    begin
		assign rx_serial_data_loopback = tx_serial_data_loopback;
    end
`endif
endmodule
