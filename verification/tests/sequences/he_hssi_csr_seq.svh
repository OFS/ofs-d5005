// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class he_hssi_csr_seq is executed by he_hssi_csr_test
// MMIO access for HE_HSSI Registers - Scratchpad
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HE_HSSI_CSR_SEQ_SVH
`define HE_HSSI_CSR_SEQ_SVH

class he_hssi_csr_seq extends base_seq;
    `uvm_object_utils(he_hssi_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "he_hssi_csr_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0]                               wdata, rdata;

        super.body();
        `uvm_info(get_name(), "Entering he_hssi_csr_seq...", UVM_LOW)

        wdata = 64'hdead_beef;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h48), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h48), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

        wdata = 64'hAAAA_AAAA;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h48), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h48), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

        wdata = 64'hffff_ffff;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h48), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h48), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

        wdata = 64'h0000_0000;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h48), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h48), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)
        `uvm_info(get_name(), "Exiting he_hssi_csr_seq...", UVM_LOW)

       wdata = 64'h0000FFFF00000003;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h30), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h30), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

        wdata = 64'h0000AAAA00000002;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h30), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h30), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

     
        wdata = 64'h0000000000000000;
        
        mmio_write64(.addr_(he_hssi_base_addr+'h30), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h30), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)


       wdata = 64'hFFFFFFFF00000000;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h38), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h38), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)
    
       wdata = 64'hAAAAAAAA00000000;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h38), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h38), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)


      wdata = 64'h0000000000000000;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h38), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h38), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)


        wdata = 64'h000000000000000f;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h40), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h40), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)
    
       wdata = 64'h000000000000000A;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h40), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h40), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)
  
      wdata = 64'h0000000000000000;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h40), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h40), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

     wdata = 64'h0000000000000001;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h50), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h50), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)

     wdata = 64'h0000000000000000;

        
        mmio_write64(.addr_(he_hssi_base_addr+'h50), .data_(wdata));
        mmio_read64 (.addr_(he_hssi_base_addr+'h50), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Exp = %0h, Act = %0h", wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match! data = %0h", rdata), UVM_LOW)







    endtask : body

endclass : he_hssi_csr_seq

`endif // HE_HSSI_CSR_SEQ_SVH
