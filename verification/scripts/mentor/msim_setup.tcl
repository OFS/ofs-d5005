# Copyright (C) 2001-2021 Intel Corporation
# SPDX-License-Identifier: MIT

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     config_reset_release.config_reset_release
#     cfg_mon.cfg_mon
#     sys_pll.sys_pll
#     avst_pipeline_st_pipeline_stage_0.avst_pipeline_st_pipeline_stage_0
#     avst_pipeline_st_pipeline_stage_1.avst_pipeline_st_pipeline_stage_1
#     PR_IP.PR_IP
#     qph_user_clk_iopll_s10_RF100M.qph_user_clk_iopll_s10_RF100M
#     qph_user_clk_iopll_reconfig.qph_user_clk_iopll_reconfig
#     remote_debug_jtag_only_clock_in.remote_debug_jtag_only_clock_in
#     host_if.host_if
#     jop_blaster.jop_blaster
#     remote_debug_jtag_only_reset_in.remote_debug_jtag_only_reset_in
#     sys_clk.sys_clk
#     pcie_ep_g3x16.pcie_ep_g3x16
#     address_decode_clk_csr.address_decode_clk_csr
#     address_decode_master_0.address_decode_master_0
#     address_decode_merlin_master_translator_0.address_decode_merlin_master_translator_0
#     address_decode_mm_to_mac.address_decode_mm_to_mac
#     address_decode_mm_to_phy.address_decode_mm_to_phy
#     address_decode_rx_xcvr_clk.address_decode_rx_xcvr_clk
#     address_decode_tx_xcvr_clk.address_decode_tx_xcvr_clk
#     address_decode_tx_xcvr_half_clk.address_decode_tx_xcvr_half_clk
#     altera_eth_10g_mac.altera_eth_10g_mac
#     altera_eth_10gbaser_phy.altera_eth_10gbaser_phy
#     altera_xcvr_atx_pll_ip.altera_xcvr_atx_pll_ip
#     pll.pll
#     reset_control.reset_control
#     spi_bridge_reset_in.spi_bridge_reset_in
#     spi_bridge_spi_0.spi_bridge_spi_0
#     spi_bridge_clock_in.spi_bridge_clock_in
#     fme_id_rom.fme_id_rom
#     apf_clock_bridge.apf_clock_bridge
#     apf_reset_bridge.apf_reset_bridge
#     apf_bpf_mst.apf_bpf_mst
#     apf_bpf_slv.apf_bpf_slv
#     apf_st2mm_mst.apf_st2mm_mst
#     apf_st2mm_slv.apf_st2mm_slv
#     apf_pgsk_slv.apf_pgsk_slv
#     apf_achk_slv.apf_achk_slv
#     apf_rsv_b_slv.apf_rsv_b_slv
#     apf_rsv_c_slv.apf_rsv_c_slv
#     apf_rsv_d_slv.apf_rsv_d_slv
#     apf_rsv_e_slv.apf_rsv_e_slv
#     apf_rsv_f_slv.apf_rsv_f_slv
#     bpf_clock_bridge.bpf_clock_bridge
#     bpf_reset_bridge.bpf_reset_bridge
#     bpf_apf_mst.bpf_apf_mst
#     bpf_apf_slv.bpf_apf_slv
#     bpf_fme_mst.bpf_fme_mst
#     bpf_fme_slv.bpf_fme_slv
#     bpf_pmci_slv.bpf_pmci_slv
#     bpf_pcie_slv.bpf_pcie_slv
#     bpf_emif_slv.bpf_emif_slv
#     bpf_hssi_slv.bpf_hssi_slv
#     bpf_rsv_5_slv.bpf_rsv_5_slv
#     bpf_rsv_6_slv.bpf_rsv_6_slv
#     bpf_rsv_7_slv.bpf_rsv_7_slv
#     emif_ddr4_no_ecc.emif_ddr4_no_ecc
#     avmm_cdc.avmm_cdc
#     avmm_pipeline_bridge.avmm_pipeline_bridge
#     remote_debug_jtag_only.remote_debug_jtag_only
#     address_decode.address_decode
#     spi_bridge.spi_bridge
#     apf.apf
#     bpf.bpf
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Intel simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "mentor.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
# #
# # Source the generated IP simulation script.
# source $QSYS_SIMDIR/mentor/msim_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
# dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
# com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog <compilation options> <design and testbench files>
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
# elab
# #
# # Run the simulation.
# run -a
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# ACDS 21.1 169 linux 2021.09.22.02:17:28

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "bpf.bpf"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "/p/psg/swip/releases2/acds/21.1/169/linux64/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_VHDL_COMPILE_OPTIONS] { 
  set USER_DEFINED_VHDL_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_VERILOG_COMPILE_OPTIONS] { 
  set USER_DEFINED_VERILOG_COMPILE_OPTIONS ""
}

if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

if ![info exists SILENCE] { 
  set SILENCE "false"
}

if ![info exists FORCE_MODELSIM_AE_SELECTION] { 
  set FORCE_MODELSIM_AE_SELECTION "false"
}

# ----------------------------------------
# Source Common Tcl File
source $QSYS_SIMDIR/common/modelsim_files.tcl


# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
set LD_LIBRARY_PATH [dict create]
if { ![ string match "*-64 vsim*" [ vsimVersionString ] ] } {
  set SIMULATOR_TOOL_BITNESS "bit_32"
} else {
  set SIMULATOR_TOOL_BITNESS "bit_64"
}
set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
if {[dict size $LD_LIBRARY_PATH] !=0 } {
  set LD_LIBRARY_PATH [subst [join [dict keys $LD_LIBRARY_PATH] ":"]]
  setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH"
}
append ELAB_OPTIONS [subst [get_elab_options $SIMULATOR_TOOL_BITNESS]]
append SIM_OPTIONS [subst [get_sim_options $SIMULATOR_TOOL_BITNESS]]

