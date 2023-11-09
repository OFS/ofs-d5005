// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class MMIOTimedOut_seq is executed by MMIOTimedout_test.
// This sequence verifies the Error vector mechanism of protocol-checker block  
// To generate the error the corrupt transactions are forced.
// The sequence monitors the error register is set or not 
// Error is clear using the soft_reset
//-----------------------------------------------------------------------------

`ifndef MMIOTIMEDOUT_SEQ_SVH
`define MMIOTIMEDOUT_SEQ_SVH

class MMIOTimedOut_seq extends base_seq;

  `uvm_object_utils(MMIOTimedOut_seq)

   function new(string name = "MMIOTimedOut_seq");
      super.new(name); 
   endfunction    
    
   virtual task body();
      pcie_rd_mmio_seq mmio_rd;
      bit[63:0] rw_bits,default_value;
      bit[63:0] rdata = 0;
      bit[63:0] wdata = 0;
      bit[63:0] rdata_s = 1;
      uvm_status_e       status;
      uvm_reg_data_t     reg_data;
      int                timeout;
      time dly_after_err  = 5us;
      time dly_rst_window = 1us;
      time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us
      logic[63:0] addr;
      super.body();
  
  fork
     begin
       addr = pf0_bar0+'h60068; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata), .blocking_(0));
      `uvm_info(get_name(), $psprintf("Data_64 addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     end
     begin
      force {tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tvalid} = 0;
    `uvm_info("INFO", "tvalid forced to 0", UVM_LOW);
      #10us; // Delay decreased to 10us for MMIOTimed Error
      release {tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tvalid};
    `uvm_info("INFO", "tvalid released from 0", UVM_LOW);  
      end
  join_any
  
   #dly_after_err;

   //using soft_reset

  port_rst_assert(); //write 05 
  #dly_rst_window;            // not sure when ack will assert 
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

// polling PORT_ERROR[4] for 5us.
rdata=0;
 fork
   begin
    while(!rdata[7]) begin
      mmio_read64 (.addr_(pf0_bar0 + 'hA0010), .data_(rdata));
     `uvm_info(get_full_name(), $psprintf("PORT0 rdata = %0h", rdata),UVM_LOW)
    end
    `uvm_info(get_name(), $psprintf("value of rdata - PORT ERROR = %0h", rdata), UVM_LOW)
  end
    begin
      #15us;
    end
 join_any

 if(!rdata[7])
   `uvm_error(get_full_name(), $psprintf("PORT ERROR is not asserted for 15us rdata = %0h" , rdata))
 else
   `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:8] || |rdata[6:0])
   `uvm_info(get_full_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata),UVM_LOW)

// polling PORT_FIRST_ERROR[7] for 5us
rdata = 0;
 fork
  begin
    while(!rdata[7]) begin
      mmio_read64 (.addr_(pf0_bar0 + 'hA0018), .data_(rdata));
     `uvm_info(get_full_name(), $psprintf("PORT1 rdata = %0h", rdata),UVM_LOW)
    end
    `uvm_info(get_name(), $psprintf("value of rdata - PORT FIRST ERROR = %0h", rdata), UVM_LOW)
  end
     begin
     #15us;
   end
 join_any

 if(!rdata[7])
   `uvm_error(get_full_name(), $psprintf("PORT FIRST ERROR is not asserted for 15us"))
 else
   `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:8] || |rdata[6:0])
   `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata = %0h", rdata))

	    tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
       `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
        tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
       `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif

 #10us
  clear_port_error(64'h0000_0080);
   #1
  //check if any transaction is completing 
    
     wdata = 64'h55555555ffffffff;
     mmio_write64(.addr_(he_hssi_base_addr+'h48), .data_(wdata));
     mmio_read64 (.addr_(he_hssi_base_addr+'h48), .data_(rdata));
 
     if(rdata == wdata)
       `uvm_info(get_name(), $psprintf(" AFU_SCRATCHPAD match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
     else
       `uvm_error(get_name(), $psprintf("AFU_SCRATCHPAD Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

    //AFU_INTF_DFH read
     tb_env0.regs.afu_intf_regs.AFU_INTF_DFH.read(status,rdata);
     `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_DFH.cg_vals.sample();`endif


  
  //==================================================
     // Write and Read 'hFFFFFFFF_FFFFFFFF to AFU_INTF_SCRATCHPAD
     //==================================================
     wdata='hFFFFFFFF_FFFFFFFF ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&default_value)|rw_bits ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)


     //==================================================
     // Write and Read 'hAAAAAAAA_AAAAAAAA to AFU_INTF_SCRATCHPAD
     //==================================================
     wdata='hAAAAAAAA_AAAAAAAA ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&rw_bits)|default_value;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)

//==================================================
     // Write and Read 'h00000000_00000000 to AFU_INTF_SCRATCHPAD
     //==================================================
     wdata='h00000000_00000000 ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata|default_value)&(~rw_bits) ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)

     //==================================================
     // Write and Read 32'hFFFFFFFFto AFU_INTF_SCRATCHPAD
     //==================================================
     wdata=32'hFFFFFFFF ;
     default_value=32'h00000000 ;
     rw_bits = 'hFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&default_value)|rw_bits ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)

     //==================================================
     // Write and Read 32'hAAAAAAAA to AFU_INTF_SCRATCHPAD
     //==================================================
     wdata=32'hAAAAAAAA ;
     default_value=32'h00000000 ;
     rw_bits = 'hFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&rw_bits)|default_value;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)


     //==================================================
     // Write and Read 32'h00000000 to AFU_INTF_SCRATCHPAD
     //==================================================
     wdata=32'h00000000 ;
     default_value=32'h00000000 ;
     rw_bits = 32'hFFFFFFFF ;
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata|default_value)&(~rw_bits) ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","AFU_INTF_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "AFU_INTF_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","AFU_INTF_SCRATCHPAD",wdata, rdata), UVM_LOW)

 
endtask

task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = pf0_bar0+'hA0010; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[7])
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
 
endclass : MMIOTimedOut_seq 

`endif








