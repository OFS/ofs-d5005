# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
#   Platform top level SDC
#
#-----------------------------------------------------------------------------
proc add_reset_sync_sdc { pin_name } {
   set_max_delay -to [get_pins $pin_name] 100.000
   set_min_delay -to [get_pins $pin_name] -100.000
   #set_max_skew  -to [get_pins $pin_name] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 
}

proc add_sync_sdc { name } {
   set_max_delay -to [get_keepers $name] 100.000
   set_min_delay -to [get_keepers $name] -100.000
}

#**************************************************************
# Create Clock
#**************************************************************
derive_clock_uncertainty

create_clock -name qsfp1_644_53125_clk    -period 1.552   -waveform {0.000  0.776} [get_ports {qsfp1_644_53125_clk}]
create_clock -name qsfp0_644_53125_clk    -period 1.552   -waveform {0.000  0.776} [get_ports {qsfp0_644_53125_clk}]
create_clock -name {altera_reserved_tck}  -period 100.000 -waveform {0.000 50.000} [get_ports {altera_reserved_tck}]

#**************************************************************
# Set Clock Groups
#************************************************************** 
set_clock_groups -asynchronous -group {altera_reserved_tck}

#---------------------------------------------  
# CDC constraints for reset synchronizers
#---------------------------------------------
add_reset_sync_sdc {*|rst_clk100_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {*|rst_clk1x_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {*|rst_clk2x_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {*|pwr_good_n_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|rx_cdc|rx_avst_dcfifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|rx_cdc|rx_avst_dcfifo|dcfifo|dcfifo_component|auto_generated|wraclr|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|tx_cdc|tx_axis_dcfifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|tx_cdc|tx_axis_dcfifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_sync_sdc {afu_top|port_gasket|remote_stp_top_inst|remote_debug_jtag_only|*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[1]} 
#-----------------------------------------------------------------------------------------------------------------------------------------------
# CDCs...
#-----------------------------------------------------------------------------------------------------------------------------------------------

if {$::quartus(nameofexecutable) != "quartus_sta"} {                                # constraints for synthesis
       set_max_delay                                                -to *_cal_*_sync_*                             10ns
       set_max_delay                                                -to *resync_chains*synchronizer*|din*          10ns   
       set_max_delay                                                -to *dcfifo_*dffpipe_*aclr|dffe*a[*]           10ns
       set_max_delay  -from  *softreset*                            -to *pr_slot|rst_p0_tx_sync|d*                 10ns
       set_max_delay  -from  rst_n_e_1x                             -to *pr_slot|rst_p0_tx_sync|d*                 10ns
       set_max_delay  -from  rst_n_b_1x                             -to *pcie_bridge_cdc*dcfifo*|*aclr|dff*        10ns
       set_max_delay  -from *qph_user_clk_freq|prescaler[*]         -to *qph_user_clk_freq|smpclk_meta             10ns
       set_max_delay  -from *pr_freeze[*]                           -to *pr_freeze_sync|*                          10ns
       set_max_delay  -from *pcie_flr*launch[*]                     -to *pcie_flr*capture[*]                       10ns
       set_max_delay  -from *pcie_top*dcfifo*|*delayed_wrptr_g*     -to *pcie_top*dcfifo*|*rs_dgwp*                10ns
       set_max_delay  -from *pcie_top*dcfifo*|*rdptr_g*             -to *pcie_top*dcfifo*|*ws_dgrp*                10ns
       set_max_delay  -from *altera_iopll_i*pll~pll_e_reg__nff      -to *rst_ctrl|*                                10ns
       set_max_delay  -from *pcie_top*pcie_s10_hip*reset_*_reg*     -to *rst_ctrl|*                                10ns

       set_min_delay                                                -to *_cal_*_sync_*                            -100ns
       set_min_delay                                                -to *resync_chains*synchronizer*|din*         -100ns   
       set_min_delay                                                -to *dcfifo_*dffpipe_*aclr|dffe*a[*]          -100ns
       set_min_delay  -from  *softreset*                            -to *pr_slot|rst_p0_tx_sync|d*                -100ns
       set_min_delay  -from  rst_n_e_1x                             -to *pr_slot|rst_p0_tx_sync|d*                -100ns
       set_min_delay  -from  rst_n_b_1x                             -to *pcie_bridge_cdc*dcfifo*|*aclr|dff*       -100ns
       set_min_delay  -from *qph_user_clk_freq|prescaler[*]         -to *qph_user_clk_freq|smpclk_meta            -100ns
       set_min_delay  -from *pr_freeze[*]                           -to *pr_freeze_sync|*                         -100ns
       set_min_delay  -from *pcie_flr*launch[*]                     -to *pcie_flr*capture[*]                      -100ns
       set_min_delay  -from *pcie_top*dcfifo*|*delayed_wrptr_g*     -to *pcie_top*dcfifo*|*rs_dgwp*               -100ns
       set_min_delay  -from *pcie_top*dcfifo*|*rdptr_g*             -to *pcie_top*dcfifo*|*ws_dgrp*               -100ns
       set_min_delay  -from *altera_iopll_i*pll~pll_e_reg__nff      -to *rst_ctrl|*                               -100ns
       set_min_delay  -from *pcie_top*pcie_s10_hip*reset_*_reg*     -to *rst_ctrl|*                               -100ns
} else {                                                                         # contraints for timing report
       set_max_delay                                                -to *_cal_*_sync_*                             100ns
       set_max_delay                                                -to *resync_chains*synchronizer*|din*          100ns   
       set_max_delay                                                -to *dcfifo_*dffpipe_*aclr|dffe*a[*]           100ns
       set_max_delay  -from  *softreset*                            -to *pr_slot|rst_p0_tx_sync|d*                 100ns
       set_max_delay  -from  rst_n_e_1x                             -to *pr_slot|rst_p0_tx_sync|d*                 100ns
       set_max_delay  -from  rst_n_b_1x                             -to *pcie_bridge_cdc*dcfifo*|*aclr|dff*        100ns
       set_max_delay  -from *qph_user_clk_freq|prescaler[*]         -to *qph_user_clk_freq|smpclk_meta             100ns
       set_max_delay  -from *pr_freeze[*]                           -to *pr_freeze_sync|*                          100ns
       set_max_delay  -from *pcie_flr*launch[*]                     -to *pcie_flr*capture[*]                       100ns
       set_max_delay  -from *pcie_top*dcfifo*|*delayed_wrptr_g*     -to *pcie_top*dcfifo*|*rs_dgwp*                100ns
       set_max_delay  -from *pcie_top*dcfifo*|*rdptr_g*             -to *pcie_top*dcfifo*|*ws_dgrp*                100ns
       set_max_delay  -from *altera_iopll_i*pll~pll_e_reg__nff      -to *rst_ctrl|*                                100ns
       set_max_delay  -from *pcie_top*pcie_s10_hip*reset_*_reg*     -to *rst_ctrl|*                                100ns

       set_false_path                                               -to *_cal_*_sync_*                            -hold
       set_false_path                                               -to *resync_chains*synchronizer*|din* 		   -hold   
       set_false_path                                               -to *dcfifo_*dffpipe_*aclr|dffe*a[*]          -hold
       set_false_path -from  *softreset*                            -to *pr_slot|rst_p0_tx_sync|d*                -hold
       set_false_path -from  rst_n_e_1x                             -to *pr_slot|rst_p0_tx_sync|d*                -hold
       set_false_path -from  rst_n_b_1x                             -to *pcie_bridge_cdc*dcfifo*|*aclr|dff*       -hold
       set_false_path -from *qph_user_clk_freq|prescaler[*]         -to *qph_user_clk_freq|smpclk_meta            -hold
       set_false_path -from *pr_freeze[*]                           -to *pr_freeze_sync|*                         -hold
       set_false_path -from *pcie_flr*launch[*]                     -to *pcie_flr*capture[*]                      -hold
       set_false_path -from *pcie_top*dcfifo*|*delayed_wrptr_g*     -to *pcie_top*dcfifo*|*rs_dgwp*               -hold
       set_false_path -from *pcie_top*dcfifo*|*rdptr_g*             -to *pcie_top*dcfifo*|*ws_dgrp*               -hold
       set_false_path -from *altera_iopll_i*pll~pll_e_reg__nff      -to *rst_ctrl|*                               -hold
       set_false_path -from *pcie_top*pcie_s10_hip*reset_*_reg*     -to *rst_ctrl|*                               -hold
}
