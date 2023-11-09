// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_hssi_err_seq is executed by he_hssi_err_test
// This sequence tests the error registers of HE_HSSI block
// The Error is introduce in traffic by forcing "tuser.client" bits
// Assertion of error is verified in code coverage by reading the HE_HSSI Error register
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_ERR_SEQ_SVH
`define HE_HSSI_ERR_SEQ_SVH

class he_hssi_err_seq extends base_seq;
    `uvm_object_utils(he_hssi_err_seq)

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

    parameter TG_SRC_MAC_L_ADDR=32'hE014; 
    parameter TG_SRC_MAC_H_ADDR=32'hE018;  
    parameter TG_DST_MAC_L_ADDR=32'hE01C;  
    parameter TG_DST_MAC_H_ADDR=32'hE020;  
    
    parameter TG_RANDOM_SEED0_ADDR=32'hE028;  
    parameter TG_RANDOM_SEED1_ADDR=32'hE02C;  
    parameter TG_RANDOM_SEED2_ADDR=32'hE030;  


    rand bit RD_MAC_STATS_EN;
    constraint RD_MAC_STATS_EN_c {
        soft RD_MAC_STATS_EN == 0;
    }

    function new (string name = "he_hssi_err_seq");
        super.new(name);
    endfunction : new
    
    task body();
        super.body();
	`uvm_info(get_name(), "Entering sequence...", UVM_LOW)
        CFG_HSSI();
      for(int err_bit=0;err_bit<7;err_bit++)
       begin
        ERR_TRAFFIC_HEHSSI(err_bit);
	`uvm_info(get_name(), "READING ERROR _REG...", UVM_LOW)
        read_TM_AVST_RX_ERR();
       end
         `uvm_info(get_name(), "GENRATE CRCERROR...", UVM_LOW)
       CRCErr_traffic_10G_25G(0);
        read_TM_AVST_RX_ERR();
       
    endtask 

    task CFG_HSSI();
     logic [63:0] cur_pf_table;
     logic [63:0] framesOK_1,framesOK_2;
	 logic        tx_rx_mismatch = 0;
  	 logic        error_bit = 0;
     bit [31:0] scratch_reg;
	 bit [63:0] tg_num_pkt, tm_pkt_good, tm_pkt_bad;
	`uvm_info(get_name(), "Entering Configure HSSI...", UVM_LOW)

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
         end
        join
    endtask

    task ERR_TRAFFIC_HEHSSI();
     
      input logic[7:0] err_bit; 
      logic [31:0] RDDATA;
      logic [63:0] cur_pf_table;

	`uvm_info(get_name(), "Entering ERR_TRAFFIC_HEHSSI...", UVM_LOW)
        fork
          begin
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE034, 32'h42);
	write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE004, 32'h1);
	    write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE008, 32'h1);
	    write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE000, 32'h1);
	    write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE00C, 32'h1);

           //SRC_MAC_L
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_L_ADDR, 32'hFFFF_FFFF);
           //SRC_MAC_H
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_H_ADDR, 32'hFFFF_FFFF);
           //DST_MAC_L
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_L_ADDR, 32'hFFFF_FFFF);
           //DST_MAC_H
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_H_ADDR, 32'hFFFF_FFFF);
           //RANDOM_SEED0
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR, 32'hFFFF_FFFF);
           //RANDOM_SEED1
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR,32'hFFFF_FFFF);
           //RANDOM_SEED2
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR,32'hFFFF_FFFF);

        
        //FC - TX GEN
        write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h2);
	    write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h0);  
          end
          begin
	  @(posedge tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tlast);
            `uvm_info(get_name(), $psprintf("FORCING ERROR BIT -  = %0d", err_bit), UVM_LOW)
          case(err_bit)
           0:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[0]} ='h1;
           1:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[1]} ='h1;
           2:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[2]} ='h1;
           3:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[3]} ='h1;
           4:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[4]} ='h1;
           5:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[5]} ='h1;
           6:force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[6]} ='h1;
          endcase
         @(negedge tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tlast);
            `uvm_info(get_name(), $psprintf("RELEASE FORCED ERROR BIT -  = %0d", err_bit), UVM_LOW)
         release {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tuser.client[6:0]}; 
       	  end
         join

      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

    
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


	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask

    task write_mailbox();
        input [31:0] cmd_ctrl_addr;
	    input [31:0] addr;
	    input [31:0] write_data32;
	begin
            #50 mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
            #50 mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4      );
            #50 mmio_write32(cmd_ctrl_addr                    , MB_WR       );
	        #50 read_ack_mailbox(cmd_ctrl_addr);
            #50 mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
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

task read_mailbox;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
   input  logic [31:0] addr; //Byte address
   output logic [63:0] rd_data64;
   begin
     #50 mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4); // DW address
     #50 mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
     #50 read_ack_mailbox(cmd_ctrl_addr);
     #50 mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
     $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
     #50 mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
   end
endtask
// Wait until all packets received back
task read_TM_AVST_RX_ERR;
   logic [63:0] wdata;
   logic [63:0] cur_pf_table;
   logic [63:0] addr;
   logic [31:0] ERR_PKT_RCVD;
   logic [31:0] len;
      
    #1us;
    read_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE41C,ERR_PKT_RCVD);
    `uvm_info("body", $sformatf("ERR_REG %b ",ERR_PKT_RCVD), UVM_LOW);

       
 

endtask
task CRCErr_traffic_10G_25G;
   input int len;
   logic [63:0] wdata;
   logic [63:0] addr;
   logic [31:0] scratch1;
   logic [31:0] GOOD_PKT_RCVD;
   logic [31:0] BAD_PKT_RCVD;
   logic [63:0] cur_pf_table;
   logic [31:0] RDDATA;

      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
  fork  
      begin                                                                                                      
     //Set packet length type

         write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE034, 32'h42); //reduce lenght to genrate CRC
	     write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE008, 32'h1);
         write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE000, 32'h10);
	     write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE00C, 32'h1);

        //SRC_MAC_L
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_L_ADDR, 32'h0);
           //SRC_MAC_H
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_H_ADDR, 32'h0);
           //DST_MAC_L
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_L_ADDR, 32'h0);
           //DST_MAC_H
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_H_ADDR, 32'h0);
           //RANDOM_SEED0
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR,32'h0);
           //RANDOM_SEED1
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR,32'h0);
           //RANDOM_SEED2
            write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR,32'h0);

        
        //FC - TX GEN
         write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h2);
         write_mailbox(he_hssi_base_addr+TRAFFIC_CTRL_CMD_ADDR, 32'hE038, 32'h0); 

	    `uvm_info(get_name(), "TRAFFIC_SENT...", UVM_LOW)
        end

        begin
          @(posedge tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tvalid);
           force {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tdata[63:0]} = 64'h1111_2222_3333_4444;
          @(negedge tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tlast);
           release {tb_top.DUT.afu_top.hssi_ss_st_rx[0].rx.tdata[63:0]};
        end
     join

      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

    
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


 endtask
    

endclass : he_hssi_err_seq

`endif // HE_HSSI_ERR_SEQ_SVH
