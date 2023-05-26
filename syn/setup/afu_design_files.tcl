# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#--------------------
# AFU modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_pcie_ss_plat_cfg_pkg.sv

#--------------------
# AFU Top
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/afu_top.sv


#--------------------
# Common sources
#--------------------
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/afu_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/afu_design_files.tcl


#--------------------
# Port Gasket modules
#--------------------
# SDC
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/user_clock.sdc
# Synthetic timing constraints on user clock to achieve user-defined frequencies.
# *** This must follow the user clock IP. ***
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/setup_user_clock_for_pr.sdc

set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/par/he_hssi.sdc

#--------------------
# MSIX modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/pcie_mux_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/fme_msix_table.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_filter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_fme_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_pba_update.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_user_irq.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_wrapper.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/interrupt/msix_csr.sv
