// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : 
// class helb_csr_seq is executed by helb_csr_test
// MMIO access for HE_LPK Registers
// Sequence is running on virtual_sequencer 
//-----------------------------------------------------------------------------

`ifndef HELB_CSR_SEQ_SVH
`define HELB_CSR_SEQ_SVH

class helb_csr_seq extends fme_csr_seq;
    `uvm_object_utils(helb_csr_seq)

    function new(string name = "helb_csr_seq");
        super.new(name);
    endfunction : new

    virtual function void get_regs();
	tb_env0.helb_regs.get_registers(m_regs);
    endfunction : get_regs

    task wr_rd_cmp();
        uvm_reg m_reg;    
        // HE-LB Configuration is allowed only when CSR_CTL [0] = 1 & CSR_CTL [1] = 0.
	program_ctl();
        for(int i = 0; i < m_regs.size(); i++) begin
	    bit [63:0] mask, field_mask;
	    uvm_reg_field m_reg_fields[$];
	    if(m_regs[i].get_name() == "CTL")
	        continue;
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
	    if(mask) begin
	        if(m_regs[i].get_name() == "NUM_LINES")
	            std::randomize(wdata) with { wdata < 1024; };
		else

        for(int i=0;i<=2;i++) begin 
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
	
    endtask : wr_rd_cmp

    virtual task program_ctl();
        wdata = 64'h1;
        tb_env0.helb_regs.CTL.write(status, wdata);
    endtask : program_ctl

endclass : helb_csr_seq

`endif // HELB_CSR_SEQ_SVH
