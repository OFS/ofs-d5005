# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# no special sdc constraints needed.
# FUTURE_IMPROVEMENT markdte (there are warnings in the auto-generated constraints (ip))

# Create generated clock at sclk port derived from SCLK_reg pin

create_generated_clock \
 -source [get_pins {pmci_top|spi_bridge_top|spi_bridge|spi_0|spi_0|SCLK_reg|clk}] \
 -divide_by 10 -multiply_by 1 -duty_cycle 50 -phase 0 -offset 0 \
 -name spi_sclk_internal [get_pins {pmci_top|spi_bridge_top|spi_bridge|spi_0|spi_0|SCLK_reg|q}]

create_generated_clock \
 -source [get_pins {pmci_top|spi_bridge_top|spi_bridge|spi_0|spi_0|SCLK_reg|q}] \
 -name spi_sclk [get_ports {SPI_sclk}]

# setup multicycle constraints

set_multicycle_path 5 -setup -start -from sys_pll|iopll_0_clk1x -to spi_sclk
set_multicycle_path 5 -setup -end -from spi_sclk -to sys_pll|iopll_0_clk1x

set_multicycle_path 9 -hold -start -from sys_pll|iopll_0_clk1x -to spi_sclk
set_multicycle_path 9 -hold -end -from spi_sclk -to sys_pll|iopll_0_clk1x

set_output_delay -clock spi_sclk -clock_fall -min  0 [get_ports {SPI_mosi}]
set_output_delay -clock spi_sclk -clock_fall -max 7 [get_ports {SPI_mosi}]

set_output_delay -clock spi_sclk -clock_fall -min  0 [get_ports {SPI_mosi}]
set_output_delay -clock spi_sclk -clock_fall -max 15 [get_ports {SPI_mosi}]

set_input_delay -clock spi_sclk -min 0  [get_ports {SPI_miso}]
set_input_delay -clock spi_sclk -max 15  [get_ports {SPI_miso}]

# False path for chip select.IP chip select is active at least 1 full clock cycle before clock is active.
set_false_path -to [get_ports {SPI_cs_l}]

# False path CDC
set_false_path -from [get_clocks {spi_sclk}] -to [get_clocks {sys_pll|iopll_0_clk_125M}]
set_false_path -from [get_clocks {sys_pll|iopll_0_clk_125M}] -to [get_clocks {spi_sclk}]
