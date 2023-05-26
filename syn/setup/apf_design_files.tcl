# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# design  files
#--------------------

#set_global_assignment -name SYSTEMVERILOG_FILE fabric/rtl/s10/apf.sv 
 
#--------------------
# IPs
#--------------------
set_global_assignment -name QSYS_FILE ../ip_lib/src/pd_qsys/fabric/apf.qsys

set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_clock_bridge.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_reset_bridge.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_bpf_mst.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_bpf_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_st2mm_mst.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_st2mm_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_pgsk_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_achk_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_rsv_b_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_rsv_c_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_rsv_d_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_rsv_e_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_rsv_f_slv.ip
#--------------------
# SDC
#-------------------- 


