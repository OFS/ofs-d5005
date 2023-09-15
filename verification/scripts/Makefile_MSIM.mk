# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# Description:
#  	Makefile for VCS

ifndef OFS_ROOTDIR
    $(error undefined OFS_ROOTDIR)
endif
ifndef WORKDIR
    WORKDIR := $(OFS_ROOTDIR)
endif


VERDIR_COMMON = $(OFS_ROOTDIR)/ofs-common/verification
TEST_DIR :=  $(shell $(VERDIR)/scripts/create_dir.pl $(VERDIR)/sim_msim/$(TESTNAME) )

SCRIPTS_DIR = $(VERDIR)/scripts
D5005_DIR = $(OFS_ROOTDIR)/sim/scripts

export VIPDIR = $(VERDIR)
export RALDIR = $(VERDIR)/testbench/ral
export QLIB_DIR = $(SCRIPTS_DIR)/../sim_msim/libraries
export VIP_DIR = $(SCRIPTS_DIR)/..


# initialize variables
QUARTUS_INSTALL_DIR=$(QUARTUS_HOME)
QSYS_SIMDIR=$(SCRIPTS_DIR)/qip
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="-finish exit"
TOP_LEVEL_NAME="tb_top"

export SCRIPTS_DIR=$(VERDIR)/scripts
VLOG_OPT = +define+QUESTA
VLOG_OPT = +define+MODEL_TECH
VLOG_OPT = +define+MODELTECH
VLOG_OPT += +incdir+$(QUESTA_HOME)/verilog_src/uvm-1.2/src
VLOG_OPT += +incdir+$(VIPDIR)/vip/axi_vip/include/verilog
VLOG_OPT += +incdir+$(VIPDIR)/vip/axi_vip/include/sverilog
VLOG_OPT += +incdir+$(VIPDIR)/vip/axi_vip/src/verilog/mti
VLOG_OPT += +incdir+$(VIPDIR)/vip/axi_vip/src/sverilog/mti
VLOG_OPT += +incdir+$(VIPDIR)/vip/pcie_vip/include/verilog
VLOG_OPT += +incdir+$(VIPDIR)/vip/pcie_vip/include/sverilog
VLOG_OPT += +incdir+$(VIPDIR)/vip/pcie_vip/src/verilog/mti
VLOG_OPT += +incdir+$(VIPDIR)/vip/pcie_vip/src/sverilog/mti
VLOG_OPT += +incdir+$(VERDIR)/tests/sequences/pcie_seq
VLOG_OPT += +incdir+$(VERDIR)/tests/sequences
VLOG_OPT += +incdir+$(VERDIR)/tests
VLOG_OPT += +incdir+$(VERDIR)/testbench
VLOG_OPT += +incdir+$(VERDIR)/testbench/ral
VLOG_OPT += +incdir+$(VERDIR)/testbench/tb_pcie
VLOG_OPT += +incdir+$(VERDIR)/testbench/tb_pcie/src/verilog/mti
VLOG_OPT += +incdir+$(VIP_DIR)/vip/axi_vip/lib/linux64
VLOG_OPT += +incdir+$(VIP_DIR)/vip/pcie_vip/lib/linux64

VLOG_OPT += +define+IGNORE_DF_SIM_EXIT
VLOG_OPT += +define+SIM_MODE +define+SIM_SERIAL #Enable PCIE Serial link up for p-tile  
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_NO_DEPRECATED
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+MMIO_TIMEOUT_IN_CYCLES=1024
VLOG_OPT += +define+SVT_PCIE_ENABLE_GEN3+GEN3
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SYNOPSYS_SV
VLOG_OPT += +define+BASE_AFU=dummy_afu+
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/common/includes
VLOG_OPT += +incdir+$(WORKDIR)/src/includes
VLOG_OPT += +incdir+$(RALDIR)

SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
SIMV_OPT += -l runsim.log 


ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif

ifdef TEST_LPBK
    VLOG_OPT += +define+TEST_LPBK 
