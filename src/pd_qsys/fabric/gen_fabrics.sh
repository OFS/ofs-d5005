#!/bin/bash
# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
# commands collection to generate APF/BPF fabric
#
 SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P)"
 set PROJECT=d5005

 # Clean up old generated files
 rm -rf apf* bpf* ip* *ipx *qpf *qsf
 
 # Generate BPF/APF Qsys scripts using dfl.txt as input
 $SCRIPT_DIR/dfl2tcl.pl iofs_dfl.txt "Stratix10" "1SX280HN2F43E2VG" 
 
 # Create apf.qsys interconnect fabric
 $QUARTUS_HOME/sopc_builder/bin/qsys-script --new-quartus-project=$PROJECT --script=apf.tcl
 
 # Create bpf.qsys interconnect fabric
 $QUARTUS_HOME/sopc_builder/bin/qsys-script -qpf=$PROJECT --script=bpf.tcl
 
 # Generate apf.qsys
 $QUARTUS_HOME/sopc_builder/bin/qsys-generate -syn=VERILOG -sim=VERILOG -qpf=$PROJECT apf.qsys
 
 # Generate bpf.qsys
 $QUARTUS_HOME/sopc_builder/bin/qsys-generate -syn=VERILOG -sim=VERILOG -qpf=$PROJECT bpf.qsys
 
