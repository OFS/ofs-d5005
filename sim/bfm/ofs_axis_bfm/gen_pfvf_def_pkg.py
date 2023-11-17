#!/usr/bin/env python3
# Copyright (C) 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

#------------------------------------------------------------------------------------------------------
# This Python script generates the PFVF and FLR definition packages for the OFS AXI-S BFM.
# The files generated are:
#    * pfvf_def_pkg.sv      >>> PFVF types and associative array for PF/VF access handling.
#    * flr_def_pkg.sv       >>> FLR types and associative array for FLR handling.
#    * gen_pfvf_def_pkg.log >>> A log file providing information about the generated packages.
#
# The PF/VF information used by this script is derived from the ".vh" include file generated by
# the qsys-script, pcie_ss_get_cfg.tcl:
#    $OFS_ROOTDIR/sim/scripts/qip_gen_n6001/syn/board/n6001/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh
#        
# This include file should contain the number of required PFs for OFS as well as the number and 
# association of the VFs.  This script utilizes two of the defines in the above file to configure
# the PF/VF configuration.  Here is an excerpt of the lines used at ~ line 47:
#    // Vector indicating enabled PFs (1 if enabled) with
#    // index range 0 to OFS_FIM_IP_CFG_PCIE_SS_MAX_PF_NUM
#    `define OFS_FIM_IP_CFG_PCIE_SS_PF_ENABLED_VEC 1, 1, 1, 1, 1
#    // Vector with the number of VFs indexed by PF
#    `define OFS_FIM_IP_CFG_PCIE_SS_NUM_VFS_VEC 3, 0, 0, 0, 0
#------------------------------------------------------------------------------------------------------

import argparse
import subprocess
import logging
import time
import datetime
import re
import sys
import os


#----------------------------------------------------------------
# The following function obtains the $OFS_ROOTDIR setting from
# the shell to orient the script.  If this environment variable
# is not set, then the script uses the git top-level directory 
# and navigates to where $OFS_ROOTDIR should be.
#----------------------------------------------------------------
def get_rootdir():
    rootdir = os.getenv('OFS_ROOTDIR')
    if rootdir is None:
        rootdir_pattern_found = 0
        rootdir = ""
        rootdir_pattern = r'(/\S*)'
        rootdir_cmd = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
        with rootdir_cmd.stdout:
            for line in iter(rootdir_cmd.stdout.readline, ""):
                line_contains_pattern = re.search(rootdir_pattern, line)
                if (line_contains_pattern):
                    rootdir = line_contains_pattern.group(1) + "/" + "n6001@commit"
                    rootdir_pattern_found = 1
        rootdir_cmd.wait()
        command_success = rootdir_cmd.poll()
        if (command_success == 0):
            if (rootdir_pattern_found):
                logger.debug(f"Git root directory search has returned successfully with return value {command_success}.")
                logger.debug(f"Git root directory is: {rootdir}.")
            else:
                logger.error(f"ERROR: Git root directory returned is not in an absolute format.")
                logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.")
                sys.exit(1)
        else:
            logger.error(f"ERROR: Git root directory search has failed.")
            logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.")
            sys.exit(1)

    simdir = os.path.join(rootdir, 'sim')
    if not os.path.isdir(simdir):
        logger.error(f"ERROR: {simdir}/ directory not found. Check OFS_ROOTDIR environment varable.")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    return rootdir


#----------------------------------------------------------------
# The following function sets up the configuration file name for
# n6001 and f2000x projects.  Otherwise, it exits gracefully, 
# skipping the package generation.
#----------------------------------------------------------------
def get_config_file():
    n6001_pattern  = r'n6001@commit'
    f2000x_pattern  = r'f2000x@commit'
    found_n6001 = re.search(n6001_pattern, rootdir)
    found_f2000x = re.search(f2000x_pattern, rootdir)
    config_file_name = "ofs_ip_cfg_pcie_ss.vh"
    if (found_n6001):
        if (os.path.exists(os.path.join(rootdir, 'sim/scripts/qip_gen_n6000'))):
            config_file_path = rootdir + "/sim/scripts/qip_gen_n6000/syn/board/n6000/syn_top/ofs_ip_cfg_db"
            config_file = config_file_path + "/" + config_file_name
        elif (os.path.exists(os.path.join(rootdir, 'sim/scripts/qip_gen_fseries-dk'))):
            config_file_path = rootdir + "/sim/scripts/qip_gen_fseries-dk/syn/board/fseries-dk/syn_top/ofs_ip_cfg_db"
            config_file = config_file_path + "/" + config_file_name
        elif (os.path.exists(os.path.join(rootdir, 'sim/scripts/qip_gen_iseries-dk'))):
            config_file_path = rootdir + "/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/ofs_ip_cfg_db"
            config_file = config_file_path + "/" + config_file_name
        else:
            config_file_path = rootdir + "/sim/scripts/qip_gen_n6001/syn/board/n6001/syn_top/ofs_ip_cfg_db"
            config_file = config_file_path + "/" + config_file_name
    else:
        if (found_f2000x):
            config_file_path = rootdir + "/sim/scripts/qip_gen_f2000x/syn/syn_top/ofs_ip_cfg_db"
            config_file = config_file_path + "/" + config_file_name
        else: 
            logger.info(f">>> Project not n6001 nor f2000x: Skipping PF/VF and FLR package generation in script {os.path.basename(__file__)}")
            sys.exit(0)
    return config_file



