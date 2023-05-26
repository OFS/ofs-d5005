// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class hehssi_csr_seq is executed by hehssi_csr_test
// MMIO access for HE HSSI Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HEHSSI_CSR_SEQ_SVH
`define HEHSSI_CSR_SEQ_SVH

class hehssi_csr_seq extends base_seq;
    `uvm_object_utils(hehssi_csr_seq)

    parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;
    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_NOOP = 32'h0;
    parameter MB_RD = 32'h1;
    parameter MB_WR = 32'h2;

    function new(string name = "hehssi_csr_seq");
        super.new(name);
    endfunction : new

    //virtual function void get_regs();
    //    tb_env0.hehssi_regs.get_registers(m_regs);
    //endfunction : get_regs

    task body();
       bit [31:0] wdata32, rdata32, mask, addr;
       bit [63:0] wdata64, rdata64;
       string reg_name;
       super.body();

       check_rst_value();

       // TG_NUM_PKT
       std::randomize(wdata32);
       rw_check("TG_NUM_PKT", 32'h3800, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_NUM_PKT", 32'h3800, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_NUM_PKT", 32'h3800, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_NUM_PKT", 32'h3800, wdata32, 32'hffff_ffff);
       

       // TG_PKT_LEN_TYPE
       rw_check("TG_PKT_LEN_TYPE", 32'h3801, 32'h1, 32'h1);
       rw_check("TG_PKT_LEN_TYPE", 32'h3801, 32'h0, 32'h1);

       // TG_DATA_PATTERN
       rw_check("TG_DATA_PATTERN", 32'h3802, 32'h1, 32'h1);
       rw_check("TG_DATA_PATTERN", 32'h3802, 32'h0, 32'h1);

        
       rw_check("TG_PKT_LEN_TYPE", 32'h3801, 32'h1, 32'h1);
       rw_check("TG_DATA_PATTERN", 32'h3802, 32'h1, 32'h1);
        
       // TG_START_XFR
       rw_check("TG_START_XFR", 32'h3803, 32'h1, 32'h0);
       rw_check("TG_START_XFR", 32'h3803, 32'h0, 32'h0);

       // TG_STOP_XFR
       rw_check("TG_STOP_XFR", 32'h3804, 32'h1, 32'h1);
       rw_check("TG_STOP_XFR", 32'h3804, 32'h0, 32'h1);

       // TG_SRC_MAC_L
       std::randomize(wdata32);
       rw_check("TG_SRC_MAC_L", 32'h3805, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_SRC_MAC_L", 32'h3805, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_SRC_MAC_L", 32'h3805, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_SRC_MAC_L", 32'h3805, wdata32, 32'hffff_ffff);


       // TG_SRC_MAC_H
       std::randomize(wdata32);
       rw_check("TG_SRC_MAC_H", 32'h3806, wdata32, 32'hffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_SRC_MAC_H", 32'h3806, wdata32, 32'hffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_SRC_MAC_H", 32'h3806, wdata32, 32'hffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_SRC_MAC_H", 32'h3806, wdata32, 32'hffff);


       // TG_DST_MAC_L
       std::randomize(wdata32);
       rw_check("TG_DST_MAC_L", 32'h3807, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_DST_MAC_L", 32'h3807, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_DST_MAC_L", 32'h3807, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_DST_MAC_L", 32'h3807, wdata32, 32'hffff_ffff);



       // TG_DST_MAC_H
       std::randomize(wdata32);
       rw_check("TG_DST_MAC_H", 32'h3808, wdata32, 32'hffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_DST_MAC_H", 32'h3808, wdata32, 32'hffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_DST_MAC_H", 32'h3808, wdata32, 32'hffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_DST_MAC_H", 32'h3808, wdata32, 32'hffff);



       // TG_RANDOM_SEED0
       std::randomize(wdata32);
       rw_check("TG_RANDOM_SEED0", 32'h380A, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_RANDOM_SEED0", 32'h380A, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_RANDOM_SEED0", 32'h380A, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_RANDOM_SEED0", 32'h380A, wdata32, 32'hffff_ffff);



       // TG_RANDOM_SEED1
       std::randomize(wdata32);
       rw_check("TG_RANDOM_SEED1", 32'h380B, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_RANDOM_SEED1", 32'h380B, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_RANDOM_SEED1", 32'h380B, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_RANDOM_SEED1", 32'h380B, wdata32, 32'hffff_ffff);



       // TG_RANDOM_SEED2
       std::randomize(wdata32);
       rw_check("TG_RANDOM_SEED2", 32'h380C, wdata32, 32'h0fff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_RANDOM_SEED2", 32'h380C, wdata32, 32'h0fff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_RANDOM_SEED2", 32'h380C, wdata32, 32'h0fff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_RANDOM_SEED2", 32'h380C, wdata32, 32'h0fff_ffff);



       // TG_PKT_LEN
       std::randomize(wdata32);
       rw_check("TG_PKT_LEN", 32'h380D, wdata32, 32'h3fff);

       wdata32 = 32'hffff_ffff;
       rw_check("TG_PKT_LEN", 32'h380D, wdata32, 32'h3fff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TG_PKT_LEN", 32'h380D, wdata32, 32'h3fff);

       wdata32 = 32'h0000_0000;
       rw_check("TG_PKT_LEN", 32'h380D, wdata32, 32'h3fff);



       // TM_NUM_PKT
       std::randomize(wdata32);
       rw_check("TM_NUM_PKT", 32'h3900, wdata32, 32'hffff_ffff);

       wdata32 = 32'hffff_ffff;
       rw_check("TM_NUM_PKT", 32'h3900, wdata32, 32'hffff_ffff);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("TM_NUM_PKT", 32'h3900, wdata32, 32'hffff_ffff);

       wdata32 = 32'h0000_0000;
       rw_check("TM_NUM_PKT", 32'h3900, wdata32, 32'hffff_ffff);



       // LOOPBACK_EN
       std::randomize(wdata32);
       rw_check("LOOPBACK_EN", 32'h3A00, wdata32, 32'h1);

       wdata32 = 32'hffff_ffff;
       rw_check("LOOPBACK_EN", 32'h3A00, wdata32, 32'h1);

       wdata32 = 32'hAAAA_AAAA;
       rw_check("LOOPBACK_EN", 32'h3A00, wdata32, 32'h1);

       wdata32 = 32'h0000_0000;
       rw_check("LOOPBACK_EN", 32'h3A00, wdata32, 32'h1);

       check_afu_intf_error();

    endtask : body

    task rw_check();
        input string reg_name;
	input bit [31:0] addr;
	input bit [31:0] wdata32;
	input bit [31:0] mask;

	begin
	    bit [63:0] rdata64;
            write_mailbox(he_hssi_base_addr + TRAFFIC_CTRL_CMD_ADDR, addr*4, wdata32);
            read_mailbox(he_hssi_base_addr + TRAFFIC_CTRL_CMD_ADDR, addr*4, rdata64);
            if((wdata32 & mask) !== (rdata64[31:0] & mask))
                `uvm_error(get_full_name(), $psprintf("Data mismatch for %s wdata = %0h rdata = %0h mask = %0h", reg_name, wdata32,rdata64[31:0], mask))
        end
    endtask : rw_check

    task write_mailbox();
        input [31:0] cmd_ctrl_addr;
	input [31:0] addr;
	input [31:0] write_data32;
	begin
            #5000 mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
            #5000 mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4      );
            #5000 mmio_write32(cmd_ctrl_addr                    , MB_WR       );
	    #5000 read_ack_mailbox(cmd_ctrl_addr);
            #5000 mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
	end
    endtask : write_mailbox

    task read_mailbox;
       input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
       input  logic [31:0] addr; //Byte address
       output logic [63:0] rd_data64;
       begin
         #5000 mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr/4); // DW address
         #5000 mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
         #5000 read_ack_mailbox(cmd_ctrl_addr);
         #5000 mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
         #5000 mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
       end
    endtask

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

    task check_rst_value();
        bit [63:0] act_dat, exp_dat;
	uvm_status_e status;
	tb_env0.hehssi_regs.AFU_DFH.read(status, act_dat);
	exp_dat = tb_env0.hehssi_regs.AFU_DFH.get_reset();
	if(act_dat !== exp_dat)
	    `uvm_error(get_name(), $psprintf("Reset value mismatch for AFU_DFH act_dat = %0h exp_dat = %0h", act_dat, exp_dat))

	tb_env0.hehssi_regs.AFU_ID_L.read(status, act_dat);
	exp_dat = tb_env0.hehssi_regs.AFU_ID_L.get_reset();
	if(act_dat !== exp_dat)
	    `uvm_error(get_name(), $psprintf("Reset value mismatch for AFU_ID_L act_dat = %0h exp_dat = %0h", act_dat, exp_dat))

	tb_env0.hehssi_regs.AFU_ID_H.read(status, act_dat);
	exp_dat = tb_env0.hehssi_regs.AFU_ID_H.get_reset();
	if(act_dat !== exp_dat)
	    `uvm_error(get_name(), $psprintf("Reset value mismatch for AFU_ID_H act_dat = %0h exp_dat = %0h", act_dat, exp_dat))

    endtask : check_rst_value

endclass : hehssi_csr_seq

`endif // HEHSSI_CSR_SEQ_SVH
