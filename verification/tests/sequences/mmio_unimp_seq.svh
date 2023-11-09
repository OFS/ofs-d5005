// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class mmio_unimp_seq is executed by mmio_unimp_test
// MMIO acccess to unimplemented addresses
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef MMIO_UNIMP_SEQ_SVH
`define MMIO_UNIMP_SEQ_SVH

class mmio_unimp_seq extends base_seq;
    `uvm_object_utils(mmio_unimp_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mmio_unimp_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0] wdata, rdata, addr;

        super.body();
        `uvm_info(get_name(), "Entering mmio_unimp_seq...", UVM_LOW)

        assert(std::randomize(wdata));
        addr = he_lb_base_addr + 'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" HE_LB scratchpad Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf(" HE_LB scratchpad Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
      
         
        
        
	// HE-LB unimplemented CSR access
        assert(std::randomize(wdata));
	addr = he_lb_base_addr + 64'h190;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

       `uvm_info(get_name(), $psprintf("HE-LB CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)
     
      if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

	// HE-LB unimplemented CSR access
        assert(std::randomize(wdata));
	addr = he_lb_base_addr + 64'h200;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

       `uvm_info(get_name(), $psprintf("HE-LB CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)
     
       if(rdata !== 64'h1000010000000000)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata ! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

        assert(std::randomize(wdata));
	addr = he_lb_base_addr + 64'hff8;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

         `uvm_info(get_name(), $psprintf("HE-LB CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

       if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
 
     
        // PCIe 
        assert(std::randomize(wdata));
        addr = pcie_base_addr +'h8;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch pcie_SCRATCHPAD! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match pcie_SCRATCHPAD! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      

        assert(std::randomize(wdata));
        addr = pcie_base_addr +'h1008; 
         mmio_write64(.addr_(addr), .data_(wdata));
         mmio_read64 (.addr_(addr), .data_(rdata));


      `uvm_info(get_name(), $psprintf("PCIE CSR! addr = %0h, rdata = %0h ", addr, rdata ), UVM_LOW)
          if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("Data unimplemented CSR ! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data unimplemented CSR ! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    
      
      

        //pcie unmp CSR
        assert(std::randomize(wdata));
        addr = pcie_base_addr +'h28;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

         `uvm_info(get_name(), $psprintf("PCIE CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

          if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("pcie unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("pcie unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        
       //pcie unmp CSR
        assert(std::randomize(wdata));
        addr = pcie_base_addr +'h1000;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

         `uvm_info(get_name(), $psprintf("PCIE CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

          if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("pcie unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("pcie unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

   
         // HSSI scratchpad
        assert(std::randomize(wdata));
        addr = hssi_base_addr+'h38;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
       if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch HSSI_SCRATCHPAD! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match HSSI_SCRATCHPAD! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        
         // HSSI umimp CSR
        assert(std::randomize(wdata));
        addr = hssi_base_addr+'h40;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf("HSSI CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
       
         // HSSI umimp CSR
        assert(std::randomize(wdata));
        addr = hssi_base_addr+'hf000;        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf("HSSI CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

        // FME DFH
        addr = fme_base_addr;        
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" FME DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)

 
       // FME umimp CSR
        assert(std::randomize(wdata));
        addr = fme_base_addr +'h4078;     // FME range 0x00000 – 0x0FFFF   
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" FME unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

        if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("FME unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("FME unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME umimp CSR
        assert(std::randomize(wdata));
        addr = fme_base_addr +'h0F000  ;     // FME range 0x00000 – 0x0FFFF   
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" FME unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

        if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("FME unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("FME unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
  
        // ST2MM DFH
        addr = st2mm_base_addr;    
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" ST2MM DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)

       // ST2MM unimp CSR
        assert(std::randomize(wdata));
        addr = st2mm_base_addr +'h28  ;     // ST2MM range 0x80000 – 0x8FFFF
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" ST2MM unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("ST2MM unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("ST2MM unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
  
         
       // ST2MM unimp CSR
        assert(std::randomize(wdata));
        addr = st2mm_base_addr +'h1000  ;     // ST2MM range 0x80000 – 0x8FFFF
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" ST2MM unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h3000000100000fff)
            `uvm_error(get_name(), $psprintf("ST2MM unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("ST2MM unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

      
        // EMIF DFH
        addr = emif_base_addr;
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" EMIF DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)

      // EMIF unimp CSR
        assert(std::randomize(wdata));
        addr =emif_base_addr +'h18  ;     // EMIF  range 0x40000 – 0x4FFFF
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" EMIF unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("EMIF unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("EMIF  unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
 

      // EMIF unimp CSR
        assert(std::randomize(wdata));
        addr =emif_base_addr +'h1000  ;     // EMIF  range 0x40000 – 0x4FFFF
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" EMIF unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h3000000500000009)
            `uvm_error(get_name(), $psprintf("EMIF unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("EMIF  unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

      // PR DFH
        addr = pgsk_base_addr ; 
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" PR DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)

        
      // PR unimp CSR
      
     /*   assert(std::randomize(wdata));
        addr = pgsk_base_addr+'h3010 ;     //PR  range  0x90000 – 0x9FFFF

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" PR unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf(" PR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf(" PR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       // PR unimp CSR
      
        assert(std::randomize(wdata));
        addr = pgsk_base_addr+'h3020 ;     //PR  range  0x90000 – 0x9FFFF

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" PR unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf(" PR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf(" PR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
 

 
       // PR unimp CSR
      
        assert(std::randomize(wdata));
        addr = pgsk_base_addr+'h4000 ;     //PR  range  0x90000 – 0x9FFFF

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" PR unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf(" PR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf(" PR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) */

       // HE-HSSI DFH
        addr = he_hssi_base_addr; 
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" HE-HSSI DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)  

 
       // VF2 = HE-HSSI
           
        assert(std::randomize(wdata));
        addr = he_hssi_base_addr+'h58 ;     

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

        `uvm_info(get_name(), $psprintf(" HE-HSSI unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)

         if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf(" HE-HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf(" HE-HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        
         
       // HE-MEM DFH
        addr = he_mem_base_addr ;
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" HE-MEM DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)


       // HE-MEM unimplemented CSR access
        assert(std::randomize(wdata));
	addr = he_mem_base_addr + 64'h200;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

       `uvm_info(get_name(), $psprintf("HE-MEM unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)
     
       if(rdata !== 64'h1000010000000000)
            `uvm_error(get_name(), $psprintf("HE-MEM unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("HE_MEM unimplemented CSR returning correct rdata ! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

 
       // PMCI DFH
        addr = pmci_base_addr;
        mmio_read64 (.addr_(addr), .data_(rdata));
       `uvm_info(get_name(), $psprintf(" PMCI DFH! addr = %0h, rdata = %0h", addr, rdata ), UVM_LOW)


         //PMCI  unimplemented CSR access
        assert(std::randomize(wdata));
	addr =pmci_base_addr + 'h30;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

       `uvm_info(get_name(), $psprintf("PMCI unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)
     
      if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("PMCI unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("PMCI unimplemented CSR returning correct rdata ! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



         //PMCI  unimplemented CSR access
        assert(std::randomize(wdata));
	addr =pmci_base_addr + 'h1000;

        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));

       `uvm_info(get_name(), $psprintf("PMCI unimplemented CSR! addr = %0h, rdata = %0h, wdata= %0h ", addr, rdata, wdata ), UVM_LOW)
     
      if(rdata !== 64'h300000010000000e)
            `uvm_error(get_name(), $psprintf("PMCI unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("PMCI unimplemented CSR returning correct rdata ! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 




 
        `uvm_info(get_name(), "Exiting mmio_unimp_seq...", UVM_LOW)
    endtask : body

endclass : mmio_unimp_seq

`endif // MMIO_UNIMP_SEQ_SVH
