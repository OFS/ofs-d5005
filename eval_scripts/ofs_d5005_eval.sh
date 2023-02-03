#!/bin/bash
# Copyright 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

# This script relies on the following set of software tools, (intelFPGA_pro, Synopsys, Questasim and Intel OFS) which should be installed using the directory structure below. Tool versions can vary.

##├── intelFPGA_pro
##│   └── 22.3
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

## The Intel OFS repos are then cloned beneath ofs-X.X.X and is assigned to the $IOFS_BUILD_ROOT environment variable. This script is then copied to the same directory location, see example below

##├── ofs-1.3.1
##│   ├── examples-afu
##│   ├── linux-dfl
##│   ├── ofs-d5005
##│   ├── ofs-hld-shim
##│   ├── opae-sdk
##│   ├── opae-sim
##│   ├── iofs_d5005_eval.sh

# Repository Contents
## examples-afu	          (Basic Building Blocks (BBB) for Intel FPGAs is a suite of application building blocks and shims for transforming the CCI-P interface)
## linux-dfl	            (Contains mirror of linux-dfl and specific Intel OFS drivers that are being upstreamed to the Linux kernel)
## ofs-d5005	            (Contains FIM or shell RTL, automated compilation scripts, unit tests framework)
## ofs-hld-shim	          (Contains the hardware and software components you need to develop your own OneAPI or OpenCL board support package for the Intel® Stratix 10® and Intel® Agilex® FPGAs)
## opae-sdk	              (Contains the files for building and installing Open Programmable Acceleration Engine Software Development Kit from source)
## opae-sim	              (Contains the files for an AFU developer to build the Accelerator Funcitonal Unit Simulation Environment (ASE) for workload development)

# Generate Log file
TIMESTAMP=`date "+%Y_%m_%d-%H%M%S"`
mkdir -p log_files/d5005_log_$TIMESTAMP
LOG_FILE=$PWD/log_files/d5005_log_$TIMESTAMP/ofs_d5005_eval.log
exec > >(tee ${LOG_FILE}) 2>&1

unset SCRIPT_DIR

# Set-Up Proxy Server
export http_proxy=
export https_proxy=
export no_proxy=

# License Files
export LM_LICENSE_FILE=
export DW_LICENSE_FILE=
export SNPSLMD_LICENSE_FILE=

# General Environment Variables
export IOFS_BUILD_ROOT=$PWD

export OFS_ROOTDIR=$IOFS_BUILD_ROOT/fim-d5005
export WORKDIR=$OFS_ROOTDIR

#################################################################################
#################### Set Tools Location  ########################################
#################################################################################

# ************** Set Location of Quartus and Synopsys Tools ***************** #
export TOOLS_LOCATION=/home
# ************** Set Location of Quartus and Synopsys Tools ***************** #

# Quartus Tools
# ************** Set version of Quartus ***************** #
export QUARTUS_VERSION=22.3
# ************** Set version of Quartus ***************** #

export QUARTUS_HOME=$TOOLS_LOCATION/intelFPGA_pro/$QUARTUS_VERSION/quartus 
export QUARTUS_ROOTDIR=$QUARTUS_HOME
export QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
export IMPORT_IP_ROOTDIR=$QUARTUS_ROOTDIR/../ip
export QSYS_ROOTDIR=$QUARTUS_ROOTDIR/../qsys/bin
export PATH=$QUARTUS_HOME/bin:$QUARTUS_HOME/qsys/bin:$QUARTUS_HOME/sopc_builder/bin/:$PATH

# OPAE Tools
# ************** change OPAE SDK VERSION ***************** #
export OPAE_SDK_VERSION=2.3.0-1
# ************** change OPAE SDK VERSION ***************** #

export OPAE_SDK_REPO_BRANCH=release/$OPAE_SDK_VERSION
export OPAE_SDK_ROOT=$OFS_ROOTDIR/../opae-sdk
export PATH=$PATH:$OPAE_SDK_ROOT/bin
export LD_LIBRARY_PATH=$OPAE_SDK_ROOT/lib64:$LD_LIBRARY_PATH

# OFS Platform Tools
export OFS_PLATFORM_AFU_BBB_EXTERNAL=$OFS_ROOTDIR/external/ofs-platform-afu-bbb

# OFS Platform BBB Tools
# Set the FPGA_BBB_CCI_SRC variable to the full path of the intel-fpga-bbb directory
export FPGA_BBB_CCI_SRC=$IOFS_BUILD_ROOT/examples-afu
 
# Synopsys Verification Tools
export DESIGNWARE_HOME=$TOOLS_LOCATION/synopsys/vip_common/vip_Q-2020.03A
export PATH=$DESIGNWARE_HOME/bin:$PATH
export VCS_HOME=$TOOLS_LOCATION/synopsys/vcsmx/S-2021.09-SP1/linux64/rhel
export PATH=$VCS_HOME/bin:$PATH

## QuestaSIM Verification Tools
export MTI_HOME=$TOOLS_LOCATION/mentor/questasim/2021.4/linux64
export PATH=$MTI_HOME/linux_x86_64/:$MTI_HOME/bin/:$PATH
export QUESTA_HOME=$MTI_HOME

#################################################################################
#################### Set ADP Platform  ##########################################
#################################################################################

# Definition of (d5005) Board
#* PCIe Gen3x16, 250 MHz
#* 1x10GbE
#* 4 channels of DDR4
#* Partial Reconfiguration support
#* OpenCL support

