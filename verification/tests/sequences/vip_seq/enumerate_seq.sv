// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description : PCIE Enumerate sequence

//`ifndef GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV
//`define GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV


class enumerate_seq extends `PCIE_DRIVER_TRANSACTION_BASE_SEQ_CLASS; 

 `include "pcie_hip_defines.svh"
   bit[31:0]   dev_ctl_data, pci_ctl;
   bit[2:0]    max_rd_req, max_pl_size;
   bit[63:0]   root_dma_msi_addr;
   bit[31:0]   msi_msgdata;
   bit[15:0]   num_vfs;
   bit[31:0]   vf_page_size;
   static bit[31:0]   vf_size_index;
  `PCIE_DEV_CFG_CLASS  cfg;
   rand bit        use_64b_bar;
   rand bit [63:0] pf0_bar0;

   static bit [63:0] bar4,pf0_vf0_bar0, pf0_vf0_bar4_addr;

   static bit[31:0]  pf0_vf1_bar4_size;

  `uvm_object_utils_begin(enumerate_seq)
      `uvm_field_int(dev_ctl_data, UVM_DEFAULT)
      `uvm_field_int(pci_ctl, UVM_DEFAULT)
      `uvm_field_int(bar4, UVM_DEFAULT)
      `uvm_field_int(pf0_vf0_bar4_addr, UVM_DEFAULT)    
  `uvm_object_utils_end


  function new(string name="enumerate_seq");
    super.new(name);
  endfunction

  virtual task body();
     `PCIE_DRIVER_TRANSACTION_CLASS write_tran, read_tran;
     `VIP_CFG get_cfg;
     bit status1;
     bit[31:0]  msi_ctl;
     bit[31:0]  dev_ctl;
     bit[31:0]  rdata;
     int        pf0_idx;
    if(use_64b_bar) 
	    pf0_vf0_bar4_addr = 64'hab20_0000_0000_0000; 
    else           
	    pf0_vf0_bar4_addr = 32'h0000_0000_ab20_0000; //This is BAR4 address for VF1; PF0_BAR4 offset is 10_0000 fo PF0_VF0_bar4 = 20_0000 and PF0_VF1_BAR4 = 30_0000
     
      
     `uvm_info("body", "SDEBUG enum: Entered Enumerating...", UVM_LOW)

     super.body();
     	`uvm_info(get_name(), $psprintf("pf0_bar0 = %0h and use_64b_bar = %0h",pf0_bar0,use_64b_bar ), UVM_LOW)

 
     //Obtain a handle to the port configuration 
     p_sequencer.get_cfg(get_cfg);
     if (!$cast(cfg, get_cfg)) begin
        `uvm_fatal("body", "Unable to $cast the configuration class");
     end


      max_rd_req   = 3'b000;
    //SSS  max_pl_size  = 3'b010;    // Setting to 512 as DUT supports 512 as max. MAke this part of CONFIG class. 'b010 - 512 'b000 - 128 'b001 - 256
      max_pl_size  = 3'b001;    // Setting to 512 as DUT supports 512 as max. MAke this part of CONFIG class. 'b010 - 512 'b000 - 128 'b001 - 256
      dev_ctl_data = {16'h0, 0, max_rd_req, 4'h0, max_pl_size, 5'b01111};

      
      pci_ctl      = 32'h0506; //disable legacy interrupt, enable Mem space and bus master Enable SERR
      cfg_wr(0, 'h010, 32'hffff_ffff); // PF0 BAR0 size
      cfg_rd(0, 'h010, rdata);
      for(int i = 31; i >= 0; i--) begin
          if(!rdata[i]) begin
	      pf0_idx = i + 1;
	      break;
	  end
      end
      bar4 = pf0_bar0 + (2**pf0_idx);


       `uvm_info(get_name(), $psprintf("pf0_br4 = %0h, pf0_idx =%h,  pf0_bar0_size = %0h ",bar4,  pf0_idx, ( 2**pf0_idx) ), UVM_LOW)

      cfg_wr(0, 'h020, 32'hffff_ffff); // PF0 BAR4 size
      cfg_rd(0, 'h020, rdata);
      //$display("Yang read bar4 = %0h", rdata);
      for(int i = 31; i >= 0; i--) begin
          if(!rdata[i]) begin
	      pf0_idx = i + 1;
	      break;
	  end
      end
    `uvm_info(get_name(), $psprintf("pf0_idx =%h,  pf0_bar4_size = %0h ", pf0_idx, ( 2**pf0_idx) ), UVM_LOW)

      pf0_vf0_bar0 = bar4 + (2**pf0_idx);
      `uvm_info(get_name(), $psprintf(" pf0_vf0_bar0 =%h ", pf0_vf0_bar0 ), UVM_LOW)

      cfg_wr(0, 'h020, bar4[31:0]);
      if(use_64b_bar)
        cfg_wr(0, 'h024, bar4[63:32]);


      cfg_wr(0, 'h1DC, 32'hffff_ffff);
      cfg_rd(0, 'h1DC, rdata);
      for(int i = 31; i >= 0; i--) begin
          if(!rdata[i]) begin
	      pf0_idx = i + 1;
	      break;
	  end
      end
      //$display("Yang vf size = %0h", 2**pf0_idx);
      if(pf0_idx == 12) vf_page_size = 32'h1;
      vf_size_index = pf0_idx;
      vf_page_size = 1 << (pf0_idx-12);
      `uvm_info(get_name(), $psprintf("vf_page_size = %0h, rdata = %0h, vf_size_index= %h ", vf_page_size, rdata, vf_size_index), UVM_LOW)       



      pf0_vf0_bar0 = (pf0_vf0_bar0 % (2**pf0_idx)) ? (pf0_vf0_bar0 / (2**pf0_idx) + 1) * (2**pf0_idx) : pf0_vf0_bar0;
     `uvm_info(get_name(), $psprintf(" pf0_vf0_bar0 =%h ", pf0_vf0_bar0 ), UVM_LOW)
     
      `uvm_info(get_name(), $psprintf("pf0_vf0_bar4_addr = %0h",pf0_vf0_bar4_addr ), UVM_LOW)


   
      `uvm_info(get_name(), $psprintf("pf0_bar0 = %0h",pf0_bar0 ), UVM_LOW)

      cfg_wr(0, 'h078, dev_ctl_data);
      //cfg_wr(0, 'h010, `PF0_BAR0);
      cfg_wr(0, 'h010, pf0_bar0[31:0]);
      if(use_64b_bar)
          cfg_wr(0, 'h014, pf0_bar0[63:32]);

      // reading pf0 bar0-bar4
      cfg_rd(0, 'h10, rdata);
      `uvm_info(get_name(), $psprintf("PF0 BAR0 = %0h", rdata), UVM_LOW)
      cfg_rd(0, 'h14, rdata);
      `uvm_info(get_name(), $psprintf("PF0 BAR1 = %0h", rdata), UVM_LOW)
      cfg_rd(0, 'h18, rdata);
      `uvm_info(get_name(), $psprintf("PF0 BAR2 = %0h", rdata), UVM_LOW)
      cfg_rd(0, 'h1C, rdata);
      `uvm_info(get_name(), $psprintf("PF0 BAR3 = %0h", rdata), UVM_LOW)
      cfg_rd(0, 'h20, rdata);
      `uvm_info(get_name(), $psprintf("PF0 BAR4 = %0h", rdata), UVM_LOW)

      cfg_wr(0, 'h054, root_dma_msi_addr[31:0]);
      if($test$plusargs("pf_msix_mask")) 
	  cfg_wr(0, 'h0B0, 32'hC000_0000);
      else
	  cfg_wr(0, 'h0B0, 32'h8000_0000);
      cfg_wr(0, 'h058, msi_msgdata);
      cfg_rd(0, 'h050, rdata);
      msi_ctl = rdata;
      msi_ctl[16] = (pci_ctl[10] == 1'b1)? 1 : 0;
      cfg_wr(0, 'h050, msi_ctl);
      cfg_wr(0, 'h004, pci_ctl);
      cfg_rd(0, 'h078, rdata);
      dev_ctl = rdata;
      dev_ctl =  dev_ctl | 'h0000_000f;
      cfg_wr(0, 'h078, dev_ctl);

// Set Page Size
      cfg_rd(0, 'h1D4, rdata);
      cfg_wr(0, 'h1D8, vf_page_size);

        cfg_rd(0, 'h1D8, rdata);

// Set NumVFs
      cfg_rd(0, 'h1C4, rdata);
      num_vfs = rdata[15:0];
      cfg_rd(0, 'h1C8, rdata);
      rdata = {rdata[31:16], num_vfs};
      cfg_wr(0, 'h1C8, rdata);
      cfg_rd(0, 'h1C8, rdata);

//check first VF offset and stride
      cfg_rd(0, 'h1CC, rdata);

// Set VF 1,1 Bar0

      cfg_wr(0, 'h1DC, pf0_vf0_bar0[31:0]);
      if(use_64b_bar)
          cfg_wr(0, 'h1E0, pf0_vf0_bar0[63:32]);
      cfg_rd(0, 'h1DC, rdata);
// Set  VF 1, Bar4 

     cfg_rd(0, 'h1EC, rdata);    
     cfg_rd(0, 'h1F0, rdata);
       
     cfg_wr(0, 'h1EC, pf0_vf0_bar4_addr[31:0]);
      `uvm_info(get_name(), $psprintf("pf0_vf0_bar4_addr = %0h",pf0_vf0_bar4_addr[31:0] ), UVM_LOW)

    if(use_64b_bar)begin
      	cfg_wr(0, 'h1F0, pf0_vf0_bar4_addr[63:32]);
       `uvm_info(get_name(), $psprintf("pf0_vf0_bar4_addr = %0h",pf0_vf0_bar4_addr[63:32] ), UVM_LOW)
    end 
       
     cfg_rd(0, 'h1EC, rdata);    
     cfg_rd(0, 'h1F0, rdata);

// Enable VF and MSE
      cfg_wr(0, 'h1C0, 32'h19);
// Enable bus master
      cfg_wr(0, 'h004, pci_ctl);
    
    `uvm_info("body", "SDEBUG enum: Exiting Enumerating...", UVM_LOW)
  endtask: body

  task cfg_rd(input int addr, input int reg_num, output bit [31:0] data);
     `PCIE_DRIVER_TRANSACTION_CLASS cfg_seq;
     `uvm_create(cfg_seq)
      cfg_seq.cfg                 = cfg;
      cfg_seq.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_RD;
      cfg_seq.address             = addr;
      cfg_seq.register_number     = reg_num/4;
      cfg_seq.length              = 1;
      cfg_seq.traffic_class       = 0;
      cfg_seq.address_translation = 0;
      cfg_seq.first_dw_be         = 4'b1111;
      cfg_seq.last_dw_be          = 4'b0000;
      cfg_seq.ep                  = 0;
      cfg_seq.block               = 1;
      cfg_seq.payload             = new[cfg_seq.length];
      `uvm_send(cfg_seq)
      get_response(cfg_seq);

      data = cfg_seq.payload[0];

      `uvm_info("ENUM", $sformatf("Read from addr %0h reg_num = %0h data = %8h", addr, reg_num, cfg_seq.payload[0]), UVM_LOW);

  endtask : cfg_rd

  task cfg_wr(input int addr, input int reg_num, input bit [31:0] data);
      `PCIE_DRIVER_TRANSACTION_CLASS cfg_seq;
      `uvm_create(cfg_seq)
      cfg_seq.cfg                 = cfg;
      cfg_seq.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_WR;
      cfg_seq.address             = addr;
      cfg_seq.register_number     = reg_num/4;
      cfg_seq.length              = 1;
      cfg_seq.traffic_class       = 0;
      cfg_seq.address_translation = 0;
      cfg_seq.first_dw_be         = 4'b1111;
      cfg_seq.last_dw_be          = 4'b0000;
      cfg_seq.ep                  = 0;
      cfg_seq.block               = 1;
      cfg_seq.payload             = new[cfg_seq.length];
      foreach (cfg_seq.payload[i]) begin
         cfg_seq.payload[i]        = data;
      end
      `uvm_send(cfg_seq)
      get_response(cfg_seq);
      `uvm_info("ENUM", $sformatf("Write to addr %0h reg_num = %0h data = %8h", addr, reg_num, data), UVM_LOW);

  endtask : cfg_wr

endclass: enumerate_seq

//`endif //GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV


