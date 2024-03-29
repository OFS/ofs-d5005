# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

ifndef WORKDIR
    $(error undefined WORKDIR)
endif

#ifndef UVM_HOME
#    $(error undefined UVM_HOME)
#endif 

#ifndef TESTNAME
#    $(error undefined TESTNAME)
#endif    
VERDIR_COMMON = $(OFS_ROOTDIR)/ofs-common/verification
TEST_DIR :=  $(shell ./create_dir.pl $(VERDIR)/sim/$(TESTNAME) )
SCRIPTS_DIR=$(VERDIR)/scripts
# Synthesis scripts directory. Some synthesis scripts also work for setting up
# simulation.
SYN_SCRIPTS_DIR=$(WORKDIR)/scripts/common/syn

D5005_DIR = $(OFS_ROOTDIR)/sim/scripts

VCDFILE = $(SCRIPTS_DIR)/vpd_dump.key

export LIB_DIR = $(SCRIPTS_DIR)/../sim/libraries
#VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -CFLAGS -debug_pp -l vlog.log -assert enable_diag -ignore unique_checks -debug_all
VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -l vlog.log -assert enable_diag -ignore unique_checks 
VLOG_OPT += -Mdir=./csrc +warn=noBCNACMBP -CFLAGS -y $(VERDIR)/vip/pcie_vip/src/verilog/vcs -y $(VERDIR)/vip/pcie_vip/src/sverilog/vcs -P $(VERDIR)/scripts/vip/pli.tab $(WORKDIR)/scripts/vip/msglog.o -notice -work work +incdir+./ 
VLOG_OPT += +define+IGNORE_DF_SIM_EXIT
VLOG_OPT += +define+SIM_MODE +define+SIM_SERIAL 
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+MMIO_TIMEOUT_IN_CYCLES=1024
VLOG_OPT += +define+SVT_PCIE_ENABLE_GEN3+GEN3
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SYNOPSYS_SV
#ifeq ($(SITE),pdx)
#VLOG_OPT += +define+/nfs/pdx/disks/atp.08/users/vvrudome/eda/vip_Q-2020.03A
#$else
VLOG_OPT += +define+DESIGNWARE_HOME=$(DESIGNWARE_HOME)
#endif
VLOG_OPT += +define+define+__ALTERA_STD__METASTABLE_SIM
VLOG_OPT += +define+BASE_AFU=dummy_afu+
VLOG_OPT += +define+SVT_AXI_MAX_TDATA_WIDTH=784 +define+SVT_AXI_MAX_TUSER_WIDTH=44
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/common/includes
VLOG_OPT += +incdir+$(WORKDIR)/src/includes
#VLOG_OPT += +incdir+$(WORKDIR)/src/fims/d5005/includes

VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue  +vcs+lic+wait -l vcs.log  

SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
#SIMV_OPT += +UVM_NO_RELNOTES
SIMV_OPT += -l runsim.log 
SIMV_OPT += +ntb_disable_cnst_null_object_warning=1 -assert nopostproc +vcs+lic+wait +vcs+initreg+0 
SIMV_OPT += +UVM_PHASE_TRACE
SIMV_OPT +=  +vcs+lic+wait 
ifdef COV 
    COV_TST := $(shell basename $(TEST_DIR))
    VLOG_OPT += +define+ENABLE_R1_COVERAGE +define+ENABLE_COV_MSG +define+COV -cm line+cond+fsm+tgl+branch+assert -cm_dir simv.vdb
    VCS_OPT  += -cm line+cond+fsm+tgl+branch+assert -cm_dir simv.vdb
    SIMV_OPT += -coverage -cm line+cond+fsm+tgl+branch+assert+group -cm_name $(COV_TST) -cm_dir ../regression.vdb
    #SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name seed.1 -cm_dir regression.vdb
endif



#SIMV_OPT +=  +vcs+lic+wait -ucli 

ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif

#Suppress unique/priority case/if warnings
#ifdef NORT_WARN
    VCS_OPT += -ignore all
#endif

ifndef MSG
    SIMV_OPT += +UVM_VERBOSITY=LOW
else
    SIMV_OPT += +UVM_VERBOSITY=$(MSG)
endif

ifdef DUMP
    VLOG_OPT += -debug_all 
    VCS_OPT += -debug_all 
    SIMV_OPT += -ucli -i $(VCDFILE)
endif

ifdef GUI
    VCS_OPT += -debug_all +memcbk
    SIMV_OPT += -gui
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
PIM_TEMPLATE_DIR=$(VERDIR)/ip_libraries/pim_template
PIM_PLATFORM_NAME=d5005
PIM_INI_FILE=$(WORKDIR)/src/fims/d5005/ofs_d5005.ini
# PIM sources, dynamically generated by ofs_pim_sim_setup.sh below
PIM_FLIST=$(PIM_TEMPLATE_DIR)/pim_source_files.list

