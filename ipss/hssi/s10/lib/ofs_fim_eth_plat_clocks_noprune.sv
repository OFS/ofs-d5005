// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// For use in green_bs: consume and preserve Ethernet PR clocks.
//  
//-----------------------------------------------------------------------------

module ofs_fim_eth_plat_clocks_noprune (   
   input ofs_fim_eth_plat_if_pkg::t_eth_clocks eth_clocks
);

   (* noprune *) logic clk_q1, clk_q2;
   always_ff @(posedge eth_clocks.clk) begin
      clk_q1 <= clk_q2;
      clk_q2 <= ~clk_q1;

      // Generally force 0 when not in reset to reduce power (the opposite of normal)
      if (eth_clocks.rst_n) begin
         clk_q1 <= 1'b0;
      end
   end

   (* noprune *) logic clkDiv2_q1, clkDiv2_q2;
   always_ff @(posedge eth_clocks.clkDiv2) begin
      clkDiv2_q1 <= clkDiv2_q2;
      clkDiv2_q2 <= ~clkDiv2_q1;

      // Generally force 0 when not in reset to reduce power (the opposite of normal)
      if (eth_clocks.rstDiv2_n) begin
         clkDiv2_q1 <= 1'b0;
      end
   end

endmodule // ofs_fim_eth_plat_clocks_noprune
