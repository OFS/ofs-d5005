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

task verify_pcie_err_count;
   output logic result;
   input logic [7:0] exp_err;
begin
   // Wait 30 clock cycles for checker error to be logged
   repeat (30)
      @(posedge fim_clk);

   if (checker_err_count != exp_err) 
   begin
      result = 1'b0;
      $display("Failed - expected errors: %0d,  actual errors: %0d", exp_err, checker_err_count);
   end else begin
      result = 1'b1;
      $display("Checker error count matches: %0d", checker_err_count);
   end
   if (~result)
      test_utils::incr_err_count();
end
endtask

task verify_pcie_err_code;
   output logic result;
   input logic [31:0] exp_err_code;
begin
   // Wait 10 clock cycles for checker error to be logged
   repeat (10)
      @(posedge fim_clk);

   if (pcie_p2c_chk_err_code != exp_err_code) 
   begin
      result = 1'b0;
      $display("Failed - error code mismatch, expected: 0x%x,  actual: 0x%x", exp_err_code, pcie_p2c_chk_err_code);
   end else begin
      result = 1'b1;
      $display("Checker error code matches: 0x%x", pcie_p2c_chk_err_code);
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

task verify_mmio_err_code;
   output logic result;
   input logic [255:0][3:0] exp_err_code;
   logic [31:0] scratch;
   logic        error;
