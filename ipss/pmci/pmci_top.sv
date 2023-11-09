// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// This module instantiates the Platform Management Interface Controllers
//-----------------------------------------------------------------------------

module pmci_top #(
parameter ADDR_WIDTH  = 10,
parameter DATA_WIDTH  = 64,
parameter WSTRB_WIDTH = (DATA_WIDTH/8)
)(
input clk_1x,
input rst_n_1x,
input clk_div2,
input rst_n_div2,

ofs_fim_axi_lite_if.slave csr_lite_if,

input  spi_miso,
output spi_mosi,
output spi_s_clk,
output spi_cs_l
);

//-------------------------------------
// Internal signals and interfaces
//-------------------------------------

ofs_fim_axi_mmio_if csr_mmio_if();

//-------------------------------------
// Modules instances
//-------------------------------------

axi_lite2mmio axi_lite2mmio (
.clk    (clk_1x),
.rst_n  (rst_n_1x),
.lite_if(csr_lite_if),
.mmio_if(csr_mmio_if)
);

spi_bridge_top spi_bridge_top (
.clk_2x     (clk_1x     ),
.rst_n_2x   (rst_n_1x   ),

.clk_1x     (clk_div2   ),
.rst_n_1x   (rst_n_div2 ),

.spi_miso   (spi_miso   ),
.spi_mosi   (spi_mosi   ),
.spi_s_clk  (spi_s_clk  ),
.spi_cs_l   (spi_cs_l   ),

.csr_if     (csr_mmio_if)
);
 
endmodule