ifdef AFU_WITH_PIM
    # Simulating an AFU wrapped by the PIM's ofs_plat_afu() top-level
    # module wrapper.
    AFU_WITH_PIM_DIR=$(VERDIR)/sim/afu_with_pim
    AFU_FLIST=$(AFU_WITH_PIM_DIR)/afu_sim_files.list
else
    # Normal simulation with default exerciser AFUs
    AFU_FLIST=$(D5005_DIR)/afu_flist.f
endif

batch: vcs
	./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)

dump:
	make DUMP=1

clean:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml *.mif DVEfiles;
	#@rm -rf $(VERDIR)/sim $(VERDIR)/ip_libraries $(VERDIR)/vip $(VERDIR)/scripts/qip $(VERDIR)/scripts/rtl_comb.f $(VERDIR)/scripts/rtl_comb_common.f $(VERDIR)/scripts/rtl_pcie.f $(VERDIR)/scripts/ip_list.f $(VERDIR)/scripts/ip_flist.f;
	@rm -rf $(VERDIR)/sim $(VERDIR)/ip_libraries $(VERDIR)/vip $(VERDIR)/scripts/qip 
clean_dve:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml *.mif;

setup: clean_dve
	@echo WORK \> DEFAULT > synopsys_sim.setup
	@echo DEFAULT \: worklib >> synopsys_sim.setup              
	@mkdir worklib
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
	test -s $(VERDIR)/sim || mkdir $(VERDIR)/sim
	test -s $(VERDIR)/vip || mkdir $(VERDIR)/vip
	test -s $(VERDIR)/vip/axi_vip || mkdir $(VERDIR)/vip/axi_vip
	test -s $(VERDIR)/vip/pcie_vip || mkdir $(VERDIR)/vip/pcie_vip
	rsync -avz --checksum --ignore-times --exclude pim_template ../ip_libraries/* $(VERDIR)/sim/
	@echo ''
	@echo VCS_HOME: $(VCS_HOME)
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/axi_vip -add axi_system_env_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/pcie_vip -add pcie_device_agent_svt -svlog
	@echo ''  

cmplib:
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh d5005
	mkdir -p ../ip_libraries
	# Generate the PIM template for the target platform
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$(PIM_TEMPLATE_DIR)" -b "${PIM_PLATFORM_NAME}"
	test -s $(SCRIPTS_DIR)/qip || ln -s $(D5005_DIR)/qip_sim_script qip
	cp -f qip/synopsys/vcsmx/synopsys_sim.setup ../ip_libraries/
	cd ../ip_libraries && ../scripts/qip/synopsys/vcsmx/vcsmx_setup.sh SKIP_SIM=1 QSYS_SIMDIR=../scripts/qip QUARTUS_INSTALL_DIR=$(QUARTUS_HOME) USER_DEFINED_COMPILE_OPTIONS="+define+__ALTERA_STD__METASTABLE_SIM"

## When AFU_WITH_PIM=<filelist.txt> is set, construct a PIM environment and
## configure the AFU sources specified in filelist.txt using OPAE's
## afu_sim_setup. The AFU will be compiled into the simulation instead of
## the default device exercisers.
$(AFU_FLIST):
ifdef AFU_WITH_PIM
	rm -rf "$(AFU_WITH_PIM_DIR)"
	mkdir -p "$(AFU_WITH_PIM_DIR)"
	# Construct the simulation build environment for the target AFU
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$(AFU_WITH_PIM_DIR)" -r "$(PIM_TEMPLATE_DIR)" -b "${PIM_PLATFORM_NAME}" "$(AFU_WITH_PIM)"
endif

vlog: setup $(AFU_FLIST)
	test -s $(SCRIPTS_DIR)/rtl_comb.f  || ln -s $(D5005_DIR)/rtl_comb.f rtl_comb.f	
	cd $(VERDIR)/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(VERDIR)/sim && vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ns -l vlog_uvm.log
	cd $(VERDIR)/sim && vlogan $(VLOG_OPT) -f $(OFS_ROOTDIR)/sim/scripts/ip_flist.f -f $(SCRIPTS_DIR)/rtl_comb.f -F "$(PIM_FLIST)" -F "$(AFU_FLIST)" -f $(SCRIPTS_DIR)/ver_list.f

build:	vcs

vcs: vlog
	cd $(VERDIR)/sim && vcs $(VCS_OPT) tb_top
        
view:
	dve -full64 -vpd inter.vpd&
run:    
ifndef TEST_DIR
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/sim && mkdir $(TEST_DIR) && cd $(TEST_DIR) && cp ../*.hex . && cp $(OFS_ROOTDIR)/ofs-common/src/common/fme_id_rom/fme_id.mif . && cp $(LIB_DIR)/../recalibration.mif . && ../simv $(SIMV_OPT) $(SIMV_OPT_EXTRA);
endif
rundb:    
ifndef TESTNAME
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/sim && ./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)
endif

build_run: vcs run
build_all: cmplib vcs
do_it_all: cmplib vcs run


