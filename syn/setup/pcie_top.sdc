# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
#   Platform top level SDC 
#
#-----------------------------------------------------------------------------

#**************************************************************
# IP/Quartus Workaround
#**************************************************************
# Disable min_pulse_width check for known failure in PCIe Gen3x16 IP (case:590754) 
#disable_min_pulse_width [get_clocks {pcie_wrapper|pcie_top|dut|dut|altera_pcie_s10_hip_ast_pipen1b_inst|altera_pcie_s10_hip_ast_pllnphy_inst|g_phy_g3x16.phy_g3x16|phy_g3x16|tx_pcs_x2_clk|ch0}]
disable_min_pulse_width [get_clocks {pcie_wrapper|pcie_top|dut|pcie_s10_hip_ast_0|altera_pcie_s10_hip_ast_pipen1b_inst|altera_pcie_s10_hip_ast_pllnphy_inst|g_phy_g3x16.phy_g3x16|phy_g3x16|tx_pcs_x2_clk|ch0}]


