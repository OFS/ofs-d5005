##
## Top-level AFU sources specification.
##
## Import AFU interfaces from the FIM as well as the AFU sources.
##

# FIM-provided configuration scripts
set FIM_SCRIPT_DIR "../setup"

##### Paths were sources are found

set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/src/includes
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes

##### Interfaces and definitions

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/pf_vf_mux_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/mux/top_cfg_pkg.sv
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/afu_if_design_files.tcl

##### AFU <- Keep this tag. The pattern is used by scripts to update AFU sources.

# OPAE_PLATFORM_GEN is set when a script is generating the PR build environment
# used with OPAE SDK tools. The Verilog macro is consumed in the PIM variant
# of afu_main, causing afu_main to act as a simple template that defines the module
# but doesn't include an actual AFU.
if { [info exist env(OPAE_PLATFORM_GEN) ] } {
    # In OPAE_PLATFORM_GEN mode, no additional sources are loaded. The goal is
    # to configure the minimal environment required to define AFU interfaces and
    # instantiate the top-level PR module.
    set_global_assignment -name VERILOG_MACRO OPAE_PLATFORM_GEN
} else {
    # In non-OPAE_PLATFORM_GEN mode, a sample PR AFU is configured using the
    # FIM-provided exercisers. These sources are required for those exercisers,
    # but are unlikely to be required by other AFUs.
    set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/src
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/common_design_files.tcl
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/pcie_design_files.tcl
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/eth_design_files.tcl
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/fme_design_files.tcl
    set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/afu_design_files.tcl
}

# Import a specific AFU
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${FIM_SCRIPT_DIR}/afu_main.tcl