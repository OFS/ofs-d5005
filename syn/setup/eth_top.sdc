# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#-----------------------------------------------------------------------------
# Description
#-----------------------------------------------------------------------------
#
#   Eth Top SDC 
#
#-----------------------------------------------------------------------------

#--------------------
# Common procedures
#--------------------
proc add_reset_sync_sdc { pin_name } {
   set_max_delay -to [get_pins $pin_name] 100.000
   set_min_delay -to [get_pins $pin_name] -100.000
   #set_max_skew  -to [get_pins $pin_name] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 
}

proc add_sync_sdc { name } {
   set_max_delay -to [get_keepers $name] 100.000
   set_min_delay -to [get_keepers $name] -100.000
}

#---------------------------------------------
# CDC constraints for reset synchronizers
#---------------------------------------------

#---------------------------------------------
# CDC constraints for synchronizers
#---------------------------------------------
add_sync_sdc {eth_ac_wrapper|eth_top|*|altera_reset_synchronizer_int_chain[*]}
add_sync_sdc {eth_ac_wrapper|eth_top|*|altera_reset_synchronizer_int_chain_out}
add_sync_sdc {eth_ac_wrapper|eth_top|*|resync_chains[*].synchronizer_nocut|din_s1}

add_sync_sdc {*|he_hssi_top_inst|*|resync_chains[*].synchronizer_nocut|din_s1}

set_false_path -from {rst_ctrl|rst_clk1x_sync|dreg[*]} -to {*|he_hssi_top_inst|GenRstSync[0].tx_reset_synchronizer|resync_chains[0].synchronizer|dreg[*]}  
set_false_path -from {rst_ctrl|rst_clk1x_sync|dreg[*]} -to {*|he_hssi_top_inst|GenRstSync[0].tx_reset_synchronizer|resync_chains[0].synchronizer|din_s1} -setup 


# 100G
set CLK100      [get_clocks sys_pll|iopll_0_clk_100M]
set CLK250      [get_clocks sys_pll|iopll_0_clk_250M]
set TX_CORE_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|xcvr|tx_clkout2|ch1]
set RX_CORE_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|xcvr|rx_clkout2|ch1]

# RSFEC clocks
set RX_RS_CORE_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|WITH_FEC.fecpll|RXIOPLL_INST.fecrxpll|alt_e100s10ex_iopll_rx_outclk0]
set RX_RS_CORE_NCK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|WITH_FEC.fecpll|RXIOPLL_INST.fecrxpll|alt_e100s10ex_iopll_rx_n_cnt_clk]
set TX_RS_CORE_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|WITH_FEC.fecpll|TXPLL_IN.TXFPLL_INST.tx_pll_gen.fectxpll|clkdiv_output_div1]

set_clock_groups -asynchronous -group -group $TX_CORE_CLK -group $CLK100
set_clock_groups -asynchronous -group -group $TX_CORE_CLK -group $CLK250
set_clock_groups -asynchronous -group -group $RX_CORE_CLK -group $CLK100

set_clock_groups -asynchronous -group $TX_CORE_CLK -group $RX_CORE_CLK -group -group $CLK100 -group $RX_RS_CORE_CLK -group $TX_RS_CORE_CLK -group $RX_RS_CORE_NCK

for {set chNum 0} {$chNum < 4} {incr chNum} {
  set RX_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|xcvr|rx_pcs_x2_clk|ch$chNum] 
  set TX_CLK [get_clocks eth_ac_wrapper|eth_top|CHANNEL[0].eth_channel|ll_100g_ethernet_inst|alt_e100s10_0|xcvr|tx_pcs_x2_clk|ch$chNum]

  set_clock_groups -asynchronous -group $TX_CLK -group $CLK100 -group
  set_clock_groups -asynchronous -group $RX_CLK -group $CLK100 -group
 
}