endif

ifdef REMOVE_HSSI
    VLOG_OPT += +define+REMOVE_HSSI 
endif

ifndef MSG
    SIMV_OPT += +UVM_VERBOSITY=LOW
else
    SIMV_OPT += +UVM_VERBOSITY=$(MSG)
endif


ifdef DEBUG
SIMV_OPT += -l runsim.log
VLOG_OPT += +define+RUNSIM
endif


ifdef QUIT
    SIMV_OPT_EXTRA = +UVM_MAX_QUIT_COUNT=1
else
   SIMV_OPT_EXTRA = ""
endif


## The Platform Interface Manager is always available for use by AFUs,
## whether or not a specific AFU requires it. These parameters define
## the platform-dependent PIM instance that will be created below
## during cmplib.
PIM_TEMPLATE_DIR=$(VERDIR)/msim_ip_libraries/pim_template
PIM_PLATFORM_NAME=d5005
# PIM sources, dynamically generated by ofs_pim_sim_setup.sh below
PIM_FLIST=$(PIM_TEMPLATE_DIR)/pim_source_files.list

ifdef AFU_WITH_PIM
    # Simulating an AFU wrapped by the PIM's ofs_plat_afu() top-level
    # module wrapper.
    AFU_WITH_PIM_DIR=$(VERDIR)/sim_msim/afu_with_pim
    AFU_FLIST=$(AFU_WITH_PIM_DIR)/afu_sim_files.list
else
    # Normal simulation with default exerciser AFUs
    AFU_FLIST=$(D5005_DIR)/afu_flist.f
endif

dump:
	make DUMP=1

clean:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.hex *.xml DVEfiles;
	@rm -rf $(VERDIR)/sim_msim $(VERDIR)/msim_ip_libraries $(VERDIR)/vip $(SCRIPTS_DIR)/qip $(SCRIPTS_DIR)/rtl_comb.f $(SCRIPTS_DIR)/rtl_comb_common.f $(SCRIPTS_DIR)/rtl_pcie.f $(SCRIPTS_DIR)/transcript;

clean_dve:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.hex *.xml;
             
