// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//===============================================================================================================
// Description : 
// class fme_ras_cat_fat_err_seq.svh is executed by fme_ras_cat_fat_err_test 
// This sequnce verifies the RAS fatal error regsiter of FME  
// The Error is generated by forcing / writing the error register 
// PBA mechanism is verified using masking and un-masking the intruppt vector
// Sequnce is running on virtual_sequencer 
//===============================================================================================================

`ifndef FME_RAS_CAT_FAT_ERR_SEQ_SVH
`define FME_RAS_CAT_FAT_ERR_SEQ_SVH

class fme_ras_cat_fat_err_seq extends base_seq;
    `uvm_object_utils(fme_ras_cat_fat_err_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

  rand bit[63:0]    intr_addr;
  rand bit[63:0]    intr_wr_data;
  rand bit[63:0]    ras_err_code;//1:CatastError, 2:FatalError, 4:NoFatalError
  rand bit[63:0]    fme_err_code;//1:PartialReconfigFIFOParityErr, 2:RemoteSTPParityErr, 32:AfuAccessModeErr
  rand bit inj_ras_err; 
  rand bit inj_fme_err; 
  static int e_set;

  rand bit [63:0] dut_mem_start;
  rand bit [63:0] dut_mem_end;
  rand bit Err_type;
  constraint addr_cons {
     dut_mem_end > dut_mem_start;
     intr_addr[7:0] == 0;
     intr_addr   >= dut_mem_start;
     intr_addr    < dut_mem_end;
     intr_addr[63:32] == 32'b0;
  }
    
  constraint wr_dat_cons {
     !(intr_wr_data inside {64'h0});
      intr_wr_data[63:32] == 32'b0; 
  }

  constraint ras_err_code_cons {
     ras_err_code inside {64'h1, 64'h2, 64'h4};//1:CatastError, 2:FatalError, 4:NoFatalError
  }

  constraint fme_err_code_cons {
     fme_err_code inside {64'h1};//1:PartialReconfigFIFOParityErr
  }

  constraint err_type_cons{
    soft inj_ras_err==1;
    soft inj_fme_err==0;
  }
  typedef enum {FAB_FAT_ERR,PCIE_POS_ERR,INJ_FAT_ERR,CRC_CAT_ERR,INJ_CAT_ERR} CAT_FAT_ERR;

    function new(string name = "fme_ras_cat_fat_err_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr, intr_masked_data;
        bit [63:0] afu_id_l, afu_id_h;
        bit msix_req_set;
       
       
       

        super.body();
        `uvm_info(get_name(), "Entering fme_intr_seq...", UVM_LOW)
         if (Err_type)  GEN_RAS_CAT_ERR(INJ_FAT_ERR);
         else GEN_RAS_CAT_ERR(INJ_CAT_ERR);
    endtask
      
     
    task GEN_RAS_CAT_ERR();
        input CAT_FAT_ERR cat_fat_err ;  //{FABRIC_FATAL_ERR:-40,PCIE_POIS_ERR:-,INJ_FAT_ERR:-,CRC_CAT_ERR:-,INJ_CAT_ERR:-}
        bit [63:0] wdata, rdata, addr, intr_masked_data;
        bit [31:0] host_intr_rdata[16];
        bit [63:0] afu_id_l, afu_id_h;
        bit msix_req_set;
        uvm_status_e       status;


 
      `uvm_info(get_name(), $psprintf("GENREATE RAS ERROR =%s",cat_fat_err.name()), UVM_LOW)
       this.randomize() with{dut_mem_start == tb_env0.tb_cfg0.dut_mem_start && dut_mem_end == tb_env0.tb_cfg0.dut_mem_end;};
      `uvm_info(get_name(), $psprintf("TEST: STEP 0 - inj_ras_err=%0d, inj_fme_err=%0d dut_mem_start=%0h dut_mem_end=%0h", inj_ras_err, inj_fme_err, dut_mem_start, dut_mem_end), UVM_LOW)

      `uvm_info(get_name(), $psprintf("TEST: STEP 1 - Configure MSIX Table BAR0 MSIX_ADDR6/MSIX_CTLDAT6"), UVM_LOW)
      `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE to MSIX_ADDR6"), UVM_LOW)
       mmio_write64(.addr_(pf0_bar4+20'h0_3060), .data_(intr_addr));
       #1us;

      `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE to MSIX_CTLDAT6 with masked Interrupt"), UVM_LOW)
       intr_masked_data[31:0] = intr_wr_data[31:0];
       intr_masked_data[63:32] = 32'b1; 
       mmio_write64(.addr_(pf0_bar4+20'h0_3068), .data_(intr_masked_data));
       #25us;
 
       if(inj_ras_err)begin
           `uvm_info(get_name(), $psprintf("TEST: STEP 2 - Inject RAS ERROR ras_err_code=%0x",'h2), UVM_LOW)
            case(cat_fat_err)
              INJ_FAT_ERR: begin tb_env0.fme_regs.RAS_ERROR_INJ.write(status,'h2);
                            end
              INJ_CAT_ERR: begin tb_env0.fme_regs.RAS_ERROR_INJ.write(status,'h1);
                            end
            endcase
       end
	  
      `uvm_info(get_name(), $psprintf("TEST: STEP 3 - Poll MSIX interrupt signal"), UVM_LOW)
       fork 
            begin
               #10us;
            end
            begin
            `uvm_info(get_type_name(),$sformatf("Waiting for MSIX Req"),UVM_LOW)
	     @(posedge `MSIX_TOP.o_intr_valid)
	     @(posedge `MSIX_TOP.o_msix_valid)
             msix_req_set = 1'b1;
            end
      join_any
      disable fork;

      if(msix_req_set)                                                                      
            `uvm_fatal(get_type_name(),"TEST: msix_req generated for masked fme interrupt")
      else
            `uvm_info(get_name(), $psprintf("TEST: msix_req not generated for masked interrupt"), UVM_LOW)

            `uvm_info(get_name(), $psprintf("TEST: STEP 4 - Check MSIX_PBA[6] is set for masked FME interrupt"), UVM_LOW)
     for(int i=0;i<200;i++) begin
            mmio_read64(.addr_(pf0_bar4+20'h0_2000),.data_(rdata));
            if(rdata[6]) break;
            #1ns;
            end
            assert(rdata[6]) else 
           `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[6] not set post masked interrupt"))

           `uvm_info(get_name(), $psprintf("TEST: STEP 5 - Unmasked FME interrupt by writing on MSIX_CTLDAT6[63:32]"), UVM_LOW)
            mmio_write64(.addr_(pf0_bar4+20'h0_3068), .data_(intr_wr_data));

           `uvm_info(get_name(), $psprintf("TEST: STEP 6 - Poll MSIX interrupt signal"), UVM_LOW)
          fork 
            begin
               #10us;
            end
            begin
             `uvm_info(get_type_name(),$sformatf("Waiting for MSIX Req"),UVM_LOW)
	     @(posedge `MSIX_TOP.o_intr_valid)
	     @(posedge `MSIX_TOP.o_msix_valid)
             msix_req_set = 1'b1;
            end
          join_any
          disable fork;

      if(!msix_req_set)                                                                      
            `uvm_fatal(get_type_name(), "TEST: msix_req not generated after unmasking FME interrupt")
      else
            `uvm_info(get_name(), $psprintf("TEST: msix_req generated after unmasking FME interrupt"), UVM_LOW)

      #1us;
      `uvm_info(get_name(), $psprintf("TEST: STEP 7 - Check MSIX_PBA[6] is clear after asserting pending FME interrupt"), UVM_LOW)
       mmio_read64(.addr_(pf0_bar4+20'h0_2000),.data_(rdata));
       assert(rdata[6]==0) else 
      `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[6] is not clear after asserting pending FME interrupt"));

      `uvm_info(get_name(), $psprintf("TEST: STEP 8 - Read Host memory"), UVM_LOW)
       host_mem_read( .addr_(intr_addr) , .data_(host_intr_rdata) , .len('d16) );
       if(changeEndian(host_intr_rdata[0]) !== intr_wr_data)
             `uvm_error(get_name(), $psprintf("Interrupt write data mismatch exp = %0h act = %0h", intr_wr_data, changeEndian(host_intr_rdata[0])))
       else
             `uvm_info(get_name(), $psprintf("TEST: Interrupt data match intr_addr=%0h intr_wr_data = %0h", intr_addr, intr_wr_data), UVM_LOW)

	if(inj_ras_err)begin
             uvm_status_e      status;
             tb_env0.fme_regs.RAS_CATFAT_ERR.read(status,rdata);
            `uvm_info(get_name(), $psprintf("TEST: STEP 9 - READ RAS CAT_FAT_ERROR rdata=%0h",rdata), UVM_LOW)
             case(cat_fat_err)
              INJ_FAT_ERR: begin if(!rdata[8]) `uvm_error(get_type_name(),$sformatf("RAS_CATFAT_STATUS REG is not set for inj_fat_error"));
                                 tb_env0.fme_regs.RAS_ERROR_INJ.write(status,'h0);
                                 #1us;
                                 tb_env0.fme_regs.RAS_CATFAT_ERR.read(status,rdata);
                                 if(rdata) `uvm_error(get_type_name(),$sformatf("RAS_CATFAT_STATUS REG is not Clear for inj_fat_error"));end
                        
              INJ_CAT_ERR: begin if(!rdata[11]) `uvm_error(get_type_name(),$sformatf("RAS_CATFAT_STATUS REG is not set for inj_fat_error"));
                                 tb_env0.fme_regs.RAS_ERROR_INJ.write(status,'h0);
                                 #1us;
                                 tb_env0.fme_regs.RAS_CATFAT_ERR.read(status,rdata);
                                 if(rdata) `uvm_error(get_type_name(),$sformatf("RAS_CATFAT_STATUS REG is not Clear for inj_cat_error"));end
             endcase
            
            `uvm_info(get_name(), $psprintf("TEST: STEP 9 - Clear RAS ERROR and msix_req_set"), UVM_LOW)
	  end
	  if(inj_fme_err)begin
            uvm_reg_data_t    ctl_data;
            uvm_status_e      status;
            release `FME_CSR_TOP.inp2cr_fme_error[63:0]; 
            tb_env0.fme_regs.FME_ERROR0.read(status,ctl_data);
           `uvm_info(get_type_name(),$sformatf("FME Error read ctl_data: %x",ctl_data ),UVM_MEDIUM)
            if(ctl_data != fme_err_code)
     	      `uvm_error(get_type_name(), $psprintf("FME ERROR mismatch ctl_data=%0x fme_err_code=%0x", ctl_data, fme_err_code))
            tb_env0.fme_regs.FME_ERROR0.write(status,'1);
	  end
          msix_req_set = 0;
          #1us;
         `uvm_info(get_name(), "Exiting GEN_ERR_TASK..", UVM_LOW)

    endtask

endclass : fme_ras_cat_fat_err_seq

`endif // FME_RAS_CAT_FAT_ERR_SEQ_SVH