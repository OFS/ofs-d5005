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
import test_param_defs::*;

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


//-------------------
// Test cases 
//-------------------

// Mailbox write
task write_mailbox;
    input logic [31:0]   bar;
    input logic          vf_active;
    input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
    input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
    input logic [31:0]   cmd_ctrl_addr; // Start address of mailbox access reg
    input logic [31:0]   addr; //Byte address
    input logic [31:0]   write_data32;

    //WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
    begin
        #5000 WRITE32(ADDR32, cmd_ctrl_addr + MB_WRDATA_OFFSET, bar, vf_active, pfn, vfn, write_data32);
        #5000 WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar, vf_active, pfn, vfn, addr/4); 
        #5000 WRITE32(ADDR32, cmd_ctrl_addr, bar, vf_active, pfn, vfn, MB_WR); 
        #5000 read_ack_mailbox(bar, vf_active, pfn, vfn, cmd_ctrl_addr);
        #5000 WRITE32(ADDR32, cmd_ctrl_addr, bar, vf_active, pfn, vfn, MB_NOOP);
        $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end 
endtask

// Mailbox read
task read_mailbox;
    input  logic [64:0]                             cur_pf_table;
    input  logic [31:0]                             bar;
    input  logic                                    vf_active;
    input  logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]   pfn;
    input  logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]   vfn;
    input  logic [31:0]                             cmd_ctrl_addr; // Start address of mailbox access reg
    input  logic [31:0]                             addr; //Byte address
    output logic [64:0]                             rd_data64;

    logic               error;

    begin
        #5000 WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar, vf_active, pfn, vfn, addr/4); // DW address 
        #5000 WRITE32(ADDR32, cmd_ctrl_addr, bar, vf_active, pfn, vfn, MB_RD); // read Cmd
        #5000 read_ack_mailbox(bar, vf_active, pfn, vfn, cmd_ctrl_addr);
        #5000 READ64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar, vf_active, pfn, vfn, rd_data64, error);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            test_utils::incr_err_count();
         end
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data64);
        #5000 WRITE32(ADDR32, cmd_ctrl_addr, bar, vf_active, pfn, vfn, MB_NOOP); // no op Cmd
   end
endtask


// Mailbox ack check
task read_ack_mailbox;
   input  logic [31:0] bar;
   input  logic vf_active;
   input  logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0] pfn;
   input  logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0] vfn;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
          logic [31:0] scratch1;
          logic [4:0]  rd_attempts;
          logic        ack_done;
          logic        error;
   begin
     scratch1     = 32'h0;
     rd_attempts  = 'b0;
     ack_done     = 1'h0;
    
     //$display("JB: vfa=%h, pfn = %h, vfn = %h", vf_active, pfn, vfn);
     while (~ack_done && rd_attempts<15) begin
         READ32(ADDR32, cmd_ctrl_addr, bar, vf_active, pfn, vfn, scratch1, error);
         ack_done = scratch1[2];
         #100000
         rd_attempts=rd_attempts+1;
     end
     if (error || (~ack_done)) begin
       $display("\nERROR: Mailbox Ack failed.\n");
       test_utils::incr_err_count();
     end
     $display("Ack status: 0x%0x",ack_done);
   end
endtask