# ADP Platform (Example:= d5005)
export ADP_PLATFORM=d5005

# Multi Card (Example:= SINGLE or MULTI)
export ADP_CARD_CONFIG=SINGLE

# (Device ID) (Example:= 0b2b(d5005))

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    
  
        echo ""
        export ADP_CARD1_DEVICE_ID=bcce
        echo ""
  
    else 

        echo "None of the conditions met"

    fi  
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    
  
        echo ""
        export ADP_CARD1_DEVICE_ID=bcce
        echo ""
  
    else 

        echo "None of the conditions met"

    fi  
  
else
 
  echo "None of the conditions met"

fi

#################################################################################
#################### Identify ADP Platform  #####################################
#################################################################################

# PCIe (Socket Number)
export ADP_CARD0_SOCKET_NUMBER=0000
export ADP_CARD1_SOCKET_NUMBER=0000

# PCIe (Bus Number)
# The Bus number must be entered by the user after installing the hardware in the chosen server, in the example below "86" is the Bus Number for a single card
if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_BUS_NUMBER=86
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_BUS_NUMBER=86
        echo ""    
  
        echo ""
        export ADP_CARD1_BUS_NUMBER=XX
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_BUS_NUMBER=86
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_BUS_NUMBER=86
        echo ""    
  
        echo ""
        export ADP_CARD1_BUS_NUMBER=XX
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

# PCIe (Device Number)
export ADP_CARD0_DEVICE_NUMBER=00
export ADP_CARD1_DEVICE_NUMBER=00

# PCIe (Function Number)
export ADP_CARD0_FUNCTION_NUMBER=0
export ADP_CARD1_FUNCTION_NUMBER=0

# PCIe ((Full Identification-Socket:Bus:Device:Function(S:B:D:F))
export ADP_CARD0_ID=$ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER
export ADP_CARD1_ID=$ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.$ADP_CARD1_FUNCTION_NUMBER

# OpenCL Slot Identification
if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    
  
        echo ""
        export ADP_CARD1_ACL1=acl1
        echo ""
  
    else 

        echo "None of the conditions met"

    fi

elif [ $ADP_PLATFORM == "dXXXX" ]

then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    
  
        echo ""
        export ADP_CARD1_ACL1=acl1
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
else 

  echo "None of the conditions met"

fi

#################################################################################
#################### FIM and PR/AFU Set-up  #####################################
#################################################################################

# SKU1 FIM Options (fim_x16_1x4x10G)
export FIM_SHELL=fim_x16_1x4x10G

# SKU1 FIM Null Options ()
export FIM_SHELL_NULL=

# FIM working directories
if [ $ADP_PLATFORM == "d5005" ]

  then

      export FIM_WORKDIR=work_adp_${FIM_SHELL}
      export FIM_WORKDIR_PR=work_adp_${FIM_SHELL}_pr
      export FIM_WORKDIR_PR_STP=work_adp_${FIM_SHELL}_pr_stp
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

      export FIM_WORKDIR=work_adp_${FIM_SHELL}
      export FIM_WORKDIR_PR=work_adp_${FIM_SHELL}_pr
      export FIM_WORKDIR_PR_STP=work_adp_${FIM_SHELL}_pr_stp
      
else
 
  echo "None of the conditions met"

fi

#################################################################################
#################### FLASH Set-up  ##############################################
#################################################################################

# BMC FLASH Image (RTL and FW)
export BMC_RTL_FW_FLASH=PACsigned_unsigned_bmc_fw.bin

# FPGA STATIC REGION USER FLASH Image (user1, user2)
export FPGA_SR_USER_FLASH=user

# FPGA STATIC REGION PAGE FLASH Image (page1, page2)
export FPGA_SR_PAGE_FLASH=page1

#################################################################################
#################### AFU Set-up  ################################################
#################################################################################

# OFS AFU Examples (host_chan_intr, host_chan_mmio, host_chan_params, local_mem_params)
export AFU_TEST_NAME=host_chan_mmio

#################################################################################
#################### AFU BBB Set-up  ############################################
#################################################################################

# OFS AFU BBB Examples (clocks, copy_engine, hello_world, local_memory, PIM_advanced)
export AFU_BBB_TEST_NAME=hello_world

# OFS AFU BBB Interface Types (avalon, axi, ccip)
export AFU_BBB_INTERFACE_NAME=axi

#################################################################################
#################### OPENCL Set-up  #############################################
#################################################################################

# OpenCL BSP's (ofs_d5005, ofs_d5005_usm)
export OPENCL_BOARD_NAME=ofs_d5005

# Kernel Name (Example:= boardtest, mem_bandwidth_usm)
export OPENCL_KERNEL_TEST_NAME=boardtest

#################################################################################
#################### Simulater Set-up  ##########################################
#################################################################################

# Simulation Tool for Unit Test (MSIM, VCS, VCSMX)
export SIMULATION_TOOL_UNIT_TEST=VCS

#################################################################################
#################### Unit test Set-up  ##########################################
#################################################################################

# Examples for Unit test 
# (csr_test_sriov, ddr_csr_test, dfh_walker, fme_csr_directed, he_hssi_kpi_test,
#  he_hssi_lpbk_test, he_lb_lpbk_test, he_mem_lpbk_test, mmio_test, partial_reconfig,
#  pcie_csr_test, remote_stp_test, spi_basic_test)
                     
