// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   This file defines all the test cases for current test.
//
//   main_test() is the main entry function which the tester calls
//   to execute the unit tests.
//
//-----------------------------------------------------------------------------

//-------------------
// Test utilities
//-------------------

import test_csr_defs::*;
import ofs_fim_pcie_pkg::*;  //Added by Ashish
integer err_count = 0;       //Added by Ashish
logic [7:0] exp_err = 0;
reg [31:0] spi_offset = 0;

task incr_test_id;
   begin
      test_id = test_id + 1;
   end
endtask

task post_test_util;
   input logic result;
   begin
      repeat (10)
        @(posedge avl_clk);
      
      @(posedge avl_clk);
      reset_test = 1'b1;
      repeat (5)
        @(posedge avl_clk);
      reset_test = 1'b0;
      
      f_reset_tag();
      
      if (result) begin
         $display("\nTest status: OK");
         test_summary[test_id].result = 1'b1;
      end else begin
         $display("\nTest status: FAILED");
         test_summary[test_id].result = 1'b0;
      end
      incr_test_id();
   end
endtask

task print_test_header;
   input [1024*8-1:0] test_name;
   begin
      $display("\n********************************************");
      $display(" Running TEST(%0d) : %0s", test_id, test_name);
      $display("********************************************");
      test_summary[test_id].name = test_name;
   end
endtask

task verify_err_count;
   output logic result;
   input logic [7:0] exp_err;
   begin
      // Wait 30 clock cycles for checker error to be logged
      repeat (30)
        @(posedge fim_clk);
      
      if (err_count != exp_err)
        begin
           result = 1'b0;
           $display("Failed - expected errors: %0d,  actual errors: %0d", exp_err, err_count);
        end else begin
           result = 1'b1;
           $display("MMIO error count matches: %0d", err_count);
        end
      if (~result)
        test_utils::incr_err_count();
   end
endtask

task verify_mmio_err_count;
   output logic result;
   input logic [7:0] exp_err;
   begin
      // Wait 30 clock cycles for checker error to be logged
      repeat (30)
        @(posedge fim_clk);
      
      if (mmio_err_count != exp_err)
        begin
           result = 1'b0;
           $display("Failed - expected errors: %0d,  actual errors: %0d", exp_err, mmio_err_count);
        end else begin
           result = 1'b1;
           $display("MMIO error count matches: %0d", mmio_err_count);
        end
      if (~result)
        test_utils::incr_err_count();
   end
endtask