begin
   // Wait 10 clock cycles for checker error to be logged
   repeat (10)
      @(posedge fim_clk);

   result = 1'b1;
   
   for (int i=0; i<mmio_err_count; i=i+1) begin
      if (mmio_err_code[i] !== exp_err_code[i]) 
      begin
         result = 1'b0;
         $display("Failed - MMIO error code mismatch, expected: 0x%x,  actual: 0x%x", exp_err_code[i], mmio_err_code[i] );
      end else begin
         $display("MMIO error code matches: 0x%x", mmio_err_code[i]);
      end
   end

   // Now verify PCIE0_ERROR register
   if (result) begin
      READ32(ADDR32, PCIE0_ERROR, 0, 1'b0, 0, 0, scratch, error);	
      if (scratch[4:1] !== 4'hf) begin
         result = 1'b0;
         $display("Failed - MMIO error bits in PCIE0_ERROR mismatch, expected: 0xf,  actual: 0x%x", scratch[4:1] );
      end
   end

   if (~result)
      test_utils::incr_err_count();
end
endtask

task verify_afu_access_err_count;
   output logic result;
   input logic [7:0] exp_err;
begin
   // Wait 30 clock cycles for checker error to be logged
   repeat (30)
      @(posedge fim_clk);

   if (afu_access_err_count != exp_err) 
   begin
      result = 1'b0;
      $display("Failed - expected AFU access errors: %0d,  actual errors: %0d", exp_err, afu_access_err_count);
   end else begin
      result = 1'b1;
      $display("AFU access error count matches: %0d", afu_access_err_count);
   end
   if (~result)
      test_utils::incr_err_count();
end
endtask


// Enable VF port access
task enable_vf_port_access;
   logic [63:0] scratch;
   logic        error;
begin
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
   
   scratch[56] = 1'b0; // Decouple port CSR
   scratch[55] = 1'b1; // AFU access control

   WRITE32(ADDR32, (PORT0_OFFSET+3'h4), 0, 1'b0, 0, 0, scratch[63:32]);  
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
end
endtask

task disable_vf_port_access;
   logic [63:0] scratch;
   logic        error;
begin
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
   
   scratch[56] = 1'b0; // Decouple port CSR
   scratch[55] = 1'b0; // AFU access control

   WRITE32(ADDR32, (PORT0_OFFSET+3'h4), 0, 1'b0, 0, 0, scratch[63:32]);  
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
end
endtask

// Decouple PORT CSR access from AFU VF access
task decouple_vf_port_access;
   logic [63:0] scratch;
   logic        error;
begin
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
   
   scratch[56] = 1'b1; // Decouple port CSR

   WRITE32(ADDR32, (PORT0_OFFSET+3'h4), 0, 1'b0, 0, 0, scratch[63:32]);  
   READ64(ADDR32, PORT0_OFFSET, 0, 1'b0, 0, 0, scratch, error);	
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

// Test 32-bit CSR access to unused CSR region
task test_illegal_csr_access_32;
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

   if (~error) begin
       $display("\nERROR: MMIO read to unmapped function did not return CPL with unsuccessful status.\n");
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

task test_illegal_csr_access_64;
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

   if (~error) begin
       $display("\nERROR: MMIO read to unmapped function did not return CPL with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

task test_illegal_csr_read_64;
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

   if (!error) begin
       $display("\nERROR: Completion of illegal access is returned with successful status.\n");
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
   logic        PF;
   logic        VF;
   logic [2:0]  BAR0;
   logic [2:0]  BAR2;
   input e_addr_mode addr_mode;
   logic [63:0] base_addr;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   int count;
begin

   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   BAR0 = 3'h0;
   BAR2 = 3'h2;
   PF = 1'b0;
   VF = 1'b1;

   //-----------
   // FME CSR
   //-----------
   $display("Test CSR access to FME CSR region");
      test_csr_access_32(result, addr_mode, FME_SCRATCHPAD0, BAR0, PF, 0, 0, 'h1111_2222);   
      test_csr_access_64(result, addr_mode, FME_SCRATCHPAD0, BAR0, PF, 0, 0, 'h1111_2222_3333_4444);   

   $display("Test CSR access to external FME CSR region");
      test_csr_access_32(result, addr_mode, PCIE_SCRATCHPAD, BAR0, PF, 0, 0, 'h1111_2222);   
      test_csr_access_64(result, addr_mode, PCIE_SCRATCHPAD, BAR0, PF, 0, 0, 'h1111_2222_3333_4444);   
      test_csr_read_64(result, addr_mode, EMIF_DFH, BAR0, PF, 0, 0, EMIF_DFH_VALUE);   

   $display("Test CSR access to unused FME CSR region");
      test_unused_csr_access_32(result, addr_mode, 32'h7f000, BAR0, PF, 0, 0, 'hF00D_0001);
      test_unused_csr_access_64(result, addr_mode, 32'h7f000, BAR0, PF, 0, 0, 'hF00D_0001_6464_6464);
      
   //-----------
   // Port CSR
   //-----------
   $display("Test CSR access to Port CSR region");
      test_csr_access_32(result, addr_mode, PORT_SCRATCHPAD0, BAR0, PF, 0, 0, 'hF00D_0001);   
      test_csr_access_64(result, addr_mode, PORT_SCRATCHPAD0, BAR0, PF, 0, 0, 'h1111_2222_3333_4444); 

   $display("Test CSR access to External Port CSR region");
      test_csr_read_64  (result, addr_mode, USER_CLK_DFH,   BAR0, PF, 0, 0, USER_CLK_DFH_VALUE);   
      test_csr_access_32(result, addr_mode, USER_CLK_CMD_0, BAR0, PF, 0, 0, 'hF00D_0002);
      test_csr_access_64(result, addr_mode, USER_CLK_CMD_0, BAR0, PF, 0, 0, 'hF00D_0002_6464_6464);

   $display("Test CSR access to unused Port CSR region");
      test_unused_csr_access_32(result, addr_mode, 32'h20028, BAR0, PF, 0, 0, 'hF00D_0003);
      test_unused_csr_access_64(result, addr_mode, 32'h20028, BAR0, PF, 0, 0, 'hF00D_0003_6464_6464);
      test_unused_csr_access_32(result, addr_mode, 32'h30040, BAR0, PF, 0, 0, 'hF00D_0001);
      test_unused_csr_access_64(result, addr_mode, 32'h30040, BAR0, PF, 0, 0, 'hF00D_0001_6464_6464);
      //===================================
      //HSD Raised for below address spaces
      //===================================
      test_unused_csr_access_32(result, addr_mode, 32'h21000, BAR0, PF, 0, 0, 'hF00D_0003);
      test_unused_csr_access_64(result, addr_mode, 32'h21000, BAR0, PF, 0, 0, 'hF00D_0003_6464_6464);
      test_unused_csr_access_32(result, addr_mode, 32'h3f000, BAR0, PF, 0, 0, 'hF00D_0001);
      test_unused_csr_access_64(result, addr_mode, 32'h3f000, BAR0, PF, 0, 0, 'hF00D_0001_6464_6464);


   //verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end
endtask

// Test AFU MMIO read 
task test_afu_mmio;
   output logic result;
   logic        VF;
   logic        PF;
   logic [2:0]  BAR0;
   logic [2:0]  BAR2;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result = 1'b1; 

   addr_mode = ADDR32;
   BAR0 = 3'h0;
   BAR2 = 3'h2;
   PF = 1'b0;
   VF = 1'b1;

   //----------------------
   // Test illegal AFU MMIO access 
   //----------------------
   // PF access to AFU when set to VF mode, or vice versa are treated like unimplemented registers. FIM will return all 0s
   create_mwr_packet(addr_mode, 32'h40000, 10'd64, BAR0, VF, 0, 1, {16{32'h0123_4567}});
   f_send_test_packet();
   $display("\nPF0-VF1 access to 0x40000 address in PF0-BAR0 returns all 0s.\n");
   test_unused_csr_access_32(result, addr_mode, 32'h40000, BAR0, VF, 0, 1, 'hAFC0_0001);   
   
   // Enable VF AFU access
   enable_vf_port_access(); //VF Access not applicable for R1

   create_mwr_packet(addr_mode, 32'h40000, 10'd64, BAR0, VF, 0, 1, {16{32'h0123_4567}});
   f_send_test_packet();
   $display("\nPF0-VF1 access to 0x40000 address in PF0-BAR0 with VF AFU access also returns all 0s.\n");
   test_unused_csr_access_32(result, addr_mode, 32'h40000, BAR0, VF, 0, 1, 'hAFC0_0001);

   //if (result) verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end
endtask


// Test FLR reset
task test_pf0_flr_reset;
   logic        vf_flr;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
begin
   static int count = 0;
   print_test_header("test_pf0_flr_reset");
   old_test_err_count = test_utils::get_err_count();

   // Assert PF FLR
   vf_flr = 1'b0;

   //==================================================
   //Writing and Reading ST2MM Scratchpad Register
   //==================================================
   $display("Writing and Reading ST2MM Scratchpad Register\n");
   WRITE64(ADDR64, 'h80008, 0, 1'b0, 1'b0, 1'b0, 'hDEAD_BEEF);	
   READ64(ADDR64, 'h80008, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hDEAD_BEEF) begin
       $display("\nERROR: ST2MM Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Writing and Reading Port Gasket Scratchpad Register
   //=========================================================
   $display("Writing and Reading Port Gasket Scratchpad Register\n");
   WRITE64(ADDR64, 'h900B8, 0, 1'b0, 1'b0, 1'b0, 'hFEED_CAFE);	
   READ64(ADDR64, 'h900B8, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hFEED_CAFE) begin
       $display("\nERROR: Port Gasket Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Writing and Reading PR Slot PR_DATA Register
   //=========================================================
   $display("Writing and Reading PR Slot PR_DATA Register\n");
   WRITE64(ADDR64, 'h90018, 0, 1'b0, 1'b0, 1'b0, 'hBEEF_DEAD);	
   READ64(ADDR64, 'h90018, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hBEEF_DEAD) begin
       $display("\nERROR: PR Slot PR_DATA register data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Writing and Reading FME Scratchpad Register
   //=========================================================
   $display("Writing and Reading FME Scratchpad Register\n");
   WRITE64(ADDR64, 'h00028, 0, 1'b0, 1'b0, 1'b0, 'hCAFE_FEED);	
   READ64(ADDR64, 'h00028, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hCAFE_FEED) begin
       $display("\nERROR: FME Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //Sending PF0 FLR
   send_flr(vf_flr,'h0,'h0);
   
   while((DUT.afu_top.axis_axil_bridge.axil_bridge_csr.rst_n == 1'b0 && DUT.afu_top.he_lb_inst.rst_n == 1'b0 && DUT.afu_top.port_gasket.pr_slot.afu_main.he_hssi_top_inst.softreset == 1'b1 && DUT.afu_top.port_gasket.pr_slot.afu_main.he_lb_inst.rst_n == 1'b0 && DUT.afu_top.afu_rst_n[0] == 1'b0 && DUT.afu_top.afu_rst_n[1] == 1'b0 && DUT.rst_ctrl.flr_active_pf0 == 1'b1) == 0 && count < 100) begin
      #10000 count++;      
  end

    if (count == 100) begin
        $display("\nERROR: ST2MM is not in reset state ...");
        test_utils::incr_err_count();
        $finish;       
   end else begin
      $display("\nST2MM, HE-LPBK, HE-MEM and HE-HSSI are in reset state...!");
   end

   // Wait for PF FLR to be cleared
   wait_flr(vf_flr,'h0,'h0);
   
   //========================================================
   //Reading ST2MM Scratchpad Register
   //=========================================================
   $display("Reading ST2MM Scratchpad Register\n");
   READ64(ADDR64, 'h80008, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== '0) begin
       $display("\nERROR: ST2MM Scratchpad data mismatch after reset..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Reading Port Gasket Scratchpad Register
   //=========================================================
   $display("Reading Port Gasket Scratchpad Register\n");
   READ64(ADDR64, 'h900B8, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hFEED_CAFE) begin
       $display("\nERROR: Port Gasket Scratchpad data mismatch..last write value is not available..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Reading PR Slot PR_DATA Register
   //=========================================================
   $display("Reading PR Slot PR_DATA Register\n");
   READ64(ADDR64, 'h90018, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hBEEF_DEAD) begin
       $display("\nERROR: PR Slot PR_DATA data mismatch..last write value is not available after Reset..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   //========================================================
   //Reading FME Scratchpad Register
   //=========================================================
   $display("Reading FME Scratchpad Register\n");
   READ64(ADDR64, 'h00028, 0, 1'b0, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hCAFE_FEED) begin
       $display("\nERROR: FME Scratchpad data mismatch..last write value is not available after Reset..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end


   $display("\nAFU is out of reset ...");

   post_test_util(old_test_err_count);
end
endtask


// Test VF2 FLR reset
task test_vf2_flr_reset;
   logic        vf_flr;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
begin
   static int count = 0;
   print_test_header("test_vf2_flr_reset");
   old_test_err_count = test_utils::get_err_count();

   // Assert VF FLR
   vf_flr = 1'b1;

   //========================================================
   //Writing and Reading HE-HSSI Scratchpad Register
   //=========================================================
   $display("Writing and Reading HE-HSSI Scratchpad Register\n");
   WRITE64(ADDR64, 'h00048, 0, 1'b1, 1'b0, 2'b10, 'hFEED_CAFE);	
   READ64(ADDR64, 'h00048, 0, 1'b1, 1'b0, 2'b10, scratch, error);	
   if (scratch !== 'hFEED_CAFE) begin
       $display("\nERROR: Port Gasket Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end
   
   // Send FLR
   send_flr(vf_flr,'h0,'h2);
   
   // Wait for Port Reset Ack 
   count = 0;
   $display("\nCheck HSSI Reset is asserted along with Reset Controller bits for FLR..."); 
   
     while ((DUT.afu_top.port_gasket.pr_slot.afu_main.he_hssi_top_inst.softreset==1'b1 && DUT.afu_top.afu_rst_n[0] == 1'b1 && DUT.afu_top.afu_rst_n[1]== 1'b0 && DUT.rst_ctrl.flr_active_vf == 1'b1 && DUT.rst_ctrl.flr_rcvd_vf_flag == 1'b1 && DUT.rst_ctrl.flr_rcvd_vf_num == 2'b10) == 1'b0 && count <100) begin
      #10000 count++;      
   end 

   if (count == 100) begin
       $display("\nERROR: HSSI Reset never gets asserted ...");
       test_utils::incr_err_count();
       $finish;       
   end else begin
       $display("\nHE-HSSI is in reset state..!\n");
   end

   wait_flr(vf_flr,'h0,'h2);
   //========================================================
   //Reading HE-HSSI Scratchpad Register
   //=========================================================
   $display("Reading HE-HSSI Scratchpad Register after Reset\n");
   READ64(ADDR64, 'h00048, 0, 1'b1, 1'b0, 2'b10, scratch, error);	
   if (scratch !== 'h0000_0000_4532_4511) begin
       $display("\nERROR: HE-HSSI Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   $display("\nHE-HSSI is successfully reset ...");

   post_test_util(old_test_err_count);
end
endtask

// Test VF1 FLR reset
task test_vf1_flr_reset;
   logic        vf_flr;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
begin
   static int count = 0;
   print_test_header("test_vf1_flr_reset");
   old_test_err_count = test_utils::get_err_count();

   // Assert VF FLR
   vf_flr = 1'b1;

   //========================================================
   //Writing and Reading HE-MEM Scratchpad Register
   //=========================================================
   $display("Writing and Reading HE-MEM Scratchpad Register\n");
   WRITE64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b1, 'hFEED_CAFE);	
   READ64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b1, scratch, error);	
   if (scratch !== 'hFEED_CAFE) begin
       $display("\nERROR: HE-MEM Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end
   
   // Send FLR
   send_flr(vf_flr,'h0,'h1);
   
   // Wait for Port Reset Ack 
   count = 0;
   $display("\nCheck HE-MEM Reset is asserted..!"); 
   
     while ((DUT.afu_top.port_gasket.pr_slot.afu_main.he_lb_inst.rst_n  == 1'b0 && DUT.afu_top.afu_rst_n[0] == 1'b0 && DUT.afu_top.afu_rst_n[1]== 1'b1 && DUT.rst_ctrl.flr_active_vf == 1'b1 && DUT.rst_ctrl.flr_rcvd_vf_flag == 1'b1 && DUT.rst_ctrl.flr_rcvd_vf_num == 2'b01 ) == 1'b0  && count < 100) begin
      #10000 count++;      
   end 

   if (count == 100) begin
       $display("\nERROR: HE-MEM soft reset never get asserted ...");
       test_utils::incr_err_count();
       $finish;       
   end else begin
      $display("\nHE-MEM is in reset state...!");
   end

   wait_flr(vf_flr,'h0,'h1);
   //========================================================
   //Reading HE-MEM Scratchpad Register
   //=========================================================
   $display("Reading HE-MEM Scratchpad Register after Reset\n");
   READ64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b1, scratch, error);	
   if (scratch !== 'h0) begin
       $display("\nERROR: HE-MEM Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   $display("\nHE-MEM is successfully reset ...");

   post_test_util(old_test_err_count);
end
endtask

// Test VF0 FLR reset
task test_vf0_flr_reset;
   logic        vf_flr;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
begin
   static int count = 0;
   print_test_header("test_vf0_flr_reset");
   old_test_err_count = test_utils::get_err_count();

   // Assert VF FLR
   vf_flr = 1'b1;

   //========================================================
   //Writing and Reading HE-LB Scratchpad Register
   //=========================================================
   WRITE64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b0, 'hFEED_CAFE);	
   READ64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'hFEED_CAFE) begin
       $display("\nERROR: Port Gasket Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end
   
   // Send FLR
   send_flr(vf_flr,'h0,'h0);
   
   // Wait for Port Reset Ack 
   count = 0;
   $display("\nCheck HE-LB Reset is asserted..!"); 
   
   READ64(ADDR32, 'h91038, 0, 1'b0, 0, 0, scratch, error);
     while (DUT.afu_top.he_lb_inst.rst_n !=1'b0 && count <100) begin
      #10000 count++;      
   end 
   if (count == 100) begin
       $display("\nERROR: HE-LB soft reset never get asserted ...");
       test_utils::incr_err_count();
       $finish;       
   end 

   wait_flr(vf_flr,'h0,'h0);
   //========================================================
   //Reading HE-LB Scratchpad Register
   //=========================================================
   $display("Reading HE-LB Scratchpad Register after reset\n");
   READ64(ADDR64, 'h00108, 0, 1'b1, 1'b0, 1'b0, scratch, error);	
   if (scratch !== 'h0) begin
       $display("\nERROR: HE-LB Scratchpad data mismatch..!, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
   end

   $display("\nHE-LB is successfully reset ...");

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
   deassert_afu_reset (PORT_CONTROL);
   test_afu_mmio      (test_result); 
 
   test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);

   test_vf2_flr_reset();   //VF2 Reset Scenario  
   test_vf1_flr_reset();   //VF1 Reset Scenario  
   test_vf0_flr_reset();   //VF0 Reset Scenario  
   test_pf0_flr_reset();   //PF0 Reset Scenario

end
endtask
