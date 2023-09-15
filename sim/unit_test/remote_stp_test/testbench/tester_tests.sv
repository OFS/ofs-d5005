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

// Test 32-bit data access with 64b address
task test_csr_access_32_addr64;
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

   WRITE32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, scratch, error);	

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

// Test 32-bit read access
task test_csr_read_access_32;
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
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test back-to-back MMIO access 
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
                $display("\nERROR: Data mismatched!address=0x%x expected=0x%x actual=0x%x\n",pending_rd_addr_vec[i], exp_data, scratch);
                test_utils::incr_err_count();
                result = 1'b0;
            end
         end
      end
   join 

   if (result) verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);
end

endtask

// Test back-to-back MMIO read 
task test_mmio_burst_rd;
   output logic result;
   input logic  valid_csr_region;
   input [2:0]  bar;
   input logic [31:0] base_addr;
   input logic [31:0] start_value;
   input int    num_loc;
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
   result = 1'b1;

   pending_req_vec = '0;

   // Stretch test MMIO read access with a burst of MMIO read
   fork 
      // MMIO request 
      begin : mmio_read_thread
         addr = base_addr;
         for (int i=0; i<num_loc; i=i+1) begin   
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
         for (int i=0; i<num_loc; i=i+1) begin
            wait (pending_req_vec[i]);

            exp_data = valid_csr_region ? {32'h0, (start_value+i+1)} : 'h0;
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

end
endtask

// Test back-to-back MMIO write 
task test_mmio_burst_wr;
   input [2:0]  bar;
   input logic [31:0] base_addr;
   logic [31:0] addr;
begin

   // Stretch test MMIO write access with a burst of MMIO write
   addr = base_addr;
   for (int i=0; i<128; i=i+1) begin
      $display("WRITE32: address=0x%x bar=%0d pfn=0 vfn=0, data=0x%x", addr, bar, (i+1));
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
      create_mwr_packet(ADDR32, addr, 10'd1, bar, 1'b0, 0, 0, {32'h0, i+1});
      addr += 32'h4;
   end
   f_send_test_packet();

end
endtask


// Test 64-bit data access with 64b address
task test_csr_access_64_addr64;
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

   WRITE64(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, scratch, error);	

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

// Test  RemoteSTP MMIO read write
task test_rstp_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [31:0] CHANNEL_ID;
   logic [31:0] CONN_ID;
   logic [31:0] START_LOC;
   logic [31:0] PKT_LEN;
   logic [31:0] LAST_LOC;
   logic [31:0] CTRL_REG;
begin
   print_test_header("test_rstp_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result     = 1'b1;
   addr_mode  = ADDR32;
   CHANNEL_ID = 'hB;
   CONN_ID    = 'hC;
   START_LOC  = 'h8; // Multiple of 8
   PKT_LEN    = 'h40; // Multiple of 8
   LAST_LOC   = START_LOC + PKT_LEN; // Multiple of 8
   CTRL_REG   = 'h7; // [2:0] are valid
   
   // CSR
   // DFH Register check
     
   CSR_READ(addr_mode, PORT_STP_DFH_ADDR, 10'd02, 0, 1'b0, 0, 0, scratch, error);
   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== PORT_STP_DFH_VAL) begin
       $display("\nERROR: DFH CSR expected and read mismatch! expected=0x%x read=0x%x\n", PORT_STP_DFH_VAL, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
 

  CSR_READ(addr_mode,  PORT_STP_STATUS_ADDR , 10'd02, 0, 1'b0, 0, 0, scratch, error);
   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== PORT_STP_STATUS_VAL) begin
       $display("\nERROR: PORT_STP_STATUS_CSR expected and read mismatch! expected=0x%x read=0x%x\n", PORT_STP_STATUS_VAL, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
     
/*   // RW access check
   // test_csr_access_32(result, addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_INTR_MASK_ADDR, 2, 1'b0, 0, 0, 'hA);
   //test_csr_access_32(result, addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_INTR_MASK_ADDR, 2, 1'b0, 0, 0, 'h5);

   // Self-Clearing register test
   // Applying Reset and enabling loopback
   WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_CTRL_ADDR, 2, 1'b0, 0, 0, CTRL_REG);	
  // test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_CTRL_ADDR, 2, 1'b0, 0, 0, 'h7);
  // test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_CTRL_ADDR, 2, 1'b0, 0, 0, (CTRL_REG & 32'hFFFF_FFFE));
  
   // Check whether ready is getting deasserted after reset
   //if (top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.st_dbg_if.h2t_ready) begin
   //if (~top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.mm_interconnect_0_st_dbg_ip_ip_avmm_s_waitrequest) begin
   //   $display("\nERROR: H2T Ready not deasserted after Reset\n");
   //   test_utils::incr_err_count();
   //   result = 1'b0;
   //   $finish();
   //end

   // Writing H2T memory
   //test_mmio_burst_wr(2, RSTP_H2T_MEM_ADDR);
   
   // WO access check
   // Set H2T packet length, start location, connection ID and channel ID
 //  WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_PKT_LEN_ADDR, 2, 1'b0, 0, 0, PKT_LEN);
  // WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_START_LOC_ADDR, 2, 1'b0, 0, 0, START_LOC);
   $display("Reading addr 0'h8110\n");
  // WRITE64(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_CONNECTION_ID_ADDR, 2, 1'b0, 0, 0, {CHANNEL_ID,CONN_ID});
   //WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_CHANNEL_ID_ADDR, 2, 1'b0, 0, 0, CHANNEL_ID);   //uncommenting
   
  // WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_T2H_DESC_DONE_ADDR, 2, 1'b0, 0, 0, 'h1); // As no signal to capture, we making sure writing to this register is not breaking anything
   
   // Wating till h2t memory read is initiated from dbg_if ip

   //@(posedge top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip_h2t_mem_read);

   @(posedge top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.st_dbg_ip_h2t_mem_read); //doubt

      //scratch = top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip_h2t_mem_address;

      scratch = {top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.st_dbg_ip_h2t_mem_address[11:0]}; //doubt

    // Check for start location in h2t memory matches START_LOC register value

    if (scratch !== START_LOC) begin
       $display("\nERROR: H2T Start Location Expected and read mismatch! expected=0x%x read=0x%x\n", START_LOC, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end 
   else begin
      $display("H2T Start Location read=0x%x\n", scratch);
   end
   
   #2500000
   
   // scratch = {top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip.h2t_conn_id};

   scratch = { top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.h2t_mem };  //doubt,ddint find this signal in R1
   
      if (scratch !== CONN_ID) begin

         $display("\nERROR: H2T Connection ID Expected and read mismatch! expected=0x%x read=0x%x\n", CONN_ID, scratch);
         test_utils::incr_err_count();
         result = 1'b0; 
   end 
   else begin
      $display("H2T Connection ID read=0x%x\n", scratch);
   end  
   
   //scratch = {top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip_h2t_src_channel[10:0]};

   scratch =  {top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.st_dbg_ip_h2t_src_channel[10:0]}; //doubt


   if (scratch !== CHANNEL_ID) begin
      $display("\nERROR: H2T Channel ID Expected and read mismatch! expected=0x%x read=0x%x\n", CHANNEL_ID, scratch);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   else begin
      $display("H2T Channel ID read=0x%x\n", scratch);
   end
   
   // Check for last location in h2t memory is PKT_LEN away from START_LOC
   //scratch = top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip.h2t_mem_address;
   scratch = {top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.st_dbg_ip_h2t_mem_address[11:0]};  //doubt

   
  if (scratch !== LAST_LOC) begin
      $display("\nERROR: H2T Last Location Expected and read mismatch! expected=0x%x read=0x%x\n", LAST_LOC, scratch);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   else begin
      $display("H2T Last Location read=0x%x\n", scratch);
   end

   // RO access check
   // result, addr_mode, addr, bar, vf_active, pfn, vfn, data
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_RDDM_VER_ADDR, 2, 1'b0, 0, 0, DBG_IP_RDDM_VER_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_RDDM_REV_ADDR, 2, 1'b0, 0, 0, DBG_IP_RDDM_REV_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_EXT_MEM_DEPTH_ADDR, 2, 1'b0, 0, 0, DBG_IP_EXT_MEM_DEPTH_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_EXT_DESC_DEPTH_ADDR, 2, 1'b0, 0, 0, DBG_IP_EXT_DESC_DEPTH_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_H2T_SLOT_AVAIL_ADDR, 2, 1'b0, 0, 0, DBG_IP_H2T_SLOT_AVAIL_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_T2H_PKT_LEN_ADDR, 2, 1'b0, 0, 0, DBG_IP_T2H_PKT_LEN_VAL);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_T2H_START_LOC_ADDR, 2, 1'b0, 0, 0, DBG_IP_T2H_START_LOC_VAL);
  // test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_T2H_CONNECTION_ID_ADDR, 2, 1'b0, 0, 0, CONN_ID);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_T2H_CHANNEL_ID_ADDR, 2, 1'b0, 0, 0, CHANNEL_ID);
      
   test_mmio_burst_rd(result,1'b1,2, RSTP_T2H_MEM_ADDR, (START_LOC >> 2), PKT_LEN/4 );
   
   // 64- RO 
   CSR_READ(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_T2H_CONNECTION_ID_ADDR, 10'd02, 2, 1'b0, 0, 0, scratch, error);
   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== {CHANNEL_ID,CONN_ID}) begin
       $display("\nERROR: DFH CSR expected and read mismatch! expected=0x%x read=0x%x\n", {CHANNEL_ID,CONN_ID}, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end

   //--------------------------------
   // Negative tests
   //--------------------------------
   
   // unimplemented PORT STP address
 //READ64(addr_mode, PORT_STP_UNIMPLEMENTED_ADDR, 2, 1'b0, 0, 0, scratch, error);
 //if (scratch !==  64'hdeadc0dedeadc0de) begin
 //    $display("\nERROR: MMIO read with unimplemented address did not return CPL with unsuccessful status.\n");
 //    test_utils::incr_err_count();
 //    result = 1'b0;
 //end
 //
 //// unimplemented DGB_IP address
 //test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_T2H_UNIMPLEMENTED_ADDR, 2, 1'b0, 0, 0, DBG_IP_FAULT_VAL);

   // Write to ready only register
   WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_RDDM_VER_ADDR, 2, 1'b0, 0, 0, 'hF012CE);
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_RDDM_VER_ADDR, 2, 1'b0, 0, 0, DBG_IP_RDDM_VER_VAL);

   // Read to write only register
   test_csr_read_access_32(result, addr_mode,  RSTP_DBG_IP_ADDR + DBG_IP_H2T_CONNECTION_ID_ADDR, 2, 1'b0, 0, 0, DBG_IP_FAULT_VAL);
 
   // asserting reset in between reset
   //WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_PKT_LEN_ADDR, 2, 1'b0, 0, 0, PKT_LEN);
  // WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_START_LOC_ADDR, 2, 1'b0, 0, 0, START_LOC);
   //WRITE64(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_CONNECTION_ID_ADDR, 2, 1'b0, 0, 0, {CHANNEL_ID,CONN_ID});
   // Wating till h2t memory read is initiated from dbg_if ip
   //@(posedge top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.intel_jop_blaster_0.intel_jop_blaster_0.st_dbg_ip_h2t_mem_read);
   @(posedge top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.st_dbg_ip_h2t_mem_read);  //doubt
  
 WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_CTRL_ADDR, 2, 1'b0, 0, 0, CTRL_REG);
   
   #2500000
   // Check for last location in h2t memory is PKT_LEN away from START_LOC
   //scratch = top_tb.DUT.corefim.port.port0.remote_stp_top.remote_debug_jtag_only.mm_interconnect_0.intel_jop_blaster_0_avmm_s_address;
   scratch = {top_tb.DUT.afu_top.port_gasket.remote_stp_top_inst.remote_debug_jtag_only.jop_blaster.jop_blaster.avmm_s_address[13:0]}; //doubt

   if (scratch == LAST_LOC) begin
      $display("\nERROR: H2T Last Location indicates reset note applied");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   
   // Proper after transation stopped abruptly
  // WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_PKT_LEN_ADDR, 2, 1'b0, 0, 0, PKT_LEN);
  // WRITE32(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_START_LOC_ADDR, 2, 1'b0, 0, 0, START_LOC);
   //WRITE64(addr_mode, RSTP_DBG_IP_ADDR + DBG_IP_H2T_CONNECTION_ID_ADDR, 2, 1'b0, 0, 0, {CHANNEL_ID,CONN_ID});
  // #200
  // test_mmio_burst_rd(result,1'b1,2, RSTP_T2H_MEM_ADDR, (START_LOC >> 2), PKT_LEN/4 );  
    
   
   if (result) verify_mmio_err_count(result, 0);
   post_test_util(old_test_err_count);     
 */

   end
endtask

// Test AFU reset
task test_afu_reset;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_afu_reset");
   old_test_err_count = test_utils::get_err_count();

   // Reset AFU
   assert_afu_reset(PORT_CONTROL);
   deassert_afu_reset(PORT_CONTROL);
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
   
   valid_csr_region = 1'b1;
   //test_mmio_burst   (test_result, valid_csr_region,  2, RSTP_H2T_MEM_ADDR, "test_h2t_mmio_burst");
   //test_mmio_burst   (test_result, valid_csr_region,  2, RSTP_T2H_MEM_ADDR, "test_t2h_mmio_burst");
   test_rstp_mmio    (test_result);

end
endtask
