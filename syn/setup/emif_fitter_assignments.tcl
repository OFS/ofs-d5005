# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# EMIF pins assignments
#--------------------------
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ./emif_all_x8.tcl

#--------------------------
# EMIF location assignments
#--------------------------
#set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ./mem_bank_0_location.tcl
#set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ./mem_bank_1_location.tcl

#--------------------------
# EMIF fitter assignments
#--------------------------
for {set ddr_bank 0} {$ddr_bank < 4} {incr ddr_bank} {
   # Disable global signal promotion on reset_sync_pri_sdc_anchor, 
   # due to long routing to global driver in the core causing recovery failure
   set_instance_assignment -name GLOBAL_SIGNAL OFF -to mem|mem_bank[$ddr_bank].emif_ddr4_inst|emif_s10_0|arch|arch_inst|non_hps.core_clks_rsts_inst|reset_sync_pri_sdc_anchor

   # Overwrite MAX_FANOUT assignment in EMIF IP core to avoid resource congestion 
   # in DDR region due to synthesis duplication
   set_instance_assignment -name MAX_FANOUT 256 -to mem|mem_bank[$ddr_bank].emif_ddr4_inst|emif_s10_0|arch|arch_inst|hmc_avl_if_inst|amm.ready_0_hyper_regs.amm_ready_0_r1
   set_instance_assignment -name MAX_FANOUT 256 -to mem|mem_bank[$ddr_bank].emif_ddr4_inst|emif_s10_0|arch|arch_inst|hmc_avl_if_inst|amm.ready_1_hyper_regs.amm_ready_1_r1
}
