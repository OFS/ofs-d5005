// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

task mmio_pcie_read32(input bit [63:0] addr_, output bit [31:0] data_, input blocking_ = 1, input bit is_soc_ = 1);
     pcie_rd_mmio_seq mmio_rd;
     bit timeout = 0;
     if(is_soc_) begin
      if(blocking_) begin
	    fork
	        begin
                    `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                        rd_addr == addr_;
                        rlen    == 1;
                        l_dw_be == 4'b0000;
	                block == blocking_;
                    })
                    data_ = changeEndian(mmio_rd.read_tran.payload[0]);
	        end
	        begin
	            #50us;
	    	    timeout = 1;
	        end
	    join_any
	    if(timeout)
	        `uvm_fatal(get_name(), $psprintf("MMIO read timed out! addr = %0h", addr_))
        end
	else begin
            `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                rd_addr == addr_;
                rlen    == 1;
                l_dw_be == 4'b0000;
	        block == blocking_;
            })
            data_ = changeEndian(mmio_rd.read_tran.payload[0]);
	end
      end
endtask : mmio_pcie_read32

task mmio_pcie_read64(input bit [63:0] addr_, output bit [63:0] data_, input blocking_ = 1, input bit is_soc_ = 1);
     pcie_rd_mmio_seq mmio_rd;
     bit timeout = 0;
     if(is_soc_) begin
      if(blocking_) begin
	    fork
	        begin
                    `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                        rd_addr == addr_;
                        rlen    == 2;
                        l_dw_be == 4'b1111;
	                block == blocking_;
                    })
                    data_ = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
	        end
	        begin
	            #50us;
	    	    timeout = 1;
	        end
	    join_any
	    if(timeout)
	        `uvm_fatal(get_name(), $psprintf("MMIO read timed out! addr = %0h", addr_))
        end
	else begin
            `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                rd_addr == addr_;
                rlen    == 2;
                l_dw_be == 4'b1111;
	        block == blocking_;
            })
            data_ = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
	end
      end
endtask : mmio_pcie_read64


task mmio_pcie_write32(input bit [63:0] addr_, input bit [31:0] data_, input bit is_soc_ = 1);
     pcie_wr_mmio_seq mmio_wr;
     if(is_soc_) begin
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h1;
           l_dw_be       == 4'b0000;
           wr_payload[0] == changeEndian(data_);
       })
     end
endtask : mmio_pcie_write32 

task mmio_pcie_write64(input bit [63:0] addr_, input bit [63:0] data_, input bit is_soc_ = 1);
     pcie_wr_mmio_seq mmio_wr;
     if(is_soc_) begin
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h2;
           l_dw_be       == 4'b1111;
           wr_payload[0] == changeEndian(data_[31:0]);
           wr_payload[1] == changeEndian(data_[63:32]);
       })
     end
    
endtask : mmio_pcie_write64 

task host_pcie_mem_write (input  bit [63:0] addr_, input bit [31:0] data_ [], input int unsigned len ,input bit is_soc_ = 1);
     host_pcie_mem_write_seq pcie_mem_wr_seq;
    `uvm_do_on_with(pcie_mem_wr_seq, p_sequencer.root_virt_seqr.mem_target_seqr,{
	  address           == addr_;
	  dword_length      == len;
          data_seq.size()   == len;
          foreach(data_seq[i]) { data_seq[i] == data_[i]; }
      })
endtask


task host_pcie_mem_read (input  bit [63:0] addr_, output bit [31:0] data_ [],input int unsigned len ,input bit is_soc_ = 1);
     host_pcie_mem_read_seq pcie_mem_rd_seq;
     `uvm_do_on_with(pcie_mem_rd_seq, p_sequencer.root_virt_seqr.mem_target_seqr, {
          address           == addr_;
	  dword_length      == len;
      })
     data_ = new[len] (pcie_mem_rd_seq.data_buf);
     
endtask

