// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Default AFU that instantiates standard device exercisers.
// No Platform Interface Manager (PIM)
//

-F $WORKDIR/ofs-common/src/common/he_lb/files_sim.f
$WORKDIR/ofs-common/src/fpga_family/stratix10/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv

