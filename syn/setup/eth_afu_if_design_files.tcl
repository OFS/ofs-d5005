# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# Ethernet interfaces passed to AFUs. These files are used by both FIM and PR builds.
#
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/s10/includes/ofs_fim_eth_plat_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/inc/ofs_fim_eth_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/inc/ofs_fim_eth_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/inc/ofs_fim_eth_avst_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/inc/ofs_fim_eth_avst_if.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_avst_if.sv
