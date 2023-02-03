// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Platform-specific OFS R1 configuration of the PCIe subsystem.
//
// This file exists mainly to associate a version tag with the values in
// ofs_pcie_ss_plat_cfg_pkg::. The version tag makes it easier to manage
// varation among platforms when importing the platform-specific configuration
// into the platform-independent ofs_pcie_ss_cfg_pkg::.
//

`ifndef __OFS_PCIE_SS_PLAT_CFG_VH__
`define __OFS_PCIE_SS_PLAT_CFG_VH__ 1

`define OFS_PCIE_SS_PLAT_CFG_R1 1
`define OFS_PCIE_SS_PLAT_CFG_V1 1

`endif // __OFS_PCIE_SS_PLAT_CFG_VH__
