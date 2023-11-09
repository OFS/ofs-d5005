// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class base_seq is common base sequence, all the sequences are extended from this sequence 
// This sequence starts the config_seq
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef BASE_SEQ_SVH
`define BASE_SEQ_SVH

class base_seq extends uvm_sequence;
    `uvm_object_utils(base_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    `include "VIP/vip_task.sv"
    // index by start_addr, value is size of the mem block
    static int mem_pool[bit [63:0]];

    rand bit bypass_config_seq;
    rand bit use_64b_bar;
    rand bit [63:0] pf0_bar0;
    config_seq config_seq;
    static bit [63:0] pf0_bar4;
    static bit [63:0] fme_base_addr;
    static bit [63:0] pmci_base_addr;
    static bit [63:0] pcie_base_addr;
    static bit [63:0] hssi_base_addr;
    static bit [63:0] emif_base_addr;
    static bit [63:0] rsv_5_base_addr;
    static bit [63:0] rsv_6_base_addr;
    static bit [63:0] rsv_7_base_addr;
    static bit [63:0] st2mm_base_addr;
    static bit [63:0] pgsk_base_addr;
    static bit [63:0] achk_base_addr;
    static bit [63:0] rsv_b_base_addr;
    static bit [63:0] rsv_c_base_addr;
    static bit [63:0] rsv_d_base_addr;
    static bit [63:0] rsv_e_base_addr;
    static bit [63:0] rsv_f_base_addr;

    static bit [63:0] he_lb_base_addr;
    static bit [63:0] he_mem_base_addr;
    static bit [63:0] he_mem_base4_addr;
    static bit [63:0] he_hssi_base_addr;

    typedef struct {
        bit [63:0]  pf0_bar0; 
        bit [63:0] he_lb_base;
        bit [63:0] he_mem_base;
        bit [63:0] he_mem_base4;
        bit [63:0] he_hssi_base;   
                   }st_base_addr;

    st_base_addr st_addr;
   
        tb_env tb_env0;

    constraint bypass_config_seq_c { soft bypass_config_seq == 0; }
    constraint use_64b_bar_c { soft use_64b_bar == 0; }
    constraint pf0_bar0_c {
        if(use_64b_bar) pf0_bar0 == 64'hab00_0000_0000_0000;
	else            pf0_bar0 == 64'h0000_0000_ab00_0000;
    }

    function new(string name = "base_seq");
        super.new(name);
	get_tb_env();
    endfunction : new

    virtual function void get_tb_env();                
        uvm_component   comp;

        comp = uvm_top.find("uvm_test_top.tb_env0"); 
        assert(comp) else uvm_report_fatal(get_name(), "failed finding tb_env0"); 
        
        assert ($cast(tb_env0, comp)) else 
        uvm_report_fatal(get_name(), "failed in obtaining tb_env0!");
        
    endfunction

    task body();
        super.body();
	`uvm_info(get_name(), $psprintf("pf0_bar0 = %0h, use_64b_bar = %0h",pf0_bar0, use_64b_bar ), UVM_LOW)

	if(!bypass_config_seq) begin
	    `uvm_do_on_with(config_seq, p_sequencer, {
	        config_seq.pf0_bar0 == local::pf0_bar0; 
		config_seq.use_64b_bar == local::use_64b_bar;
	    })
	    cfg_port_rst_assert();  //SOFT_RESET_APPLIED
            cfg_release_port_rst(); //SOFT_RESET_RELEASED
	    fme_base_addr   = pf0_bar0 + FME_BASE;
	    pmci_base_addr  = pf0_bar0 + PMCI_BASE;
	    pcie_base_addr  = pf0_bar0 + PCIE_BASE;
	    hssi_base_addr  = pf0_bar0 + HSSI_BASE;
	    emif_base_addr  = pf0_bar0 + EMIF_BASE;
	    rsv_5_base_addr = pf0_bar0 + RSV_5_BASE;
	    rsv_6_base_addr = pf0_bar0 + RSV_6_BASE;
	    rsv_7_base_addr = pf0_bar0 + RSV_7_BASE;
	    st2mm_base_addr = pf0_bar0 + ST2MM_BASE;
	    pgsk_base_addr  = pf0_bar0 + PGSK_BASE;
	    achk_base_addr  = pf0_bar0 + ACHK_BASE;
	    rsv_b_base_addr = pf0_bar0 + RSV_b_BASE;
	    rsv_c_base_addr = pf0_bar0 + RSV_c_BASE;
	    rsv_d_base_addr = pf0_bar0 + RSV_d_BASE;
	    rsv_e_base_addr = pf0_bar0 + RSV_e_BASE;
	    rsv_f_base_addr = pf0_bar0 + RSV_f_BASE;

            pf0_bar4 = enumerate_seq::bar4;
	    he_lb_base_addr = enumerate_seq::pf0_vf0_bar0;
	    he_mem_base_addr = he_lb_base_addr + (2 ** enumerate_seq::vf_size_index); 
	    he_hssi_base_addr = he_mem_base_addr + (2 ** enumerate_seq::vf_size_index);
	    he_mem_base4_addr = enumerate_seq::pf0_vf0_bar4_addr+ (2 ** enumerate_seq::vf_size_index); // to get Vf1_bar4 add page offset to vf0_bar4 address 

	     
	    `uvm_info("", "===========================", UVM_LOW)
	    `uvm_info("", "Base Address Configurations", UVM_LOW)
	    `uvm_info("", "===========================", UVM_LOW)
	    `uvm_info("", $psprintf("FME_BASE         %h", fme_base_addr)    , UVM_LOW)
	    `uvm_info("", $psprintf("PMCI_BASE        %h", pmci_base_addr)   , UVM_LOW)
	    `uvm_info("", $psprintf("PCIE_BASE        %h", pcie_base_addr)   , UVM_LOW)
	    `uvm_info("", $psprintf("HSSI_BASE        %h", hssi_base_addr)   , UVM_LOW)
	    `uvm_info("", $psprintf("EMIF_BASE        %h", emif_base_addr)   , UVM_LOW)
	    `uvm_info("", $psprintf("ST2MM_BASE       %h", st2mm_base_addr)  , UVM_LOW)
	    `uvm_info("", $psprintf("PGSK_BASE        %h", pgsk_base_addr)   , UVM_LOW)
	    `uvm_info("", $psprintf("HE_LB_BASE       %h", he_lb_base_addr)  , UVM_LOW)
	    `uvm_info("", $psprintf("he_MEM_BASE      %h", he_mem_base_addr) , UVM_LOW)
	    `uvm_info("", $psprintf("he_MEM_BASE4     %h", he_mem_base4_addr) , UVM_LOW)
	    `uvm_info("", $psprintf("HE_HSSI_BASE     %h", he_hssi_base_addr), UVM_LOW)
	    `uvm_info("", $psprintf("pf0_bar4         %h", pf0_bar4), UVM_LOW)
	    setup_ral();
      
        
         st_addr.he_lb_base=he_lb_base_addr;
         st_addr.he_mem_base=he_mem_base_addr;
         st_addr.he_mem_base4=he_mem_base4_addr;
         st_addr.he_hssi_base=he_hssi_base_addr;
            
      uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_lb_base", st_addr.he_lb_base);
      uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_mem_base", st_addr.he_mem_base);
      uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_mem_base4", st_addr.he_mem_base4);
      uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_hssi_base", st_addr.he_hssi_base);

      `uvm_info("", $psprintf("HE_LB_BASE         %8h", st_addr.he_lb_base)    , UVM_LOW)    
      `uvm_info("", $psprintf("HE_HSSI_BASE       %8h", st_addr.he_hssi_base)  , UVM_LOW)  
      `uvm_info("", $psprintf("HE_MEM_BASE        %8h", st_addr.he_mem_base)   , UVM_LOW)  
      `uvm_info("", $psprintf("HE_MEM_BASE4        %8h", st_addr.he_mem_base4)   , UVM_LOW)  
    
//`uvm_info("INTF",$sformatf("HE_MEM_BASE = %0h " ,st_addr.he_mem_base_addr ), UVM_LOW) 
	end
    endtask : body

    virtual function setup_ral();
        tb_env0.regs.build(pf0_bar4, pf0_bar0, he_lb_base_addr, he_mem_base_addr, he_hssi_base_addr);
        tb_env0.regs.lock_model();
	tb_env0.fme_regs    = tb_env0.regs.fme_regs;
    tb_env0.msix_regs   = tb_env0.regs.msix_regs;
	tb_env0.hehssi_regs = tb_env0.regs.hehssi_regs;
	tb_env0.helb_regs   = tb_env0.regs.helb_regs;
	tb_env0.hemem_regs  = tb_env0.regs.hemem_regs;
	tb_env0.pcie_regs   = tb_env0.regs.pcie_regs;
	tb_env0.pgsk_regs   = tb_env0.regs.pgsk_regs;
	tb_env0.pmci_regs   = tb_env0.regs.pmci_regs;
	tb_env0.st2mm_regs  = tb_env0.regs.st2mm_regs;
    tb_env0.afu_intf_regs = tb_env0.regs.afu_intf_regs;
	tb_env0.port_gasket_regs  = tb_env0.regs.port_gasket_regs;
	tb_env0.regs.fme_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.fme_map.set_auto_predict(1);
    tb_env0.regs.msix_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.msix_map.set_auto_predict(1);
	tb_env0.regs.hehssi_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.hehssi_map.set_auto_predict(1);
	tb_env0.regs.helb_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.helb_map.set_auto_predict(1);
	tb_env0.regs.hemem_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.hemem_map.set_auto_predict(1);
	tb_env0.regs.pcie_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.pcie_map.set_auto_predict(1);
	tb_env0.regs.pmci_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.pmci_map.set_auto_predict(1);
	tb_env0.regs.pgsk_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.pgsk_map.set_auto_predict(1);
	tb_env0.regs.st2mm_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.st2mm_map.set_auto_predict(1);
	tb_env0.regs.port_gasket_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.port_gasket_map.set_auto_predict(1);
	tb_env0.regs.afu_intf_map.set_sequencer(tb_env0.v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
	tb_env0.regs.afu_intf_map.set_auto_predict(1);
    endfunction : setup_ral

    task mmio_write32(input bit [63:0] addr_, input bit [31:0] data_, input bit is_soc_ = 1);
      mmio_pcie_write32(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
   endtask : mmio_write32 

    task mmio_write64(input bit [63:0] addr_, input bit [63:0] data_, input bit is_soc_ = 1);
      mmio_pcie_write64(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask : mmio_write64

    task host_mem_write (input  bit [63:0] addr_,  input bit [31:0] data_ [], input int unsigned len ,input bit is_soc_ = 1);
       host_pcie_mem_write(.addr_(addr_) , .data_(data_),.len(len), .is_soc_(is_soc_));
    endtask 

   task host_mem_read (input  bit [63:0] addr_, output bit [31:0] data_ [] ,input int unsigned len , input bit is_soc_ = 1);
       host_pcie_mem_read(.addr_(addr_) , .data_(data_),.len(len), .is_soc_(is_soc_));
    endtask : host_mem_read


   task mmio_read32(input bit [63:0] addr_, output bit [31:0] data_, input blocking_ = 1, input bit is_soc_ = 1);
      mmio_pcie_read32(.addr_(addr_) , .data_(data_), .blocking_(blocking_), .is_soc_(is_soc_));       
    endtask : mmio_read32

    task mmio_read64(input bit [63:0] addr_, output bit [63:0] data_, input blocking_ = 1, input bit is_soc_ = 1);
      mmio_pcie_read64(.addr_(addr_) , .data_(data_), .blocking_(blocking_), .is_soc_(is_soc_));       
    endtask : mmio_read64


    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction
    
    // Allocate the memory and return the start address
    function bit [63:0] alloc_mem(int size, bit low32 = 0);
        bit [63:0] m_addr;
	std::randomize(m_addr) with {
	    m_addr[11:0] == 0;

            // Avoid addresses higher than the available physical/virtual address
            // ranges.
            m_addr[63:48] == 0;

	    if(low32) {
	        m_addr[63:32] == 32'h0;
	    }
	    foreach(mem_pool[i]) {
	        !(m_addr inside {[i:i+'h40*mem_pool[i]]}); 
	    }
	    (m_addr + 'h40*size) < 64'hffff_ffff_ffff_ffff;
	};
	mem_pool[m_addr] = size;
        return m_addr;
    endfunction : alloc_mem

    // De-allocate the memory with start address and size of the memory
    function void dealloc_mem(bit [63:0] start_addr);
        mem_pool.delete(start_addr);
    endfunction : dealloc_mem

    virtual task check_afu_intf_error();
        bit [63:0] rdata;
        mmio_read64(.addr_(pf0_bar0 + 'ha0010), .data_(rdata));
	if(rdata[15:0] != 0)
	    `uvm_error(get_full_name(), $psprintf("AFU_INTF_ERROR is non-zero: %0h", rdata[15:0]))
    endtask : check_afu_intf_error

    virtual task port_rst_flow(bit do_rst = 0);
        bit [63:0] rdata;
	uvm_status_e status;
        if(do_rst) begin
	    tb_env0.regs.port_gasket_regs.PORT_CONTROL.read(status, rdata);
	    //mmio_read64(pgsk_base_addr + 'h1038, rdata);
	    rdata[0] = 1;
	    tb_env0.regs.port_gasket_regs.PORT_CONTROL.write(status, rdata);
	    //mmio_write64(pgsk_base_addr + 'h1038, rdata);
	end
	rdata = 0;
	fork
	    while(!rdata[4]) begin
	        tb_env0.regs.port_gasket_regs.PORT_CONTROL.read(status, rdata);
                #100ns;
	    end
	    begin
                #5us;
	    end
	join_any

	if(!rdata[4])
	    `uvm_fatal(get_name(), "port reset acknowledge is not asserted in 5us")

    endtask : port_rst_flow

    task cfg_port_rst_assert();
       bit [63:0]    rdata, wdata, addr;
       addr = pf0_bar0+24'h91038;	
      `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", rdata), UVM_LOW)
       begin
        //wdata ='h5;
        mmio_read64  (.addr_(addr), .data_(rdata));
        wdata = rdata;
        if(rdata[0] != 1) 
         begin wdata[0] = 1'b1;
          mmio_write64 (.addr_(addr), .data_(wdata));
          `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
         end
       end
  endtask 

  task cfg_release_port_rst();
       bit [63:0]    rdata, wdata, addr;
       addr = pf0_bar0+24'h91038;	
       begin
       // wdata ='h4;
        mmio_read64  (.addr_(addr), .data_(rdata));
        wdata = rdata;
        if(rdata[0] == 1'b1)
	 begin
          wdata[0] = 1'b0;
          mmio_write64 (.addr_(addr), .data_(wdata));
         `uvm_info(get_name(), $psprintf("Reset is de-asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
          while(rdata[4])  mmio_read64  (.addr_(addr), .data_(rdata));      
         `uvm_info(get_name(), $psprintf("SOFT_RESET_ACK is released = %0h", rdata), UVM_LOW)
         end
       end
       `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
            #1us;
  endtask : cfg_release_port_rst

    task port_rst_assert();
        bit [63:0]    rdata, wdata, addr;
        addr = pf0_bar0+24'h91038;	
       `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", rdata), UVM_LOW)
        begin
          wdata ='h5;
          mmio_write64 (.addr_(addr), .data_(wdata));
         `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
       end
         `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
    endtask 


    task release_port_rst();
        bit [63:0]       rdata, wdata,addr;
        addr = pf0_bar0+24'h91038;	
       `uvm_info(get_name(), $psprintf("Port reset bit is set to default 0x1 value. PORT_CONTROL = %0h", rdata), UVM_LOW)
        begin
          wdata = 'h4;// De-assert Port reset by writing 1'b0 on PORT_CONTROL[0]
          mmio_write64 (.addr_(addr), .data_(wdata));
	 `uvm_info(get_name(), $psprintf("Reset is de- asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
       end
        `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
         #1us;
    endtask : release_port_rst

endclass : base_seq

`endif // BASE_SEQ_SVH
