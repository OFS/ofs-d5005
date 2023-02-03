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

import test_csr_defs::*;
import ofs_fim_pcie_pkg::*;  //Added by Ashish

//-------------------
// Test utilities
//-------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   logic result;
begin
   if (test_utils::get_err_count() > old_test_err_count) begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

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
// Test cases 
//-------------------
// Test 32-bit CSR access
task test_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR access to unused CSR region
task test_unused_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access
task test_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR read access
task test_csr_read_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR read access
task test_csr_read_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access to unused CSR region
task test_unused_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test MMIO access with 32-bit address 
task test_mmio_addr32;
   output logic result;
begin
   print_test_header("test_mmio_addr32");
   test_mmio(result, ADDR32);
end
endtask

// Test MMIO access with 64-bit address 
task test_mmio_addr64;
   output logic result;
begin
   print_test_header("test_mmio_addr64");
   test_mmio(result, ADDR64);
end
endtask

// Test memory write 32-bit address 
task test_mmio;
   output logic result;
   input e_addr_mode addr_mode;
   logic [63:0] base_addr;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   $display("Test CSR access");
      test_csr_access_32(result, addr_mode, PCIE_SCRATCHPAD, 0, 1'b0, 0, 0, 'h1111_2222);   
      test_csr_access_64(result, addr_mode, PCIE_SCRATCHPAD, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   
      test_csr_access_32(result, addr_mode, PCIE_SCRATCHPAD, 0, 1'b0, 0, 0, 'hAAAA_BBBB);   
      test_csr_access_32(result, addr_mode, PCIE_SCRATCHPAD+3'h4, 0, 1'b0, 0, 0, 'hCCCC_DDDD);   
      test_csr_read_64(result, addr_mode, PCIE_SCRATCHPAD, 0, 1'b0, 0, 0, 'hCCCC_DDDD_AAAA_BBBB);
      test_csr_read_64(result, addr_mode, PCIE_DFH, 0, 1'b0, 0, 0, 'h3000000100000020);
      test_csr_read_64(result, addr_mode, PCIE_STAT, 0, 1'b0, 0, 0, 'h0);

      test_csr_access_64(result, addr_mode, PCIE_ERROR_MASK, 0, 1'b0, 0, 0, 'h3FF);     
      test_csr_access_64(result, addr_mode, PCIE_ERROR_MASK, 0, 1'b0, 0, 0, 'h0);      
   
   $display("Test CSR access to unused CSR region");
      test_unused_csr_access_32(result, addr_mode, PCIE_UNUSED_OFFSET, 0, 1'b0, 0, 0, 'hF00D_0001);
      test_unused_csr_access_64(result, addr_mode, PCIE_UNUSED_OFFSET, 0, 1'b0, 0, 0, 'hF00D_0001_6464_6464);

   verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end
endtask

// Test PCIE error bits in PCIE0_ERROR register 
task test_pcie_err;
   output logic result;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_pcie_err");

   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   @(posedge avl_clk);
//    force DUT.pcie_top.pcie_csr.i_chk_rx_err_code = 32'h1ff;
      force DUT.pcie_wrapper.pcie_top.pcie_csr.i_chk_rx_err_code = 32'h1ff;
   repeat (4)
      @(posedge avl_clk);
  //  release DUT.pcie_top.pcie_csr.i_chk_rx_err_code;
      release DUT.pcie_wrapper.pcie_top.pcie_csr.i_chk_rx_err_code ;

   repeat (20)                                       
      @(posedge avl_clk);

   $display("Reading PCIE_ERROR register in PCIe feature region");
      test_csr_read_32(result, ADDR32, PCIE_ERROR, 0, 1'b0, 0, 0, 32'h1ff);
   
// $display("Writing Reading PCIE_ERROR register in PCIe feature region");                
//    test_csr_access_32(result, ADDR32, PCIE_ERROR, 0, 1'b0, 0, 0, 32'h1ff);   
      
// $display("Reading PCIE0_ERROR register in FME Global Error feature region");
//    test_csr_read_32(result, ADDR32, PCIE0_ERROR, 0, 1'b0, 0, 0, 32'h1ee1);
   
   verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);
   test_pcie_err      (test_result);
end
endtask



