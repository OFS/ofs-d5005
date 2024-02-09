# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# Ethernet
#--------------------

set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/lib/ofs_fim_eth_plat_clocks_noprune.sv
#set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/d5005/eth/s10/includes/ofs_fim_eth_plat_if_pkg.sv 

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/lib/bridge/ofs_fim_eth_afu_avst_to_fim_axis_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/lib/bridge/ofs_fim_eth_sb_afu_avst_to_fim_axis_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/lib/bridge/ofs_fim_eth_axis_connect.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/lib/pipeline/pr_eth_axis_if_reg.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/hssi_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/hssi_stats_sync.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/av_axi_st_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/altera_eth_10g_mac_base_r_wrap.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/resync.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/mm_ctrl_xcvr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/hssi_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/eth_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/eth_ac_wrapper.sv

set_global_assignment -name QSYS_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/address_decode.qsys
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_clk_csr.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_master_0.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_merlin_master_translator_0.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_mac.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_phy.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_rx_xcvr_clk.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_clk.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_half_clk.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/mac/altera_eth_10g_mac.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/phy/altera_eth_10gbaser_phy.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/pll_atxpll/altera_xcvr_atx_pll_ip.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/pll_mpll/pll.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/ip/xcvr_reset_controller/reset_control.ip

# SDC
set_global_assignment -name SDC_FILE     $::env(BUILD_ROOT_REL)/syn/setup/eth_top.sdc
