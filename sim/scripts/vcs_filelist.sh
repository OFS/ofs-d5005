# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

. $OFS_ROOTDIR/sim/scripts/ip_flist.sh

# <COPY_ROM_BEGIN>
cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif ./
# <COPY_ROM_END>

LIB_FILELIST="-v $QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v \
-v $QUARTUS_ROOTDIR/eda/sim_lib/220model.v \
-v $QUARTUS_ROOTDIR/eda/sim_lib/sgate.v \
-v $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v \
$QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/fourteennm_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/synopsys/fourteennm_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ct1_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ct1_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/synopsys/cr3v0_serdes_models_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ct1_hip_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ct1_hip_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctp_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctp_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/cta_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/cta_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctab_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctab_hssi_atoms_ncrypt.sv"

INC_DIR="+incdir+$OFS_ROOTDIR/ofs-common/src/common/includes/ \
+incdir+$OFS_ROOTDIR/src/includes/ \
+incdir+$OFS_ROOTDIR/ipss/eth/inc/"


PLAT_RTL_FILELIST="-f $OFS_ROOTDIR/sim/scripts/rtl_comb.f"

RTL_FILELIST="$COMMON_RTL_FILELIST \
$PLAT_RTL_FILELIST"

VCS_FILELIST="$INC_DIR \
$LIB_FILELIST \
$QSYS_FILELIST \
$RTL_FILELIST"

if [ -z ${SIM_DIR} ];
then
   PIM_TEMPLATE_DIR=$OFS_ROOTDIR/sim/ip_libraries/pim_template
else
   PIM_TEMPLATE_DIR=$SIM_DIR/sim/ip_libraries/pim_template
fi
echo "Setting for PIM_TEMPLATE_DIR=${PIM_TEMPLATE_DIR}"
PIM_PLATFORM_NAME=d5005
PIM_INI_FILE=$OFS_ROOTDIR/src/top/ofs_d5005.ini
PIM_FLIST=$PIM_TEMPLATE_DIR/pim_source_files.list
AFU_FLIST=$OFS_ROOTDIR/sim/scripts/afu_flist.f

# Configure a PIM-based AFU
# Construct the simulation build environment for the target AFU. A common
# script can be used for UVM and unit tests on all targets. The script
# will generate a simulator include file afu_with_pim/all_sim_files.list.
$OFS_ROOTDIR/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$PIM_TEMPLATE_DIR" -b "$PIM_PLATFORM_NAME"

# Load AFU and PIM sources into simulation
BASE_AFU_SRC="-F $PIM_FLIST -F  $AFU_FLIST"
