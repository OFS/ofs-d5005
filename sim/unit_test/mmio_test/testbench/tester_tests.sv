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
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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

// Test 32-bit CSR read access
task test_csr_read_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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

// Test 64-bit CSR access to unused CSR region
task test_unused_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
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

   // -----------------------------------------------------------------------------------------------------------------------------
   //                       (result, addr_mode, addr,                  bar, vf_act, pfn,    vfn,    data                    )               
   // -----------------------------------------------------------------------------------------------------------------------------
   $display("\n---------------------------------------------------");
   $display("Test CSR access to FME CSR region");
   $display("---------------------------------------------------\n");
      test_csr_access_32    (result, addr_mode, FME_SCRATCHPAD0,        0,  1'b0,   0,      0,      'h1111_2222             );   
      test_csr_access_32    (result, addr_mode, FME_SCRATCHPAD0+32'h4,  0,  1'b0,   0,      0,      'hAAAA_BBBB             );   
      test_csr_read_64      (result, addr_mode, FME_SCRATCHPAD0,        0,  1'b0,   0,      0,      'hAAAA_BBBB_1111_2222   );   
      test_csr_access_64    (result, addr_mode, FME_SCRATCHPAD0,        0,  1'b0,   0,      0,      'h1111_2222_3333_4444   );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to SPI CSR region");
   $display("---------------------------------------------------\n");
      test_csr_access_32    (result, addr_mode, PMCI_SCRATCHPAD,        0,  1'b0,   0,      0,      'h1221_2112             );   
      test_csr_access_32    (result, addr_mode, PMCI_SCRATCHPAD+32'h4,  0,  1'b0,   0,      0,      'hABBA_BAAB             );   
      test_csr_read_64      (result, addr_mode, PMCI_SCRATCHPAD,        0,  1'b0,   0,      0,      'hABBA_BAAB_1221_2112   );   
      test_csr_access_64    (result, addr_mode, PMCI_SCRATCHPAD,        0,  1'b0,   0,      0,      'h1111_2222_3333_4444   );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to PCIE CSR region");
   $display("---------------------------------------------------\n");
      test_csr_access_32    (result, addr_mode, PCIE_SCRATCHPAD,        0,  1'b0,   0,      0,      'h2222_0000             );   
      test_csr_access_32    (result, addr_mode, PCIE_SCRATCHPAD+32'h4,  0,  1'b0,   0,      0,      'hAAAA_CCCC             );   
      test_csr_read_64      (result, addr_mode, PCIE_SCRATCHPAD,        0,  1'b0,   0,      0,      'hAAAA_CCCC_2222_0000   );   
      test_csr_access_64    (result, addr_mode, PCIE_SCRATCHPAD,        0,  1'b0,   0,      0,      'h1111_2222_3333_4444   );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to ST2MM CSR region");
   $display("---------------------------------------------------\n");
      test_csr_access_64    (result, addr_mode, ST2MM_SCRATCHPAD,       0,  1'b0,   0,      0,      'h1111_2222_3333_4444   );   
      test_csr_access_32    (result, addr_mode, ST2MM_SCRATCHPAD,       0,  1'b0,   0,      0,      'h3333_1111             );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to Port Gasket region");
   $display("\n---------------------------------------------------");
      test_csr_access_64    (result, addr_mode, PGSK_SCRATCHPAD,        0,  1'b0,   0,      0,      'h1111_2222_3333_4444   );
      test_csr_access_32    (result, addr_mode, PGSK_SCRATCHPAD,        0,  1'b0,   0,      0,      'haa02_02aa             );   
      
   $display("\n---------------------------------------------------");
   $display("Test CSR access to HSSI region");
   $display("\n---------------------------------------------------");
      test_csr_access_64    (result, addr_mode, HSSI_SCRATCHPAD,        0,  1'b0,   0,      0,      'h4444_2222_3333_1111   );
      test_csr_access_32    (result, addr_mode, HSSI_SCRATCHPAD,        0,  1'b0,   0,      0,      'haa02_02aa             );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to HE-LB (PF0-VF0)");
   $display("\n---------------------------------------------------");
      test_csr_access_64    (result, addr_mode, HE_LB_SCRATCHPAD,       0,  1'b1,   3'h0,   0,      'h1111_3333_2222_4444   );
      test_csr_access_32    (result, addr_mode, HE_LB_SCRATCHPAD,       0,  1'b1,   3'h0,   0,      'hdead_beef             ); 

   $display("\n---------------------------------------------------");
   $display("Test CSR access to HE-MEM (PF0-VF1)");
   $display("\n---------------------------------------------------");
      test_csr_access_64    (result, addr_mode, HE_LB_SCRATCHPAD,       0,  1'b1,   3'h0,   1,      'h1111_3333_2222_4444   );
      test_csr_access_32    (result, addr_mode, HE_LB_SCRATCHPAD,       0,  1'b1,   3'h0,   1,      'habc0_4321             );   

   $display("\n---------------------------------------------------");
   $display("Test CSR access to HE-HSSI (PF0-VF2)");
   $display("\n---------------------------------------------------");
      test_csr_access_64    (result, addr_mode, HE_HSSI_SCRATCHPAD,     0,  1'b1,   3'h0,   2,      'h1111_2222_3333_4444   );
      test_csr_access_32    (result, addr_mode, HE_HSSI_SCRATCHPAD,     0,  1'b1,   3'h0,   2,      'haa06_06aa             );   

      
   post_test_util(old_test_err_count);
end
endtask

// Test AFU MMIO read 
task test_afu_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [4:0][31:0] unsupported_addr_vec;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result = 1'b1;
   addr_mode = ADDR32;

   // AFU CSR
   test_csr_access_32(result, addr_mode, 32'h41000, 2, 1'b0, 0, 0, 'hAFC0_0001);   
   test_csr_access_64(result, addr_mode, 32'h41020, 2, 1'b0, 0, 0, 'hAFC0_0003_AFC0_0002);  

   // AFU unsupported address range should return 0
   unsupported_addr_vec[0] = 32'h40030;
   unsupported_addr_vec[1] = 32'h41200;
   unsupported_addr_vec[2] = 32'h42060;
   unsupported_addr_vec[3] = 32'h43030;
   unsupported_addr_vec[4] = 32'h44000;
   for (int i=0; i<5; ++i) begin
      addr = unsupported_addr_vec[i];
      WRITE64(addr_mode, addr, 2, 1'b0, 0, 0, 64'h1234_5678_9abc_def0); 
      test_csr_read_64(result, addr_mode, addr, 0, 1'b0, 0, 0, 'h0);
      if (~result) begin
         $display("Error: MMIO read to unsupported AFU address (addr=0x%0x) doesn't return 0.", addr);
      end
   end
   
   // Test illegal memory read returns CPL
      // misaligned address
   READ64(addr_mode, 32'h41001, 2, 1'b0, 0, 0, scratch, error);
   if (~error) begin
       $display("\nERROR: MMIO read with unaligned address did not return CPL with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end
      // illegal length
   CSR_READ(addr_mode, 32'h41000, 10'd16, 2, 1'b0, 0, 0, scratch, error);
   if (~error) begin
       $display("\nERROR: MMIO read with illegal length did not return CPL with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end

   post_test_util(old_test_err_count);
end
endtask

// Test back-to-back MMIO write and read 
task test_mmio_burst;
   output logic result;
   input logic  valid_csr_region;
   input [2:0]  bar;
   input logic [31:0] base_addr;
   input [1024*8-1:0] test_name;
   logic [31:0] addr;
   logic [63:0] exp_data;
   logic [63:0] scratch;
   logic [1:0]  status;
   t_tlp_tag    tag;
   logic [127:0]       pending_req_vec;
   t_tlp_tag [127:0]   pending_rd_tag_vec;
   logic [127:0][31:0] pending_rd_addr_vec;
   int req_cnt;
   logic [31:0] old_test_err_count;
begin
   print_test_header(test_name);
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   // Stretch test MMIO write access with a burst of MMIO write
   addr = base_addr;
   for (int i=0; i<128; i=i+1) begin
      $display("WRITE32: address=0x%x bar=%0d pfn=0 vfn=0, data=0x%x", addr, bar, (i+1));
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
      create_mwr_packet(ADDR32, addr, 10'd1, bar, 1'b0, 0, 0, {32'h0, i+1});
      addr += 32'h4;
   end
   f_send_test_packet();

   pending_req_vec = '0;

   // Stretch test MMIO read access with a burst of MMIO read
   fork 
      // MMIO request 
      begin : mmio_read_thread
         addr = base_addr;
         for (int i=0; i<128; i=i+1) begin   
            f_get_tag(tag);
            pending_req_vec[i] = 1'b1;
            pending_rd_tag_vec[i] = tag;
            pending_rd_addr_vec[i] = addr;
               // addr_32, address, length, bar, vf_active, pfn, vfn 
            create_mrd_packet(tag, ADDR32, addr, 10'd1, bar, 1'b0, 0, 0);
            $display("(%0d) Added MRD packet: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d", i, addr, bar, tag);
            
            req_cnt += 1;
            addr += 32'h4;

            // Send the packets when all tags are occupied
            if (req_cnt == RP_MAX_TAGS) begin
               f_send_test_packet();
               wait (~|tag_active);
               req_cnt = '0;
            end
         end
         // Send the remaining packets
         f_send_test_packet();
      end

      // MMIO response
      begin : mmio_rsp_thread
         for (int i=0; i<128; i=i+1) begin
            wait (pending_req_vec[i]);

            exp_data = valid_csr_region ? {32'h0, (i+1)} : 'h0;
            $display("READ64: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d\n", pending_rd_addr_vec[i], bar, pending_rd_tag_vec[i]);
            read_mmio_rsp(pending_rd_tag_vec[i], scratch, status);
      
            if (status !== 3'h0) begin
                test_utils::incr_err_count();
                result = 1'b0;
            end else if (scratch[31:0] !== exp_data[31:0]) begin
                $display("\nERROR: Data mismatched! expected=0x%x actual=0x%x\n", exp_data, scratch);
                test_utils::incr_err_count();
                result = 1'b0;
            end
         end
      end
   join 

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
    assert_afu_reset(PORT_CONTROL);
    deassert_afu_reset(PORT_CONTROL);
    $display("Starting mmio test ..");
   test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);

end
endtask

