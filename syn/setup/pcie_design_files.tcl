# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/

#--------------------
# PCIE IP
#--------------------
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/qip/pcie_ep_g3x16.ip

#--------------------
# PCIE bridge
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_checker.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pipeline/axis_reg_pcie_txs.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge_htile.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge_htile.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge_ptile.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge_ptile.sv

#----------
# PCIE CSR
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_csr.sv

#----------
# PCIE top
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_flr_resync.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_msix_resync.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_wrapper.sv

#----------
# PCIE Adapter
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/axi_s_adapter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_ch0_align_tx.sv

#----------
# PCIE Tx Arbiter
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_arbiter.sv


#----------
# SDC
#----------
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/pcie_top.sdc
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/dcfifo.sdc