#----------------------------------------------------------------
# The following function fetches the latest git commit of the 
# local repo for documentation purposes.
#----------------------------------------------------------------
def get_last_commit():
    commit_pattern_found = 0
    commit = ""
    commit_pattern = r'commit\s*(\w+)'
    commit_cmd = subprocess.Popen(['git', 'log', '-n', '1'], stdout=subprocess.PIPE, bufsize=1, universal_newlines=True)
    with commit_cmd.stdout:
        for line in iter(commit_cmd.stdout.readline, ""):
            line_contains_pattern = re.search(commit_pattern, line)
            if (line_contains_pattern):
                commit = line_contains_pattern.group(1)
                commit_pattern_found = 1
    commit_cmd.wait()
    command_success = commit_cmd.poll()
    if (command_success == 0):
        if (commit_pattern_found):
            logger.debug(f"Git repo last commit search has returned successfully with return value {command_success}.")
            logger.debug(f"Git repo last commit is: {commit}.")
        else:
            logger.error(f"ERROR: Git repo last commit could not be found.") 
            logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
            sys.exit(1)
    else:
        logger.error(f"ERROR: Git Log command has failed.")
        logger.error(f"       Script {os.path.basename(__file__)} execution has been halted.") 
        sys.exit(1)
    return commit


#----------------------------------------------------------------
# The following function does the work of extracting the PF and 
# VF information from the SystemVerilog include file.
#----------------------------------------------------------------
def extract_vectors():
    pf_vec_pattern = r'OFS_FIM_IP_CFG_PCIE_SS_PF_ENABLED_VEC\s+((\d(,)*\s*)+)'
    vf_vec_pattern = r'OFS_FIM_IP_CFG_PCIE_SS_NUM_VFS_VEC\s+((\d(,)*\s*)+)'
    try:
        with open(config_file) as file_object:
            for line in file_object:
                line_contains_pf_pattern = re.search(pf_vec_pattern,line)
                if (line_contains_pf_pattern):
                    pf_vec_string = line_contains_pf_pattern.group(1)
                    pf_vec_string = pf_vec_string.rstrip()
                    pf_vec_string = pf_vec_string.replace(" ", "")
                    logger.info(f"pf_vec_string: >{pf_vec_string}<")
                line_contains_vf_pattern = re.search(vf_vec_pattern,line)
                if (line_contains_vf_pattern):
                    vf_vec_string = line_contains_vf_pattern.group(1)
                    vf_vec_string = vf_vec_string.rstrip()
                    vf_vec_string = vf_vec_string.replace(" ", "")
                    logger.info(f"vf_vec_string: >{vf_vec_string}<")
    except FileNotFoundError:
        logger.error(f">>> ERROR: Configuration File Not Found! .............: {config_file}")
        sys.exit(1)
    pf_enabled_list = pf_vec_string.split(",")
    num_vfs_per_pf = vf_vec_string.split(",")
    return pf_enabled_list,num_vfs_per_pf


#----------------------------------------------------------------
# The following function takes a 64-bit address and sections it
# into four 16-bit chunks for easier reading.  This data is then
# returned by a list of the four 16-bit chunks with the lower-
# order index containing the lower order 16-bit chunk, and the 
# higher-order index containing the higher-order 16-bit chunk.
#----------------------------------------------------------------
def section_addr(addr_passed):
    addr_section = []
    for i in range(4):
        addr = addr_passed >> (16*i)
        addr = addr & 0xFFFF
        addr_section.append(addr)
    return addr_section


