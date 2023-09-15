# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

SCRIPT_NAME=$BASH_SOURCE
SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

BFM_DIR="$(readlink -f ${SCRIPT_DIR})/../../bfm"
WORK_DIR="$(readlink -f ${SCRIPT_DIR})/../../../.."
BFM_SRC="+incdir+$BFM_DIR \
+incdir+$WORK_DIR/sim/d5005/ip_libraries/pim_template/hw/lib/build/platform/ofs_plat_if/rtl \
+incdir+$WORK_DIR/src/he_lb \
+incdir+$WORK_DIR/src/fims/d5005/includes \
+incdir+$WORK_DIR/src/shells/d5005/includes \
+incdir+$SCRIPT_DIR/testbench \
$BFM_DIR/test_utils.sv \
$BFM_DIR/test_pcie_utils.sv \
$BFM_DIR/ready_gen.sv \
$BFM_DIR/packet_sender.sv \
$BFM_DIR/packet_receiver.sv \
$BFM_DIR/shmem.sv \
$BFM_DIR/pcie_flr.sv \
$BFM_DIR/tester.sv \
$BFM_DIR/top_tb.sv"
