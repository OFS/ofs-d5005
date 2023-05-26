// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description  : 
// class maxpayloaderror_seq is executed by maxpayloaderror_test.
// This sequence verifies the Error vector mechanism of protocol-checker block  
// To generate the error the corrupt transactions are forced.
// The sequence monitors the error register is set or not 
// Error is clear using the soft_reset 
//-----------------------------------------------------------------------------

`ifndef MAXPAYLOADERROR_SEQ_SVH
`define MAXPAYLOADERROR_SEQ_SVH

class maxpayloaderror_seq extends he_lpbk_wr_seq;

 `uvm_object_utils(maxpayloaderror_seq)
 `uvm_declare_p_sequencer(virtual_sequencer)
  constraint num_lines_c { num_lines == 512; }

  function new(string name = "maxpayloaderror_seq");
   super.new(name); 
  endfunction    
    
  task body(); 
  bit [63:0] wdata, rdata,rdata_e;
  bit [63:0] addr;
  bit[63:0] rdata_s = 1;
  pcie_rd_mmio_seq  mmio_rd;
  uvm_status_e      status;
  uvm_reg_data_t    reg_data;
  int               timeout;
  time dly_after_err  = 1us;
  time dly_rst_window = 1us;
  time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us

 fork 
  begin
   super.body();
  end
  begin
   wait(tb_top.DUT.afu_top.afu_intf_inst.i_afu_softreset == 0)begin
   #500ns;
   wait(tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tdata[31:24]==8'h60 && tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tvalid == 1 && tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tuser_vendor[9:0] ==10'h1)
  #200ns;
  begin
   force tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tdata[9:0] = 10'd560;   
   `uvm_info(get_name(),"force", UVM_LOW)
    @ (negedge tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tvalid or negedge tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tready) begin
    #50ns;
    release {tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tdata[9:0]};
   `uvm_info(get_name(),"release", UVM_LOW)
    end   //negedge
  end  //fmt_type
 end  //soft_reset
 end
join_any

#dly_after_err;

  port_rst_assert();
  #dly_rst_window;
  release_port_rst ();
  #dly_before_read; //for 512 cycle timout

//check if block traffic is set to 0
rdata_s[31]=1;

 fork
   begin
    while(rdata_s[31]) begin
      mmio_read64 (.addr_(pf0_bar0 + 'hA0010), .data_(rdata_s));
     `uvm_info(get_full_name(), $psprintf("BLOCK_TRAFFIC rdata = %0h", rdata_s),UVM_LOW)
    end
    `uvm_info(get_name(), $psprintf("BLOCK_TRAFFIC = %0h", rdata_s), UVM_LOW)
   end
   begin
      #15us;
   end
 join_any

 if(rdata_s[31])
   `uvm_error(get_full_name(), $psprintf("BLOCK TRAFFIC is not de-asserted in more than 15us rdata = %0h" , rdata_s))
 else
   `uvm_info(get_name(), $psprintf("BLOCK TRAFFIC IS de-asserted, READY TO READ value of rdata = %0h", rdata_s), UVM_LOW)
 

// polling PORT_ERROR[13] for 5us.
rdata_e = 0;
fork
 begin 
  while(!rdata_e[13]) begin
   `uvm_info(get_name(), "Entering  polling port_error...", UVM_LOW) 
   `uvm_info(get_name(), $psprintf(" while..PORT ERROR = %0h", rdata_e), UVM_LOW)
    mmio_read64 (.addr_(pf0_bar0 + 'hA0010), .data_(rdata_e));
   `uvm_info(get_full_name(), $psprintf("rdata = %0h", rdata_e),UVM_LOW)
  end
  `uvm_info(get_name(), $psprintf("PORT_ERROR_value = %0h", rdata_e), UVM_LOW)
 end 
 begin
  `uvm_info(get_name(), $psprintf("20US FORK THREAD"), UVM_LOW)
  #20us;
  end
join_any
 if(!rdata_e[13])
   `uvm_error(get_full_name(), "PORT ERROR is not asserted for 5us")
  else 
   `uvm_info(get_name(), $psprintf("PORT ERROR = %0h", rdata_e), UVM_LOW)

if(|rdata_e[63:14] || |rdata_e[12:0])
  `uvm_info(get_full_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata_e),UVM_LOW);

 // polling PORT_FIRST_ERROR[13] for 5us
rdata_e = 0;
fork
 begin 
  while(!rdata_e[13]) begin
  `uvm_info(get_name(), "Entering  polling port_first_error...", UVM_LOW)
  `uvm_info(get_name(), $psprintf(" while PORT FIRST ERROR = %0h", rdata_e), UVM_LOW)
   mmio_read64 (.addr_(pf0_bar0 + 'hA0018), .data_(rdata_e));
  `uvm_info(get_full_name(), $psprintf(" rdata = %0h", rdata_e),UVM_LOW)
  end
 `uvm_info(get_name(), $psprintf("PORT_FIRST_ERROR_value = %0h", rdata_e), UVM_LOW)
 end 
 begin
  #15us;
 end
join_any

if(!rdata_e[13])
 `uvm_error(get_full_name(), "PORT FIRST ERROR is not asserted for 5us")
else
 `uvm_info(get_name(), $psprintf("PORT FIRST ERROR = %0h", rdata_e), UVM_LOW)

 if(|rdata_e[63:14] || |rdata_e[12:0])
   `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata = %0h", rdata_e))

   tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
   `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
    tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
   `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif
  
  
 clear_port_error(64'h0000_2002);    

    endtask

task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = pf0_bar0+'hA0010; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[13])
    mmio_write64(addr,wdata); // DW address
  else
    `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"));
    #1
    mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata),UVM_LOW);
     #5us;
     rdata ='h0;
     addr = pf0_bar0+'hA0018; // FIRST_PORT_ERR_REG
     mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata));

endtask
 
endclass : maxpayloaderror_seq 


`endif