// Wait until all packets received back
task wait_for_all_eop_done;
   input logic [31:0]  num_pkt;
   logic [31:0]        pkt_cnt;
   begin
      pkt_cnt = 32'h0;
      while (pkt_cnt < num_pkt) begin
         @(posedge top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.he_hssi_top_inst.multi_port_axi_sop_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.rx.eop)
         @(posedge top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.he_hssi_top_inst.multi_port_axi_sop_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.clk)
         pkt_cnt=pkt_cnt+1;
         $display("INFO: Packet received: %d", pkt_cnt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
   end
endtask

task automatic compare_eth_stats;
    input  logic [63:0] cur_pf_table;
    input  logic [31:0] addr1;
    input  logic [31:0] addr2; 
    output logic        error;
    output logic [63:0] framesOK_1;
    output logic [63:0] framesOK_2;
    // Statistic 1
    logic [63:0] framesOK_stat1;
    logic [63:0] framesErr_stat1;
    logic [63:0] framesCRCErr_stat1;
    logic [63:0] octetsOK_stat1;
    logic [63:0] pauseMACCtrlFrames_stat1;
    logic [63:0] ifErrors_stat1;
    logic [63:0] unicastFramesOK_stat1;
    logic [63:0] unicastFramesErr_stat1;
    logic [63:0] multicastFramesOK_stat1;
    logic [63:0] multicastFramesErr_stat1;
    logic [63:0] broadcastFramesOK_stat1;
    logic [63:0] broadcastFramesErr_stat1;
    logic [63:0] etherStatsOctets_stat1;
    logic [63:0] etherStatsPkts_stat1;
    logic [63:0] etherStatsUndersizePkts_stat1;
    logic [63:0] etherStatsOversizePkts_stat1;
    logic [63:0] etherStatsPkts64Octets_stat1;
    logic [63:0] etherStatsPkts65to127Octets_stat1;
    logic [63:0] etherStatsPkts128to255Octets_stat1;
    logic [63:0] etherStatsPkts256to511Octet_stat1;
    logic [63:0] etherStatsPkts512to1023Octets_stat1;
    logic [63:0] etherStatsPkts1024to1518Octets_stat1;
    logic [63:0] etherStatsPkts1519OtoXOctets_stat1;
    logic [63:0] etherStatsFragments_stat1;
    logic [63:0] etherStatsJabbers_stat1;
    logic [63:0] etherStatsCRCErr_stat1;
    logic [63:0] unicastMACCtrlFrames_stat1;
    logic [63:0] multicastMACCtrlFrames_stat1;
    logic [63:0] broadcastMACCtrlFrames_stat1;   
    // Statistic 2
    logic [63:0] framesOK_stat2;
    logic [63:0] framesErr_stat2;
    logic [63:0] framesCRCErr_stat2;
    logic [63:0] octetsOK_stat2;
    logic [63:0] pauseMACCtrlFrames_stat2;
    logic [63:0] ifErrors_stat2;
    logic [63:0] unicastFramesOK_stat2;
    logic [63:0] unicastFramesErr_stat2;
    logic [63:0] multicastFramesOK_stat2;
    logic [63:0] multicastFramesErr_stat2;
    logic [63:0] broadcastFramesOK_stat2;
    logic [63:0] broadcastFramesErr_stat2;
    logic [63:0] etherStatsOctets_stat2;
    logic [63:0] etherStatsPkts_stat2;
    logic [63:0] etherStatsUndersizePkts_stat2;
    logic [63:0] etherStatsOversizePkts_stat2;
    logic [63:0] etherStatsPkts64Octets_stat2;
    logic [63:0] etherStatsPkts65to127Octets_stat2;
    logic [63:0] etherStatsPkts128to255Octets_stat2;
    logic [63:0] etherStatsPkts256to511Octet_stat2;
    logic [63:0] etherStatsPkts512to1023Octets_stat2;
    logic [63:0] etherStatsPkts1024to1518Octets_stat2;
    logic [63:0] etherStatsPkts1519OtoXOctets_stat2;
    logic [63:0] etherStatsFragments_stat2;
    logic [63:0] etherStatsJabbers_stat2;
    logic [63:0] etherStatsCRCErr_stat2;
    logic [63:0] unicastMACCtrlFrames_stat2;
    logic [63:0] multicastMACCtrlFrames_stat2;
    logic [63:0] broadcastMACCtrlFrames_stat2;

    logic error_status = 0;

    // Read Statistic 1
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesOK_OFFSET, framesOK_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesErr_OFFSET, framesErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesCRCErr_OFFSET, framesCRCErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_octetsOK_OFFSET, octetsOK_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_pauseMACCtrlFrames_OFFSET, pauseMACCtrlFrames_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_ifErrors_OFFSET, ifErrors_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastFramesOK_OFFSET, unicastFramesOK_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastFramesErr_OFFSET, unicastFramesErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastFramesOK_OFFSET, multicastFramesOK_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastFramesErr_OFFSET, multicastFramesErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastFramesOK_OFFSET, broadcastFramesOK_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastFramesErr_OFFSET, broadcastFramesErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsOctets_OFFSET, etherStatsOctets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts_OFFSET, etherStatsPkts_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsUndersizePkts_OFFSET, etherStatsUndersizePkts_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsOversizePkts_OFFSET, etherStatsOversizePkts_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts64Octets_OFFSET, etherStatsPkts64Octets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts65to127Octets_OFFSET, etherStatsPkts65to127Octets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts128to255Octets_OFFSET, etherStatsPkts128to255Octets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts256to511Octets_OFFSET, etherStatsPkts256to511Octet_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts512to1023Octets_OFFSET, etherStatsPkts512to1023Octets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatPkts1024to1518Octets_OFFSET, etherStatsPkts1024to1518Octets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts1519toXOctets_OFFSET, etherStatsPkts1519OtoXOctets_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsFragments_OFFSET, etherStatsFragments_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsJabbers_OFFSET, etherStatsJabbers_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsCRCErr_OFFSET, etherStatsCRCErr_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastMACCtrlFrames_OFFSET, unicastMACCtrlFrames_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastMACCtrlFrames_OFFSET, multicastMACCtrlFrames_stat1);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastMACCtrlFrames_OFFSET, broadcastMACCtrlFrames_stat1);

    // Read Statistic 2
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesOK_OFFSET, framesOK_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesErr_OFFSET, framesErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesCRCErr_OFFSET, framesCRCErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_octetsOK_OFFSET, octetsOK_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_pauseMACCtrlFrames_OFFSET, pauseMACCtrlFrames_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_ifErrors_OFFSET, ifErrors_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastFramesOK_OFFSET, unicastFramesOK_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastFramesErr_OFFSET, unicastFramesErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastFramesOK_OFFSET, multicastFramesOK_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastFramesErr_OFFSET, multicastFramesErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastFramesOK_OFFSET, broadcastFramesOK_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastFramesErr_OFFSET, broadcastFramesErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsOctets_OFFSET, etherStatsOctets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts_OFFSET, etherStatsPkts_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsUndersizePkts_OFFSET, etherStatsUndersizePkts_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsOversizePkts_OFFSET, etherStatsOversizePkts_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts64Octets_OFFSET, etherStatsPkts64Octets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts65to127Octets_OFFSET, etherStatsPkts65to127Octets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts128to255Octets_OFFSET, etherStatsPkts128to255Octets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts256to511Octets_OFFSET, etherStatsPkts256to511Octet_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts512to1023Octets_OFFSET, etherStatsPkts512to1023Octets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatPkts1024to1518Octets_OFFSET, etherStatsPkts1024to1518Octets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts1519toXOctets_OFFSET, etherStatsPkts1519OtoXOctets_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsFragments_OFFSET, etherStatsFragments_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsJabbers_OFFSET, etherStatsJabbers_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsCRCErr_OFFSET, etherStatsCRCErr_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastMACCtrlFrames_OFFSET, unicastMACCtrlFrames_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastMACCtrlFrames_OFFSET, multicastMACCtrlFrames_stat2);
    read_mailbox(cur_pf_table, 0, 0, 0, 0, HSSI_BASE_ADDR + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastMACCtrlFrames_OFFSET, broadcastMACCtrlFrames_stat2);

    // Display the collected statistics of the MAC
    $display("\n-------------");
    $display("TX Statistics");
    $display("-------------");
    $display("\tframesOK                          = %0d", framesOK_stat1);
    $display("\tframesErr                         = %0d", framesErr_stat1);
    $display("\tframesCRCErr                      = %0d", framesCRCErr_stat1);
    $display("\toctetsOK                          = %0d", octetsOK_stat1);
    $display("\tpauseMACCtrlFrames                = %0d", pauseMACCtrlFrames_stat1);
    $display("\tifErrors                          = %0d", ifErrors_stat1);
    $display("\tunicastFramesOK                   = %0d", unicastFramesOK_stat1);
    $display("\tunicastFramesErr                  = %0d", unicastFramesErr_stat1);
    $display("\tmulticastFramesOK                 = %0d", multicastFramesOK_stat1);
    $display("\tmulticastFramesErr                = %0d", multicastFramesErr_stat1);
    $display("\tbroadcastFramesOK                 = %0d", broadcastFramesOK_stat1);
    $display("\tbroadcastFramesErr                = %0d", broadcastFramesErr_stat1);
    $display("\tetherStatsOctets                  = %0d", etherStatsOctets_stat1);
    $display("\tetherStatsPkts                    = %0d", etherStatsPkts_stat1);
    $display("\tetherStatsUndersizePkts           = %0d", etherStatsUndersizePkts_stat1);
    $display("\tetherStatsOversizePkts            = %0d", etherStatsOversizePkts_stat1);
    $display("\tetherStatsPkts64Octets            = %0d", etherStatsPkts64Octets_stat1);
    $display("\tetherStatsPkts65to127Octets       = %0d", etherStatsPkts65to127Octets_stat1);
    $display("\tetherStatsPkts128to255Octets      = %0d", etherStatsPkts128to255Octets_stat1);
    $display("\tetherStatsPkts256to511Octet       = %0d", etherStatsPkts256to511Octet_stat1);
    $display("\tetherStatsPkts512to1023Octets     = %0d", etherStatsPkts512to1023Octets_stat1);
    $display("\tetherStatsPkts1024to1518Octets    = %0d", etherStatsPkts1024to1518Octets_stat1);
    $display("\tetherStatsPkts1519OtoXOctets      = %0d", etherStatsPkts1519OtoXOctets_stat1);
    $display("\tetherStatsFragments               = %0d", etherStatsFragments_stat1);
    $display("\tetherStatsJabbers                 = %0d", etherStatsJabbers_stat1);
    $display("\tetherStatsCRCErr                  = %0d", etherStatsCRCErr_stat1);
    $display("\tunicastMACCtrlFrames              = %0d", unicastMACCtrlFrames_stat1);
    $display("\tmulticastMACCtrlFrames            = %0d", multicastMACCtrlFrames_stat1);
    $display("\tbroadcastMACCtrlFrames            = %0d", broadcastMACCtrlFrames_stat1);

    $display("\n-------------");
    $display("RX Statistics");
    $display("-------------");
    $display("\tframesOK                          = %0d", framesOK_stat2);
    $display("\tframesErr                         = %0d", framesErr_stat2);
    $display("\tframesCRCErr                      = %0d", framesCRCErr_stat2);
    $display("\toctetsOK                          = %0d", octetsOK_stat2);
    $display("\tpauseMACCtrlFrames                = %0d", pauseMACCtrlFrames_stat2);
    $display("\tifErrors                          = %0d", ifErrors_stat2);
    $display("\tunicastFramesOK                   = %0d", unicastFramesOK_stat2);
    $display("\tunicastFramesErr                  = %0d", unicastFramesErr_stat2);
    $display("\tmulticastFramesOK                 = %0d", multicastFramesOK_stat2);
    $display("\tmulticastFramesErr                = %0d", multicastFramesErr_stat2);
    $display("\tbroadcastFramesOK                 = %0d", broadcastFramesOK_stat2);
    $display("\tbroadcastFramesErr                = %0d", broadcastFramesErr_stat2);
    $display("\tetherStatsOctets                  = %0d", etherStatsOctets_stat2);
    $display("\tetherStatsPkts                    = %0d", etherStatsPkts_stat2);
    $display("\tetherStatsUndersizePkts           = %0d", etherStatsUndersizePkts_stat2);
    $display("\tetherStatsOversizePkts            = %0d", etherStatsOversizePkts_stat2);
    $display("\tetherStatsPkts64Octets            = %0d", etherStatsPkts64Octets_stat2);
    $display("\tetherStatsPkts65to127Octets       = %0d", etherStatsPkts65to127Octets_stat2);
    $display("\tetherStatsPkts128to255Octets      = %0d", etherStatsPkts128to255Octets_stat2);
    $display("\tetherStatsPkts256to511Octet       = %0d", etherStatsPkts256to511Octet_stat2);
    $display("\tetherStatsPkts512to1023Octets     = %0d", etherStatsPkts512to1023Octets_stat2);
    $display("\tetherStatsPkts1024to1518Octets    = %0d", etherStatsPkts1024to1518Octets_stat2);
    $display("\tetherStatsPkts1519OtoXOctets      = %0d", etherStatsPkts1519OtoXOctets_stat2);
    $display("\tetherStatsFragments               = %0d", etherStatsFragments_stat2);
    $display("\tetherStatsJabbers                 = %0d", etherStatsJabbers_stat2);
    $display("\tetherStatsCRCErr                  = %0d", etherStatsCRCErr_stat2);
    $display("\tunicastMACCtrlFrames              = %0d", unicastMACCtrlFrames_stat2);
    $display("\tmulticastMACCtrlFrames            = %0d", multicastMACCtrlFrames_stat2);
    $display("\tbroadcastMACCtrlFrames            = %0d", broadcastMACCtrlFrames_stat2);

    // Check for err statistic for stat1, must be 0
    if(framesErr_stat1 != 0 || framesCRCErr_stat1 != 0 || ifErrors_stat1 != 0 || unicastFramesErr_stat1 != 0 || 
       multicastFramesErr_stat1 != 0 || broadcastFramesErr_stat1 != 0 || etherStatsCRCErr_stat1 != 0) begin
        error_status = 1;
    end

    // Check for err statistic for stat2, must be 0
    if(framesErr_stat2 != 0 || framesCRCErr_stat2 != 0 || ifErrors_stat2 != 0 || unicastFramesErr_stat2 != 0 || 
       multicastFramesErr_stat2 != 0 || broadcastFramesErr_stat2 != 0 || etherStatsCRCErr_stat2 != 0) begin
        error_status = 1;
    end

    // Compare non-err statistic between stat1 & stat2, they must be equal
    if(framesOK_stat1 != framesOK_stat2 || octetsOK_stat1 != octetsOK_stat2 || pauseMACCtrlFrames_stat1 != pauseMACCtrlFrames_stat2 ||
       unicastFramesOK_stat1 != unicastFramesOK_stat2 || multicastFramesOK_stat1 != multicastFramesOK_stat2 || broadcastFramesOK_stat1 != broadcastFramesOK_stat2 || 
       etherStatsOctets_stat1 != etherStatsOctets_stat2 || etherStatsPkts_stat1 != etherStatsPkts_stat2 || etherStatsUndersizePkts_stat1 != etherStatsUndersizePkts_stat2 ||
       etherStatsOversizePkts_stat1 != etherStatsOversizePkts_stat2 || etherStatsPkts64Octets_stat1 != etherStatsPkts64Octets_stat2 ||
       etherStatsPkts65to127Octets_stat1 != etherStatsPkts65to127Octets_stat2 || etherStatsPkts128to255Octets_stat1 != etherStatsPkts128to255Octets_stat2 ||
       etherStatsPkts256to511Octet_stat1 != etherStatsPkts256to511Octet_stat2 || etherStatsPkts512to1023Octets_stat1 != etherStatsPkts512to1023Octets_stat2 ||
       etherStatsPkts1024to1518Octets_stat1 != etherStatsPkts1024to1518Octets_stat2 || etherStatsPkts1519OtoXOctets_stat1 != etherStatsPkts1519OtoXOctets_stat2 ||
       etherStatsFragments_stat1 != etherStatsFragments_stat2 || etherStatsJabbers_stat1 != etherStatsJabbers_stat2 ||
       unicastMACCtrlFrames_stat1 != unicastMACCtrlFrames_stat2 || multicastMACCtrlFrames_stat1 != multicastMACCtrlFrames_stat2 ||
       broadcastMACCtrlFrames_stat1 != broadcastMACCtrlFrames_stat2) begin
        error_status = 1;
    end

    framesOK_1 = framesOK_stat1;
    framesOK_2 = framesOK_stat2;
    error = error_status;

