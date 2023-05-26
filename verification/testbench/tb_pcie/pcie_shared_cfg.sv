//=======================================================================
// COPYRIGHT (C) 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

// Description :PCIE Shared Config file

`ifndef PCIE_SHARED_CFG_SV
`define PCIE_SHARED_CFG_SV

`include "svt_pcie_device_configuration.sv"
import svt_uvm_pkg::*;
 // Import the PCIE VIP UVM package 
import svt_pcie_uvm_pkg::*;

parameter  GEN = 3;
class pcie_shared_cfg extends uvm_object;
 
  rand `PCIE_DEV_CFG_CLASS root_cfg;
  rand `PCIE_DEV_CFG_CLASS endpoint_cfg;
  rand bit rdcomplt_ooo; // rdcomplt_ooo: 1 read completions out-of-order, 0 in-order

  constraint same_properties_across_pcie_link
  {
    root_cfg.pcie_spec_ver == endpoint_cfg.pcie_spec_ver;
  }

  constraint enforce_location
  {
    root_cfg.device_is_root == 1'b1;
    endpoint_cfg.device_is_root == 1'b0;
    rdcomplt_ooo == 0; 
  }

  constraint physical_root_endpoint_match
  {
    root_cfg.pcie_cfg.pl_cfg.skip_polling_active == endpoint_cfg.pcie_cfg.pl_cfg.skip_polling_active;
  }

  `uvm_object_utils_begin(pcie_shared_cfg)
     `uvm_field_object  (root_cfg , UVM_ALL_ON | UVM_DEEP)
     `uvm_field_object  (endpoint_cfg , UVM_ALL_ON | UVM_DEEP)
     `uvm_field_int     (rdcomplt_ooo, UVM_DEFAULT)
  `uvm_object_utils_end
 
  //=======================
  //function new
  //=======================
  function new(string name = "pcie_shared_cfg");
    super.new(name);
    begin
      // Create Root complex and endpoint configurations
      this.root_cfg = new("root_cfg"); 
      this.endpoint_cfg = new("endpoint_cfg"); 
    end
  endfunction

  //================================
 //function string get_class_name
 //================================
  virtual function string get_class_name ();
    get_class_name = "pcie_shared_cfg";
  endfunction
 
  /** Setup the PCIE device system default values */
  function void setup_pcie_device_system_defaults();
    begin

      /** Enable Protocol Analyzer i.e. PA XML file generation */
      //FUTURE_IMPROVEMENT: root_cfg.pcie_cfg.enable_tl_xml_gen = 1'b1;
      //FUTURE_IMPROVEMENT: root_cfg.pcie_cfg.enable_dl_xml_gen = 1'b1;
      //FUTURE_IMPROVEMENT: root_cfg.pcie_cfg.enable_pl_xml_gen = 1'b1;
      root_cfg.pcie_cfg.enable_transaction_logging = 1'b1;
      root_cfg.pcie_cfg.transaction_log_filename = "trans.log";
      //root_cfg.pcie_cfg.enable_symbol_logging = 1'b1;
      //root_cfg.pcie_cfg.symbol_log_filename = "symbol.log";

      //FUTURE_IMPROVEMENT: endpoint_cfg.pcie_cfg.enable_tl_xml_gen = 1'b1;
      //FUTURE_IMPROVEMENT: endpoint_cfg.pcie_cfg.enable_dl_xml_gen = 1'b1;
      //FUTURE_IMPROVEMENT: endpoint_cfg.pcie_cfg.enable_pl_xml_gen = 1'b1;
      endpoint_cfg.pcie_cfg.enable_transaction_logging = 1'b1;
     
      // Root Complex Configuration 
      root_cfg.device_is_root         = 1;
      `uvm_info("pcie_shared_cfg", $psprintf("SDEBUG: GEN=%d", GEN), UVM_LOW)
      root_cfg.pcie_spec_ver =`PCIE_DEV_CFG_CLASS::PCIE_SPEC_VER_3_0;
      root_cfg.pipe_spec_ver =`PCIE_DEV_CFG_CLASS::PIPE_SPEC_VER_4;

      //root_cfg.pcie_spec_ver                       = `PCIE_DEV_CFG_CLASS:::PCIE_SPEC_VER_2_1;
      //Old: root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_2_5G);
`ifdef BOARD_GEN3X8
      root_cfg.pcie_cfg.pl_cfg.set_link_width_values(8);
`else
      root_cfg.pcie_cfg.pl_cfg.set_link_width_values(16);
`endif
      case(GEN) 
         1 : root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_2_5G);
         2 : root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
         3 : root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_8_0G | `PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
      //   3 : root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G );
         default : root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
      endcase
      root_cfg.pcie_cfg.pl_cfg.skip_polling_active = 1;

      `ifndef SIM_SERIAL
          root_cfg.pcie_cfg.pl_cfg.max_spipe_phystatus_delay = 100;
          root_cfg.pcie_cfg.pl_cfg.min_spipe_phystatus_delay = 80;
          //root_cfg.pcie_cfg.pl_cfg.recovery_idle_timeout_ns = 610000;
	  //root_cfg.pcie_cfg.pl_cfg.recovery_rcvrlock_timeout_ns = 610000;
      `endif
     
      // Endpoint Configuration
      endpoint_cfg.device_is_root         = 0;
      endpoint_cfg.pcie_spec_ver = `PCIE_DEV_CFG_CLASS::PCIE_SPEC_VER_3_0;
      endpoint_cfg.pipe_spec_ver = `PCIE_DEV_CFG_CLASS::PIPE_SPEC_VER_4;
      //Old: endpoint_cfg.pcie_spec_ver                       = `PCIE_DEV_CFG_CLASS:::PCIE_SPEC_VER_2_1;
      //endpoint_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
