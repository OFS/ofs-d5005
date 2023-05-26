// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : Top level TB Env - Consists of all env components
//-----------------------------------------------------------------------------

`ifndef TB_ENV_SVH
`define TB_ENV_SVH

class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)

`ifndef INCLUDE_HSSI
    // AXI System ENV
    `AXI_SYS_ENV axi_system_env;
    axi_mmio_access_wrapper axi_mmio_wrapper;
    axi_virtual_sequencer sequencer;
    // AXI System Configuration
    cust_axi_system_configuration cfg;

`endif // INCLUDE_HSSI

    // Virtual Sequencer
    virtual_sequencer v_sequencer;

    tb_config      tb_cfg0;

    // PCIe agent instance
    `PCIE_DEV_AGENT  root;
    `PCIE_DEV_STATUS root_status;

    rand int p_hdr_credit, np_hdr_credit, cpl_hdr_credit;
    rand int p_data_credit, np_data_credit, cpl_data_credit;
    rand bit en_dsbp;
    rand bit enable_bp_credit;

    ral_block_fme    fme_regs;
    ral_block_msix   msix_regs;
    ral_block_hssi   hehssi_regs;
    ral_block_loop   helb_regs;
    ral_block_he_mem hemem_regs;
    ral_block_pcie   pcie_regs;
    ral_block_pr     pgsk_regs;
    ral_block_spi    pmci_regs;
    ral_block_st2mm  st2mm_regs;
    ral_block_port_gasket port_gasket_regs;
    ral_block_afu_intf afu_intf_regs;
    ral_block regs;
//COVERAGE   
   `ifdef ENABLE_R1_COVERAGE
      ofs_coverage  cov_r1;
  `endif

    constraint root_credit {
       p_hdr_credit inside {[10:100]};
       np_hdr_credit inside {[10:100]};
       cpl_hdr_credit inside {[10:100]};
       p_data_credit inside {[100:1000]};
       np_data_credit inside {[100:1000]};
       cpl_data_credit inside {[100:1000]};
       en_dsbp dist { 1 := 10, 0 := 90};
       enable_bp_credit  == 1;
    }


    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bit status1, status2;
	int max_payload_size, max_read_request_size;
        super.build_phase(phase);

        if(!uvm_config_db#(tb_config)::get(this,"","tb_cfg0",tb_cfg0))
            `uvm_fatal(get_name(), "failed to get tb_cfg ");

`ifndef INCLUDE_HSSI
        if (uvm_config_db#(`AXI_SYS_CFG_CLASS)::get(this, "", "cfg", cfg)) begin
          /** Apply the configuration to the System ENV */
          uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axi_system_env", "cfg", cfg);
        end
        // No configuration passed from test
        else begin
          cfg =  `AXI_SYS_CFG_CLASS::type_id::create("cfg");
          /** Apply the configuration to the System ENV */
          uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axi_system_env", "cfg", cfg);
        end
        // create an instance of env
        axi_system_env = `AXI_SYS_ENV::type_id::create("axi_system_env", this);
	axi_mmio_wrapper = axi_mmio_access_wrapper::type_id::create("axi_mmio_wrapper", this); 
	sequencer = axi_virtual_sequencer::type_id::create("sequencer", this);
