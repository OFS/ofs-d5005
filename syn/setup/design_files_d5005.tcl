# Copyright (C) 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

############################################################################################
# OFS IP database
############################################################################################

# Load this first. The script manages a database of IP from which parameters will
# be extracted before synthesis. The parameters are written to header files in
# ofs_ip_cfg_db/.
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE "$::env(BUILD_ROOT_REL)/ofs-common/scripts/common/syn/ip_get_cfg/ofs_ip_cfg_db.tcl"

# Add the constructed IP database to the search path. It will be populated
# by a hook at the end of ipgenerate
set_global_assignment -name SEARCH_PATH "ofs_ip_cfg_db"


## design files and script

### design files_list
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/afu_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/eth_afu_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/emif_afu_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/pcie_afu_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/pmci_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/ofs_common_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/common_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/pcie_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/pcie_location.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/eth_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/eth_location.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/spi_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/spi_location.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/afu_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/apf_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/bpf_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/emif_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/emif_x8_location.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/afu_main.tcl

### Partial Reconfiguration and floorplan
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/syn/setup/sr_logic_lock_region.tcl

### design files 
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/top/rst_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/top/iofs_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/mux/top_cfg_pkg.sv
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/top.sdc

# Generate timing reports during quartus_sta
set_global_assignment -name TIMING_ANALYZER_REPORT_SCRIPT $::env(BUILD_ROOT_REL)/ofs-common/scripts/common/syn/report_timing.tcl

# Generate PR interface ID
set_global_assignment -name MISC_FILE $::env(BUILD_ROOT_REL)/ofs-common/scripts/common/syn/update_fme_ifc_id.py

# Post-process the project between modules. For d5005 there is no platform-specific script.
# Invoke the platform-independent script directly.
set_global_assignment -name POST_MODULE_SCRIPT_FILE "quartus_sh:$::env(BUILD_ROOT_REL)/ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl"