`ifdef BOARD_GEN3X8
      endpoint_cfg.pcie_cfg.pl_cfg.set_link_width_values(8);
`else
      endpoint_cfg.pcie_cfg.pl_cfg.set_link_width_values(16);
`endif
      case(GEN)
         1 : endpoint_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_2_5G);
         2 : endpoint_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
         3 : endpoint_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_8_0G | `PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
         default : endpoint_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`PCIE_SPEED_5_0G | `PCIE_SPEED_2_5G);
      endcase
      endpoint_cfg.pcie_cfg.pl_cfg.skip_polling_active = 1;

      // OOO: change completion latency values
      // rdcomplt_ooo: 1 read completions out-of-order, 0 in-order
      if(rdcomplt_ooo) begin
         root_cfg.target_cfg[0].min_mem_cpl_latency_ns  =    20;
         root_cfg.target_cfg[0].max_mem_cpl_latency_ns  =  1000;
         `uvm_info("SUTRAN", $psprintf("SUTRAN: in Out-Of-Order setting"), UVM_LOW)
      end
      //FUTURE_IMPROVEMENT sutran: save for coverage
      // Enable Coverage for all layers
       root_cfg.pcie_cfg.enable_cov     = 4'b1111;      // [3] TL [2] DL [1] PL [0] PIPE
       endpoint_cfg.pcie_cfg.enable_cov = 4'b1111;      // [3] TL [2] DL [1] PL [0] PIPE
		
	root_cfg.pcie_cfg.tl_cfg.remote_max_payload_size = 1024;//256;
//	root_cfg.pcie_cfg.tl_cfg.init_np_hdr_tx_credits[0] = 116;
//	root_cfg.pcie_cfg.tl_cfg.init_np_data_tx_credits[0] = 231;
	//Disable Shadow memory checking 
	root_cfg.driver_cfg[0].enable_tx_tlp_reporting = 0;
	root_cfg.driver_cfg[0].enable_shadow_memory_checking = 0;
	root_cfg.driver_cfg[0].enable_tlp_field_user_control_vector[6] = 0; 
	root_cfg.requester_cfg.enable_tx_tlp_reporting = 0;
	root_cfg.requester_cfg.enable_shadow_memory_checking = 0;
	root_cfg.pcie_cfg.dl_cfg.enable_tx_tlp_reporting = 0;
	root_cfg.pcie_cfg.tl_cfg.enable_shadow_cfg_lookup = 0;
 	root_cfg.pcie_cfg.dl_trace_options[0] = 1 ;
//Enable VIP sent and received tlp for scoreboarding
    root_cfg.pcie_cfg.dl_cfg.sent_tlp_interface_mode = 1;
    root_cfg.pcie_cfg.dl_cfg.received_tlp_interface_mode = 1;
    root_cfg.pcie_cfg.dl_cfg.sent_dllp_interface_mode = 1;
    root_cfg.pcie_cfg.dl_cfg.received_dllp_interface_mode = 1;
    end
  endfunction
  //==============================
  //function bit is_valid()
  //==============================
  virtual function bit is_valid ( bit silent = 1, int kind = -1 );
    begin
      is_valid = 1;
      `uvm_info("is_valid", "check", UVM_LOW)
 
      if (!root_cfg.is_valid()) begin
        if(!silent) begin
          `uvm_info("is_valid", $psprintf("Invalid root configuration.  Contents:\n%s", root_cfg.sprint()), UVM_HIGH)
        end
        is_valid = 0;
      end
 
      if(!endpoint_cfg.is_valid()) begin
        if(!silent) begin
          `uvm_info("is_valid", $psprintf("Invalid endpoint configuration.  Contents:\n%s", endpoint_cfg.sprint()), UVM_HIGH)
        end
        is_valid = 0;
      end
 
      if (root_cfg.pcie_spec_ver != endpoint_cfg.pcie_spec_ver) begin
        if (!silent) begin
          `uvm_error("is_valid", $sformatf("The pcie_spec_ver variable mismatch between root_cfg and endpoint_cfg.\n"));
        end
        is_valid = 0;
      end
 
      if (root_cfg.pcie_cfg.pl_cfg.skip_polling_active != endpoint_cfg.pcie_cfg.pl_cfg.skip_polling_active) begin
        if (!silent) begin
          `uvm_error("is_valid", $sformatf("The configuration::skip_polling_active variable mismatch between root_cfg and endpoint_cfg.\n"));
        end
        is_valid = 0;
      end
      if (root_cfg.device_is_root == 1'b0) begin
        if (!silent) begin
          `uvm_error("is_valid", $sformatf("The device_is_root variable is set to 1'b0 for root_cfg.\n"));
        end
        is_valid = 0;
      end
 
      if (endpoint_cfg.device_is_root == 1'b1) begin
        if (!silent) begin
          `uvm_error("is_valid", $sformatf("The device_is_root variable is set to 1'b1 for endpoint_cfg.\n"));
        end
        is_valid = 0;
      end
 
    end
  endfunction

endclass

`endif // PCIE_SHARED_CFG_SV
