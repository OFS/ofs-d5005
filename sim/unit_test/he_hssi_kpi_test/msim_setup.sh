# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

TEST_SRC_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

# initialize variables
OFS_ROOTDIR=""
QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="-finish exit"

TOP_LEVEL_NAME="top_tb"
# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

SIM_ROOTDIR="$TEST_SRC_DIR/../../.."
COMMON_TESTUTIL_DIR="$TEST_SRC_DIR/../scripts"
SIM_DIR="${TEST_DIR}/sim_msim"

#-----------------------------------------
# Test will be picked up from base fim by default
# Point this to TEST_SRC_DIR if test path is local fim, and not base fim
TEST_BASE_DIR=$TEST_SRC_DIR

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

###################################
# Source the BBS filelist for msim #
###################################
. ${SIM_DIR}/msim_filelist.sh

##################################
### BFM related verilog source ###
##################################
. $COMMON_TESTUTIL_DIR/vcs_filelist.sh

TB_SRC="${TEST_BASE_DIR}/testbench/test_csr_defs.sv \
${TEST_BASE_DIR}/testbench/test_param_defs.sv \
$BFM_SRC"

##################################
### AFU related verilog source ###
##################################
vlib work
vlog -mfcu -timescale=1ns/1fs +libext+.v+.sv -lint -sv \
 +define+IGNORE_DF_SIM_EXIT \
 +define+SIM_MODE \
 +define+SIM_SERIAL \
 +define+SIMULATION_MODE \
 +define+HTILE \
 +define+R1_UNIT_TEST_ENV \
 +define+MMIO_TIMEOUT_IN_CYCLES=1024 \
 +define+SVT_PCIE_ENABLE_GEN3+GEN3 \
 +define+define+__ALTERA_STD__METASTABLE_SIM \
 +define+BASE_AFU="dummy_afu" \
 +define+SVT_AXI_MAX_TDATA_WIDTH=784 \
 +define+SVT_AXI_MAX_TUSER_WIDTH=44 \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES="26'd12500000" \
 +define+MSIM_IOFS_D5005 \
 +define+VCS_S10 +define+RP_MAX_TAGS=64 \
 +define+INCLUDE_DDR4 \
 +define+INCLUDE_SPI_BRIDGE \
 +define+INCLUDE_USER_CLOCK \
 +define+INCLUDE_HSSI \
 +define+SIM_USE_PCIE_DUMMY_CSR \
 +define+R1_UNIT_TEST_ENV \
 $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
 +incdir+./ \
 +incdir+$TEST_BASE_DIR/testbench \
 $MSIM_FILELIST \
 $BASE_AFU_SRC \
 $TB_SRC -work work -l msim_vlog.log -suppress 8386,7033,7061,2388,12003,2892
#suppress 8386 : Replication operator in Conactenation Operator
#suppress 2892 : Net type of 'clk' was not explicitly declared
#suppress 7061 : Variable 'clear_tdo_bit_select' driven in an always_ff block, may not be driven by any other process
#suppress 7033 : Variable 'parser_result' driven in a combinational block, may not be driven by any other process

# ----------------------------------------
# simulate
# parse transcript to remove redundant comment block (fb:435978)
if [ $SKIP_SIM -eq 0 ]; then
  vopt $TOP_LEVEL_NAME -o opt -suppress 2732,12003,7033,3837 -l msim_vopt.log
  vsim -c opt -nosva -suppress 2732,12003,7033,3837 -do "add log -r /*; run -all ; quit -f"
fi


