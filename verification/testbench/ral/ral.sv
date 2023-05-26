// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_SV
`define RAL_SV

`ifndef COV

`include "ral_fme.sv"
`include "ral_msix.sv"
`include "ral_hssi.sv"
`include "ral_loop.sv"
`include "ral_pcie.sv"
`include "ral_pr.sv"
`include "ral_spi.sv"
`include "ral_st2mm.sv"
`include "ral_he_mem.sv"
`include "ral_port_gasket.sv"
`include "ral_afu_intf.sv"

`else

`include "ral_afu_intf_cov.sv"
`include "ral_fme.sv"
`include "ral_msix.sv"
`include "ral_hssi.sv"
`include "ral_loop.sv"
`include "ral_pcie.sv"
`include "ral_pr.sv"
`include "ral_spi.sv"
`include "ral_st2mm.sv"
`include "ral_he_mem.sv"
`include "ral_port_gasket.sv"

`endif

class ral_block extends uvm_reg_block;
    `uvm_object_utils(ral_block)

    rand ral_block_fme    fme_regs;
    rand ral_block_msix   msix_regs;
    rand ral_block_hssi   hehssi_regs;
    rand ral_block_loop   helb_regs;
    rand ral_block_he_mem hemem_regs;
    rand ral_block_pcie   pcie_regs;
    rand ral_block_pr     pgsk_regs;
    rand ral_block_spi    pmci_regs;
    rand ral_block_st2mm  st2mm_regs;
    rand ral_block_port_gasket port_gasket_regs;
    rand ral_block_afu_intf afu_intf_regs;

    uvm_reg_map          fme_map;
    uvm_reg_map          msix_map;
    uvm_reg_map          hehssi_map;
    uvm_reg_map          helb_map;
    uvm_reg_map          hemem_map;
    uvm_reg_map          pcie_map;
    uvm_reg_map          pgsk_map;
    uvm_reg_map          pmci_map;
    uvm_reg_map          st2mm_map;
    uvm_reg_map          port_gasket_map;
    uvm_reg_map          afu_intf_map;

    function new(string name = "ral_block");
     `ifndef COV
     super.new(name, build_coverage(UVM_NO_COVERAGE));
    `else
    super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
  `endif

    endfunction : new

    virtual function void build(bit [63:0] pf0_bar4_, pf0_bar0_, helb_base_, hemem_base_, hehssi_base_);
        this.fme_map    = create_map("", pf0_bar0_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.msix_map   = create_map("", pf0_bar4_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.pcie_map   = create_map("", pf0_bar0_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.pgsk_map   = create_map("", pf0_bar0_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.pmci_map   = create_map("", pf0_bar0_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.st2mm_map  = create_map("", pf0_bar0_   , 8, UVM_LITTLE_ENDIAN, 1);
        this.helb_map   = create_map("", helb_base_  , 8, UVM_LITTLE_ENDIAN, 0);
        this.hemem_map  = create_map("", hemem_base_ , 8, UVM_LITTLE_ENDIAN, 0);
        this.hehssi_map = create_map("", hehssi_base_, 8, UVM_LITTLE_ENDIAN, 0);
	this.port_gasket_map = create_map("", pf0_bar0_, 8, UVM_LITTLE_ENDIAN, 1);
	this.afu_intf_map = create_map("", pf0_bar0_, 8, UVM_LITTLE_ENDIAN, 1);

   `ifdef COV
    uvm_reg::include_coverage("*", UVM_CVR_FIELD_VALS);
    `endif


	fme_regs = ral_block_fme::type_id::create("fme");
	fme_regs.configure(this);
	fme_regs.build();
	fme_map.add_submap(this.fme_regs.default_map, 0);
	fme_regs.lock_model();

    msix_regs =ral_block_msix::type_id::create("msix");
    msix_regs.configure(this);
    msix_regs.build();
    msix_map.add_submap(this.msix_regs.default_map, 0);
    msix_regs.lock_model();

	hehssi_regs = ral_block_hssi::type_id::create("hehssi");
	hehssi_regs.configure(this);
	hehssi_regs.build();
	hehssi_map.add_submap(this.hehssi_regs.default_map, 0);
	hehssi_regs.lock_model();

	helb_regs = ral_block_loop::type_id::create("helb");
	helb_regs.configure(this);
	helb_regs.build();
	helb_map.add_submap(this.helb_regs.default_map, 0);
	helb_regs.lock_model();

	hemem_regs = ral_block_he_mem::type_id::create("hemem");
	hemem_regs.configure(this);
	hemem_regs.build();
	hemem_map.add_submap(this.hemem_regs.default_map, 0);
	hemem_regs.lock_model();

	pcie_regs = ral_block_pcie::type_id::create("pcie");
	pcie_regs.configure(this);
	pcie_regs.build();
	pcie_map.add_submap(this.pcie_regs.default_map, 0);
	pcie_regs.lock_model();

	pgsk_regs = ral_block_pr::type_id::create("pgsk");
	pgsk_regs.configure(this);
	pgsk_regs.build();
	pgsk_map.add_submap(this.pgsk_regs.default_map, 0);
	pgsk_regs.lock_model();

	pmci_regs = ral_block_spi::type_id::create("pmci");
	pmci_regs.configure(this);
	pmci_regs.build();
	pmci_map.add_submap(this.pmci_regs.default_map, 0);
	pmci_regs.lock_model();

	st2mm_regs = ral_block_st2mm::type_id::create("st2mm");
	st2mm_regs.configure(this);
	st2mm_regs.build();
	st2mm_map.add_submap(this.st2mm_regs.default_map, 0);
	st2mm_regs.lock_model();

	port_gasket_regs = ral_block_port_gasket::type_id::create("port_gasket");
	port_gasket_regs.configure(this);
	port_gasket_regs.build();
	port_gasket_map.add_submap(this.port_gasket_regs.default_map, 0);
	port_gasket_regs.lock_model();


	afu_intf_regs = ral_block_afu_intf::type_id::create("afu_intf");
	afu_intf_regs.configure(this);
	afu_intf_regs.build();
	afu_intf_map.add_submap(this.afu_intf_regs.default_map, 0);
	afu_intf_regs.lock_model();
    endfunction : build

endclass : ral_block

`endif // RAL_SV
