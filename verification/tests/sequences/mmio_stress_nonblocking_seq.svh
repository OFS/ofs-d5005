// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class mmio_stress_nonblocking_seq is executed by mmio_stress_nonblocking_test 
// Stressing MMIO on PF/VF Mux/Demux with non-blocking MMIO reads
// Scratchpad is accessed simultaneosly to generate the stress
//-----------------------------------------------------------------------------

`ifndef MMIO_STRESS_NONBLOCKING_SEQ_SVH
`define MMIO_STRESS_NONBLOCKING_SEQ_SVH

class mmio_stress_nonblocking_seq extends base_seq;
    `uvm_object_utils(mmio_stress_nonblocking_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand int loop;

    constraint loop_c { soft loop inside {[10:50]}; }

    function new(string name = "mmio_stress_nonblocking_seq");
        super.new(name);
    endfunction : new

    task mmio_wr_rd_cmp(input [63:0] addr);
        int iter;
	bit [63:0] wdata, rdata, exp_data;

	std::randomize(iter) with { iter == 1; };
	for(int i = 0; i < iter; i++) begin
            std::randomize(wdata);
            mmio_write64(.addr_(addr), .data_(wdata));
	    exp_data = wdata;
	end

	std::randomize(iter) with {iter inside {[1:10]}; };
	for(int i = 0; i < iter; i++) begin
            mmio_read64 (.addr_(addr), .data_(rdata), .blocking_(0));
            if(rdata !== exp_data)
                `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, exp_data, rdata))
            else
                `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
	end
    endtask : mmio_wr_rd_cmp

    task body();
        super.body();
        `uvm_info(get_name(), "Entering mmio_stress_nonblocking_seq...", UVM_LOW)

	this.randomize();

        fork
	    begin // FME Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(fme_base_addr + 'h28);
		end
	    end
	    begin // HE-LPBK Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(he_lb_base_addr + 'h100);
		end
	    end
	    begin // HE-MEM Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(he_mem_base_addr + 'h100);
		end
	    end
	    begin // HE-HSSI Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(he_hssi_base_addr + 'h48);
		end
	    end
	    begin // SPI Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(pmci_base_addr + 'h28);
		end
	    end
	    begin // PCIe Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(pcie_base_addr + 'h8);
		end
	    end
	    begin // HSSI Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(hssi_base_addr + 'h38);
		end
	    end
	    begin // ST2MM Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(st2mm_base_addr + 'h8);
		end
	    end
	    begin // PR Scratchpad
	        for(int i = 0; i < loop; i++) begin
		    mmio_wr_rd_cmp(pgsk_base_addr + 'hb8);
		end
	    end
	join

        `uvm_info(get_name(), "Exiting mmio_stress_nonblocking_seq...", UVM_LOW)
    endtask : body

endclass : mmio_stress_nonblocking_seq

`endif // MMIO_STRESS_NONBLOCKING_SEQ_SVH