export UNIT_TEST_NAME=dfh_walker

#################################################################################
#################### Multi-Test Set-up  #########################################
#################################################################################

# A user can run a sequence of tests and execute them sequentially. In the example below when the user selects option 47 from the main menu the script will execute 17 tests ie (main menu options 2, 9, 10, 11, 12, 13, 14, 15, 27, 29, 30, 32, 34, 35, 39, 45 and 46. All other tests with an "X" indicates do not run that test
intectiveprum=0
declare -A MULTI_TEST

# Enter Number of sequential tests to run
MULTI_TEST[47,tests]=16

# Enter options number from main menu

# "=======================================================================================" 
# "========================= ADP TOOLS MENU ==============================================" 
# "======================================================================================="
MULTI_TEST[47,X]=1
MULTI_TEST[47,0]=2
# "=======================================================================================" 
# "========================= ADP HARDWARE MENU ===========================================" 
# "=======================================================================================" 
MULTI_TEST[47,X]=3
MULTI_TEST[47,X]=4
MULTI_TEST[47,X]=5
MULTI_TEST[47,X]=6
MULTI_TEST[47,X]=7
MULTI_TEST[47,X]=8
# "=======================================================================================" 
# "========================= ADP FIM/PR BUILD MENU =======================================" 
# "=======================================================================================" 
MULTI_TEST[47,1]=9
MULTI_TEST[47,2]=10
MULTI_TEST[47,3]=11
MULTI_TEST[47,4]=12
MULTI_TEST[47,5]=13
MULTI_TEST[47,6]=14
MULTI_TEST[47,7]=15
# "=======================================================================================" 
# "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
# "=======================================================================================" 
MULTI_TEST[47,X]=16
MULTI_TEST[47,X]=17
MULTI_TEST[47,X]=18
MULTI_TEST[47,X]=19
MULTI_TEST[47,X]=20
MULTI_TEST[47,X]=21
MULTI_TEST[47,X]=22
MULTI_TEST[47,X]=23
MULTI_TEST[47,X]=24
MULTI_TEST[47,X]=25
MULTI_TEST[47,X]=26
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
# "=======================================================================================" 
MULTI_TEST[47,8]=27
MULTI_TEST[47,X]=28
MULTI_TEST[47,9]=29
MULTI_TEST[47,10]=30
MULTI_TEST[47,X]=31
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
# "======================================================================================="
MULTI_TEST[47,11]=32
MULTI_TEST[47,X]=33
# "=======================================================================================" 
# "========================== ADP OPENCL PROJECT MENU ====================================" 
# "======================================================================================="
MULTI_TEST[47,12]=34
MULTI_TEST[47,13]=35
MULTI_TEST[47,X]=36
MULTI_TEST[47,X]=37
MULTI_TEST[47,X]=38
MULTI_TEST[47,14]=39
MULTI_TEST[47,X]=40
MULTI_TEST[47,X]=41
MULTI_TEST[47,X]=42
MULTI_TEST[47,X]=43
MULTI_TEST[47,X]=44
# "=======================================================================================" 
# "========================== ADP UNIT TEST PROJECT MENU =================================" 
# "======================================================================================="
MULTI_TEST[47,15]=45
MULTI_TEST[47,16]=46

test_number=0
i=0
function press_enter
{
    echo ""
    
    if [ "$intectiveprum" = "0" ]  
    then           
      echo -n "Press Enter to continue" 
      read
      clear      
    elif [ "$intectiveprum" = "2" ]    
      then      
        if [ $i -gt ${MULTI_TEST[$test_number,tests]} ]        
          then          
            selection=
            multiplesteps=0
            i=0
            intectiveprum=0           
        else                          
            selection=${MULTI_TEST[$test_number,$i]}
            ((i++))      
        fi        
    else    
      echo -n "cycle complete exiting..."
      echo ""
      exit 0      
    fi    
}

