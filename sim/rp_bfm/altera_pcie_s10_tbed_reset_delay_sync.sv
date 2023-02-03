// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altera_pcie_s10_tbed_reset_delay_sync #(
   parameter ACTIVE_RESET           = 0,
   parameter WIDTH_RST              = 1,
   parameter NODENAME               = "altera_pcie_s10_tbed_reset_delay_sync",// Expecting Instance name
   parameter LOCK_TIME_CNT_WIDTH    = 1
) (
   input clk,
   input async_rst,
   output reg [WIDTH_RST-1:0] sync_rst /* synthesis preserve */
);

wire sync_rst_clk;
localparam SDC={"-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *", NODENAME ,"*rs_meta\[*\]] -to [get_keepers *", NODENAME ,"*rs_meta\[*\]]\" "};


(* altera_attribute = SDC *)
reg [2:0] rs_meta = (ACTIVE_RESET==0)?3'b000:3'b111 /* synthesis preserve dont_replicate */;

// synthesis translate_off
initial begin
   sync_rst[WIDTH_RST-1:0]={WIDTH_RST{1'b0}};
   $display("INFO:         altera_pcie_s10_tbed_reset_delay_sync::---------------------------------------------------------------------------------------------");
   $display("INFO:         altera_pcie_s10_tbed_reset_delay_sync:: NODENAME is %s", NODENAME);
   $display("INFO:         altera_pcie_s10_tbed_reset_delay_sync:: SDC is %s", SDC);
   rs_meta = (ACTIVE_RESET==0)?3'b000:3'b111;
end
// synthesis translate_on

always @(posedge clk) begin
   sync_rst[WIDTH_RST-1:0] <= {WIDTH_RST{sync_rst_clk}};
end

generate begin : g_rstsync
   if (ACTIVE_RESET==0) begin : g_rstsync
      always @(posedge clk or negedge async_rst) begin
         if (!async_rst) rs_meta <= 3'b000;
         else rs_meta <= {rs_meta[1:0],1'b1};
      end

      if (LOCK_TIME_CNT_WIDTH>1) begin : g_rstsync1
         wire ready_sync = rs_meta[2];
         reg [LOCK_TIME_CNT_WIDTH-1:0] cntr = {LOCK_TIME_CNT_WIDTH{1'b0}} /* synthesis preserve */;
         assign sync_rst_clk = cntr[LOCK_TIME_CNT_WIDTH-1];

         always @(posedge clk) begin
              sync_rst[WIDTH_RST-1:0] <= {WIDTH_RST{sync_rst_clk}};
         end
         always @(posedge clk or negedge ready_sync) begin
            if (!ready_sync) cntr <= {LOCK_TIME_CNT_WIDTH{1'b0}};
            else if (!sync_rst_clk) cntr <= cntr + 1'b1;
         end
      end
      else begin : g_rstsync2
         assign sync_rst_clk = rs_meta[2];
      end
   end

   else begin : g_rstsync3 // ACTIVE_RESET=1
      always @(posedge clk or posedge async_rst) begin
         if (async_rst) rs_meta <= 3'b111;
         else rs_meta <= {rs_meta[1:0],1'b0};
      end
      if (LOCK_TIME_CNT_WIDTH>1) begin : g_rstsync4
         wire ready_sync = rs_meta[2];
         wire sync_rst_clkn ;
         reg [LOCK_TIME_CNT_WIDTH-1:0] cntr = {LOCK_TIME_CNT_WIDTH{1'b0}} /* synthesis preserve */;
         assign sync_rst_clk=~sync_rst_clk;
         assign sync_rst_clkn = cntr[LOCK_TIME_CNT_WIDTH-1];
         always @(posedge clk or posedge ready_sync) begin
            if (ready_sync) cntr <= {LOCK_TIME_CNT_WIDTH{1'b0}};
            else if (!sync_rst_clkn) cntr <= cntr + 1'b1;
         end
      end
      else begin : g_rstsync5
         assign sync_rst_clk = rs_meta[2];
      end
   end
end
endgenerate

endmodule
