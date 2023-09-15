// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   SPI master bridge
//
//-----------------------------------------------------------------------------

module spi_bridge_top  (
                        input  wire clk_2x,
                        input  wire clk_1x,
                        input  wire rst_n_1x,
                        input  wire rst_n_2x,

                        input  wire spi_miso,
                        output wire spi_mosi,
                        output wire spi_s_clk,
                        output wire spi_cs_l,

                        ofs_fim_axi_mmio_if.slave  csr_if
                        );

   wire                                     spi_miso_sel;

   wire                                     spi_rden;
   wire                                     spi_wren;
   wire [02:00]                             spi_address;
   wire [31:00]                             spi_readdata;
   wire [31:00]                             spi_writedata;
   reg                                      spi_readdata_valid;

   reg                                      spi_rden_r1;
   reg                                      spi_wren_r1;
   reg                                      spi_rden_1x;
   reg                                      spi_wren_1x;
   reg                                      spi_rden_1x_r1;
   reg                                      spi_wren_1x_r1;
   wire                                     spi_rden_1x_pulse_2_clocks_wide;
   wire                                     spi_wren_1x_pulse_2_clocks_wide;

   always @(posedge clk_1x) begin
      spi_readdata_valid <= spi_rden_1x_r1;
   end

   //--------------------------------------------------------------------------------------------------
   // Instantiate an Avalon MM slave to SPI master bridge to enable the communication with the MAX10 BMC
   // Both read_n and write_n are active-low signals while reset_reset is active-high
   //--------------------------------------------------------------------------------------------------
   spi_bridge spi_bridge  (
                           .clk_clk                          (clk_1x),             //   input,  width =  1,                    clk.clk
                           .reset_reset                      (~rst_n_1x),          //   input,  width =  1,                  reset.reset
                           .spi_0_external_MISO              (spi_miso),           //   input,  width =  1,         spi_0_external.MISO
                           .spi_0_external_MOSI              (spi_mosi),           //  output,  width =  1,                       .MOSI
                           .spi_0_external_SCLK              (spi_s_clk),          //  output,  width =  1,                       .SCLK
                           .spi_0_external_SS_n              (spi_cs_l),           //  output,  width =  1,                       .SS_n
                           .spi_0_irq_irq                    (),                   //  output,  width =  1,              spi_0_irq.irq
                           .spi_0_spi_control_port_writedata (spi_writedata),      //   input,  width = 32, spi_0_spi_control_port.writedata
                           .spi_0_spi_control_port_readdata  (spi_readdata),       //  output,  width = 32,                       .readdata
                           .spi_0_spi_control_port_address   (spi_address),        //   input,  width =  3,                       .address
                           .spi_0_spi_control_port_read_n    (~spi_rden_1x_pulse_2_clocks_wide),       //   input,  width =  1,                       .read_n
                           .spi_0_spi_control_port_chipselect(1'b1),               //   input,  width =  1,                       .chipselect
                           .spi_0_spi_control_port_write_n   (~spi_wren_1x_pulse_2_clocks_wide)        //   input,  width =  1,                       .write_n
                           );

   spi_bridge_csr spi_bridge_csr (
      .axi (csr_if),

      .spi_rden           (spi_rden),
      .spi_wren           (spi_wren),
      .spi_address        (spi_address),
      .spi_writedata      (spi_writedata),
      .spi_readdata_valid (spi_readdata_valid),
      .spi_readdata       (spi_readdata),
      .spi_miso_sel       (spi_miso_sel) // not used anymore because the spi_debug is no longer supported.
      );


   // make pulses at the 1x clock domaind
   always @(posedge clk_2x) begin
      spi_rden_r1 <= spi_rden;
      spi_wren_r1 <= spi_wren;
   end

   //Because of a bug in the master ip, the rden and wren pulse must be 2 1x-clock cycles long
   always @(posedge clk_1x) begin
      spi_rden_1x    <= spi_rden | spi_rden_r1;
      spi_wren_1x    <= spi_wren | spi_wren_r1;
      spi_rden_1x_r1 <= spi_rden_1x;
      spi_wren_1x_r1 <= spi_wren_1x;
   end
   assign spi_rden_1x_pulse_2_clocks_wide = spi_rden_1x | spi_rden_1x_r1;
   assign spi_wren_1x_pulse_2_clocks_wide = spi_wren_1x | spi_wren_1x_r1;

endmodule