setup: clean_dve
	@echo WORK \> DEFAULT > synopsys_sim.setup
	@echo DEFAULT \: worklib >> synopsys_sim.setup              
	@mkdir worklib
	@echo VIPDIR  $(VIPDIR)              
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
	test -s $(VERDIR)/sim_msim || mkdir $(VERDIR)/sim_msim
	test -s $(VERDIR)/vip || mkdir $(VERDIR)/vip
	test -s $(VERDIR)/vip/axi_vip || mkdir $(VERDIR)/vip/axi_vip
	test -s $(VERDIR)/vip/pcie_vip || mkdir $(VERDIR)/vip/pcie_vip
	rsync -avz --checksum --ignore-times --exclude pim_template ../msim_ip_libraries/* $(VERDIR)/sim_msim/
	@echo ''
	@echo VCS_HOME: $(VCS_HOME)
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/axi_vip -add axi_system_env_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/pcie_vip -add pcie_device_agent_svt -svlog
	@echo ''  

cmplib:
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh d5005
	mkdir -p ../msim_ip_libraries
	# Generate the PIM template for the target platform
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$(PIM_TEMPLATE_DIR)" -b "${PIM_PLATFORM_NAME}"
	test -s $(SCRIPTS_DIR)/qip || ln -s $(D5005_DIR)/qip_sim_script qip
	cd $(VERDIR)/msim_ip_libraries
	vsim -c -do msim_lib.do | tee msim_cmplib.log
	perl msim_lib_gen.pl msim_cmplib.log

vlog: setup 
ifdef AFU_WITH_PIM
	rm -rf "$(AFU_WITH_PIM_DIR)"
	mkdir -p "$(AFU_WITH_PIM_DIR)"
	# Construct the simulation build environment for the target AFU
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$(AFU_WITH_PIM_DIR)" -r "$(PIM_TEMPLATE_DIR)" -b "${PIM_PLATFORM_NAME}" "$(AFU_WITH_PIM)"
endif
	test -s $(SCRIPTS_DIR)/rtl_comb.f  || ln -s $(D5005_DIR)/rtl_comb.f rtl_comb.f	
	cd $(VERDIR)/sim_msim  && vlog  $(VLOG_OPT)  -suppress 2388,13364,8303,8386,2892,7061,7033 -64 -mfcu  -timescale=1ns/1ns -l msim_vlog.log +libext+.v+.sv -lint -sv +define+QUESTA -f $(D5005_DIR)/msim_ip_flist.f  -f $(SCRIPTS_DIR)/rtl_comb.f -F "$(PIM_FLIST)" -F "$(AFU_FLIST)" -f $(SCRIPTS_DIR)/questa_list.f  -f $(SCRIPTS_DIR)/msim_ver_list.f  


vopt:
	vopt $(TOP_LEVEL_NAME) -o des $(VLOG_OPT) -suppress 2732,12003,7033,3837,8386,13364,2388,7061,7033,7077,19,8303,12110 -f msim_lib.f  -L $(QUESTA_HOME)/uvm-1.2 -work $(VERDIR)/sim_msim/libraries/work -l msim_vopt.log

build: vlog vopt 

ifeq ($(DUMP),1)
run: 
	gcc -m64 -fPIC -DQUESTA -g -W -shared -x c -I $(QUESTA_HOME)/include -I $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi  $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi/uvm_dpi.cc -o $(VERDIR)/sim_msim/uvm_dpi.so	

	cd $(VERDIR)/sim_msim && mkdir $(TEST_DIR)  &&  cd $(TEST_DIR) && cp -f ../*.hex . && cp -f $(OFS_ROOTDIR)/ofs-common/src/common/fme_id_rom/fme_id.mif . && cp $(QLIB_DIR)/../recalibration.mif . && cp $(SCRIPTS_DIR)/msim_lib.f . && vsim -suppress 2732,12003,7033,3837,8386,13364,2388,7061,7033,7077,19,8303,12110,3197,3748 -64 -nosva des -lib $(VERDIR)/sim_msim/libraries/work -permit_unmatched_virtual_intf   +UVM_TESTNAME=$(TESTNAME)  -sv_lib $(VERDIR)/sim_msim/uvm_dpi -sv_lib $(VERDIR)/vip/pcie_vip/lib/linux64/libvcap -sv_lib $(VERDIR)/vip/axi_vip/lib/linux64/libvcap -c -l runsim.log -do "add log -r /*; run -all; quit -f";

else
run: 
	gcc -m64 -fPIC -DQUESTA -g -W -shared -x c -I $(QUESTA_HOME)/include -I $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi  $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi/uvm_dpi.cc -o $(VERDIR)/sim_msim/uvm_dpi.so	

	cd $(VERDIR)/sim_msim && mkdir $(TEST_DIR)  &&  cd $(TEST_DIR) && cp -f ../*.hex . && cp -f $(OFS_ROOTDIR)/ofs-common/src/common/fme_id_rom/fme_id.mif . && cp $(QLIB_DIR)/../recalibration.mif . && cp $(SCRIPTS_DIR)/msim_lib.f . && vsim -suppress 2732,12003,7033,3837,8386,13364,2388,7061,7033,7077,19,8303,12110,3197,3748 -64 -nosva des -lib $(VERDIR)/sim_msim/libraries/work -permit_unmatched_virtual_intf   +UVM_TESTNAME=$(TESTNAME)  -sv_lib $(VERDIR)/sim_msim/uvm_dpi -sv_lib $(VERDIR)/vip/pcie_vip/lib/linux64/libvcap -sv_lib $(VERDIR)/vip/axi_vip/lib/linux64/libvcap -c -l runsim.log -do "run -all; quit -f";
endif