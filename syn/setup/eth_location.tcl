# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# HSSI pin and location assignments
#
#-----------------------------------------------------------------------------
#####################################################
# QSFP / Ethernet
#####################################################
# Pin and location assignments
set_location_assignment PIN_Y28 -to qsfp_3v0_port_en
set_location_assignment PIN_W28 -to qsfp_3v0_port_int_n

set_location_assignment PIN_H34 -to qsfp1_644_53125_clk
set_location_assignment PIN_F38 -to qsfp1_tx_serial[0]
set_location_assignment PIN_C32 -to qsfp1_rx_serial[0]
set_location_assignment PIN_C40 -to qsfp1_tx_serial[1]
set_location_assignment PIN_B30 -to qsfp1_rx_serial[1]
set_location_assignment PIN_B38 -to qsfp1_tx_serial[2]
set_location_assignment PIN_A28 -to qsfp1_rx_serial[2]
set_location_assignment PIN_A36 -to qsfp1_tx_serial[3]
set_location_assignment PIN_D30 -to qsfp1_rx_serial[3]

# set_location_assignment PIN_AD34 -to qsfp0_644_53125_clk
# set_location_assignment PIN_AG40 -to qsfp0_tx_serial[0]
# set_location_assignment PIN_AG36 -to qsfp0_rx_serial[0]
# set_location_assignment PIN_AF42 -to qsfp0_tx_serial[1]
# set_location_assignment PIN_AD38 -to qsfp0_rx_serial[1]
# set_location_assignment PIN_AD42 -to qsfp0_tx_serial[2]
# set_location_assignment PIN_AB38 -to qsfp0_rx_serial[2]
# set_location_assignment PIN_AC40 -to qsfp0_tx_serial[3]
# set_location_assignment PIN_AC36 -to qsfp0_rx_serial[3]

#set_location_assignment PIN_AG29 -to ETH_RefClk
#set_instance_assignment -name IO_STANDARD LVDS -to ETH_RefClk
#set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to ETH_RefClk

#####################################################
# Fitter assignments
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp1_rx_serial -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp1_tx_serial -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp1_rx_serial[*] -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp1_tx_serial[*] -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp0_rx_serial -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp0_tx_serial -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp0_rx_serial[*] -entity ofs_fim
set_instance_assignment -name GXB_0PPM_CORECLK ON -to qsfp0_tx_serial[*] -entity ofs_fim
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp1_rx_serial -entity ofs_fim
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp1_tx_serial -entity ofs_fim
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp1_rx_serial[*] -entity ofs_fim
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp1_tx_serial[*] -entity ofs_fim
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_1V -to qsfp1_rx_serial[*] -entity ofs_fim
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_1V -to qsfp1_tx_serial[*] -entity ofs_fim
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp0_rx_serial -entity ofs_fim
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp0_tx_serial -entity ofs_fim
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp0_rx_serial[*] -entity ofs_fim
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp0_tx_serial[*] -entity ofs_fim
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_1V -to qsfp0_rx_serial[*] -entity ofs_fim
set_instance_assignment -name XCVR_VCCR_VCCT_VOLTAGE 1_1V -to qsfp0_tx_serial[*] -entity ofs_fim
set_instance_assignment -name IO_STANDARD LVDS -to qsfp1_644_53125_clk -entity ofs_fim
set_instance_assignment -name IO_STANDARD LVDS -to "qsfp1_644_53125_clk(n)" -entity ofs_fim
set_instance_assignment -name IO_STANDARD LVDS -to qsfp0_644_53125_clk -entity ofs_fim
set_instance_assignment -name IO_STANDARD LVDS -to "qsfp0_644_53125_clk(n)" -entity ofs_fim
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to qsfp_3v0_port_en -entity ofs_fim
set_instance_assignment -name USE_AS_3V_GPIO ON -to qsfp_3v0_port_en
set_instance_assignment -name IO_STANDARD "3.0-V LVCMOS" -to qsfp_3v0_port_int_n -entity ofs_fim
set_instance_assignment -name USE_AS_3V_GPIO ON -to qsfp_3v0_port_int_n

