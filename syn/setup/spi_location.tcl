# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# SPI Bridge pin and location assignments
#
#-----------------------------------------------------------------------------
set_location_assignment PIN_Y11 -to SPI_sclk
set_location_assignment PIN_W11 -to SPI_cs_l
set_location_assignment PIN_AA12 -to SPI_mosi
set_location_assignment PIN_AA11 -to SPI_miso
set_instance_assignment -name IO_STANDARD "1.8 V" -to SPI_sclk
set_instance_assignment -name IO_STANDARD "1.8 V" -to SPI_cs_l
set_instance_assignment -name IO_STANDARD "1.8 V" -to SPI_mosi
set_instance_assignment -name IO_STANDARD "1.8 V" -to SPI_miso