#----------------------------------------------------------------
# The following function is the one that does all the work of
# creating the PF/VF and FLR definition packages based on the 
# information in the generated include file.
#----------------------------------------------------------------
def generate_package(pf_enabled_list, num_vfs_per_pf):
    banner = [   
            f"//\n",
            f"// Generated by OFS script {os.path.basename(__file__)}\n",
            f"//    Date/Time.........: {script_run_start}\n",
            f"//    Configuration File: {config_file}\n",
            f"\n" ]
    define_pfvf_header = [  
            f"`ifndef __PFVF_DEF_PKG__\n",
            f"`define __PFVF_DEF_PKG__\n",
            f"\n" ]
    define_flr_header = [  
            f"`ifndef __FLR_DEF_PKG__\n",
            f"`define __FLR_DEF_PKG__\n",
            f"\n" ]
    package_pfvf_header = [  
            f"package pfvf_def_pkg;\n",
            f"\n" ]
    package_flr_header = [  
            f"package flr_def_pkg;\n",
            f"\n" ]
    localparam_header = [
            f"//----------------------------------\n",
            f"// Parameter Definitions for Package\n",
            f"//----------------------------------\n",
            f"\n" ]
    address_enum_header = [
            f"//------------------------------------------------------------------------------------------\n",
            f"// BAR Address Assignments:\n",
            f"//    The following address assignments are done for the base addresses that are provided   \n",
            f"//    to the PF/VF MUX.  These values can be randomized if desired.                         \n",
            f"//    Note that these values will determine if the Power User PCIe Header will be in a 4DW  \n",
            f"//    or 3DW format.                                                                        \n",
            f"//    Although each of the addresses are defined for 64-bits, these are the base addresses. \n",
            f"//    Address offsets may be added or logically OR'ed with the lower bits to create an      \n",
            f"//    effective address for the PF/VF range desired.  For example, PF0 is currently using   \n",
            f"//    the lower 20 bits of address, leaving the upper address bits [63:20] (44 bits) for    \n",
            f"//    the BAR decode: 64'bXXXX_XXXX_XXX0_0000.  If we assign 'h0000_0000_8000_0000 for PFO  \n",
            f"//    and want to access a register at offset 'h0_4000, then the resulting address would be:\n",
            f"//    64'h0000_0000_8000_4000.                                                              \n",
            f"//------------------------------------------------------------------------------------------\n",
            f"\n" ]
    package_pfvf_footer = [
            f"\n",
            f"endpackage: pfvf_def_pkg\n" ]
    package_flr_footer = [
            f"\n",
            f"endpackage: flr_def_pkg\n" ]
    define_pfvf_footer = [
            f"\n",
            f"`endif // `ifndef __PFVF_DEF_PKG__" ]
    define_flr_footer = [
            f"\n",
            f"`endif // `ifndef __FLR_DEF_PKG__" ]
    pf_base_address = 0x8000 << 16
    vf_base_address = 0x9000 << 48
    pf_base_offset  = 0x2000 << 16
    vf_base_offset  = 0x100  << 16
    pf_base_address_section = section_addr(pf_base_address)
    vf_base_address_section = section_addr(vf_base_address)
    pf_base_offset_section = section_addr(pf_base_offset)
    vf_base_offset_section = section_addr(vf_base_offset)
    logger.info(f"pf_base_address: 64'h{pf_base_address_section[3]:04x}_{pf_base_address_section[2]:04x}_{pf_base_address_section[1]:04x}_{pf_base_address_section[0]:04x}")
    logger.info(f"vf_base_address: 64'h{vf_base_address_section[3]:04x}_{vf_base_address_section[2]:04x}_{vf_base_address_section[1]:04x}_{vf_base_address_section[0]:04x}")
    logger.info(f"pf_base_offset:  64'h{pf_base_offset_section[3]:04x}_{pf_base_offset_section[2]:04x}_{pf_base_offset_section[1]:04x}_{pf_base_offset_section[0]:04x}")
    logger.info(f"vf_base_offset:  64'h{vf_base_offset_section[3]:04x}_{vf_base_offset_section[2]:04x}_{vf_base_offset_section[1]:04x}_{vf_base_offset_section[0]:04x}")
    file_out_pfvf_path = rootdir + "/sim/bfm/ofs_axis_bfm"
    file_out_pfvf_name = file_out_pfvf_path + "/" + "pfvf_def_pkg.sv"
    file_out_flr_path = rootdir + "/sim/bfm/ofs_axis_bfm"
    file_out_flr_name  = file_out_flr_path + "/" + "flr_def_pkg.sv"
    file_out_pfvf = open(file_out_pfvf_name, "w")
    file_out_flr  = open(file_out_flr_name, "w")
    file_out_pfvf.writelines(banner)
    file_out_pfvf.writelines(define_pfvf_header)
    file_out_pfvf.writelines(package_pfvf_header)
    file_out_pfvf.writelines(localparam_header)
    file_out_flr.writelines(banner)
    file_out_flr.writelines(define_flr_header)
    file_out_flr.writelines(package_flr_header)
    file_out_flr.writelines(localparam_header)
    #-------------------------------------------------------------
    # Here are the localparam definitions for the pfvf package
    #-------------------------------------------------------------
    file_out_pfvf.write("   localparam AXI_ST_ADDR_WIDTH = 64;\n")
    file_out_pfvf.write("\n")
    #-------------------------------------------------------------
    # Here is the pfvf_type_t definition and setup for flr_type_t
    #-------------------------------------------------------------
    flr_type_defs = []
    line = "   typedef enum {\n"
    file_out_pfvf.write(line)
    flr_type_defs.append(line)
    last_pf_index = -1
    last_vf_index = -1
    pfvf_attr_defs = []
    flr_attr_defs  = []
    if (len(pf_enabled_list) > 0):
        for i in range(len(pf_enabled_list)):
            if (pf_enabled_list[i] == '1'):
                last_pf_index = i
    if (len(num_vfs_per_pf) > 0):
        for i in range(len(num_vfs_per_pf)):
            if ((num_vfs_per_pf[i] != '0') and (num_vfs_per_pf[i].isdigit())):
                last_vf_index = i
    if ((len(pf_enabled_list) > 0) and (last_pf_index >= 0)):
        for i in range(len(pf_enabled_list)):
            if (pf_enabled_list[i] == '1'):
                if ((i == last_pf_index) and (last_vf_index < 0)):
                    line = f"      PF{i}\n"
                    file_out_pfvf.write(line)
                    flr_type_defs.append(line)
                    pfvf_attr_defs.append(f"      PF{i}:     '{{3'd{i}, 11'd0, 1'b0, 64'h{pf_base_address_section[3]:04x}_{pf_base_address_section[2]:04x}_{pf_base_address_section[1]:04x}_{pf_base_address_section[0]:04x}}}\n")
                    flr_attr_defs.append(f"      PF{i}:     '{{3'd{i}, 11'd0, 1'b0}}\n")
                else:
                    line = f"      PF{i},\n"
                    file_out_pfvf.write(line)
                    flr_type_defs.append(line)
                    pfvf_attr_defs.append(f"      PF{i}:     '{{3'd{i}, 11'd0, 1'b0, 64'h{pf_base_address_section[3]:04x}_{pf_base_address_section[2]:04x}_{pf_base_address_section[1]:04x}_{pf_base_address_section[0]:04x}}},\n")
                    flr_attr_defs.append(f"      PF{i}:     '{{3'd{i}, 11'd0, 1'b0}},\n")
                pf_base_address += pf_base_offset
                pf_base_address_section = section_addr(pf_base_address)
    if ((len(num_vfs_per_pf) > 0) and (last_vf_index >= 0)):
        for i in range(len(num_vfs_per_pf)):
            if (num_vfs_per_pf[i] != '0'):
                if (num_vfs_per_pf[i].isdigit()):
                    for j in range(int(num_vfs_per_pf[i])):
                        if ((i == last_vf_index) and (j == int(num_vfs_per_pf[i])-1)):
                            line = f"      PF{i}_VF{j},\n"
                            file_out_pfvf.write(line)
                            flr_type_defs.append(line)
                            pfvf_attr_defs.append(f"      PF{i}_VF{j}: '{{3'd{i}, 11'd{j}, 1'b1, 64'h{vf_base_address_section[3]:04x}_{vf_base_address_section[2]:04x}_{vf_base_address_section[1]:04x}_{vf_base_address_section[0]:04x}}}\n")
                            flr_attr_defs.append(f"      PF{i}_VF{j}: '{{3'd{i}, 11'd{j}, 1'b1}}\n")
                        else:
                            line = f"      PF{i}_VF{j},\n"
                            file_out_pfvf.write(line)
                            flr_type_defs.append(line)
                            pfvf_attr_defs.append(f"      PF{i}_VF{j}: '{{3'd{i}, 11'd{j}, 1'b1, 64'h{vf_base_address_section[3]:04x}_{vf_base_address_section[2]:04x}_{vf_base_address_section[1]:04x}_{vf_base_address_section[0]:04x}}},\n")
                            flr_attr_defs.append(f"      PF{i}_VF{j}: '{{3'd{i}, 11'd{j}, 1'b1}},\n")
                        vf_base_address += vf_base_offset
                        vf_base_address_section = section_addr(vf_base_address)
                else:
                    logger.error(f"ERROR: Value for number of VFs for PF{i} is not a number: {num_vfs_per_pf[i]}.")
    line = f"      FUNC_MAX\n"
    file_out_pfvf.write(line)
    flr_type_defs.append(line)
    file_out_pfvf.write("   } pfvf_type_t;\n")
    file_out_pfvf.write("\n")
    #-------------------------------------------------------------
    # Here is the flr_type_t definition
    #-------------------------------------------------------------
    file_out_flr.writelines(flr_type_defs)
    file_out_flr.write("   } flr_type_t;\n")
    file_out_flr.write("\n")
    #-------------------------------------------------------------
    # Here is the pfvf_attr_struct definition
    #-------------------------------------------------------------
    file_out_pfvf.write("   typedef struct packed {\n")
    file_out_pfvf.write("      bit  [2:0] pfn;\n")
    file_out_pfvf.write("      bit [10:0] vfn;\n")
    file_out_pfvf.write("      bit        vfa;\n")
    file_out_pfvf.write("      bit [63:0] base_addr;\n")
    file_out_pfvf.write("   } pfvf_attr_struct;\n")
    file_out_pfvf.write("\n")
    #-------------------------------------------------------------
    # Here is the flr_attr_struct definition
    #-------------------------------------------------------------
    file_out_flr.write("   typedef struct packed {\n")
    file_out_flr.write("      bit  [2:0] pfn;\n")
    file_out_flr.write("      bit [10:0] vfn;\n")
    file_out_flr.write("      bit        vfa;\n")
    file_out_flr.write("   } flr_attr_struct;\n")
    file_out_flr.write("\n")
    #-------------------------------------------------------------
    # Here is the pfvf_attr associative array
    #-------------------------------------------------------------
    file_out_pfvf.writelines(address_enum_header)
    file_out_pfvf.write("   pfvf_attr_struct pfvf_attr [pfvf_type_t] = '{\n")
    file_out_pfvf.writelines(pfvf_attr_defs)
    file_out_pfvf.write("   };\n")
    file_out_pfvf.write("\n")
    #-------------------------------------------------------------
    # Here is the flr_attr associative array
    #-------------------------------------------------------------
    file_out_flr.write("   flr_attr_struct flr_attr [flr_type_t] = '{\n")
    file_out_flr.writelines(flr_attr_defs)
    file_out_flr.write("   };\n")
    #-------------------------------------------------------------
    # Here is the package footer
    #-------------------------------------------------------------
    file_out_pfvf.writelines(package_pfvf_footer)
    file_out_pfvf.writelines(define_pfvf_footer)
    file_out_pfvf.close()
    file_out_flr.writelines(package_flr_footer)
    file_out_flr.writelines(define_flr_footer)
    file_out_flr.close()

