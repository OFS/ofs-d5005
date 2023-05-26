#!/bin/bash
# Copyright 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

# This script relies on the following set of software tools, (intelFPGA_pro, Synopsys, Questasim and OFS) which should be installed using the directory structure below. Tool versions can vary.

##├── intelFPGA_pro
##│   └── 23.1
##│       ├── devdata
##│       ├── gcc
##│       ├── hld
##│       ├── hls
##│       ├── ip
##│       ├── licenses
##│       ├── logs
##│       ├── nios2eds
##│       ├── niosv
##│       ├── qsys
##│       ├── quartus
##│       ├── questa_fe
##│       ├── questa_fse
##│       ├── syscon
##│       └── uninstall
##├── mentor
##│   ├── questasim
##│   │   └── 2021.4
##├── synopsys
##│   ├── vcsmx
##│   │   └── S-2021.09-SP1
##│   └── vip_common
##│       └── vip_Q-2020.03A
##├── user_area
##│   └── ofs-X.X.X

## ofs-X.X.X is a directory the user creates based on version they want to test e.g ofs-1.3.1 

## The OFS repos are then cloned beneath ofs-X.X.X and is assigned to the $IOFS_BUILD_ROOT environment variable. This script is then copied to the same directory location, see example below

##├── ofs-1.3.1
##│   ├── examples-afu
##│   ├── linux-dfl
##│   ├── ofs-d5005
##│   ├── oneapi-asp
##│   ├── oneAPI-samples
##│   ├── opae-sdk
##│   ├── opae-sim
##│   ├── ofs_d5005_eval.sh

# Repository Contents
## examples-afu	          (Basic Building Blocks (BBB) for Intel FPGAs is a suite of application building blocks and shims for transforming the CCI-P interface)
## linux-dfl	            (Contains mirror of linux-dfl and specific Intel OFS drivers that are being upstreamed to the Linux kernel)
## ofs-d5005	            (Contains FIM or shell RTL, automated compilation scripts, unit tests and UVM test framework)
## oneapi-asp	            (Contains the hardware and software components you need to develop your own oneAPI or OpenCL board support package for the Intel® Stratix 10® and Intel® Agilex® FPGAs)
## oneAPI-samples         (Samples for oneAPI Toolkits)
## opae-sdk	              (Contains the files for building and installing Open Programmable Acceleration Engine Software Development Kit from source)
## opae-sim	              (Contains the files for an AFU developer to build the Accelerator Funcitonal Unit Simulation Environment (ASE) for workload development)

#################################################################################################################################################################################
# To adapt this script to the user environment please follow the instructions below which explains which line numbers to change in the ofs_d5005_eval.sh script #################
#################################################################################################################################################################################
# User Directory Creation
# The user must create the top-level source directory and then clone OFS repositories
mkdir ofs-1.3.1

In the example above we have used ofs-1.3.1 as the directory name

# Set-Up Proxy Server (lines 65-67)
#Please enter the location of your proxy server to allow access to external internet to build software packages
export http_proxy=
export https_proxy=
export no_proxy=

# License Files (lines 70-72)
#Please enter the the license file locations for the following tool variables
export LM_LICENSE_FILE=
export DW_LICENSE_FILE=
export SNPSLMD_LICENSE_FILE=

# Tools Location (line 85, 86, 87, 88)
# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #
export QUARTUS_TOOLS_LOCATION=/home
export SYNOPSYS_TOOLS_LOCATION=/home
export QUESTASIM_TOOLS_LOCATION=/home
export ONEAPI_TOOLS_LOCATION=/opt
# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #

In the example above /home is used as the base location of Quartus, Synopsys and Questasim tools, /opt is used for the oneAPI tools

# Quartus Tools Version (line 93)
# ************** Set version of Quartus ***************** #
export QUARTUS_VERSION=23.1
# ************** Set version of Quartus ***************** #

In the example above "23.1" is used as the Quartus Tools version

# OPAE Tools (line 106)
# ************** change OPAE SDK VERSION ***************** #
export OPAE_SDK_VERSION=2.5.0-1
# ************** change OPAE SDK VERSION ***************** #

In the example above "2.5.0-1" is used as the OPAE SDK tools version

