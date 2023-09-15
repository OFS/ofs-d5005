// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description :
// class malformedtlp_seq is executed by malformedtlp_test.
// This sequence verifies the Error vector mechanism of protocol-checker block  
// To generate the error the corrupt transactions are forced.
// The sequence monitors the error register is set or not 
// Error is clear using the soft_reset
//-----------------------------------------------------------------------------

`ifndef MALFORMEDTLP_SEQ_SVH
`define MALFORMEDTLP_SEQ_SVH


class malformedtlp_seq extends base_seq;

  `uvm_object_utils(malformedtlp_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
   string msgid;

   function new(string name = "malformedtlp_seq");
       super.new(name); 
       msgid=get_type_name();
   endfunction    
    
   task body();
    pcie_rd_mmio_seq mmio_rd;
       // bit[63:0] rdata = 0;
        uvm_status_e       status;
        uvm_reg_data_t     reg_data;
        int                timeout;
        bit [63:0]         wdata, rdata,regdata,rw_bits,exp_data,rdata_s;
        bit [15:0] req_id;
        logic[63:0] addr;
        time dly_after_err  = 7us; 
        time dly_rst_window = 1us;
        time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us

        super.body();

       `uvm_info(get_name(),"Entered the malformed tlp sequnence", UVM_LOW)
	   
   fork
      begin
         tb_env0.helb_regs.HE_DFH.read(status,regdata);
        `uvm_info(get_full_name(), $psprintf("value of DFH regdata = %0h", regdata), UVM_LOW)
      end    
      begin
        force {tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tdata[31:29]} = 3'b111;
        @(negedge tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tvalid);
        release {tb_top.DUT.afu_top.afu_intf_inst.afu_axis_tx.tdata[31:29]};

      end
		
   join_any
  
  #dly_after_err;
  	    
   port_rst_assert(); //write 05 
  #dly_rst_window; 
   release_port_rst ();
  #dly_before_read;
   
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
      `uvm_info(get_full_name(),$sformatf("Port Reset Done...."),UVM_LOW)
      `uvm_info(get_name(), "POLLING_ERR_BIT", UVM_LOW)
      `uvm_info(get_full_name(), $psprintf("value of rdata before polling rdata = %0h", rdata), UVM_LOW)

   // polling PORT_ERROR[14] for 5us.
   rdata = 0;
   fork
        begin
         while(!rdata[14] && !rdata[7]) begin
              `uvm_info(get_full_name(), $psprintf("value of rdata after while rdata = %0h", rdata), UVM_LOW)
             `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                 mmio_rd.rd_addr == pf0_bar0 + 'hA0010;
                 mmio_rd.rlen    == 2;
                 mmio_rd.l_dw_be == 4'b1111;
             })
             rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
        end 
            `uvm_info(get_full_name(), $psprintf("value of rdata rdata = %0h", rdata), UVM_LOW)
         end
         begin
             #5us;
         end
   join_any

   if(!rdata[14])
        `uvm_error(get_full_name(), "PORT ERROR is not asserted for 5us")
   else
        `uvm_info(get_full_name(), $psprintf("PORT_ERROR reg rdata = %0h", rdata), UVM_LOW)
   if(|rdata[63:15] || |rdata[13:0])
        `uvm_info(get_full_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata), UVM_LOW)


     // polling PORT_FIRST_ERROR[14] for 5us
   rdata = 0;
   fork
     begin
         while(!rdata[14]) begin
            `uvm_info(get_full_name(), $psprintf("PORT_FIRST_ERROR reg rdata = %0h", rdata), UVM_LOW)
             `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
                 mmio_rd.rd_addr == pf0_bar0 + 'hA0018;
                 mmio_rd.rlen    == 2;
                 mmio_rd.l_dw_be == 4'b1111;
             })
             rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
     end
        `uvm_info(get_full_name(), $psprintf("value of rdata rdata = %0h", rdata), UVM_LOW)
     end    
     begin
         #5us;
     end
   join_any

   `uvm_info(get_full_name(), $psprintf("PORT_FIRST_ERROR  rdata = %0h", rdata), UVM_LOW)
   if(!rdata[14])
       `uvm_error(get_full_name(), "PORT FIRST ERROR is not asserted for 5us")
   else
       `uvm_info(get_full_name(), $psprintf("PORT_FIRST_ERROR reg rdata = %0h", rdata), UVM_LOW)

   if(|rdata[63:15] || |rdata[13:8])
       `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata = %0h", rdata))
   
        tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
       `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
        tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
       `ifdef COV tb_env0.regs.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif

    clear_port_error(64'h0000_4080);  //MMIO timedout error is cleared as well
  
   endtask

   task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
        logic [63:0] addr;
        logic [63:0] rdata;
        addr = pf0_bar0+'hA0010; //PORT_ERR_REG
        mmio_read64 (.addr_(addr), .data_(rdata));
        if (rdata[14])
           mmio_write64(addr,wdata); // DW address
       else
          `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"))
        #1
          mmio_read64 (.addr_(addr), .data_(rdata));
       if(|rdata)    
         `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata),UVM_LOW)
          #5us;
          rdata ='h0;
          addr = pf0_bar0+'hA0018; // FIRST_PORT_ERR_REG
          mmio_read64 (.addr_(addr), .data_(rdata));
       if(|rdata)    
          `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata))
   endtask   
endclass : malformedtlp_seq 
`endif

































