if [ $# -eq 0 ];
then
  echo "$0: Missing arguments, opening the interactive screen"
  selection=
  
elif [ $# -gt 2 ];
then
  echo "$0: Too many arguments, opening the interactive screen"
  selection=
  
else
  
  selection=$1
  intectiveprum=1
  
fi

#################################################################################
#################### ADP TOOLS MENU  ############################################
#################################################################################


until [ "$selection" = "0" ]; do
if [ "$intectiveprum" = "0" ];
    
    then
echo ""
echo "=======================================================================================" 
echo "========================= ADP TOOLS MENU ==============================================" 
echo "======================================================================================="  
echo "1   - List of Documentation for ADP $ADP_PLATFORM Project" 
echo "2   - Check versions of Operating System and Quartus Premier Design Suite (QPDS)"
echo "=======================================================================================" 
echo "========================= ADP HARDWARE MENU ===========================================" 
echo "=======================================================================================" 
echo "3   - Identify Acceleration Development Platform (ADP) $ADP_PLATFORM Hardware via PCIe"
echo "4   - Identify the Board Management Controller (BMC) Version and check BMC sensors"
echo "5   - Identify the FPGA Management Engine (FME) Version"
echo "6   - Check Board Power and Temperature"
echo "7   - Check Accelerator Port status"
echo "8   - Check MAC and PHY status"
echo "=======================================================================================" 
echo "========================= ADP FIM/PR BUILD MENU =======================================" 
echo "======================================================================================="     
echo "9   - Check ADP software versions for ADP $ADP_PLATFORM Project"
echo "10  - Build FIM for $ADP_PLATFORM Hardware "
echo "11  - Check FIM Identification of FIM for $ADP_PLATFORM Hardware"
echo "12  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware"
echo "13  - Build Base FIM Identification(ID) into PR Build Tree template"
echo "14  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware with Remote Signal Tap"
echo "15  - Build Base FIM Identification(ID) into PR Build Tree template with Remote Signal Tap"
echo "=======================================================================================" 
echo "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
echo "=======================================================================================" 
echo "16  - Program BMC Image into $ADP_PLATFORM Hardware"
echo "17  - Check Boot Area Flash Image from $ADP_PLATFORM Hardware"
echo "18  - Program FIM Image into $FPGA_SR_USER_FLASH area for $ADP_PLATFORM Hardware"
echo "19  - Initiate Remote System Upgrade (RSU) from $FPGA_SR_USER_FLASH Flash Image into $ADP_PLATFORM Hardware"
echo "20  - Check PF/VF Mapping Table, vfio-pci driver binding and accelerator port status"
echo "21  - Unbind vfio-pci driver"
echo "22  - Create Virtual Functions (VF) and bind driver to vfio-pci $ADP_PLATFORM Hardware"
echo "23  - Run HE-LB Test"
echo "24  - Run HE-MEM Test"
echo "25  - Run HE-HSSI Test"
echo "26  - Read from CSR (Command and Status Registers) for $ADP_PLATFORM Hardware"
echo "=======================================================================================" 
echo "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
echo "=======================================================================================" 
echo "27  - Build and Compile $AFU_TEST_NAME example"
echo "28  - Execute $AFU_TEST_NAME example"
echo "29  - Modify $AFU_TEST_NAME example to insert Remote Signal Tap"
echo "30  - Build and Compile $AFU_TEST_NAME example with Remote Signal Tap"
echo "31  - Execute $AFU_TEST_NAME example with Remote Signal Tap"
echo "=======================================================================================" 
echo "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
echo "=======================================================================================" 
echo "32  - Build and Compile $AFU_BBB_TEST_NAME example"
echo "33  - Execute $AFU_BBB_TEST_NAME example"
echo "=======================================================================================" 
echo "=======================================================================================" 
echo "========================== ADP OPENCL PROJECT MENU ====================================" 
echo "======================================================================================="
echo "34  - Check OpenCL BSP software versions for $ADP_PLATFORM Project"
echo "35  - Build and clone shim libraries required by OpenCL host"
echo "36  - Install OpenCL Host Driver"
echo "37  - Uninstall OpenCL Host Driver"
echo "38  - Diagnose OpenCL Hardware"
echo "39  - Build OpenCL BSP $OPENCL_BOARD_NAME Default Kernel (boardtest)"
echo "40  - Check PF/VF Mapping Table, vfio-pci driver binding and accelerator port status"
echo "41  - Unbind vfio-pci driver"
echo "42  - Create Virtual Function (VF) and bind driver to vfio-pci $ADP_PLATFORM Hardware"
echo "43  - Program OpenCL BSP $OPENCL_BOARD_NAME Default Kernel (boardtest)"
echo "44  - Run OpenCL Sample Application ($OPENCL_KERNEL_TEST_NAME)"
echo "=======================================================================================" 
echo "========================== ADP UNIT TEST PROJECT MENU =================================" 
echo "======================================================================================="
echo "45  - Generate Simulation files for Unit Test"
echo "46  - Simulate Unit Test $UNIT_TEST_NAME and log waveform"
echo "=======================================================================================" 
echo "========================== ADP BUILD ALL PROJECT MENU =================================" 
echo "======================================================================================="
echo "47  - Build and Simulate Complete $ADP_PLATFORM Project"
echo ""
echo "0   - Exit program"
echo ""
echo -n "Enter selection: "
read selection
echo ""

else
	echo "Go to selection: $selection"
fi

case $selection in

        1) 

echo "###########################################################################################"
echo "#################### List of Documentation for ADP Project ################################"
echo "###########################################################################################"
echo ""
echo "Getting Started Guide: Intel Open FPGA Stack for Intel Stratix 10 FPGA"
echo "Guides you through the setup and build steps to evaluate the OFS solution targeting an Intel FPGA PAC D5005"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/user_guides/ug_qs_ofs_d5005/ug_qs_ofs_d5005.md"
echo ""
echo ""
echo "FPGA Interface Manager Technical Reference Manual: Intel Open FPGA Stack for Intel Stratix 10 FPGA"
echo "Describes the OFS FIM architecture and features"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/reference_manuals/ofs_fim/mnl_fim_ofs_d5005.md"
echo ""
echo ""
echo "Software Reference Manual: Intel® Open FPGA Stack"
echo "Describes the Open Programmable Acceleration Engine (OPAE) Software Development Kit, the OPAE C++ and Python API and management interfaces. This document also covers building the OPAE SDK, how to add a new PCIe device, and debugging the software stack"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/common/reference_manual/ofs_sw/mnl_sw_ofs.md"
echo ""
echo ""
echo "FPGA Interface Manager Developer Guide: Intel Open Stack for Intel Stratix 10 FPGA"
echo "Provides guidance on developing an FPGA Interface Manager (FIM) for a custom FPGA acceleration board"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/dev_guides/fim_dev/ug_dev_fim_ofs_d5005.md"
echo ""
echo ""
echo "Accelerator Functional Unit Developer Guide: Intel Open FPGA Stack"
echo "Provides guidance on how to build and test an AFU when designing to an OFS-based FPGA Interface Manager"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/dev_guides/AFU%20User%20Guide/AFU_User_Guide.md"
echo ""
echo ""
echo "Security User Guide: Intel Open FPGA Stack for Intel Stratix 10 FPGA"
echo "Describes how to create keys and sign bitstreams for your custom design"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/user_guides/%20ug_security_ofs_d5005/ug-pac-security-d5005.md"
echo ""
echo ""
echo "Board Management Controller User Guide: Intel Open FPGA Stack for Intel Stratix 10 FPGA"
echo "Describes how to modify the BMC RTL and Firmware for your custom board design"
echo "https://github.com/otcshare/intel-ofs-docs/blob/main/d5005/user_guides/ug_bmc_ofs_d5005/IOFS_BMC_User_Guide.md"
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        2) 

