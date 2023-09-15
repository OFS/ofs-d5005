// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description : This is the base test
//-----------------------------------------------------------------------------

`ifndef BASE_TEST_SVH
`define BASE_TEST_SVH

class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    tb_config tb_cfg0;
    tb_env    tb_env0;
    uvm_table_printer printer;
    int               regress_mode_en;
    int               timeout;
    int               test_pass = 1;
    int               sim_length_reached;
    uvm_report_object reporter;
    bit               exp_timeout = 0;

    `VIP_ERR_CATCHER_CLASS err_catcher;
    `AXI_SYS_CFG_CLASS               cfg;
   

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        string regress_mode_en_str;
        super.build_phase(phase);

        // AXI VIP
        cfg = `AXI_SYS_CFG_CLASS ::type_id::create("cfg");
	uvm_config_db #(`AXI_SYS_CFG_CLASS )::set(this, "tb_env0", "cfg", this.cfg);

	
	tb_cfg0 = tb_config::type_id::create("tb_cfg0", this);
	tb_cfg0.pcie_cfg.root_cfg = new();
	tb_cfg0.pcie_cfg.setup_pcie_device_system_defaults();

        randomize(tb_cfg0);
	uvm_config_db #(tb_config)::set(this, "tb_env0","tb_cfg0", tb_cfg0);
	
	tb_env0 = tb_env::type_id::create("tb_env0", this);

        // AXI VIP
	/** Set the default_sequence for slave vip */
        uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.axi_system_env.slave[0].sequencer.run_phase", "default_sequence", axi_slave_mem_response_sequence::type_id::get());
        /** Apply the default reset sequence */
        uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.sequencer.reset_phase", "default_sequence", axi_simple_reset_sequence::type_id::get());
	// end of AXI VIP

        printer = new();
        printer.knobs.depth = 5;
        printer.knobs.name_width = 40;
        printer.knobs.type_width = 32;
        printer.knobs.value_width = 32;

       err_catcher=new();
       //add error message string to error catcher 
       err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_mem_read_bad_cpl_lower_addr/");
       err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_spurious_cpl/");
       err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_low_byte_count/");
       err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_high_byte_count/");
       uvm_report_cb::add(null,err_catcher);

    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

   
    virtual task timeout_watch(uvm_phase phase);
        string msgid;
        int timeout,flush_timeout;
        string timeout_str;
        
        msgid = get_name();
        timeout=this.timeout;

        if(!timeout) begin
            if($value$plusargs("TIMEOUT=%s", timeout_str)) begin
                timeout = timeout_str.atoi();   // in us
            end else
                timeout = 2000;
        end

        reporter.uvm_report_info(msgid, $psprintf("TIMEOUT = %d", timeout), UVM_LOW);            
        repeat(timeout) begin
            # 1us;         
        end
        sim_length_reached = 1;
        reporter.uvm_report_info(msgid, "Reached simulation duration, finishing test...", UVM_LOW);
 
        //Regress mode tests run for 'timeout', so need larger flush times       
        flush_timeout=(timeout>2000)?2*timeout:2000;

        repeat(flush_timeout) begin
            # 1us;         
        end
        test_pass = 0;
        if(regress_mode_en) phase.phase_done.display_objections();
        if (exp_timeout) begin
            `uvm_warning(msgid, "*** TIMED OUT! ***")   
            phase.phase_done.display_objections();
        end else begin
            `uvm_fatal(msgid, "*** TIMED OUT! ***")    
        end
    endtask : timeout_watch

    endclass : base_test

class err_demoter extends uvm_report_catcher;
  bit err_demoted;
  `uvm_object_utils(err_demoter)
  function new(string name="err_demoter");
	super.new(name);
  endfunction : new
  function action_e catch();
	if((get_severity() == UVM_ERROR) && 
        (get_id() == "m_seq"))begin
  	set_severity(UVM_INFO);
  	err_demoted = 1;
    end
    return THROW;
  endfunction : catch
endclass : err_demoter

class err_demoter_1 extends uvm_report_catcher;
  bit err_demoted;
  `uvm_object_utils(err_demoter_1)
  function new(string name="err_demoter_1");
	super.new(name);
  endfunction : new
  function action_e catch();
	if((get_severity() == UVM_ERROR) && 
        (get_id() == "uvm_test_top.tb_env0.v_sequencer.m_seq"))begin
  	set_severity(UVM_INFO);
  	err_demoted = 1;
    end
    return THROW;
  endfunction : catch
endclass : err_demoter_1

`endif // BASE_TEST_SVH