proc modelsim_ae_select {force_select_modelsim_ae} {
  if [string is true -strict $force_select_modelsim_ae] {
    return 1
  }
  return [string match -nocase "*Intel*FPGA*" [ vsimVersionString ]]

}


# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] file_copy"
  }
  set memory_files [list]
  set memory_files [concat $memory_files [get_memory_files "$QSYS_SIMDIR"]]
  foreach file $memory_files { file copy -force $file ./ }
}

# ----------------------------------------
# Create compilation libraries

set logical_libraries [list "work" "work_lib" "altera_ver" "lpm_ver" "sgate_ver" "altera_mf_ver" "altera_lnsim_ver" "fourteennm_ver" "fourteennm_hssi_ver"]

proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib          ./libraries/     
ensure_lib          ./libraries/work/
vmap       work     ./libraries/work/
vmap       work_lib ./libraries/work/
if [string is false -strict [modelsim_ae_select $FORCE_MODELSIM_AE_SELECTION]] {
  ensure_lib                     ./libraries/altera_ver/         
  vmap       altera_ver          ./libraries/altera_ver/         
  ensure_lib                     ./libraries/lpm_ver/            
  vmap       lpm_ver             ./libraries/lpm_ver/            
  ensure_lib                     ./libraries/sgate_ver/          
  vmap       sgate_ver           ./libraries/sgate_ver/          
  ensure_lib                     ./libraries/altera_mf_ver/      
  vmap       altera_mf_ver       ./libraries/altera_mf_ver/      
  ensure_lib                     ./libraries/altera_lnsim_ver/   
  vmap       altera_lnsim_ver    ./libraries/altera_lnsim_ver/   
  ensure_lib                     ./libraries/fourteennm_ver/     
  vmap       fourteennm_ver      ./libraries/fourteennm_ver/     
  ensure_lib                     ./libraries/fourteennm_hssi_ver/
  vmap       fourteennm_hssi_ver ./libraries/fourteennm_hssi_ver/
}
set design_libraries [dict create]
set design_libraries [dict merge $design_libraries [get_design_libraries]]
set libraries [dict keys $design_libraries]
foreach library $libraries {
  ensure_lib ./libraries/$library/
  vmap $library  ./libraries/$library/
  lappend logical_libraries $library
}

# ----------------------------------------
# Compile device library files
alias dev_com {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] dev_com"
  }
  if [string is false -strict [modelsim_ae_select $FORCE_MODELSIM_AE_SELECTION]] {
    eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"               -work altera_ver         
    eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                        -work lpm_ver            
    eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                           -work sgate_ver          
    eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                       -work altera_mf_ver      
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                   -work altera_lnsim_ver   
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/fourteennm_atoms.sv"               -work fourteennm_ver     
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/fourteennm_atoms_ncrypt.sv" -work fourteennm_ver     
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hssi_atoms.sv"                 -work fourteennm_hssi_ver
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/ct1_hssi_atoms_ncrypt.sv"   -work fourteennm_hssi_ver
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/ct1_hip_atoms.sv"                  -work fourteennm_hssi_ver
    eval  vlog -sv  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/ct1_hip_atoms_ncrypt.sv"    -work fourteennm_hssi_ver
  }
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] com"
  }
  set design_files [dict create]
  set design_files [dict merge [get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
  set common_design_files [dict values $design_files]
  foreach file $common_design_files {
    eval $file
  }
  set design_files [list]
  set design_files [concat $design_files [get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR"]]
  foreach file $design_files {
    eval $file
  }
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] elab"
  }
  set elabcommand " $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS"
  foreach library $logical_libraries { append elabcommand " -L $library" }
  append elabcommand " $TOP_LEVEL_NAME"
  eval vsim $elabcommand
}

# ----------------------------------------
# Elaborate the top level design with -voptargs=+acc option
alias elab_debug {
  if [string is false -strict $SILENCE] {
    echo "\[exec\] elab_debug"
  }
  set elabcommand " $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS"
  foreach library $logical_libraries { append elabcommand " -L $library" }
  append elabcommand " $TOP_LEVEL_NAME"
  eval vsim -voptargs=+acc $elabcommand
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with  -voptargs=+acc
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                                         -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                                           -- Compile device library files"
  echo
  echo "com                                               -- Compile the design files in correct order"
  echo
  echo "elab                                              -- Elaborate top level design"
  echo
  echo "elab_debug                                        -- Elaborate the top level design with -voptargs=+acc option"
  echo
  echo "ld                                                -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                                          -- Compile all the design files and elaborate the top level design with  -voptargs=+acc"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                                    -- Top level module name."
  echo "                                                     For most designs, this should be overridden"
  echo "                                                     to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME                              -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                                       -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR                               -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS                      -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VHDL_COMPILE_OPTIONS                 -- User-defined vhdl compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VERILOG_COMPILE_OPTIONS              -- User-defined verilog compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS                         -- User-defined elaboration options, added to elab/elab_debug aliases."
  echo
  echo "SILENCE                                           -- Set to true to suppress all informational and/or warning messages in the generated simulation script. "
  echo
  echo "FORCE_MODELSIM_AE_SELECTION                       -- Set to true to force to select Modelsim AE always."
}
file_copy
h
