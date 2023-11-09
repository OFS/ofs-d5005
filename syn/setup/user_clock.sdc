# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
#  User clock SDC 
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
add_sync_sdc {*|qph_user_clk|qph_user_clk_locked_resync|resync_chains[*].synchronizer_nocut|din_s1}

# For input to a 2-FFs synchronizer chain within qph_user_clk module
set_false_path -from [get_registers {*|qph_user_clk|qph_user_clk_freq|prescaler[*]}]      -to [get_registers {*|qph_user_clk|qph_user_clk_freq|smpclk_meta}]
set_false_path -from [get_registers {*|qph_user_clk|qph_user_clk_freq|prescaler_div2[*]}] -to [get_registers {*|qph_user_clk|qph_user_clk_freq|smpclk_meta_div2}]

#---------------------------------------------
# Multicycle path for handshake CDC between CSR clock and QPH clock domain
#---------------------------------------------
# CSR to QPH crossing
set_multicycle_path -from {*|resync|csr_to_qph_sync|launch[*]} -to {*|resync|csr_to_qph_sync|capture[*]} -setup -end 2
set_multicycle_path -from {*|resync|csr_to_qph_sync|launch[*]} -to {*|resync|csr_to_qph_sync|capture[*]} -hold -end 1
set_multicycle_path -to {*|resync|csr_to_qph_sync|*_strb*sr*synchronizer_nocut*din_s1} 2
set_false_path -hold -to {*|resync|csr_to_qph_sync|*_strb*sr*synchronizer_nocut*din_s1}

# QPH to CSR crossing
set_multicycle_path -from {*|resync|qph_to_csr_sync|launch[*]} -to {*|resync|qph_to_csr_sync|capture[*]} -setup -end 2
set_multicycle_path -from {*|resync|qph_to_csr_sync|launch[*]} -to {*|resync|qph_to_csr_sync|capture[*]} -hold -end 1
set_multicycle_path -to {*|resync|qph_to_csr_sync|*_strb*sr*synchronizer_nocut*din_s1} 2
set_false_path -hold -to {*|resync|qph_to_csr_sync|*_strb*sr*synchronizer_nocut*din_s1}

#----------------------------------------------
# Contraints for the clock mux that selects between user outclk[0] and outclk[1]
# to the input of frequency counter
#----------------------------------------------
create_generated_clock -name qph_user_clk_clkpsc_clk0 -source [get_pins {*|qph_user_clk|qph_user_clk_iopll|iopll_0|stratix10_altera_iopll_i|s10_iopll.fourteennm_pll|outclk[0]}] [get_pins {user_clock|qph_user_clk|qph_user_clk_freq|qph_user_clk_clkpsc|combout}]
create_generated_clock -add -name qph_user_clk_clkpsc_clk1 -source [get_pins {*|qph_user_clk|qph_user_clk_iopll|iopll_0|stratix10_altera_iopll_i|s10_iopll.fourteennm_pll|outclk[1]}] [get_pins {user_clock|qph_user_clk|qph_user_clk_freq|qph_user_clk_clkpsc|combout}]