`endif // INCLUDE_HSSI

	v_sequencer = virtual_sequencer::type_id::create("v_sequencer", this);
	v_sequencer.tb_cfg0 = tb_cfg0;
        // Register configurations for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_CFG_CLASS)::set(this, "root", "cfg", this.tb_cfg0.pcie_cfg.root_cfg);

        //COVERAGE
        `ifdef ENABLE_R1_COVERAGE
           cov_r1= ofs_coverage::type_id::create("cov_r1", this);
        `endif
    
        // Construct Root complex device namely root.
        `ifdef GEN3
            this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 1;
        `else
            this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 0;
	`endif // GEN3
        //Set max_read_request_size in VIP/BFM
        status1 = uvm_config_db #(int unsigned)::get(this, "*", "max_read_request_size", max_read_request_size);
        if(status1) begin
          `uvm_info("body", $sformatf("ENV: max_read_request_size %d ", max_read_request_size), UVM_LOW);
           this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_read_request_size = max_read_request_size;
        end
        status2 = uvm_config_db #(int unsigned)::get(this, "*", "max_payload_size", max_payload_size);
	//Set max_payload_size in VIP/BFM
        if(status2) begin
          `uvm_info("body", $sformatf("SDEBUG: max_payload_size %d", max_payload_size), UVM_LOW);
           this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_payload_size = max_payload_size;
           this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_payload_size_in_bytes = max_payload_size; 
           this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_read_cpl_data_size_in_bytes = (max_payload_size > 256)? 256 :  max_payload_size; //TODO: 256B vs. 512B
        end
	// Set max_payload_size in root_cfg
        this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.dl_cfg.max_payload_size = 4096;
	// To enable extended tag in the VIP
        this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_extended_tag_field_enabled = 1'b1;

        if (enable_bp_credit || ($test$plusargs("BP_CREDIT")) )begin
           if(en_dsbp == 1) begin
             `uvm_info("body", $sformatf("SDEBUG: controlling Root header and data credits to create down stream back pressure "), UVM_LOW);
              for(int i=0; i<8; i++) begin
                 assert(this.randomize());
                 //post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_hdr_tx_credits[i] = 1;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_data_tx_credits[i] = 16;

                 //Non-post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_hdr_tx_credits[i] = 1;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_data_tx_credits[i] = np_data_credit;

                 //Completion credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[i] = 2;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_data_tx_credits[i] = 32;
              end
           end
           else begin
             `uvm_info("body", $sformatf("SDEBUG: Randomized Root posted, non-posted, completion credits "), UVM_LOW);
              for(int i=0; i<8; i++) begin
                 assert(this.randomize());
                 //post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_hdr_tx_credits[i] = p_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_data_tx_credits[i] = p_data_credit;

                 //Non-post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_hdr_tx_credits[i] = np_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_data_tx_credits[i] = np_data_credit;

                 //Completion credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[i] = cpl_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_data_tx_credits[i] = cpl_data_credit;
              end
           end
        end //end plusargs

        //Set the model instance scope
        this.tb_cfg0.pcie_cfg.root_cfg.model_instance_scope = "tb_top.root0";

        //Create status objects for Root and Endpoint devices 
        root_status = `PCIE_DEV_STATUS::type_id::create("root_status");

        // Register configurations for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_CFG_CLASS)::set(this, "root", "cfg", this.tb_cfg0.pcie_cfg.root_cfg);

        // Register status objects for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_STATUS)::set(this, "root", "shared_status", this.root_status);

	root = `PCIE_DEV_AGENT::type_id::create("root", this);

        // RAL
        regs = ral_block::type_id::create("regs", this);
	//regs.build();
	//regs.lock_model();
	//fme_regs    = regs.fme_regs;
	//hehssi_regs = regs.hehssi_regs;
	//helb_regs   = regs.helb_regs;
	//hemem_regs  = regs.hemem_regs;
	//pcie_regs   = regs.pcie_regs;
	//pgsk_regs   = regs.pgsk_regs;
	//pmci_regs   = regs.pmci_regs;
	//st2mm_regs  = regs.st2mm_regs;

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	v_sequencer.root_virt_seqr = root.virt_seqr;
`ifndef INCLUDE_HSSI
	v_sequencer.axi_seqr = axi_system_env.sequencer;
	axi_system_env.slave[0].monitor.item_observed_port.connect(axi_mmio_wrapper.axi_mmio_wr_rd);
`endif // INCLUDE_HSSI

//        if(regs.get_parent() == null) begin
//	    regs.fme_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.fme_map.set_auto_predict(1);
//	    regs.hehssi_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.hehssi_map.set_auto_predict(1);
//	    regs.helb_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.helb_map.set_auto_predict(1);
//	    regs.hemem_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.hemem_map.set_auto_predict(1);
//	    regs.pcie_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.pcie_map.set_auto_predict(1);
//	    regs.pmci_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.pmci_map.set_auto_predict(1);
//	    regs.pgsk_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.pgsk_map.set_auto_predict(1);
//	    regs.st2mm_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0], reg2pcie_reg_adapter::type_id::create());
//	    regs.st2mm_map.set_auto_predict(1);
//	end
    endfunction : connect_phase

endclass : tb_env

`endif // TB_ENV_SVH
