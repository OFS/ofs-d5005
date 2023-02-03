// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Deassert AFU reset
task deassert_afu_reset;
   input logic [63:0] func_table;
   input logic [31:0] bar;
   logic [63:0]       scratch;
   logic [31:0]       wdata;
   logic [31:0]       port_control_addr;
   int count;
begin
   port_control_addr = 32'h91038;  //Updated as per R1

   // De-assert Port Reset 
   $display("\nDe-asserting Port Reset...");
   READ64(func_table, bar, port_control_addr, scratch);
   wdata = scratch[31:0];
   wdata[0] = 1'b0;
   WRITE32(func_table, bar, port_control_addr, wdata);
   #5000000 READ64(func_table, bar, port_control_addr, scratch);
   if (scratch[4] != 1'b0) begin
      $display("\nERROR: Port Reset Ack Asserted!");
      ebfm_log_stop_sim(1);       
   end
   
   $display("\nAFU is out of reset..."); 
end
endtask

// Assert AFU reset
task assert_afu_reset;
   input logic [63:0] func_table;
   input logic [31:0] bar;
   logic [63:0]       scratch;
   logic [31:0]       wdata;
   logic [31:0]       port_control_addr;
   int count;
begin
   port_control_addr = 32'h91038;  //Updated as per R1
   count = 0;

   // Put AFU into RESET
   $display("\nAsserting Port Reset...");
   READ64(func_table, bar, port_control_addr, scratch);
   wdata = scratch;
   wdata[0] = 1'b1;
   WRITE32(func_table, bar, port_control_addr, wdata);
   
   // Wait for Port Reset Ack 
   READ64(func_table, bar, port_control_addr, scratch);
   while (scratch[4] != 1'b1 & count < 100) begin
      count++;
      #75000 READ64(func_table, bar, port_control_addr, scratch);
   end 
   if (count == 100) begin
       $display("\nERROR: Port Reset Ack never asserted ...");
       ebfm_log_stop_sim(1);       
   end 
   
   $display("\nAFU is successfully reset..."); 
end
endtask