# PCIe (Bus Number) (lines 231 and 238)
# The Bus number must be entered by the user after installing the hardware in the chosen server, in the example below "b1" is the Bus Number for a single card
export ADP_CARD0_BUS_NUMBER=b1

# BMC FLASH Image (RTL and FW) (line 395)
export BMC_RTL_FW_FLASH=PACsigned_unsigned_bmc_fw.bin

# The BMC firmware can be updated and the file name will change based on revision number. In the example above "PACsigned_unsigned_bmc_fw.bin" is the FW file used to update the BMC. 
# Please place the new flash file in the following newly created location $OFS_ROOTDIR/bmc_flash_files

#################################################################################
#################### AFU Set-up  ################################################
#################################################################################

# Testing Remote Signal Tap

after the building steps 14 and 15 from the script (ofs_d5005_eval.sh)

"14  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware with Remote Signal Tap"
"15  - Build Base FIM Identification(ID) into PR Build Tree template with Remote Signal Tap"

# Then to test the Remote Signal Tap feature for the host_chan_mmio example, copy the supplied host_chan_mmio.stp Signal Tap file to the following location
$IOFS_BUILD_ROOT

#################################################################################
#################### Multi-Test Set-up  #########################################
#################################################################################

# A user can run a sequence of tests and execute them sequentially. In the example below when the user selects option 57 from the main menu the script will execute 23 tests ie (main menu options 2, 9, 10, 11, 12, 13, 14, 15, 27, 29, 30, 32, 34, 35, 39, 40, 48, 50, 51, 52, 53, 54 and 55. All other tests with an "X" indicates do not run that test
intectiveprum=0
declare -A MULTI_TEST

# Enter Number of sequential tests to run
MULTI_TEST[57,tests]=23

# Enter options number from main menu

# "=======================================================================================" 
# "========================= ADP TOOLS MENU ==============================================" 
# "======================================================================================="
MULTI_TEST[57,X]=1
MULTI_TEST[57,0]=2
# "=======================================================================================" 
# "========================= ADP HARDWARE MENU ===========================================" 
# "=======================================================================================" 
MULTI_TEST[57,X]=3
MULTI_TEST[57,X]=4
MULTI_TEST[57,X]=5
MULTI_TEST[57,X]=6
MULTI_TEST[57,X]=7
MULTI_TEST[57,X]=8
# "=======================================================================================" 
# "========================= ADP FIM/PR BUILD MENU =======================================" 
# "=======================================================================================" 
MULTI_TEST[57,1]=9
MULTI_TEST[57,2]=10
MULTI_TEST[57,3]=11
MULTI_TEST[57,4]=12
MULTI_TEST[57,5]=13
MULTI_TEST[57,6]=14
MULTI_TEST[57,7]=15
# "=======================================================================================" 
# "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
# "=======================================================================================" 
MULTI_TEST[57,X]=16
MULTI_TEST[57,X]=17
MULTI_TEST[57,X]=18
MULTI_TEST[57,X]=19
MULTI_TEST[57,X]=20
MULTI_TEST[57,X]=21
MULTI_TEST[57,X]=22
MULTI_TEST[57,X]=23
MULTI_TEST[57,X]=24
MULTI_TEST[57,X]=25
MULTI_TEST[57,X]=26
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
# "=======================================================================================" 
MULTI_TEST[57,8]=27
MULTI_TEST[57,X]=28
MULTI_TEST[57,9]=29
MULTI_TEST[57,10]=30
MULTI_TEST[57,X]=31
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
# "======================================================================================="
MULTI_TEST[57,11]=32
MULTI_TEST[57,X]=33
# "=======================================================================================" 
# "========================== ADP ONEAPI PROJECT MENU ====================================" 
# "======================================================================================="
MULTI_TEST[57,12]=34
MULTI_TEST[57,13]=35
MULTI_TEST[57,X]=36
MULTI_TEST[57,X]=37
MULTI_TEST[57,X]=38
MULTI_TEST[57,14]=39
MULTI_TEST[57,15]=40
MULTI_TEST[57,X]=41
MULTI_TEST[57,X]=42
MULTI_TEST[57,X]=43
MULTI_TEST[57,X]=44
MULTI_TEST[57,X]=45
MULTI_TEST[57,X]=46
MULTI_TEST[57,X]=47
MULTI_TEST[57,16]=48
MULTI_TEST[57,X]=49
# "=======================================================================================" 
# "========================== ADP UNIT TEST PROJECT MENU =================================" 
# "======================================================================================="
MULTI_TEST[57,17]=50
MULTI_TEST[57,18]=51
# "=======================================================================================" 
# "========================== ADP UVM PROJECT MENU =======================================" 
# "======================================================================================="
MULTI_TEST[57,19]=52
MULTI_TEST[57,20]=53
MULTI_TEST[57,21]=54
MULTI_TEST[57,22]=55
MULTI_TEST[57,X]=56

