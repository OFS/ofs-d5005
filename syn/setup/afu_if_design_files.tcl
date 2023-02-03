# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

#
# Wrapper around all scripts that import AFU interface definitions. These
# are used by both FIM and PR builds.
#

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_fim_axi_mmio_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_fim_axi_lite_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/emif_avmm_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_fim_pwrgoodn_if.sv

##

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_fim_cfg_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/ofs_fim_if_pkg.sv
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/AFU_debug/config_reset_release.ip

# Directory of script
set THIS_DIR [file dirname [info script]]

# Include files
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/src/includes
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes

set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "${THIS_DIR}/eth_afu_if_design_files.tcl"
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "${THIS_DIR}/emif_afu_if_design_files.tcl"
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "${THIS_DIR}/pcie_afu_if_design_files.tcl"
