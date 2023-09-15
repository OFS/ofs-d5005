// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_hssi_tx_lpbk_seq is executed by he_hssi_tx_lpbk_test 
// This sequence generate the PKTs from HE-HSSI block and external loopback is done at QSFP level
// The Number of good and bad pacekts are captured in HE_HSSI registers
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_TX_LPBK_SEQ_SVH
`define HE_HSSI_TX_LPBK_SEQ_SVH

class he_hssi_tx_lpbk_seq extends base_seq;
    `uvm_object_utils(he_hssi_tx_lpbk_seq)

    parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;
    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_NOOP = 32'h0;
    parameter MB_RD = 32'h1;
    parameter MB_WR = 32'h2;
    parameter RX_STATISTICS_ADDR = 32'h3000;
    parameter TX_STATISTICS_ADDR = 32'h7000;
    parameter HSSI_RCFG_CMD_ADDR = 32'h28;

    parameter TG_SRC_MAC_L_ADDR=32'hE014; 
    parameter TG_SRC_MAC_H_ADDR=32'hE018;  
    parameter TG_DST_MAC_L_ADDR=32'hE01C;  
    parameter TG_DST_MAC_H_ADDR=32'hE020;  
    
    parameter TG_RANDOM_SEED0_ADDR=32'hE028;  
    parameter TG_RANDOM_SEED1_ADDR=32'hE02C;  
    parameter TG_RANDOM_SEED2_ADDR=32'hE030;  


    parameter STATISTICS_framesOK_OFFSET                        = 32'h008;
    parameter STATISTICS_framesErr_OFFSET                       = 32'h010;
    parameter STATISTICS_framesCRCErr_OFFSET                    = 32'h018;
    parameter STATISTICS_octetsOK_OFFSET                        = 32'h020;
    parameter STATISTICS_pauseMACCtrlFrames_OFFSET              = 32'h028;
    parameter STATISTICS_ifErrors_OFFSET                        = 32'h030;
    parameter STATISTICS_unicastFramesOK_OFFSET                 = 32'h038;
    parameter STATISTICS_unicastFramesErr_OFFSET                = 32'h040;
    parameter STATISTICS_multicastFramesOK_OFFSET               = 32'h048;
    parameter STATISTICS_multicastFramesErr_OFFSET              = 32'h050;
    parameter STATISTICS_broadcastFramesOK_OFFSET               = 32'h058;
    parameter STATISTICS_broadcastFramesErr_OFFSET              = 32'h060;
    parameter STATISTICS_etherStatsOctets_OFFSET                = 32'h068;
    parameter STATISTICS_etherStatsPkts_OFFSET                  = 32'h070;
    parameter STATISTICS_etherStatsUndersizePkts_OFFSET         = 32'h078;
    parameter STATISTICS_etherStatsOversizePkts_OFFSET          = 32'h080;
    parameter STATISTICS_etherStatsPkts64Octets_OFFSET          = 32'h088;
    parameter STATISTICS_etherStatsPkts65to127Octets_OFFSET     = 32'h090;
    parameter STATISTICS_etherStatsPkts128to255Octets_OFFSET    = 32'h098;
    parameter STATISTICS_etherStatsPkts256to511Octets_OFFSET    = 32'h0A0;
    parameter STATISTICS_etherStatsPkts512to1023Octets_OFFSET   = 32'h0A8;
    parameter STATISTICS_etherStatPkts1024to1518Octets_OFFSET   = 32'h0B0;
    parameter STATISTICS_etherStatsPkts1519toXOctets_OFFSET     = 32'h0B8;
    parameter STATISTICS_etherStatsFragments_OFFSET             = 32'h0C0;
    parameter STATISTICS_etherStatsJabbers_OFFSET               = 32'h0C8;
    parameter STATISTICS_etherStatsCRCErr_OFFSET                = 32'h0D0;
    parameter STATISTICS_unicastMACCtrlFrames_OFFSET            = 32'h0D8;
    parameter STATISTICS_multicastMACCtrlFrames_OFFSET          = 32'h0E0;
    parameter STATISTICS_broadcastMACCtrlFrames_OFFSET          = 32'h0E8;

    rand bit RD_MAC_STATS_EN;
    constraint RD_MAC_STATS_EN_c {
        soft RD_MAC_STATS_EN == 0;
    }

    function new (string name = "he_hssi_tx_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
        logic [31:0] RDDATA;
        logic [63:0] cur_pf_table;
        logic [63:0] framesOK_1,framesOK_2;
	logic        tx_rx_mismatch = 0;
	logic        error_bit = 0;
        bit [31:0] scratch_reg;
	bit [63:0] tg_num_pkt, tm_pkt_good, tm_pkt_bad;
        super.body();
	`uvm_info(get_name(), "Entering sequence...", UVM_LOW)

        fork
        begin
        //Pause-MAC Registers
        write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h4508, 32'h1); //0x44   
	write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h4680, 32'h0); //0x46    
	write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h2000, 32'h0); //0xAC   
	write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h2060, 32'h1); //0x0C0  
        //Pause Frame quanta
        write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h4500, 32'h2); //0x040
        write_mailbox(hssi_base_addr+HSSI_RCFG_CMD_ADDR, 32'h4504, 32'h5); //0x042

        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE034, 32'h42);
	write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE008, 32'h1);
	write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE000, 32'h2000);

      	//RANDOM_SEED0
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR, $urandom);
        //RANDOM_SEED1
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR, $urandom);
        //RANDOM_SEED2
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR, $urandom);

	write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE00C, 32'h1);

               
        //FC - TX GEN
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h2);
	write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h0);

         end
     `ifdef INCLUDE_HSSI
        begin
            @(posedge tb_top.DUT.eth_ac_wrapper.eth_top.core_clk_156);
            @(negedge tb_top.DUT.eth_ac_wrapper.eth_top.avalon_st_rxstatus_data_156[0]);
                 `uvm_info(get_name(), $psprintf("Pause Frame De-asserted, Pause frame test successful"), UVM_LOW)
            
        end
     `endif
         join
    
	#2us;
	fork
	    begin
	        do begin
	            // reading TG_NUM_PKT
	            read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE000, tg_num_pkt);
	            // reading TM_PKG_GOOD
	            read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE404, tm_pkt_good);
	            #1us;
	        end 
	        while(tg_num_pkt[31:0] != tm_pkt_good[31:0]);
	    end
	    begin
	        #1ms;
	    end
	join_any
         
        //READ_MONITOR
        //SRC_MAC_L
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_L_ADDR, RDDATA);      
        //SRC_MAC_H
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_H_ADDR, RDDATA);
        //DST_MAC_L
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_L_ADDR, RDDATA);
        //DST_MAC_H
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_H_ADDR, RDDATA);
        //RANDOM_SEED0
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR, RDDATA);
        //RANDOM_SEED1
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR, RDDATA);
        //RANDOM_SEED2
         read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR, RDDATA);


	if(tg_num_pkt == tm_pkt_good) begin
	    // reading TM_PKT_BAD
	    `uvm_info(get_name(), $psprintf("TG_NUM_PKT = TM_PKT_GOOD = %0d", tg_num_pkt), UVM_LOW)
	    read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE408, tm_pkt_bad);
	    if(tm_pkt_bad[31:0] != 0)
	        `uvm_error(get_name(), $psprintf("TM_PKT_BAD is not 0, it is %0d", tm_pkt_bad))
	end
	else begin
	    `uvm_error(get_name(), $psprintf("TIMEOUT: tg_num_pkt != tm_pkt_good for 10us, tg_num_pkt = %0d, tm_pkt_good = %0d", tg_num_pkt, tm_pkt_good))
	end

	disable fork;

        #5000ns;
	if(RD_MAC_STATS_EN) begin
	    compare_eth_stats(cur_pf_table, hssi_base_addr + TX_STATISTICS_ADDR, hssi_base_addr + RX_STATISTICS_ADDR, tx_rx_mismatch, framesOK_1, framesOK_2);
	    if(tx_rx_mismatch) begin
	        error_bit = 1;
		`uvm_error(get_name(), "RX MAC statistic does not match TX MAC statistic.")
	    end
	    else begin
	        if(framesOK_1 != 32 || framesOK_2 != 32) begin
	        error_bit = 1;
		`uvm_error(get_name(), "framesOK size in MAC statistic does not match FRAMESOK_SIZE defined in testcase.")
		end
	    end
	end

        check_afu_intf_error();
        

	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask : body

    task write_mailbox();
        input [31:0] cmd_ctrl_addr;
	input [31:0] addr;
	input [31:0] write_data32;
	begin
             mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
             mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4      );
             mmio_write32(cmd_ctrl_addr                    , MB_WR       );
	     read_ack_mailbox(cmd_ctrl_addr);
             mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
	end
    endtask : write_mailbox

    task read_ack_mailbox;
        input bit [63:0] cmd_ctrl_addr;
        begin
	    bit [63:0] rdata = 64'h0;
	    int        rd_attempts = 0;
	    bit        ack_done_reg = 0;
	    while(~ack_done_reg && rd_attempts < 7) begin
                mmio_read64(cmd_ctrl_addr, rdata);
		ack_done_reg = rdata[2];
		rd_attempts++;
	    end

	    if(~ack_done_reg)
	        `uvm_fatal(get_name(), "Did not ACK for last transaction!")

	end
    endtask : read_ack_mailbox

    task compare_eth_stats();
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
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesOK_OFFSET, framesOK_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesErr_OFFSET, framesErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_framesCRCErr_OFFSET, framesCRCErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_octetsOK_OFFSET, octetsOK_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_pauseMACCtrlFrames_OFFSET, pauseMACCtrlFrames_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_ifErrors_OFFSET, ifErrors_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastFramesOK_OFFSET, unicastFramesOK_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastFramesErr_OFFSET, unicastFramesErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastFramesOK_OFFSET, multicastFramesOK_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastFramesErr_OFFSET, multicastFramesErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastFramesOK_OFFSET, broadcastFramesOK_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastFramesErr_OFFSET, broadcastFramesErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsOctets_OFFSET, etherStatsOctets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts_OFFSET, etherStatsPkts_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsUndersizePkts_OFFSET, etherStatsUndersizePkts_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsOversizePkts_OFFSET, etherStatsOversizePkts_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts64Octets_OFFSET, etherStatsPkts64Octets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts65to127Octets_OFFSET, etherStatsPkts65to127Octets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts128to255Octets_OFFSET, etherStatsPkts128to255Octets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts256to511Octets_OFFSET, etherStatsPkts256to511Octet_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts512to1023Octets_OFFSET, etherStatsPkts512to1023Octets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatPkts1024to1518Octets_OFFSET, etherStatsPkts1024to1518Octets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsPkts1519toXOctets_OFFSET, etherStatsPkts1519OtoXOctets_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsFragments_OFFSET, etherStatsFragments_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsJabbers_OFFSET, etherStatsJabbers_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_etherStatsCRCErr_OFFSET, etherStatsCRCErr_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_unicastMACCtrlFrames_OFFSET, unicastMACCtrlFrames_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_multicastMACCtrlFrames_OFFSET, multicastMACCtrlFrames_stat1);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR, addr1 + STATISTICS_broadcastMACCtrlFrames_OFFSET, broadcastMACCtrlFrames_stat1);
  
        // Read Statistic 2
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesOK_OFFSET, framesOK_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesErr_OFFSET, framesErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_framesCRCErr_OFFSET, framesCRCErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_octetsOK_OFFSET, octetsOK_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_pauseMACCtrlFrames_OFFSET, pauseMACCtrlFrames_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_ifErrors_OFFSET, ifErrors_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastFramesOK_OFFSET, unicastFramesOK_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastFramesErr_OFFSET, unicastFramesErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastFramesOK_OFFSET, multicastFramesOK_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastFramesErr_OFFSET, multicastFramesErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastFramesOK_OFFSET, broadcastFramesOK_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastFramesErr_OFFSET, broadcastFramesErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsOctets_OFFSET, etherStatsOctets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts_OFFSET, etherStatsPkts_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsUndersizePkts_OFFSET, etherStatsUndersizePkts_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsOversizePkts_OFFSET, etherStatsOversizePkts_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts64Octets_OFFSET, etherStatsPkts64Octets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts65to127Octets_OFFSET, etherStatsPkts65to127Octets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts128to255Octets_OFFSET, etherStatsPkts128to255Octets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts256to511Octets_OFFSET, etherStatsPkts256to511Octet_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts512to1023Octets_OFFSET, etherStatsPkts512to1023Octets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatPkts1024to1518Octets_OFFSET, etherStatsPkts1024to1518Octets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsPkts1519toXOctets_OFFSET, etherStatsPkts1519OtoXOctets_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsFragments_OFFSET, etherStatsFragments_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsJabbers_OFFSET, etherStatsJabbers_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_etherStatsCRCErr_OFFSET, etherStatsCRCErr_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_unicastMACCtrlFrames_OFFSET, unicastMACCtrlFrames_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_multicastMACCtrlFrames_OFFSET, multicastMACCtrlFrames_stat2);
        read_mailbox(hssi_base_addr + HSSI_RCFG_CMD_ADDR,addr2 + STATISTICS_broadcastMACCtrlFrames_OFFSET, broadcastMACCtrlFrames_stat2);
  
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

task read_mailbox;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
   input  logic [31:0] addr; //Byte address
   output logic [63:0] rd_data64;
   begin
      mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4); // DW address
      mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
      read_ack_mailbox(cmd_ctrl_addr);
      mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
     $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
      mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
   end
endtask
    

endclass : he_hssi_tx_lpbk_seq

`endif // HE_HSSI_TX_LPBK_SEQ_SVH