//-------------------
// Test main entry
//-------------------
task main_test;
   output logic         test_result;
   
   logic                valid_csr_region;
   logic [31:0]         addr;
   static logic [2:0]   bar = 0;
   static logic                vf_active = 0;
   static logic [PF_WIDTH-1:0] pfn = 0;
   static logic [VF_WIDTH-1:0] vfn = 0;
   logic                error;
   logic [63:0]         scratch;
   static logic                eol = 0;
   
   reg [63:0]           rd_data64;
   reg [63:0]           wr_data64;
   reg [31:0]           rd_data32;
   reg [31:0]           wr_data32;
   reg                  rrdy;
   reg                  trdy;
   reg [31:0]           timer_count;
   reg                  done;
   reg [31:0]           dfh_list_count;
   reg [31:0]           addr_sfp;

   begin : main
      // #########################################
      // Look for the SPI DFH by doing a DFH walk.
      // #########################################
      print_test_header("SPI_DFH_identify");
      //SPI DFH   = 0x43000
      //HSSI DFH  = 0x42000
      //EMIF DFH  = 0x41000
      //PCIE DFH  = 0x40000
      
      //Decode of DFH, 64'h3_00_0_01_000000_0_00E:
      //4’h3          [63:60]: Feature Type
      //8’h0          [59:52]: Reserved
      //4’h0          [51:48]: If AFU - AFU Minor Revision Number (else, reserved)
      //7’h00         [47:41]: Reserved
      //1’h1          [40   ]: EOL (End of DFH list)
      //24’h000000    [39:16]: Next DFH Byte Offset
      //4’h0          [15:12]: If AfU, AFU Major version number (else feature #)
      //12’h00E       [11:0 ]: Feature ID
      
      $display("T:%8d INFO: TEST_PROGRAM Finding the SPI DFH by doing a DFH Walk (BAR0)", $time);
      addr           = 32'h0;
      done           = 0;
      dfh_list_count = 0;
      
      while (!(done)) begin
         READ64(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
         if ((rd_data64[11:0] === 12'h00E) & (rd_data64[63:60] === 4'h3)) begin
            spi_offset = addr;
         end
         if (rd_data64[40]) begin
            done = 1;
            $display("T:%8d INFO: TEST_PROGRAM 0x%08X ->     EOL    (%016X).", $time, addr, rd_data64);
            $display("T:%8d INFO: TEST_PROGRAM Found End Of List (EOL) at :0x%X.", $time, addr);
         end else if (rd_data64[39:16] === 24'h0) begin
            done = 1;
            $display("T:%8d ERROR: TEST_PROGRAM 0x%08X -> Ptr 0 EOL  (%016X).", $time, addr, rd_data64);
            $display("T:%8d ERROR: TEST_PROGRAM Found next pointer zero at :0x%X.", $time, addr);
            test_utils::incr_err_count();
         end else begin
            addr_sfp = addr;
            addr     = addr + rd_data64[39:16];
            $display("T:%8d INFO: TEST_PROGRAM 0x%08X -> 0x%08X (%016X)", $time, addr_sfp, addr, rd_data64);
            dfh_list_count = dfh_list_count + 1;
            if (dfh_list_count > 1000) begin
               $display("T:%8d ERROR: TEST_PROGRAM Did not find \"EOL\" after 1000 walks", $time,);
               test_utils::incr_err_count();
               done   = 1;
            end
         end // else: !if(rd_data64[39:16] === 24'h0)
      end // while (!(done))
      
      if (spi_offset) begin
         $display("T:%8d INFO: TEST_PROGRAM The SPI DFH was found at offset:0x%X", $time, spi_offset);
      end else begin
         $display("T:%8d ERROR: TEST_PROGRAM SPI DFH was not found", $time);
         test_utils::incr_err_count();
      end
      
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
      
      // #######################################
      // Test basic spi cfg accesses.
      // #######################################
      print_test_header("spi_cfg_accesses");
      addr = spi_offset + SPI_WRITEDATA;
      READ64(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
      $display("T:%8d INFO: TEST_PROGRAM %m ADDR:%X, RD_DATA64:%X", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m Completion is returned with unsuccessful status.", $time);
         test_utils::incr_err_count();
      end

      $display("T:%8d INFO: TEST_PROGRAM %m Begin Loop", $time);
      repeat (10) begin
         wr_data64 = {$urandom, $urandom};
         WRITE64(ADDR64, addr, bar, vf_active, pfn, vfn, wr_data64);	
         $display("T:%8d INFO: TEST_PROGRAM %m Writing: ADDR:%X, WR_DATA64:%X", $time, addr, wr_data64);
         
         READ64(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
         $display("T:%8d INFO: TEST_PROGRAM %m ADDR:%X, RD_DATA64:%X", $time, addr, rd_data64);
         if (error) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m Completion is returned with unsuccessful status.", $time);
            test_utils::incr_err_count();
         end
         if ({32'h0, wr_data64[31:0]} !== rd_data64) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, {32'h0, wr_data64[31:0]}, rd_data64);
            test_utils::incr_err_count();
         end
      end
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
      
      // ==================================================
      print_test_header("spi_cfg_accesses_r_w_32_a2_low");
      addr = spi_offset + SPI_CONTROL_ADDR;
      repeat (10) begin
         wr_data64 = {$urandom, $urandom};
         wr_data64 = {wr_data64[63:10], 2'h0, wr_data64[7:0]}; // lets not do any actual SPI bridge registyer accesses.
         WRITE32(ADDR64, addr, bar, vf_active, pfn, vfn, wr_data64);	
         $display("T:%8d INFO: TEST_PROGRAM %m Writing: ADDR:%X, WR_DATA64:%X", $time, addr, wr_data64);
         
         WRITE32(ADDR64, addr+4, bar, vf_active, pfn, vfn, {$urandom, $urandom});	
         $display("T:%8d INFO: TEST_PROGRAM %m Writing to upper32 bits to make sure lower32 bits are not affected.", $time);
         
         READ32(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
         $display("T:%8d INFO: TEST_PROGRAM %m ADDR:%X, RD_DATA64:%X", $time, addr, rd_data64);
         if (error) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m Completion is returned with unsuccessful status.", $time);
            test_utils::incr_err_count();
         end
         if ({61'h0, wr_data64[2:0]} !== rd_data64) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, {54'h0, wr_data64[9:8], 5'h0, wr_data64[2:0]}, rd_data64);
            test_utils::incr_err_count();
         end
      end
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
      
      // ==================================================
      print_test_header("spi_cfg_accesses_r_w_32_a2_high");
      addr = spi_offset + SPI_READDATA + 32'h4;
      repeat (10) begin
         wr_data64 = {$urandom, $urandom};
         WRITE32(ADDR64, addr, bar, vf_active, pfn, vfn, wr_data64);	
         $display("T:%8d INFO: TEST_PROGRAM %m Writing: ADDR:%X, WR_DATA64:%X", $time, addr, wr_data64);
         
         WRITE32(ADDR64, addr-4, bar, vf_active, pfn, vfn, {$urandom, $urandom});	
         $display("T:%8d INFO: TEST_PROGRAM %m Writing to lower32 bits to make sure upper32 bits are not affected.", $time);
         
         READ32(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
         $display("T:%8d INFO: TEST_PROGRAM %m ADDR:%X, RD_DATA64:%X", $time, addr, rd_data64);
         if (error) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m Completion is returned with unsuccessful status.", $time);
            test_utils::incr_err_count();
         end
         if ({63'h0, wr_data64[0]} !== rd_data64) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, {63'h0, wr_data64[0]}, rd_data64);
            test_utils::incr_err_count();
         end
      end
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
      
      // #######################################
      // Test a SPI register exchange...
      // #######################################
      print_test_header("spi_bridge_loopback");
      wr_data32 = 32'h5555AAAA;
      repeat (20) begin
         $display("T:%8d INFO: TEST_PROGRAM %m Testing wr_data32 of:%X", $time, wr_data32);
         write_spi(SPI_BRIDGE_TXDATA, wr_data32);
         
         // spin on RRDY set...
         timer_count = 0;
         rrdy = 0;
         while ((rrdy === 0) & (timer_count < 50)) begin
            read_spi(SPI_BRIDGE_STATUS, rd_data32);
            rrdy = rd_data32[7];
            timer_count = timer_count + 1;
            $display("T:%8d INFO: TEST_PROGRAM %m rrdy:%d, rd_data32:%X", $time, rrdy, rd_data32);
         end
         if (timer_count >= 50) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m Timeout waiting for rrdy", $time);
            test_utils::incr_err_count();
         end
         
         read_spi(SPI_BRIDGE_RXDATA, rd_data32);
         $display("T:%8d INFO: TEST_PROGRAM %m rd_data32 from spi register exchange: ADDR:%X, RD_DATA32:%X", $time, 3'h0, rd_data32);
         if (wr_data32 !== rd_data32) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m EXPECTED:%X RECEIVED:%X", $time, wr_data32, rd_data32);
            test_utils::incr_err_count();
         end
         wr_data32 = $urandom;
      end // repeat (20)
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
      
      // #######################################
      // Test spi unused cfg_space.
      // #######################################
      print_test_header("spi_unused_cfg_space");
      addr = spi_offset + SPI_DFH;
      while (addr < spi_offset + 32'h100) begin
         READ64(ADDR64, addr, bar, vf_active, pfn, vfn, rd_data64, error);	
         $display("T:%8d INFO: TEST_PROGRAM %m ADDR:%X, RD_DATA64:%X error:%d", $time, addr, rd_data64, error);
         addr = addr + 8;
         if (^rd_data64 === 1'bx) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m X's read back from SPI cfg space", $time);
            test_utils::incr_err_count();
         end
      end
      
      verify_err_count(test_result, exp_err);
      post_test_util(test_result);
      exp_err = test_utils::get_err_count();      
   end
endtask


task write_spi;
   input [2:0] addr;
   input [31:0] write_data32;
   
   begin
      WRITE64(ADDR64, spi_offset + SPI_WRITEDATA,    0, 0, 0, 0, write_data32);	
      WRITE64(ADDR64, spi_offset + SPI_CONTROL_ADDR, 0, 0, 0, 0, {56'h1, 5'h0, addr});
      //$display("T:%8d INFO: TEST_PROGRAM %m Wrote SPI ADDR:%x, WRITE_DATA32:%X", $time, addr, write_data32);
   end
endtask // write_spi

task read_spi;
   input [2:0] addr;
   output [31:0] rd_data32;
   
   reg           error;
   
   begin
      WRITE64(ADDR64, spi_offset + SPI_CONTROL_ADDR, 0, 0, 0, 0, {56'h2, 5'h0, addr});	
      READ64 (ADDR64, spi_offset + SPI_READDATA,     0, 0, 0, 0,  rd_data32, error);	
      if (error) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m read_spi: Completion is returned with unsuccessful status.", $time);
         test_utils::incr_err_count();
      end
      //$display("T:%8d INFO: TEST_PROGRAM %m Read SPI ADDR:%x, RD_DATA32:%X", $time, addr, rd_data32);
   end
endtask // write_spi
