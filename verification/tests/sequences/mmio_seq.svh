// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class mmio_seq is executed by mmio_test
// Performs MMIO access to all  PF/VFs
// Sequence is running on virtual_sequencer
//-----------------------------------------------------------------------------

`ifndef MMIO_SEQ_SVH
`define MMIO_SEQ_SVH

class mmio_seq extends base_seq;
    `uvm_object_utils(mmio_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mmio_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr;
        bit [63:0] afu_id_l, afu_id_h;

        super.body();
        `uvm_info(get_name(), "Entering mmio_seq...", UVM_LOW)

        // FME DFH
        addr = fme_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // SPI DFH
        addr = pmci_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // PCIe DFH
        addr = pcie_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // ST2MM DFH
        addr = st2mm_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // PR DFH
        addr = pgsk_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // HSSI DFH
        addr = hssi_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // VF0 = HELB
        assert(std::randomize(wdata));
        addr = he_lb_base_addr;
        
        mmio_read64 (.addr_(addr), .data_(rdata));
        `uvm_info(get_name(), $psprintf("VF0 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)
        
        // VF1 = HE-MEM
        assert(std::randomize(wdata));
        addr = he_mem_base_addr;
        
        mmio_read64 (.addr_(addr), .data_(rdata));
        `uvm_info(get_name(), $psprintf("VF1 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)
        
        // VF2 = HE-HSSI
        assert(std::randomize(wdata));
        addr = he_hssi_base_addr;
        
        mmio_read64 (.addr_(addr), .data_(rdata));
        `uvm_info(get_name(), $psprintf("VF2 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        addr = pf0_bar4;
	mmio_read64(.addr_(addr), .data_(rdata));
        `uvm_info(get_name(), $psprintf("PF0 BAR4 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        // PF0_VF1_BAR4 User MSIX Space 64 bit access

        wdata=64'hFFFFFFFFFFFFFFFF;
         addr = he_mem_base4_addr+'h3000;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        wdata=64'hAAAAAAAAAAAAAAAA;
       addr = he_mem_base4_addr+'h3000;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'h0000000000000000;
        addr = he_mem_base4_addr+'h3000;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'hFFFFFFFFFFFFFFFF;
        
        addr = he_mem_base4_addr+'h3008;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
       addr = he_mem_base4_addr+'h3008;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
        addr = he_mem_base4_addr+'h3008;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'hFFFFFFFFFFFFFFFF;
        addr = he_mem_base4_addr+'h3010;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

       wdata=64'hAAAAAAAAAAAAAAAA;
         addr = he_mem_base4_addr+'h3010;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'h0000000000000000;
        addr = he_mem_base4_addr+'h3010;

        addr = he_mem_base4_addr+'h3010; 
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        wdata=64'hFFFFFFFFFFFFFFFF;
        addr = he_mem_base4_addr+'h3018;


        addr = he_mem_base4_addr+'h3018; 
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

       wdata=64'hAAAAAAAAAAAAAAAA;
        addr = he_mem_base4_addr+'h3018; 
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


        wdata=64'h0000000000000000;
        
         addr = he_mem_base4_addr+'h3018; 
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        wdata=64'hFFFFFFFFFFFFFFFF;
        
	 addr = he_mem_base4_addr+'h3020;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

         wdata=64'hAAAAAAAAAAAAAAAA;
	   addr = he_mem_base4_addr+'h3020;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


        wdata=64'h0000000000000000;
         addr = he_mem_base4_addr+'h3020;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'hFFFFFFFFFFFFFFFF;
        addr = he_mem_base4_addr+'h3028;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        wdata=64'hAAAAAAAAAAAAAAAA;
          addr = he_mem_base4_addr+'h3028;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         	   addr = he_mem_base4_addr+'h3028;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
        
	   addr = he_mem_base4_addr+'h3030;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
        	   addr = he_mem_base4_addr+'h3030;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
	   addr = he_mem_base4_addr+'h3030;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
        	   addr = he_mem_base4_addr+'h3038;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         
	 addr = he_mem_base4_addr+'h3038;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         
       addr = he_mem_base4_addr+'h3038;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



      wdata=64'hFFFFFFFFFFFFFFFF;
        
       addr = he_mem_base4_addr+'h3040;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
	  addr = he_mem_base4_addr+'h3040;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
       	  addr = he_mem_base4_addr+'h3040;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
        
      addr = he_mem_base4_addr+'h3048;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
        addr = he_mem_base4_addr+'h3048;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
       
       addr = he_mem_base4_addr+'h3048;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'hFFFFFFFFFFFFFFFF;
        addr = he_mem_base4_addr+'h3050;


        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = he_mem_base4_addr+'h3050;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;

	 addr = he_mem_base4_addr+'h3050;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


    
     wdata=64'hFFFFFFFFFFFFFFFF;
       
	 addr = he_mem_base4_addr+'h3058;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
       
	 addr = he_mem_base4_addr+'h3058;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
	 addr = he_mem_base4_addr+'h3058;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
       	  addr = he_mem_base4_addr+'h3060;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
        
          addr = he_mem_base4_addr+'h3060;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
        
       addr = he_mem_base4_addr+'h3060;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
       
       addr = he_mem_base4_addr+'h3068;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         
       addr = he_mem_base4_addr+'h3068;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
       
	  addr = he_mem_base4_addr+'h3068;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
        
       addr = he_mem_base4_addr+'h3070;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
        	 addr = he_mem_base4_addr+'h3070;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
       	 addr = he_mem_base4_addr+'h3070;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
      	 addr = he_mem_base4_addr+'h3078;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         
	 addr = he_mem_base4_addr+'h3078;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
       
	 addr = he_mem_base4_addr+'h3078;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hFFFFFFFFFFFFFFFF;
         addr = st2mm_base_addr +'h8;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        wdata=64'hAAAAAAAAAAAAAAAA;
       addr = st2mm_base_addr +'h8;
       
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       wdata=64'h0000000000000000;
        addr = st2mm_base_addr +'h8;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


        
    endtask : body

endclass : mmio_seq

`endif // MMIO_SEQ_SVH
