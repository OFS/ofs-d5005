# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# FME Files
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/fme/fme_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/fme/fme_csr_io_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/fme/fme_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/fme/fme_top.sv

#--------------------
# FME ID ROM Files
#--------------------
set_global_assignment -name MIF_FILE ../ip_lib/ofs-common/src/common/fme_id_rom/fme_id.mif
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/common/fme_id_rom/fme_id_rom.ip

