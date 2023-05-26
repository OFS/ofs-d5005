// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   Top level testbench with OFS top level module instantiated as DUT
//
//-----------------------------------------------------------------------------

`include "vendor_defines.vh"
`include "fpga_defines.vh"

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_eth_if_pkg:: NUM_LANES;
import top_cfg_pkg::*;

module top_tb ();

logic SYS_REFCLK;
logic PCIE_REFCLK0;
logic PCIE_REFCLK1;
logic PCIE_RESET_N;
logic ETH_REFCLK;

localparam NUM_ETH_CHANNELS        = 1; 

wire spi_sclk;
wire spi_cs_l;
wire spi_data;

initial begin
   SYS_REFCLK   = 0;
   PCIE_REFCLK0 = 0;
   PCIE_REFCLK1 = 0;
   PCIE_RESET_N = 0;
   ETH_REFCLK   = 0;
end

initial 
begin
`ifdef VCD_ON  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon();
   `endif 
`endif
end        

ofs_fim_emif_mem_if ddr4_mem [NUM_MEM_CH-1:0] ();// [3:0] ();
`ifdef INCLUDE_HSSI
// HSSI serial data for loopback
logic [NUM_LANES-1:0] qsfp1_lpbk_serial;

`endif

initial #2us PCIE_RESET_N = 1; //  IOPLL sim model requires at least 1us of reset
always #5ns SYS_REFCLK   = ~SYS_REFCLK;   // 100MHz
always #5ns PCIE_REFCLK0 = ~PCIE_REFCLK0; // 100MHz
always #5ns PCIE_REFCLK1 = ~PCIE_REFCLK1; // 100MHz
always #775ps  ETH_REFCLK   = ~ETH_REFCLK;   // 


iofs_top DUT (
    .SYS_RefClk             ( SYS_REFCLK        ),
    .PCIE_RefClk            ( PCIE_REFCLK0      ),
    .PCIE_Rst_n             ( PCIE_RESET_N      ),

    .PCIE_Rx                ( '0                ),
    .PCIE_Tx                (                   ),

    .SPI_sclk               (spi_sclk           ),
    .SPI_cs_l               (spi_cs_l           ),
    .SPI_mosi               (spi_data           ),
    .SPI_miso               (spi_data           ),

 `ifdef INCLUDE_HSSI
    .qsfp_3v0_port_en       (                   ),
    .qsfp1_644_53125_clk    ( ETH_REFCLK        ),
    .qsfp1_tx_serial        ( qsfp1_lpbk_serial ),
    .qsfp1_rx_serial        ( qsfp1_lpbk_serial ),
 `endif

    .ddr4_mem               ( ddr4_mem          )     
);

   
endmodule

