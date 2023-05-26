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
import ofs_fim_pcie_pkg::*;  

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

// Test FME DFH walking 
task test_fme_dfh_walking;
   output logic result;
   dfh_name[MAX_FME_DFH_IDX-1:0]     fme_dfh_names;
   logic [MAX_FME_DFH_IDX-1:0][63:0] fme_dfh_values;
   t_dfh        dfh;
   int          fme_dfh_cnt;
   logic        eol;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] addr;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_fme_dfh_walking");
   
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   //--------------------------
   // DFH Bit mapping
   //--------------------------
   //   [63:60]: Feature Type   
   //   [59:52]: Reserved - 0
   //   [51:48]: If AFU - AFU Minor Revision Number (else, reserved)  - 0
   //   [47:41]: Reserved - 0
   //   [40   ]: EOL (End of DFH list)   
   //   [39:16]: Next DFH Byte Offset 
   //   [15:12]: If AfU, AFU Major version number (else feature #) - 0
   //   [11:0 ]: Feature ID 
   //--------------------------

   fme_dfh_names = get_fme_dfh_names();
   fme_dfh_values = get_fme_dfh_values();

   fme_dfh_cnt = 0;
   eol  = 1'b0;
   addr = FME_DFH_START_OFFSET;

   while (~eol && fme_dfh_cnt < MAX_FME_DFH_IDX) begin
      READ64(ADDR32, addr, FME_BAR, 1'b0, 0, 0, scratch, error);
      $fdisplay(test_utils::get_logfile_handle(), "%0s", fme_dfh_names[fme_dfh_cnt]);
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   DFH value (0x%0x)", scratch);

      dfh = t_dfh'(scratch);
      eol = dfh.eol;

      if (scratch !== fme_dfh_values[fme_dfh_cnt]) begin
         $display("\nERROR: DFH value mismatched, expected: 0x%0x actual:0x%0x\n", fme_dfh_values[fme_dfh_cnt], scratch);      
         test_utils::incr_err_count();
         eol = 1'b1; // error found, exit the loop
         result = 1'b0;
      end
      
      addr = addr + dfh.nxt_dfh_offset;
      fme_dfh_cnt = fme_dfh_cnt + 1'b1;
   end

   if (result) begin
      if (eol !== 1'b1) begin
         $display("\nERROR: Expect EOL bit to be set for last FME feature in the DFL (%0s), actual:'b%0b\n", fme_dfh_names[MAX_FME_DFH_IDX-1], eol);      
         test_utils::incr_err_count();
         result = 1'b0; 
      end

      if (fme_dfh_cnt !== MAX_FME_DFH_IDX) begin
         $display("\nERROR: Expected %d FME features to be discovered, actual:%0d\n", MAX_FME_DFH_IDX, fme_dfh_cnt);      
         test_utils::incr_err_count();
         result = 1'b0; 
      end
   end

   verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end
endtask


//Below task is commented as in EA different tasks were used to cover PORT_DFH and FME_DFH but all DFHs are covered in a single task in R1
// Test Port DFH walking 
//task test_port_dfh_walking;
//   output logic result;
//   dfh_name[MAX_PORT_DFH_IDX-1:0]     port_dfh_names;
//   logic [MAX_PORT_DFH_IDX-1:0][63:0] port_dfh_values;
//   t_dfh        dfh;
//   int          port_dfh_cnt;
//   logic        eol;
//   logic [63:0] scratch;
//   logic        error;
//   logic [31:0] addr;
//   logic [31:0] old_test_err_count;
//begin
//   print_test_header("test_port_dfh_walking");
//   
//   old_test_err_count = test_utils::get_err_count();
//   result = 1'b1;
//   
//   //--------------------------
//   // DFH Bit mapping
//   //--------------------------
//   //   [63:60]: Feature Type   
//   //   [59:52]: Reserved - 0
//   //   [51:48]: If AFU - AFU Minor Revision Number (else, reserved)  - 0
//   //   [47:41]: Reserved - 0
//   //   [40   ]: EOL (End of DFH list)   
//   //   [39:16]: Next DFH Byte Offset 
//   //   [15:12]: If AfU, AFU Major version number (else feature #) - 0
//   //   [11:0 ]: Feature ID 
//   //--------------------------
//
//   port_dfh_names = get_port_dfh_names();
//   port_dfh_values = get_port_dfh_values();
//
//   port_dfh_cnt = 0;
//   eol  = 1'b0;
//   addr = PORT_DFH_START_OFFSET;
//
//   while (~eol && port_dfh_cnt < MAX_PORT_DFH_IDX) begin
//      READ64(ADDR32, addr, PORT_BAR, 1'b0, 0, 0, scratch, error);
//      $fdisplay(test_utils::get_logfile_handle(), "%0s", port_dfh_names[port_dfh_cnt]);
//      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
//      $fdisplay(test_utils::get_logfile_handle(), "   DFH value (0x%0x)", scratch);
//
//      dfh = t_dfh'(scratch);
//      eol = dfh.eol;
//
//      if (scratch !== port_dfh_values[port_dfh_cnt]) begin
//         $display("\nERROR: DFH value mismatched, expected: 0x%0x actual:0x%0x\n", port_dfh_values[port_dfh_cnt], scratch);      
//         test_utils::incr_err_count();
//         eol = 1'b1; // error found, exit the loop
//         result = 1'b0;
//      end
//      
//      addr = addr + dfh.nxt_dfh_offset;
//      port_dfh_cnt = port_dfh_cnt + 1'b1;
//   end
//
//   if (result) begin
//      if (eol !== 1'b1) begin
//         $display("\nERROR: Expect EOL bit to be set for last PORT feature in the DFL (%0s), actual:'b%0b\n", port_dfh_names[MAX_PORT_DFH_IDX-1], eol);      
//         test_utils::incr_err_count();
//         result = 1'b0; 
//      end
//
//      if (port_dfh_cnt !== MAX_PORT_DFH_IDX) begin
//         $display("\nERROR: Expected %d PORT features to be discovered, actual:%0d\n", MAX_PORT_DFH_IDX, port_dfh_cnt);      
//         test_utils::incr_err_count();
//         result = 1'b0; 
//      end
//   end
//
//   verify_mmio_err_count(result, 0);
//   post_test_util(old_test_err_count);
//end
//endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
     test_fme_dfh_walking   (test_result);
     //test_port_dfh_walking  (test_result);
end
endtask



