// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_lbbk_seq is executed by he_lbbk_test.
// This sequence verifies its num_lines ,req_len and mode   
// The sequence extends the base_sequence 
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_LPBK_SEQ_SVH
`define HE_LPBK_SEQ_SVH

class he_lpbk_seq extends base_seq;
    `uvm_object_utils(he_lpbk_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand bit [31:0] num_lines;
    rand bit [63:0] src_addr, dst_addr;
    rand bit [63:0] dsm_addr;
    rand bit [ 2:0] mode;
    rand bit [ 1:0] req_len;
    rand bit        src_addr_64bit, dst_addr_64bit, dsm_addr_64bit;
    rand bit        he_mem;
    bit [63:0] base_addr;
    rand bit        cont_mode;
    rand int        run_time_in_ms;
    bit [511:0]     dsm_data;
    rand bit        report_perf_data;
    rand bit [2:0]  tput_interleave;
    rand bit [31:0] rand_data [16];
    rand bit [31:0] host_dsm_rdata [16];


    constraint num_lines_c {
        num_lines inside {[1:1024]};
	if(mode != 3'b011) {
	    (num_lines % (2**req_len)) == 0;
	    (num_lines / (2**req_len)) >  0;
	}
	else {
	    num_lines % 2 == 0;
	    ((num_lines/2) % ((2**req_len) * (2**tput_interleave))) == 0;
	    ((num_lines/2) / ((2**req_len) * (2**tput_interleave))) >  0;
	}
	solve mode before num_lines;
	solve req_len before num_lines;
	solve tput_interleave before num_lines;
    }

    constraint req_len_c {
	req_len inside {2'b00, 2'b01, 2'b10};
    }

    constraint tput_interleave_c {
        tput_interleave inside {3'b000, 3'b001, 3'b010};
      }

    
    constraint mode_c { soft mode == 3'b000; } // LPBK1
    constraint he_mem_c { soft he_mem == 0; }
   
    constraint cont_mode_c {
        soft cont_mode == 0;
    }

    constraint run_time_in_ms_c {
        run_time_in_ms inside {[1:5]};
    }

    constraint report_perf_data_c {
        soft report_perf_data == 0;
    }

    function new(string name = "he_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0]                  wdata, rdata;
	bit [63:0]                  dsm_addr_tmp;	
	bit [511:0]                 src_data[], dst_data[];
        bit [31:0] host_rdata [16];
        bit [63:0] host_addr;
        super.body();
	`uvm_info(get_name(), "Entering he_lpbk_seq...", UVM_LOW)

	if(he_mem) base_addr = he_mem_base_addr;
	else       base_addr = he_lb_base_addr;

	src_addr = alloc_mem(num_lines, !src_addr_64bit);
	dst_addr = alloc_mem(num_lines, !dst_addr_64bit);
	dsm_addr = alloc_mem(1, !dsm_addr_64bit);

	//this.randomize();
	`uvm_info(get_name(), $psprintf("he_mem = %0d, src_addr = %0h, dst_addr = %0h, dsm_addr = %0h. num_lines = %0d, req_len = %0h, mode = %0b, cont_mode = %0d, intlv = %0b", he_mem, src_addr, dst_addr, dsm_addr, num_lines, req_len, mode, cont_mode, tput_interleave), UVM_LOW)
	src_data = new[num_lines];
	dst_data = new[num_lines];

	// Prepare source data in host memory
	for(int i = 0; i < num_lines; i++) begin
	foreach(rand_data[j]) begin  rand_data[j] = $urandom();
	  `uvm_info(get_name(), $psprintf("RAND_DATA[%d] :- %h \n",j,rand_data[j]), UVM_LOW)end
           host_mem_write( .addr_(src_addr+'h40*i) , .data_(rand_data) , .len('d16) );
	end

        // initialize DSM data

	foreach(rand_data[i]) rand_data[i] = 32'h0;
        host_mem_write( .addr_(dsm_addr) , .data_(rand_data) , .len('d16) );

        // Program CSR_CTL to reset HE-LPBK
	wdata = 64'h0;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

        // Program CSR_CTL to remove reset HE-LPBK
	wdata = 64'h1;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

	// Program CSR_SRC_ADDR
        mmio_write64(.addr_(base_addr+'h120), .data_(src_addr>>6));
        mmio_read64 (.addr_(base_addr+'h120), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_SRC_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_DST_ADDR
        mmio_write64(.addr_(base_addr+'h128), .data_(dst_addr>>6));
        mmio_read64 (.addr_(base_addr+'h128), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_DST_ADDR = %0h", rdata), UVM_LOW)

	dsm_addr_tmp = dsm_addr >> 6;
	// Program CSR_AFU_DSM_BASEH
        mmio_write32(.addr_(base_addr+'h114), .data_(dsm_addr_tmp[63:32]));
        mmio_read32 (.addr_(base_addr+'h114), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("DSM_H_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_AFU_DSM_BASEL
        mmio_write32(.addr_(base_addr+'h110), .data_(dsm_addr_tmp[31:0]));
        mmio_read32 (.addr_(base_addr+'h110), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("DSM_L_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_NUM_LINES
        mmio_write64(.addr_(base_addr+'h130), .data_(num_lines-1));
        mmio_read64 (.addr_(base_addr+'h130), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_NUM_LINES = %0h", rdata), UVM_LOW)

	// Program CSR_CFG
	wdata = {41'h0, tput_interleave, 13'h0, req_len, mode, cont_mode, 1'b0};
        mmio_write64(.addr_(base_addr+'h140), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h140), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CFG = %0h", rdata), UVM_LOW)

	// Additional CSR programming hook before start
	additional_csr_program();

        // Program CSR_CTL to start HE-LPBK
	wdata = 64'h3;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

	if(cont_mode) begin
	    //repeat(run_time_in_ms) #1ms;
	    #800ns;
            // Program CSR_CTL to start HE-LPBK
            mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	    rdata[2] = 1;
            mmio_write64(.addr_(base_addr+'h138), .data_(rdata));
            mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	    `uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)
	end

        rdata = 0;
	// Polling DSM
	fork
	    while(!dsm_data[0]) begin
              foreach (host_dsm_rdata[i]) host_dsm_rdata[i] = 32'h0;
	        `uvm_info(get_name(), $psprintf("INSIDE WHILE WILL START HOST_RDATA"), UVM_LOW)
                 host_mem_read( .addr_(dsm_addr) , .data_(host_dsm_rdata) , .len('d16) ); 
	         foreach(host_dsm_rdata[i])
	            dsm_data |= changeEndian(host_dsm_rdata[i]) << (i*32);
		   `uvm_info(get_name(), $psprintf("Polling DSM status Addr = %0h Data = %h", dsm_addr, dsm_data), UVM_LOW)
		#1us;
	    end
	    #50us;
	join_any
	if(!dsm_data[0])
	    `uvm_fatal(get_name(), $psprintf("TIMEOUT! polling dsm_addr = %0h!", dsm_addr))

        if(mode == 3'b000) begin
	    // Compare data
	    for(int i = 0; i < num_lines; i++) begin
              host_addr = src_addr + 'h40*i;
              host_mem_read( .addr_(host_addr) , .data_(host_rdata) , .len('d16) ); 
	      foreach(host_rdata[j])
	           src_data[i] |= changeEndian(host_rdata[j]) << (j*32);
	          `uvm_info(get_name(), $psprintf("addr = %0h src_data = %0h", host_addr, src_data[i]), UVM_LOW)    
	    end
	    for(int i = 0; i < num_lines; i++) begin
              host_addr = dst_addr + 'h40*i;
              host_mem_read( .addr_(host_addr) , .data_(host_rdata) , .len('d16) ); 
	      foreach(host_rdata[j])
	         dst_data[i] |= changeEndian(host_rdata[j]) << (j*32);
	         `uvm_info(get_name(), $psprintf("addr = %0h dst_data = %0h", host_addr, dst_data[i]), UVM_LOW)
	    end
	    foreach(src_data[i]) begin
	        if(src_data[i] !== dst_data[i])
	            `uvm_error(get_name(), $psprintf("Data mismatch! src_data[%0d] = %0h dst_data[%0d] = %0h", i, src_data[i], i, dst_data[i]))
	        else
	            `uvm_info(get_name(), $psprintf("Data match! data[%0d] = %0h", i, src_data[i]), UVM_LOW)
	    end
	end

        if(!cont_mode)
            check_counter();

        if(report_perf_data) begin
	    if(mode inside {3'b001, 3'b010, 3'b011})
	        report_perf();
	end

 	`uvm_info(get_name(), "Exiting he_lpbk_seq...", UVM_LOW)
    endtask : body

    task check_counter();
        bit [63:0] rdata;
        bit interrupt_enabled;
        interrupt_enabled ='b0;
        mmio_read64 (.addr_(base_addr+'h140), .data_(rdata));
        interrupt_enabled=rdata[29];
        mmio_read64 (.addr_(base_addr+'h160), .data_(rdata));	
    if (he_mem) begin //{
	   if(mode == 3'b000) begin // LPBK {
        if(!(interrupt_enabled)) // { 
          begin
	          if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
          end
       else
         begin
	          if((rdata[31:0]-2) != num_lines) // For interrupt scenarios, interrupt command is also counted as write, hence subtracting interrupt request. Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/16018197141
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
         end//}
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end//}
	   else if(mode == 3'b010) begin // WRITE ONLY
	       if((rdata[31:0]) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
	   end
	   else if(mode == 3'b001) begin // READ ONLY
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end
	   else if(mode == 3'b011) begin // THRUPUT
	       if((rdata[31:0]) != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
	       if(rdata[63:32] != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end
   end //}
   else begin
	   if(mode == 3'b000) begin // LPBK
       if(!(interrupt_enabled)) // { 
        begin
	       if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
        end     
       else
        begin
	       if((rdata[31:0]-2) != num_lines)//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        end
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end //}
	   else if(mode == 3'b010) begin // WRITE ONLY
       if(!(interrupt_enabled)) // { 
        begin
	       if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
        end
      else
        begin
	       if((rdata[31:0]-2) != num_lines)//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        end //}
	   end
	   else if(mode == 3'b001) begin // READ ONLY
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end
	   else if(mode == 3'b011) begin // THRUPUT
       if(!(interrupt_enabled)) // { 
        begin
	       if((rdata[31:0]-1) != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
        end
       else
        begin
	       if((rdata[31:0]-2) != (num_lines/2))//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        end
	       if(rdata[63:32] != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end
        end
	check_afu_intf_error();
    endtask : check_counter

    task report_perf();
        real num_ticks;
	real perf_data;
	num_ticks = dsm_data[103:64];
        perf_data = (num_lines * 64) / (4 * num_ticks);
	$display("DSM data = %0h", dsm_data);
	$display("*** PERFORMANCE MEASUREMENT *** ", $psprintf("num_lines = %0d req_len = 0x%0h num_ticks = 0x%0h perf_data = %.4f GB/s", num_lines, req_len, num_ticks, perf_data));
    endtask : report_perf

    virtual task additional_csr_program();
    endtask : additional_csr_program

endclass : he_lpbk_seq

`endif // HE_LPBK_SEQ_SVH
