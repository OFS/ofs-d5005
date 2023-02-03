# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# PCIe file-hack
post_message -type info "   PCIe flr_pf_active signal workaround"
file copy -force ../design/pcie/stratix10/pac_d5005/ip/modified_ip_files/pcie_ep_g3x16/altera_pcie_s10_hip_ast_2000/synth/altera_pcie_s10_hip_ast.v \
            ../design/pcie/stratix10/pac_d5005/ip/pcie_ep_g3x16/altera_pcie_s10_hip_ast_2000/synth/altera_pcie_s10_hip_ast.v 

