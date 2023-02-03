# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# Import the standard exerciser sources. Some AFUs, especially default
# test AFUs, may use them.
#

set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes

#--------------------
# HE LPBK modules
#--------------------
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_lb/files_quartus.tcl

#--------------------
#HE_HSSI modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/he_hssi_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/eth_traffic_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/top_direct_green_bs/eth_traffic_pcie_tlp_to_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/top_direct_green_bs/pcie_tlp_to_csr_no_dma.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/eth_traffic_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/multi_port_axi_traffic_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/multi_port_traffic_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/traffic_controller_wrapper.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/eth_std_traffic_controller_top.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback.sv
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback_csr.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_gen.v 
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback.sv 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback_csr.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_mon.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_prtmux.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/eth_std_traffic_controller_top.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/shiftreg_ctrl.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/shiftreg_data.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/avalon_st_to_crc_if_bridge.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/bit_endian_converter.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/byte_endian_converter.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc_checksum_aligner.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc_comparator.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_calculator.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_chk.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_gen.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc_ethernet.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc_register.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat8.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat16.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat24.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat32.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat32_any_byte.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat40.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat48.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat56.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat64.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat64_any_byte.v 
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/xor6.v
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/common/lib/fifo/sc_fifo_tx_sc_fifo.ip

#--------------------
# SDC
#--------------------

#set_global_assignment -name SDC_FILE ../setup/he_lb.sdc
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/par/he_hssi.sdc
