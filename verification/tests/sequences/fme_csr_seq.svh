// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class fme_csr_seq is executed by fme_csr_test
// MMIO access for FME CSR Registers
// This sequence uses the RAL model for front-door access of registers 
// Sequence is running on virtual_sequencer
//-----------------------------------------------------------------------------

`ifndef FME_CSR_SEQ_SVH
`define FME_CSR_SEQ_SVH

class fme_csr_seq extends base_seq;
    `uvm_object_utils(fme_csr_seq)

    uvm_reg m_regs[$];
    uvm_reg_data_t wdata, rdata, exp_val;
    uvm_status_e   status;

    function new(string name = "fme_csr_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
	get_regs();
	check_reset_value();
	wr_rd_cmp();
	check_afu_intf_error();
    endtask : body

    virtual function void get_regs();
	tb_env0.fme_regs.get_registers(m_regs);
    endfunction : get_regs

    virtual task check_reset_value();
       `uvm_info(get_name(),"Entering check_reset task...", UVM_LOW)
      //uvm_reg_data_t  exp_val;
      foreach(m_regs[i]) begin
        `uvm_info(get_name(),"Entering  foreach loop...", UVM_LOW)
      //tb_env0.regs.fme_regs.read_reg_by_name(status, m_regs[i].get_name(), rdata);
       if(m_regs[i].get_name() =="INFO0")
         `uvm_info( "INFO",$sformatf("INFO0 is not compared to a known value"), UVM_LOW) //Depending on Michael Adler's response on INFO0 this is removed for check in the testcase for INFO0
/*Please don’t update the tests to expect some new specific value in INFO0. Those values will change, depending on the FIM configuration, and will be tested well enough on hardware since host_exerciser adjusts the tests/result to INFO0. You should simply stop comparing INFO0 to a “known” value.*/
       else if(m_regs[i].get_name() =="MSIX_COUNT_CSR")
         `uvm_info( "INFO",$sformatf("MSIX COUNT CSR is currently unused"), UVM_LOW)
       else if(m_regs[i].get_name() =="BITSTREAM_ID") begin
	     m_regs[i].read(status, rdata); 
         exp_val = 64'h123450789abcdef;
         if(rdata !== exp_val)
         `uvm_error(get_name(), $psprintf("Reset value mismatch! %s: act = %0h exp = %0h", m_regs[i].get_name(), rdata, exp_val))
         else
         `uvm_info(get_name(), $psprintf("Reset value match! %s: val = %0h", m_regs[i].get_name(), rdata), UVM_LOW)
       end 
       else begin
	     m_regs[i].read(status, rdata);
         exp_val = m_regs[i].get_reset();
         if(rdata !== exp_val)
           `uvm_error(get_name(), $psprintf("Reset value mismatch! %s: act = %0h exp = %0h", m_regs[i].get_name(), rdata, exp_val))
         else
	   `uvm_info(get_name(), $psprintf("Reset value match! %s: val = %0h", m_regs[i].get_name(), rdata), UVM_LOW)
       end
     end
       `uvm_info(get_name(),"exiting  check_reset task...", UVM_LOW)   
    endtask : check_reset_value
   
   virtual task wr_rd_cmp();
        uvm_reg m_reg;
        for(int i = 0; i < m_regs.size(); i++) begin
	    bit [63:0] mask, field_mask;
	    uvm_reg_field m_reg_fields[$];
        if(m_regs[i].get_name() =="INFO0")
         `uvm_info( "INFO",$sformatf("INFO0 is not compared to a known value"), UVM_LOW)
       else if(m_regs[i].get_name()== "MSIX_COUNT_CSR")
         `uvm_info("INFO", $sformatf("MSIX COUNT CSR is currently unused "), UVM_LOW)
        else
            begin
        m_reg = m_regs[i];
	    m_reg.get_fields(m_reg_fields);
	    m_reg_fields.sort(p) with (p.get_lsb_pos());
	    for(int j = 0; j < m_reg_fields.size(); j++) begin
	        int unsigned n_bits;
	        int unsigned r_bits;
		n_bits = m_reg_fields[j].get_n_bits();
		r_bits = 64 - n_bits;
		if(m_reg_fields[j].get_access() == "RW") begin
		    field_mask = {{n_bits{1'b1}}, {r_bits{1'b0}}};
		end
		else
		    field_mask = 0;
		mask = mask >> n_bits;
		mask |= field_mask;
	    end
	    if(m_reg.get_n_bits() == 32)
	        mask = mask >> 32;

       for(int i=0;i<=3;i++) begin    
	   if(mask) begin
	      if(i==0) begin	
             wdata= 64'h0000_0000_0000_0000;
             m_reg.write(status, wdata);
	         m_reg.read(status, rdata);
	      if((wdata & mask) !== (rdata & mask))
	        `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %16h rdata = %16h mask = %16h", m_reg.get_name(), wdata, rdata, mask))
	      else
	        `uvm_info(get_name(), $psprintf("Data match %s! data = %16h mask = %16h", m_reg.get_name(), rdata, mask), UVM_LOW)
           end
           if(i==1) begin   
              wdata= 64'hffff_ffff_ffff_ffff;
	      m_reg.write(status, wdata);
	      m_reg.read(status, rdata);
	      if((wdata & mask) !== (rdata & mask))
	        `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %16h rdata = %16h mask = %16h", m_reg.get_name(), wdata, rdata, mask))
	      else
	        `uvm_info(get_name(), $psprintf("Data match %s! data = %16h mask = %16h", m_reg.get_name(), rdata, mask), UVM_LOW)
	   end
           else if(i==2) begin
              wdata= 64'h0000_0000_0000_0000;
              m_reg.write(status, wdata);
	      m_reg.read(status, rdata);
	      if((wdata & mask) !== (rdata & mask))
	        `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %16h rdata = %16h mask = %16h", m_reg.get_name(), wdata, rdata, mask))
	      else
	        `uvm_info(get_name(), $psprintf("Data match %s! data = %16h mask = %16h", m_reg.get_name(), rdata, mask), UVM_LOW)
           end
          /* else begin
              std::randomize(wdata);
	      m_reg.write(status, wdata);
	      m_reg.read(status, rdata);
	      if((wdata & mask) !== (rdata & mask))
	        `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %16h rdata = %16h mask = %16h", m_reg.get_name(), wdata, rdata, mask))
	      else
	        `uvm_info(get_name(), $psprintf("Data match %s! data = %16h mask = %16h", m_reg.get_name(), rdata, mask), UVM_LOW)
            end */
          end
        end
 
     end
  end
 endtask : wr_rd_cmp 

endclass : fme_csr_seq

`endif // FME_CSR_SEQ_SVH
