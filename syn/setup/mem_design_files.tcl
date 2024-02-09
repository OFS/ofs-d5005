# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#--------------------
# Packages
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/d5005/mem/rtl/mc_ha_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/includes/ofs_fim_emif_if.sv

#--------------------
# EMIF IP
#--------------------
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/d5005/mem/qip/emif_8GB_2400/emif_8GB_2400.ip

#--------------------
# Other IP
#--------------------
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/d5005/mem/qip/reqfifo/reqfifo.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/d5005/mem/qip/rspfifo/rspfifo.ip


#--------------------
# Memory Controller RTL
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_channel.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_emif_poison.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_mmr_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mc_rmw_shim.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/mem_intf.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/emif_8GB_2400/mem_wrapper.sv

#----------
# SDC
#----------
#set_global_assignment -name SDC_FILE ../../syn/mem/sdc/s10/mc_top.sdc

