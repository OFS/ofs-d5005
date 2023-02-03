# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
#  EMIF SDC 
#
#-----------------------------------------------------------------------------

proc add_reset_sync_sdc { pin_name } {
   set_max_delay -to [get_pins $pin_name] 100.000
   set_min_delay -to [get_pins $pin_name] -100.000
   #set_max_skew  -to [get_pins $pin_name] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.800 
}

proc add_sync_sdc { name } {
   set_max_delay -to [get_keepers $name] 100.000
   set_min_delay -to [get_keepers $name] -100.000
}

#---------------------------------------------
# CDC constraints for synchronizers
#---------------------------------------------
add_sync_sdc {emif_top_inst|mem_bank[*].ddr4_*_sync|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {emif_top_inst|emif_csr|emif_csr_stat_sync|resync_chains[*].synchronizer_nocut|din_s1}



