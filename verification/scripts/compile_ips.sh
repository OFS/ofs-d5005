#!/bin/bash
# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# Script to compile all IPs based on the input file list.

if [[ $# -eq 0 ]] ; then
    echo "Error : Please provide 1 input file with IP paths."
    exit 1
fi

IP_LIB=../ip_libraries
input="$1"
rm -f ip_compile.log
touch ip_compile.log

#Create combined synopsys_sim.setup file
perl $WORKDIR/sim/stratix10/s10dx_dk/bbs/scripts/catlib.pl ip_list.f

while IFS= read -r line
do
  case "$line" in \#*) continue ;; esac #skip line starting with #
  if [ ! -z "$line" ]; then #if line is not empty
    # To catch failure from vcsmx_setup.sh in this pipeline,
    # must "set -o pipefail":
    set -o pipefail
    cd $IP_LIB && $WORKDIR/$line/sim/synopsys/vcsmx/vcsmx_setup.sh QSYS_SIMDIR=$WORKDIR/$line/sim | tee -a ip_compile.log 

    if [[ $? -ne 0 ]]; then #Exit on error
      echo "Error! Script Exiting!"
      exit 1
    fi
    set +o pipefail
  fi 
done < "$input"

#Check IP Compile log for errors
if grep -q "Error" $IP_LIB/ip_compile.log
  then
    echo "IP Compile Failed!!!"
    echo "Please check ip_libraries/ip_compile.log"
  else
    echo "Passed"
fi
