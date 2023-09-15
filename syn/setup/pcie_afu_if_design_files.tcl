# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# PCIe interfaces passed to AFUs. These files are used by both FIM and PR builds.
#

#--------------------
# Packages
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_hdr_def.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_axis_if.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_pcie_ss_plat_cfg_pkg.sv

set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/pcie_afu_if_design_files.tcl
