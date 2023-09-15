# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# PCIe pin and location assignments
#
#-----------------------------------------------------------------------------

set_instance_assignment -name IO_STANDARD "3.0-V LVTTL" -to PCIE_Rst_n
set_location_assignment PIN_AC26 -to PCIE_Rst_n

set_instance_assignment -name IO_STANDARD HCSL -to PCIE_RefClk
set_location_assignment PIN_AM34 -to  PCIE_RefClk
set_location_assignment PIN_AM33 -to "PCIE_RefClk(n)"

set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_Tx[*]
set_location_assignment PIN_BB34 -to PCIE_Tx[0]
set_location_assignment PIN_BA36 -to PCIE_Tx[1]
set_location_assignment PIN_BB38 -to PCIE_Tx[2]
set_location_assignment PIN_AY38 -to PCIE_Tx[3]
set_location_assignment PIN_BA40 -to PCIE_Tx[4]
set_location_assignment PIN_AV38 -to PCIE_Tx[5]
set_location_assignment PIN_AW40 -to PCIE_Tx[6]
set_location_assignment PIN_AV42 -to PCIE_Tx[7]
set_location_assignment PIN_AU40 -to PCIE_Tx[8]
set_location_assignment PIN_AT42 -to PCIE_Tx[9]
set_location_assignment PIN_AR40 -to PCIE_Tx[10]
set_location_assignment PIN_AP42 -to PCIE_Tx[11]
set_location_assignment PIN_AN40 -to PCIE_Tx[12]
set_location_assignment PIN_AM42 -to PCIE_Tx[13]
set_location_assignment PIN_AL40 -to PCIE_Tx[14]
set_location_assignment PIN_AK42 -to PCIE_Tx[15]

set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to PCIE_Rx[*]
set_location_assignment PIN_AV30 -to PCIE_Rx[0]
set_location_assignment PIN_AY30 -to PCIE_Rx[1]
set_location_assignment PIN_BB30 -to PCIE_Rx[2]
set_location_assignment PIN_AW32 -to PCIE_Rx[3]
set_location_assignment PIN_BA32 -to PCIE_Rx[4]
set_location_assignment PIN_AY34 -to PCIE_Rx[5]
set_location_assignment PIN_AU36 -to PCIE_Rx[6]
set_location_assignment PIN_AW36 -to PCIE_Rx[7]
set_location_assignment PIN_AR36 -to PCIE_Rx[8]
set_location_assignment PIN_AN36 -to PCIE_Rx[9]
set_location_assignment PIN_AT38 -to PCIE_Rx[10]
set_location_assignment PIN_AP38 -to PCIE_Rx[11]
set_location_assignment PIN_AL36 -to PCIE_Rx[12]
set_location_assignment PIN_AM38 -to PCIE_Rx[13]
set_location_assignment PIN_AK38 -to PCIE_Rx[14]
set_location_assignment PIN_AJ36 -to PCIE_Rx[15]

