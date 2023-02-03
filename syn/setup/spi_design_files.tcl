# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# SPI
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/spi/spi_bridge_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/spi/spi_bridge_csr.sv

#--------------------
# SPI IP
#--------------------
set_global_assignment -name QSYS_FILE ../ip_lib/src/pd_qsys/spi_bridge/spi_bridge.qsys

set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_reset_in.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_spi_0.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_clock_in.ip

#--------------------
# SDC
#--------------------

set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/spi_top.sdc

