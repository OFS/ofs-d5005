# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# EMIF interfaces passed to AFUs. These files are used by both FIM and PR builds.
#

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/includes/ofs_fim_emif_cfg_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/includes/ofs_fim_emif_if.sv
