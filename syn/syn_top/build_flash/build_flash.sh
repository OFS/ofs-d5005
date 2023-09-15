#!/bin/bash
# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

if [ -z ${Q_PROJECT} ]; then
    Q_PROJECT="d5005"
fi
SOF_FILE=${Q_PROJECT}.sof


FACTORY_SOF="factory_image.sof"
PFG_FILE=d5005.pfg
pacsign_infile=${Q_PROJECT}_page1.bin
pacsign_outfile=${pacsign_infile%.*}_unsigned.bin




# this script can be run from build_fim.sh script or 
# directly in the build_flash directory
if [ -z "${OFS_ROOTDIR}" ] ; then
    LOCAL_SCRIPT_DIR="."    
else
    LOCAL_SCRIPT_DIR="$(dirname ${WORK_BUILD_FLASH_SH_FILE})/"
fi

Q_OUTPUT_FILES_PATH="${LOCAL_SCRIPT_DIR}/../../syn_top/output_files"

# check for factory_image.sof, if not available, 
# copy over the ofs_fim.sof as the factory
if [ -e ${LOCAL_SCRIPT_DIR}/$FACTORY_SOF ]; then
    echo "Using $FACTORY_SOF as the factory image"
else
    if [ -e ${Q_OUTPUT_FILES_PATH}/${SOF_FILE} ]; then
        echo "No ${FACTORY_SOF} found, but $SOF_FILE exists"
        echo "Copying over $SOF_FILE as the $FACTORY_SOF"
        cp --remove-destination ${Q_OUTPUT_FILES_PATH}/${SOF_FILE} ${LOCAL_SCRIPT_DIR}/${FACTORY_SOF}
        echo ""
    else
        echo "Cannot find ${Q_OUTPUT_FILES_PATH}/${SOF_FILE}"
        echo "Cannot find ${LOCAL_SCRIPT_DIR}/${FACTORY_SOF}"
        echo "Check that you are running the script that is in the work directory"
        echo " - this script uses relative paths to the compile output_files directory"
        exit 1
    fi
fi


## blank bmc key - 4 bytes of FF
python3 reverse.py blank_bmc_key_programmed blank_bmc_key_programmed.reversed
objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_bmc_key_programmed.reversed ${LOCAL_SCRIPT_DIR}/blank_bmc_key_programmed.reversed.hex

## blank bmc root key hash - 32 bytes of FF
python3 ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed
objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed.hex

## blank sr (FIM) key - 4 bytes of FF
python3 ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_sr_key_programmed ${LOCAL_SCRIPT_DIR}/blank_sr_key_programmed.reversed 
objcopy -I binary -O ihex blank_sr_key_programmed.reversed blank_sr_key_programmed.reversed.hex

## blank sr (FIM) root key hash - 32 bytes of FF
python3 ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed
objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed.hex


### option bits
objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/pac_d5005_option_bits ${LOCAL_SCRIPT_DIR}/pac_d5005_option_bits.hex

### pac_d5005_rot_xip_factory>bin.reversed
python3 ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory.bin ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory.bin.reversed
objcopy -I binary -O ihex pac_d5005_rot_xip_factory.bin.reversed pac_d5005_rot_xip_factory.bin.reversed.hex

### pac_d5005_rot_xip_factory_header.bin.reversed
python3 ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed
objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed.hex


# -- generate very special pof with no root entry hash information
quartus_pfg -c ${LOCAL_SCRIPT_DIR}/${PFG_FILE}


# -- generate ihex from pof
quartus_cpf -c ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.pof ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.hexout

# -- convert to ihex to bin
objcopy -I ihex -O binary ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.hexout ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.bin

python3 ${LOCAL_SCRIPT_DIR}/extract_bitstream.py ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.map ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.bin ${Q_OUTPUT_FILES_PATH}/$pacsign_infile


# -- generate manufacturing image for 3rd party programmer to write to flash before board assembly
# uncomment following line if mfg image is desired
python ${LOCAL_SCRIPT_DIR}/reverse.py ${Q_OUTPUT_FILES_PATH}/${Q_PROJECT}.bin ${Q_OUTPUT_FILES_PATH}/mfg_${Q_PROJECT}_reversed.bin

# -- create unsigned FIM user image for fpgasupdate tool 
if which PACSign &> /dev/null ; then
    PACSign SR -y -v -t UPDATE -H openssl_manager -i ${Q_OUTPUT_FILES_PATH}/$pacsign_infile -o ${Q_OUTPUT_FILES_PATH}/$pacsign_outfile
else
    echo "PACSign not found! Please manually sign ${Q_OUTPUT_FILES_PATH}/$pacsign_infile." 1>&2
fi