echo "###########################################################################################"
echo "#################### Check versions of Operation System, Quartus ##########################"
echo "###########################################################################################"
echo ""
echo "Checking Linux release"
cat /proc/version
echo ""
echo "Checking RedHat release"
cat /etc/redhat-release
echo ""
echo "Checking Kernel parameters"
cat /proc/cmdline
echo ""
echo "Checking Licenses"
echo "LM_LICENSE_FILE is set to $LM_LICENSE_FILE" 
echo ""
echo "DW_LICENSE_FILE is set to $DW_LICENSE_FILE"
echo ""
echo "SNPSLMD_LICENSE_FILE is set to $SNPSLMD_LICENSE_FILE"
echo ""
echo "Checking Tool versions"
echo "QUARTUS_HOME is set to $QUARTUS_HOME"
echo ""
echo "QUARTUS_ROOTDIR is set to $QUARTUS_ROOTDIR"
echo ""
echo "IMPORT_IP_ROOTDIR is set to $IMPORT_IP_ROOTDIR"
echo ""
echo "QSYS_ROOTDIR is set to $QSYS_ROOTDIR"
echo ""
echo "Checking QPDS Patches"
quartus_sh --version
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        3) 

echo "###########################################################################################"
echo "#################### Identify Acceleration Development Platform ADP Hardware ##############"
echo "###########################################################################################"
echo ""

echo "PCIe card detected as" 
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    
  
        echo ""
        lspci | grep $ADP_CARD1_DEVICE_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
elif [ $ADP_PLATFORM == "dXXXX" ]  

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    
  
        echo ""
        lspci | grep $ADP_CARD1_DEVICE_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Host Server is connected to $ADP_CARD_CONFIG card configuration"
echo ""

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        4) 

echo "###########################################################################################"
echo "#################### Identify the Board Management Controller (BMC) Version ###############"
echo "###########################################################################################"
echo ""
echo "Identify BMC Image"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo bmc $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo bmc $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        5) 

echo "###########################################################################################"
echo "#################### Identify the FPGA Management Engine (FME) Version ####################"
echo "###########################################################################################"
echo ""
echo "Identify FME Image"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo fme $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo fme $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        6)

echo ""     
echo "###########################################################################################"
echo "############ Check Board Power and Temperature ############################################"
echo "###########################################################################################"
echo ""
echo "Checking Power and Temperature Status"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo power $ADP_CARD1_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo power $ADP_CARD1_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        7)

echo ""     
echo "###########################################################################################"
echo "############ Check Accelerator Port Status ################################################"
echo "###########################################################################################"
echo ""
echo "Checking Accelerator Port Status"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""    
  
        echo ""
        sudo fpgainfo port $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo port $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        8)

echo ""     
echo "###########################################################################################"
echo "############ Check MAC and PHY status #####################################################"
echo "###########################################################################################"
echo ""
echo "Checking MAC and PHY status"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo mac $ADP_CARD1_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo mac $ADP_CARD1_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        9) 

echo "###########################################################################################"
echo "#################### Check ADP software versions for ADP Project ##########################"
echo "###########################################################################################"
echo ""
echo "OFS_ROOTDIR is set to $OFS_ROOTDIR"
echo ""
echo "OPAE_SDK_REPO_BRANCH is set to $OPAE_SDK_REPO_BRANCH"
echo ""
echo "OPAE_SDK_ROOT is set to $OPAE_SDK_ROOT"
echo ""
echo "LD_LIBRARY_PATH is set to $LD_LIBRARY_PATH"

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        10) 

echo "###########################################################################################"
echo "#################### Build FIM ############################################################"
echo "###########################################################################################"
echo ""
echo "Build default FIM"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR" ]; then rm -Rf $FIM_WORKDIR; fi

    ofs-common/scripts/common/syn/build_top.sh $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR" ]; then rm -Rf $FIM_WORKDIR; fi

    ofs-common/scripts/common/syn/build_top.sh $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        11) 

echo "###########################################################################################"
echo "#################### Check FIM Identification of Base FIM #################################"
echo "###########################################################################################"
echo ""
echo "checking FIM ID fme-ifc-id.txt"

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/
    echo ""
    cat fme-ifc-id.txt
    echo ""
    echo "This FIM ID must be used for the Partial Reconfigration Build Tree Template"
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/
    echo ""
    cat fme-ifc-id.txt
    echo ""
    echo "This FIM ID must be used for the Partial Reconfiguration Build Tree Template"
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        12) 

