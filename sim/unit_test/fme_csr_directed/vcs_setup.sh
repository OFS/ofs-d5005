# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

TEST_BASE_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

# initialize variables
OFS_ROOTDIR=""
QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

TOP_LEVEL_NAME="testbench_top"
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

SIM_ROOTDIR=$TEST_DIR/../..
COMMON_TESTUTIL_DIR="$TEST_DIR/../../scripts"
SIM_DIR="$TEST_DIR/sim_vcs"
THE_PLATFORM=$OFS_ROOTDIR

TEST_TBFILES_DIR=${TEST_BASE_DIR}/testbench

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
# Source the BBS filelist for vcs #
###################################
. ${TEST_DIR}/../vcs_filelist.sh

##################################
### BFM related verilog source ###
##################################

TB_SRC="${TEST_TBFILES_DIR}/csr_transaction_class_pkg.sv \
  ${TEST_TBFILES_DIR}/test_csr_directed.sv \
  ${TEST_TBFILES_DIR}/testbench_top.sv"

##################################
### AFU related verilog source ###
##################################
vcs -lca -timescale=1ns/1fs -full64 -sverilog +vcs+lic+wait +systemverilogext+.v+.sv -ntb_opts dtm \
 -ignore unique_checks -error=noMPD +lint=TFIPC-L \
 -ignore initializer_driver_checks \
 +define+IGNORE_DF_SIM_EXIT \
 +define+SIM_MODE \
 +define+VCD_ON \
 +define+SIM_SERIAL \
 +define+SIMULATION_MODE \
 +define+MMIO_TIMEOUT_IN_CYCLES=1024 \
 +define+SVT_PCIE_ENABLE_GEN3+GEN3 \
 +define+define+__ALTERA_STD__METASTABLE_SIM \
 +define+BASE_AFU="dummy_afu" \
 +define+SVT_AXI_MAX_TDATA_WIDTH=784 \
 +define+SVT_AXI_MAX_TUSER_WIDTH=44 \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES="26'd12500000" \
 +define+SIM_MODE \
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
 $VCS_FILELIST \
 $BASE_AFU_SRC \
 $TB_SRC -top $TOP_LEVEL_NAME +error+20 -l vcs.log 

# ----------------------------------------
# simulate
# parse transcript to remove redundant comment block (fb:435978)
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -l transcript
fi


