# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

#**************************************************************
# Set Maximum Delay
# Set Minimum Delay
#**************************************************************
set_multicycle_path -from [get_cells {afu_top|*|he_lb_csr|*}] -to [get_cells {afu_top|*|he_lb_req|csr_*}]  -setup -end 2
set_multicycle_path -from [get_cells {afu_top|*|he_lb_csr|*}] -to [get_cells {afu_top|*|he_lb_req|csr_*}]  -hold  -end 1

set_multicycle_path -from [get_cells {afu_top|*|he_lb_req|csr_*}] -to [get_cells {afu_top|*|mode_*|*}] -setup -end 2
set_multicycle_path -from [get_cells {afu_top|*|he_lb_req|csr_*}] -to [get_cells {afu_top|*|mode_*|*}] -hold  -end 1

set_max_delay -through {*he_lb_req*re2csr_num_reads*}  -to {*he_lb_csr*} 2.0
set_max_delay -through {*he_lb_req*re2csr_num_writes*} -to {*he_lb_csr*} 2.0   
set_max_delay -through {*he_lb_req*re2csr_num_rdpend*} -to {*he_lb_csr*} 2.0 
set_max_delay -through {*he_lb_req*re2csr_num_wrpend*} -to {*he_lb_csr*} 2.0 
set_max_delay -through {*he_lb_req*re2csr_error*}      -to {*he_lb_csr*} 2.0  