endtask : compare_eth_stats

task test_traffic;
    input access32;
    logic [63:0]    cur_pf_table;
    logic [63:0]    framesOK_1,framesOK_2;
    static logic           tx_rx_mismatch = 0;
    static logic           RD_MAC_STATS_EN = 1;
    logic [63:0]    scratch1,scratch2;
    logic [31:0]    scratch32;

    begin
        $display("Entering sequence!");
        #36000ns // Wait for HSSI initialization in MAC and PHY 

      //Set packet length
      write_mailbox(0, 1, 0, 2, HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_ADDR, TG_PKT_LEN_VAL);
      //Set Random payload
      write_mailbox(0, 1, 0, 2, HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_DATA_PATTERN_ADDR, TG_DATA_PATTERN_VAL);
      //Set number of packets
      write_mailbox(0, 1, 0, 2, HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_NUM_PKT_ADDR, TG_NUM_PKT_VAL); // num of packets
      //Set start to send packets
      write_mailbox(0, 1, 0, 2, HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, 32'h1);

      //wait_for_all_eop_done(TG_START_XFR_ADDR);
      #5000ns // To allow enough time to receive all the packets on rx.

      // Good packet received at Traffic monitor
      read_mailbox(cur_pf_table, 0, 1, 0, 2, HE_HSSI_BASE_ADDR + TRAFFIC_CTRL_CMD_ADDR, TM_PKT_GOOD_ADDR, scratch1);
      scratch32 = scratch1[31:0];
      if (scratch32 != TG_NUM_PKT_VAL) begin
          $display("\nError: Received good packets does not match Transmitted packets!\n");
          $display("Number of Good Packets Received: \tExpected: %0d\n \tRead:%0d", TG_NUM_PKT_VAL, scratch32);
          test_utils::incr_err_count();
      end else begin
          $display("INFO: Number of Good Packets Received:%0d", scratch32);
      end

      // Bad packet received at Traffic monitor
      read_mailbox(cur_pf_table, 0, 1, 0, 2, HE_HSSI_BASE_ADDR + TRAFFIC_CTRL_CMD_ADDR, TM_PKT_BAD_ADDR, scratch1);
      scratch32 = scratch1[31:0];
      if (scratch32 != 32'h0) begin
          $display("\nError: Received bad packets > 0!\n");
          $display("Number of Bad Packets Received: \tExpected: %0d\n \tRead: %0d",32'h0,scratch32);
          test_utils::incr_err_count();
      end else begin
          $display("INFO: Number of Bad Packets Received:%0d", scratch32);
      end

      // Check MAC Stats
      if(RD_MAC_STATS_EN) begin
         compare_eth_stats(cur_pf_table, HSSI_BASE_ADDR + TX_STATISTICS_ADDR, HSSI_BASE_ADDR + RX_STATISTICS_ADDR, tx_rx_mismatch, framesOK_1, framesOK_2);
         if(tx_rx_mismatch) begin
         $display("\nERROR: RX MAC statistic does not match TX MAC statistic.");
               test_utils::incr_err_count();
         end
         else begin
            if(framesOK_1 != 32 || framesOK_2 != 32) begin
               $display("\nERROR: framesOK size in MAC statistic does not match FRAMESOK_SIZE defined in testcase.");  
                     test_utils::incr_err_count();
            end
         end
      end

        $display("Exiting sequence!");
    end
endtask


// HSSI Traffic test
task traffic_test;
   input logic  access32;
   logic [31:0] old_test_err_count;
   begin 
      print_test_header("traffic_test");
      old_test_err_count = test_utils::get_err_count();

      // Wait for ready before starting the test
      assert_afu_reset(PORT_CONTROL);
      deassert_afu_reset(PORT_CONTROL);

      test_traffic(access32);

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
   traffic_test (1); // Pass 1 for 32-bit access to mailbox, 0 for 64-bit
end
endtask