echo "###########################################################################################"
echo "#################### Build Partial Reconfiguration Tree ###################################"
echo "###########################################################################################"
echo ""
echo "Build Partial Reconfiguration Tree"

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR" ]; then rm -Rf $FIM_WORKDIR_PR; fi

    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR" ]; then rm -Rf $FIM_WORKDIR_PR; fi

    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        13) 

echo "###########################################################################################"
echo "#################### Build Base FIM ID into PR Build Tree template ########################"
echo "###########################################################################################"
echo ""
echo "Copying FIM ID into PR build tree template"

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        14) 

echo "###########################################################################################"
echo "#################### Build Partial Reconfiguration Tree with Remote Signal Tap ############"
echo "###########################################################################################"
echo ""
echo "Build Partial Reconfiguration Tree with Remote Signal Tap"

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR_STP" ]; then rm -Rf $FIM_WORKDIR_PR_STP; fi 

    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR_STP $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR_STP" ]; then rm -Rf $FIM_WORKDIR_PR_STP; fi 

    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR_STP $ADP_PLATFORM $FIM_WORKDIR

    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        15) 

echo "###########################################################################################"
echo "#################### Build Base FIM ID into PR Build Tree template with Remote Signal Tap #"
echo "###########################################################################################"
echo ""
echo "Copying FIM ID into PR build tree template"

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR_STP/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
  
    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR_STP/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        16) 

echo "###########################################################################################"
echo "#################### Program BMC Image into Hardware ######################################"
echo "###########################################################################################"
echo ""
echo "Programming BMC image into $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID        
  
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD1_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD1_ID     
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID        
  
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD1_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD1_ID
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        17) 

echo "###########################################################################################"
echo "#################### Check Boot Area Image into Hardware ##################################"
echo "###########################################################################################"
echo ""
echo "Checking Boot area Image from $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    
  
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    
  
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        18) 

echo "###########################################################################################"
echo "#################### Program FIM Image into Hardware ######################################"
echo "###########################################################################################"
echo ""
echo "Programming FIM image into $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD0_ID
        echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD0_ID
        echo ""     
  
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD0_ID
        echo ""     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD0_ID
        echo ""     
  
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ${ADP_PLATFORM}_${FPGA_SR_PAGE_FLASH}_unsigned.bin $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        19)

echo "###########################################################################################"
echo "#################### RSU FIM Image into Hardware ##########################################"
echo "###########################################################################################"
echo ""
echo "Initiate Remote System Upgrade (RSU) from $FPGA_SR_USER_FLASH FIM Image into $ADP_PLATFORM Hardware"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo ""
        sudo rsu bmc --page=user $ADP_CARD0_ID
        echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo rsu bmc --page=user $ADP_CARD0_ID
        echo ""     
  
        echo ""
        sudo rsu bmc --page=user $ADP_CARD1_ID
        echo "" 
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo rsu bmc --page=user $ADP_CARD0_ID
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo rsu bmc --page=user $ADP_CARD0_ID
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""    
  
        echo ""
        sudo rsu bmc --page=user $ADP_CARD1_ID
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD1_ID
        echo ""  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        20) 

echo "###########################################################################################"
echo "#################### Check PF/VF, vfio-pci driver binding and accelerator port status #####"
echo "###########################################################################################"
echo ""
echo "Check PF/VF Mapping Table"
echo " │MODULE          │VF"
echo ""
echo " │HE-LB           │1"
echo " │HE-MEM          │2"
echo " │HE-HSSI         │3"

echo ""
echo "Checking Current binding of Drivers"
sudo opae.io ls
echo ""

echo "Check that the accelerators are present using fpgainfo"
if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
        echo ""           

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
        echo ""         
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
        echo ""     
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
        echo ""         

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
        echo ""         
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 3 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
        echo ""     
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        21) 

echo "###########################################################################################"
echo "#################### Unbind vfio-pci driver ###############################################"
echo "###########################################################################################"
echo ""
echo "Unbinding Current Drivers"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
  
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        22) 

echo "###########################################################################################"
echo "#################### Create 3 VF's and bind vfio-pci driver ###############################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER

        echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER

        echo ""    
  
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD1_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 $USER

        echo "" 
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER

        echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER

        echo ""
   
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD1_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 $USER

        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        23) 

echo "###########################################################################################"
echo "#################### Run HE-LB Test #######################################################"
echo "###########################################################################################"
echo ""
echo "Run a simple loopback test"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""  
    
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""   
    
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo "" 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        24) 

echo "###########################################################################################"
echo "#################### Run HE-MEM Test ######################################################"
echo "###########################################################################################"
echo ""
echo "Run a simple mem test"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem 
           echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem
           echo ""  
    
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem 
           echo ""  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem 
           echo ""       

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem 
           echo ""  
    
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --mode trput --cls cl_1 mem 
           echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        25) 

echo "###########################################################################################"
echo "#################### Run HE-HSSI Test #####################################################"
echo "###########################################################################################"
echo ""
echo "HE-HSSI is responsible for handling client-side ethernet traffic. It wraps the 10G and 100G HSSI AFUs, and includes a traffic generator and checker. The user-space tool hssi exports a control interface to the HE-HSSI's AFU's packet generator logic"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo "" 

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo "" 
          
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo ""  
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo ""   

          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 hssi_10g --eth-ifc s10hssi0 --eth-loopback on --he-loopback=off --num-packets 100
          echo ""  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        26) 

