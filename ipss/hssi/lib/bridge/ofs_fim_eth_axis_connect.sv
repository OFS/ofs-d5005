// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Wire together two instances of Ethernet AXI-S interfaces.
//
//-----------------------------------------------------------------------------

module ofs_fim_eth_axis_connect_rx (
   ofs_fim_eth_rx_axis_if.master to_afu,
   ofs_fim_eth_rx_axis_if.slave  to_fim
);

   assign to_afu.clk = to_fim.clk;
   assign to_afu.rst_n = to_fim.rst_n;
   assign to_fim.tready = to_afu.tready;
   assign to_afu.rx = to_fim.rx;

endmodule // ofs_fim_eth_axis_connect_rx


module ofs_fim_eth_axis_connect_tx (
   ofs_fim_eth_tx_axis_if.slave  to_afu,
   ofs_fim_eth_tx_axis_if.master to_fim
);

   assign to_afu.clk = to_fim.clk;
   assign to_afu.rst_n = to_fim.rst_n;
   assign to_afu.tready = to_fim.tready;
   assign to_fim.tx = to_afu.tx;

endmodule // ofs_fim_eth_axis_connect_tx


module ofs_fim_eth_axis_connect_sb_rx (
   ofs_fim_eth_sideband_rx_axis_if.master to_afu,
   ofs_fim_eth_sideband_rx_axis_if.slave  to_fim
);

   assign to_afu.clk = to_fim.clk;
   assign to_afu.rst_n = to_fim.rst_n;
   assign to_afu.sb = to_fim.sb;

endmodule // ofs_fim_eth_axis_connect_sb_rx


module ofs_fim_eth_axis_connect_sb_tx (
   ofs_fim_eth_sideband_tx_axis_if.slave  to_afu,
   ofs_fim_eth_sideband_tx_axis_if.master to_fim
);

   assign to_afu.clk = to_fim.clk;
   assign to_afu.rst_n = to_fim.rst_n;
   assign to_fim.sb = to_afu.sb;

endmodule // ofs_fim_eth_axis_connect_sb_tx
