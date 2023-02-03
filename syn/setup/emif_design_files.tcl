# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# EMIF
#--------------------

# Library and package
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/ipss/mem/includes

# EMIF design files 
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/custom_altera_avalon_mm_bridge.v
set_global_assignment -name VERILOG_FILE       $::env(BUILD_ROOT_REL)/ipss/mem/ddr_avmm_bridge.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mem_intf.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/emif_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/avmm_chkr/avmm_chkr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/emif_top.sv

# EMIF IP
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/ip/emif_ddr4_no_ecc.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/ip/avmm_cdc.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/ip/avmm_pipeline_bridge.ip

# SDC
set_global_assignment -name SDC_FILE ../setup/emif_top.sdc