echo "###########################################################################################"
echo "#################### Reading Command and Status Registers (CSR) ###########################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""
          
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""
          
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 -r 0 peek 0x48
          echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        27) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU example ########################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME

if [ $ADP_PLATFORM == "d5005" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        28) 

echo "###########################################################################################"
echo "#################### Execute AFU example ##################################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
         
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME       

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        29) 

echo "###########################################################################################"
echo "#################### Insert Remote Signal Tap into AFU example ############################"
echo "###########################################################################################"
echo ""
echo "Modify ofs_top.qsf and iofs_pr_afu.qsf to add Remote Signal Tap"
echo ""
if [ $ADP_PLATFORM == "d5005" ]

    then

	  # Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
	  export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
	  cd $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
	  echo ""
	  echo set_global_assignment -name ENABLE_SIGNALTAP ON >> $ADP_PLATFORM.qsf
	  echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> $ADP_PLATFORM.qsf
	  echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  $ADP_PLATFORM.qsf
	  echo ""
	  echo set_global_assignment -name ENABLE_SIGNALTAP ON >> iofs_pr_afu.qsf
	  echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> iofs_pr_afu.qsf
	  echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  iofs_pr_afu.qsf    
    
	  echo "Copying host_chan_mmio.stp Signal Tap file to $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top"

	  cp $IOFS_BUILD_ROOT/host_chan_mmio.stp $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
    
elif [ $ADP_PLATFORM == "dXXXX" ]

    then

	  # Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
	  export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
	  cd $OPAE_PLATFORM_ROOT/hw/lib/build/syn/$ADP_PLATFORM/syn_top
	  echo ""
	  echo set_global_assignment -name ENABLE_SIGNALTAP ON >> $ADP_PLATFORM.qsf
	  echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> $ADP_PLATFORM.qsf
	  echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  $ADP_PLATFORM.qsf
	  echo ""
	  echo set_global_assignment -name ENABLE_SIGNALTAP ON >> iofs_pr_afu.qsf
	  echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> iofs_pr_afu.qsf
	  echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  iofs_pr_afu.qsf

    echo "Copying host_chan_mmio.stp Signal Tap file to $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top"

 	  cp $IOFS_BUILD_ROOT/host_chan_mmio.stp $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top

else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        30) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU example with Remote Signal Tap #################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME

if [ $ADP_PLATFORM == "d5005" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware_stp" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware_stp; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware_stp
    cd hardware_stp
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware_stp" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware_stp; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware_stp
    cd hardware_stp
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        31) 

echo "###########################################################################################"
echo "#################### Excecute AFU example with Remote Signal Tap ##########################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
         
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME       

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        32) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU BBB example ####################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME

if [ $ADP_PLATFORM == "d5005" ]

  then
    echo "Removing $AFU_BBB_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_BBB_TEST_NAME test directory"
    mkdir -p $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/hw/rtl/$AFU_BBB_INTERFACE_NAME/sources.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    echo "Removing $AFU_BBB_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_BBB_TEST_NAME test directory"
    mkdir -p $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/hw/rtl/$AFU_BBB_INTERFACE_NAME/sources.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        33) 

echo "###########################################################################################"
echo "#################### Execute AFU BBB example ##############################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME
    
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD1_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME      

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME
        
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD1_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        34) 

echo "###########################################################################################"
echo "#################### Check Set-up of ADP BSP Project ######################################"
echo "###########################################################################################"
echo ""
# OpenCL Tools
export INTELFPGAOCLSDKROOT=$QUARTUS_ROOTDIR/../hld
source $INTELFPGAOCLSDKROOT/init_opencl.sh
export AOCL_BOARD_PACKAGE_ROOT=$IOFS_BUILD_ROOT/ofs-hld-shim/d5005
export LIBOPAE_C_ROOT=/usr
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OFS_ROOTDIR/../ofs-hld-shim/d5005/linux64/lib
echo ""
echo "###########################################################################################"
echo "#################### Check AOCL_BOARD_PACKAGE_ROOT ########################################"
echo "###########################################################################################"
echo ""
echo "AOCL_BOARD_PACKAGE_ROOT is set to $AOCL_BOARD_PACKAGE_ROOT" 
echo ""
echo "###########################################################################################"
echo "#################### Check INTELFPGAOCLSDKROOT ############################################"
echo "###########################################################################################"     
echo ""
echo "LD_LIBRARY_PATH is set to $LD_LIBRARY_PATH"
echo "" 
echo "###########################################################################################"
echo "#################### Check AOC Software and Compiler Versions #############################"
echo "###########################################################################################"
echo "" 
aocl version 
echo ""  
aoc -version
echo ""                       
echo "###########################################################################################"
echo "#################### Check Board XML File #################################################"
echo "###########################################################################################"
echo "" 
aocl board-xml-test 
echo ""                 
echo "###########################################################################################"
echo "#################### Check Boards available within home BSP ###############################"
echo "###########################################################################################"
echo ""
aoc -list-boards 
echo ""
echo "BSP is set to $BSP_NAME" 
echo ""
echo "###########################################################################################"
echo "#################### Check Kernel used in BSP #############################################"
echo "###########################################################################################"
echo ""
echo "KERNEL is set to $OPENCL_KERNEL_TEST_NAME"
echo ""

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        35) 

