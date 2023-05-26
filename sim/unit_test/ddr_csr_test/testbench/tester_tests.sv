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
begin
   // Wait 10 clock cycles for checker error to be logged
   repeat (10)
      @(posedge fim_clk);

   for (int i=0; i<mmio_err_count; i=i+1) begin
      if (mmio_err_code[i] !== exp_err_code[i]) 
      begin
         result = 1'b0;
         $display("Failed - MMIO error code mismatch, expected: 0x%x,  actual: 0x%x", exp_err_code[i], mmio_err_code[i] );
      end else begin
         result = 1'b1;
         $display("MMIO error code matches: 0x%x", mmio_err_code[i]);
      end
   end
   if (~result)
      test_utils::incr_err_count();
end
endtask
    
//-------------------
// Test cases 
//-------------------
// Test EMIF CSR write/read 
task test_emif_mmio_burst;
   output logic result;
   logic [2:0]  bar;
   logic [31:0] waddr;
   logic [31:0] raddr;
   logic [63:0] exp_data;
   logic [63:0] scratch;
   logic [1:0]  status;
   t_tlp_tag    tag;
   logic [127:0]       pending_req_vec;
   t_tlp_tag [127:0]   pending_rd_tag_vec;
   logic [127:0][31:0] pending_rd_addr_vec;
   int req_cnt;
begin
   import test_csr_defs::*;

   print_test_header("test_emif_mmio_burst");
   result = 1'b1;

   // Stretch test MMIO write access with a burst of MMIO write
   waddr = EMIF_CTRL;
   bar = 0;
   

  // for (int i=0; i<10; i=i+1) begin               //old i<64
  //    $display("EMIF_CTRL_WRITE32: address=0x%x bar=%0d pfn=0 vfn=0, data=0x%x", waddr, bar, (i+1));
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
  //    create_mwr_packet(ADDR32, waddr, 10'd1, bar, 1'b0, 0, 0, 64'hFFFF_FFFF_FFFF_FFFF);
  //  create_mwr_packet(ADDR32, (waddr+4), 10'd1, bar, 1'b0, 0, 0, 32'hf);
  //  end
  //f_send_test_packet();
  // pending_req_vec = '0;
   
  //  repeat (20)
  //    @(posedge avl_clk);

   // Stretch test MMIO read access with a burst of MMIO read EMIF_CTRL
   fork : emif_ctrl_fork 
      // MMIO request EMIF_CTRL
      begin : mmio_read_thread
         for (int i=0; i<5; i=i+1) begin      //old i<128
            raddr = EMIF_CTRL;
            f_get_tag(tag);
            pending_req_vec[i] = 1'b1;
            pending_rd_tag_vec[i] = tag;
            pending_rd_addr_vec[i] = raddr;
               // addr_32, address, length, bar, vf_active, pfn, vfn 
            create_mrd_packet(tag, ADDR32, raddr, 10'd1, bar, 1'b0, 0, 0);
            $display("EMIF_CTRL_ (%0d) Added MRD packet: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d", i, raddr, bar, tag);
            
            req_cnt += 1;

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

      // MMIO response EMIF_CTRL
      begin : mmio_rsp_thread
         for (int i=0; i<5; i=i+1) begin      //old i<64
            wait (pending_req_vec[i]);

          //  if (i[0]) begin
               exp_data = 64'hF;           //old exp_data = 64'h0                       
          //  end else begin
          //     exp_data = 64'h3000000500000009;                 
          //  end

            $display("EMIF_CTRL_ READ64: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d\n", pending_rd_addr_vec[i], bar, pending_rd_tag_vec[i]);
            read_mmio_rsp(pending_rd_tag_vec[i], scratch, status);
      
            if (status !== 3'h0) begin
                test_utils::incr_err_count();
                result = 1'b0;
            end else if (scratch !== exp_data) begin
                $display("\nEMIF_CTRL_ ERROR: Data mismatched! expected=0x%x actual=0x%x\n", exp_data, scratch);
                test_utils::incr_err_count();
                result = 1'b0;
            end
         end
      end
   join 

   
    
   // Stretch test MMIO read access with a burst of MMIO read EMIF_STAT and EMIF_DFH
   fork 
      // MMIO request 
      begin : mmio_read_thread
         for (int i=0; i<10; i=i+1) begin      //old i<128
            raddr = i[0] ? EMIF_STAT : EMIF_DFH;
            f_get_tag(tag);
            pending_req_vec[i] = 1'b1;
            pending_rd_tag_vec[i] = tag;
            pending_rd_addr_vec[i] = raddr;
               // addr_32, address, length, bar, vf_active, pfn, vfn 
            create_mrd_packet(tag, ADDR32, raddr, 10'd2, bar, 1'b0, 0, 0);
            $display("(%0d) Added MRD packet: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d", i, raddr, bar, tag);
            
            req_cnt += 1;

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
         for (int i=0; i<10; i=i+1) begin      //old i<64
            wait (pending_req_vec[i]);

            if (i[0]) begin
               exp_data = 64'hf;                                 //old = 64'hf
            end else begin
               exp_data = 64'h3000000500000009;                  //old = 64'h3000000010000009 
            end

            $display("READ64: address=0x%x bar=%0d pfn=0 vfn=0 tag=%0d\n", pending_rd_addr_vec[i], bar, pending_rd_tag_vec[i]);
            read_mmio_rsp(pending_rd_tag_vec[i], scratch, status);
      
            if (status !== 3'h0) begin
                test_utils::incr_err_count();
                result = 1'b0;
            end else if (scratch !== exp_data) begin
                $display("\nERROR: Data mismatched! expected=0x%x actual=0x%x\n", exp_data, scratch);
                test_utils::incr_err_count();
                result = 1'b0;
            end
         end
      end
   join 

   if (result) verify_mmio_err_count(result, 0);
   post_test_util(result);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
begin
   test_emif_mmio_burst  (test_result);
end
endtask



