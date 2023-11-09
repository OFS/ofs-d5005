# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# design  files
#--------------------
 
#set_global_assignment -name SYSTEMVERILOG_FILE fabric/rtl/s10/apf.sv
 

#--------------------
# IPs
#--------------------
set_global_assignment -name QSYS_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/bpf.qsys

set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_clock_bridge.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_reset_bridge.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_apf_mst.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_apf_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_fme_mst.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_fme_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_pmci_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_pcie_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_emif_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_hssi_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_rsv_5_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_rsv_6_slv.ip
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/src/pd_qsys/fabric/ip/bpf/bpf_rsv_7_slv.ip