echo "###########################################################################################"
echo "#################### Build and clone shim libraries required by OpenCL host ###############"
echo "###########################################################################################"
echo ""
cd $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/scripts
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
./build-bsp.sh

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        36)
    
echo "###########################################################################################"
echo "#################### Install OpenCL Host Driver ###########################################"
echo "###########################################################################################"
echo ""     
aocl install $IOFS_BUILD_ROOT/ofs-hld-shim/d5005

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo "" 
date
echo "" ; press_enter ;;

        37)
     
echo "###########################################################################################"
echo "#################### Uninstall OpenCL Host Driver #########################################"
echo "###########################################################################################"
echo ""     
aocl uninstall $IOFS_BUILD_ROOT/ofs-hld-shim/d5005

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo "" 
date
echo "" ; press_enter ;;

        38)

echo ""     
echo "###########################################################################################"
echo "#################### Diagnose OpenCL Hardware #############################################"
echo "###########################################################################################"
echo "" 
#export ACL_PCIE_DEBUG=1
#export ACL_HAL_DEBUG=1

aocl diagnose

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
         aocl diagnose $ADP_CARD0_ACL0     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
         aocl diagnose $ADP_CARD0_ACL0        
  
         aocl diagnose $ADP_CARD0_ACL1     
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
         aocl diagnose $ADP_CARD0_ACL0    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
         aocl diagnose $ADP_CARD0_ACL0        
  
         aocl diagnose $ADP_CARD0_ACL1  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        39) 

echo "###########################################################################################"
echo "#################### Build OpenCL BSP Default Kernel (boardtest) ##########################"
echo "###########################################################################################"
echo ""
cd $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/scripts
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_PR_WORKDIR
./build-default-aocx.sh -b $OPENCL_BOARD_NAME

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        40) 

echo "###########################################################################################"
echo "#################### Check PF/VF, vfio-pci driver binding and accelerator port status #####"
echo "###########################################################################################"
echo ""
echo "Check PF/VF Mapping Table"
echo " │MODULE          │VF"
echo ""
echo " │HE-LB           │1"
echo " │HE-MEM          │2"
echo " │HE-HSSI         │3"

echo ""
echo "Checking Current binding of Drivers"
sudo opae.io ls
echo ""

echo "Check that the accelerators are present using fpgainfo"
if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""      
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""    
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""        
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo ""
        echo "Accelerater Port 2 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""    
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        41) 

echo "###########################################################################################"
echo "#################### Unbind vfio-pci driver ###############################################"
echo "###########################################################################################"
echo ""
echo "Unbinding Current Drivers"

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
  
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        42) 

echo "###########################################################################################"
echo "#################### Create 2 VF'2 and bind vfio-pci driver ###############################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD0_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD0_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
          
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD1_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD0_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD0_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
          
        echo ""
        echo "Create 2 Virtual Function's (VF)"
        sudo pci_device $ADP_CARD1_ID vf 2
        echo ""
        echo "Verify 2 VF's is created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind VF's 1 and 2 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        43) 

echo "###########################################################################################"
echo "#################### Program OpenCL BSP Default Kernel (boardtest) ########################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then

        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl0 $OPENCL_BOARD_NAME  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then

        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl0 $OPENCL_BOARD_NAME  

        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl1 $OPENCL_BOARD_NAME 
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl0 $OPENCL_BOARD_NAME  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then

        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl0 $OPENCL_BOARD_NAME  

        # Program OpenCL BSP Default Kernel (boardtest)
        aocl initialize acl1 $OPENCL_BOARD_NAME 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        44) 

echo "###########################################################################################"
echo "#################### Run OpenCL Sample Applications  ######################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
    cd $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/bringup/source/boardtest
    make
    cp $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/bringup/aocxs/$OPENCL_BOARD_NAME.aocx ./boardtest.aocx
    ./boardtest_host
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then
    cd $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/bringup/source/boardtest
    make
    cp $IOFS_BUILD_ROOT/ofs-hld-shim/d5005/bringup/aocxs/$OPENCL_BOARD_NAME.aocx ./boardtest.aocx
    ./boardtest_host
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        45) 

echo "###########################################################################################"
echo "#################### Generate Simulation files for Unit Test ##############################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR/ofs-common/scripts/common/sim
    sh gen_sim_files.sh $ADP_PLATFORM
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR/ofs-common/scripts/common/sim
    sh gen_sim_files.sh $ADP_PLATFORM
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        46) 

echo "###########################################################################################"
echo "#################### Simulate Unit Test ###################################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then

    cd $OFS_ROOTDIR/sim/unit_test/$UNIT_TEST_NAME/scripts
    sh run_sim.sh $SIMULATION_TOOL_UNIT_TEST=1
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    cd $OFS_ROOTDIR/sim/unit_test/$UNIT_TEST_NAME/scripts
    sh run_sim.sh $SIMULATION_TOOL_UNIT_TEST=1
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        47) 

echo "###########################################################################################"
echo "#################### Build and Simulate Complete Project ##################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "d5005" ]

  then
  
    echo "Building and Simulating Complete $ADP_PLATFORM Project"
    test_number=47
    intectiveprum=2

elif [ $ADP_PLATFORM == "dXXXX" ]

  then

    echo "Building and Simulating Complete $ADP_PLATFORM Project"
    test_number=47
    intectiveprum=2
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        0 ) return ;;
        * ) echo "Please enter 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47 or 0"; press_enter
    esac
done