# In the example below when the user selects option 57 from the main menu the script will only run options from the ADP FIM/PR BUILD MENU (7 options, main menu options 9, 10, 11, 12, 13, 14 and 15).All other tests with an "X" indicates do not run that test

# "=======================================================================================" 
# "========================= ADP TOOLS MENU ==============================================" 
# "======================================================================================="
MULTI_TEST[57,X]=1
MULTI_TEST[57,X]=2
# "=======================================================================================" 
# "========================= ADP HARDWARE MENU ===========================================" 
# "=======================================================================================" 
MULTI_TEST[57,X]=3
MULTI_TEST[57,X]=4
MULTI_TEST[57,X]=5
MULTI_TEST[57,X]=6
MULTI_TEST[57,X]=7
MULTI_TEST[57,X]=8
# "=======================================================================================" 
# "========================= ADP FIM/PR BUILD MENU =======================================" 
# "=======================================================================================" 
MULTI_TEST[57,0]=9
MULTI_TEST[57,1]=10
MULTI_TEST[57,2]=11
MULTI_TEST[57,3]=12
MULTI_TEST[57,4]=13
MULTI_TEST[57,5]=14
MULTI_TEST[57,6]=15
# "=======================================================================================" 
# "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
# "=======================================================================================" 
MULTI_TEST[57,X]=16
MULTI_TEST[57,X]=17
MULTI_TEST[57,X]=18
MULTI_TEST[57,X]=19
MULTI_TEST[57,X]=20
MULTI_TEST[57,X]=21
MULTI_TEST[57,X]=22
MULTI_TEST[57,X]=23
MULTI_TEST[57,X]=24
MULTI_TEST[57,X]=25
MULTI_TEST[57,X]=26
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
# "=======================================================================================" 
MULTI_TEST[57,X]=27
MULTI_TEST[57,X]=28
MULTI_TEST[57,X]=29
MULTI_TEST[57,X]=30
MULTI_TEST[57,X]=31
# "======================================================================================" 
# "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
# "======================================================================================="
MULTI_TEST[57,X]=32
MULTI_TEST[57,X]=33
# "=======================================================================================" 
# "========================== ADP ONEAPI PROJECT MENU ====================================" 
# "======================================================================================="
MULTI_TEST[57,12]=34
MULTI_TEST[57,13]=35
MULTI_TEST[57,X]=36
MULTI_TEST[57,X]=37
MULTI_TEST[57,X]=38
MULTI_TEST[57,14]=39
MULTI_TEST[57,15]=40
MULTI_TEST[57,X]=41
MULTI_TEST[57,X]=42
MULTI_TEST[57,X]=43
MULTI_TEST[57,X]=44
MULTI_TEST[57,X]=45
MULTI_TEST[57,X]=46
MULTI_TEST[57,X]=47
MULTI_TEST[57,16]=48
MULTI_TEST[57,X]=49
# "=======================================================================================" 
# "========================== ADP UNIT TEST PROJECT MENU =================================" 
# "======================================================================================="
MULTI_TEST[57,17]=50
MULTI_TEST[57,18]=51
# "=======================================================================================" 
# "========================== ADP UVM PROJECT MENU =======================================" 
# "======================================================================================="
MULTI_TEST[57,19]=52
MULTI_TEST[57,20]=53
MULTI_TEST[57,21]=54
MULTI_TEST[57,22]=55
MULTI_TEST[57,X]=56