if __name__ == '__main__':

    axi_st_addr_width = 64;
    pf_enabled_list = [];
    num_vfs_per_pf  = [];
    script_run_start = datetime.datetime.now()
    rootdir = get_rootdir()
    format = "%(asctime)s: %(message)s"
    tformat = "%Y-%m-%d %H:%M:%S"
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    formatter = logging.Formatter(format,tformat)
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.INFO)
    #stdout_handler.setLevel(logging.DEBUG)
    stdout_handler.setFormatter(formatter)
    log_file_name = rootdir + "/sim/bfm/ofs_axis_bfm" + "/" + "gen_pfvf_def_pkg.log"
    file_handler = logging.FileHandler(log_file_name)
    file_handler.setLevel(logging.INFO)
    #file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.addHandler(stdout_handler)
    #config_file_path = rootdir + "/sim/bfm/ofs_axis_bfm"
    config_file = get_config_file()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    git_commit = get_last_commit()
    logger.info(f">>> Running PF/VF Definitions Package Generator Script: {os.path.basename(__file__)}")
    logger.info(f"    Run at Date/Time..................................: {script_run_start}")
    logger.info(f"    OFS Root Directory................................: {rootdir}")
    logger.info(f"    Git Repo Last Commit..............................: {git_commit}")
    logger.info(f"    Script Location...................................: {script_dir}")
    if (os.path.exists(config_file)):
        logger.info(f"    Configuration File................................: {config_file}")
    else:
        logger.error(f">>> ERROR: Configuration File Not Found! .............: {config_file}")
        sys.exit(1)
    pf_enabled_list,num_vfs_per_pf = extract_vectors()
    generate_package(pf_enabled_list, num_vfs_per_pf)
