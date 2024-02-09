#!/usr/bin/env perl
# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# script to generate tcl files for APF/BPF fabric
#
#   Date:   Oct/2020
#   
#   This script generates apf.qsys and bpf.qsys based on dfl.txt in gen_fabric.sh directory
#      * apf.qsys - AXI4-lite AFU Peripheral Qsys interconnect fabric
#      * bpf.qsys - AXI4-lite Board Peripheral Qsys interconnect fabric
#
#   Header fields in dfl.txt
#      * REGISTER_NAME : DFH register name
#      * FABRIC        : {BPF-SLV, BPF-MST, BPF-BID, APF-SLV, APF-MST, APF-BID}
#            * BPF-SLV : Device feature is a BPF slave
#            * BPF-MST : Device feature is a BPF master
#            * BPF-BID : Device feature is a BPF master and slave
#            * APF-SLV : Device feature is a APF slave
#            * APF-MST : Device feature is a APF master
#            * APF-BID : Device feature is a APF master and slave
#      * BASE ADDRESS  : Device feature base address
#      * ADDRESS WIDTH : Device feature address width 
#
#   Currently only 1 master and 1 slave interface is supported per device feature
#
#--------------------------------------------------------------------------------------------------------
#                        |                                               A
#                        V                    APF                        |                                                     
#                   apf_st2mm_mst                                    apf_st2mm_slv                  
#     ___________________|_______________             ___________________|______________                 
#    |                   |               |           |                   |              |                    
# apf_dev_slv0 ... apf_dev_slv    apf_bpf_slv    apf_dev_mst0 ... apf_dev_mstN   apf_bpf_mst                             
#                                        |                                              |                 
#                                        |                                              |                 
#........................................|..............................................|.................
#                                        |                                              |                 
#                                        |                                              |                 
#                                 bpf_apf_mst                                    bpf_apf_slv                 
#        BPF                   __________|_________                           __________|_________                 
#                             |                    |                         |                    |                 
#                          bpf_dev_slv0  ... bpf_dev_slvN              bpf_dev_mst0  ...   bpf_dev_mstN
#
    use strict;
    use warnings;

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Check for right command-line arguments
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    my $num_cmdargs = @ARGV;
    die "ERROR: An incorrect number of arguments was specified.\nUsage: $0 <dfl_file.txt>\n" if ($num_cmdargs < 3);
    my $dfl_file = $ARGV[0];
    my $family = $ARGV[1];
    my $device = $ARGV[2];

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Define/initialize variables 
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    # These lists will hold the information for mst/slv: [name, address width]
    my @apf_mst;
    my @apf_slv;
    my @bpf_mst;
    my @bpf_slv;
    my $line;
    my $idx;
    my $idy;
    
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Read iofs_dfl.txt -- construct master and slave list apf_mst, apf_slv, bpf_mst, bpf_slv
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    open (IN_FILE, "< $dfl_file")  || die "Can't open $dfl_file file!\n";
    open (PKG_FILE, "> fpga_bars.pkg") || die "Can't open fpga_bars.pkg file!\n";
    
    # skips 1st line which is a header comment
    $line = <IN_FILE>;
    
    # read ./iofs_dfl.txt
    while ($line = <IN_FILE>)
    {
        my @dfh_info;
        my $device;
        my $fabric; 
        my $interf;
        my $base_addr;
        my $addr_width;
        
        # gets the device info: [name, fab/intf, base address, address width]
        @dfh_info = split(/\s+/, $line);
        
        # removes DFH suffix and converts to lower-case
        $device = lc($dfh_info[0]);
        
        # splits the fabric name and interface type
        $dfh_info[1] =~ "-";
        $fabric = lc($`);
        $interf = lc($');
        
        # gets base address and address width
        $base_addr  = $dfh_info[2];
        $addr_width = $dfh_info[3];
        print          "    parameter     $dfh_info[0]_BASE \t = $base_addr; \t parameter     $dfh_info[0]_SIZE \t= $addr_width\t; \n";
        print PKG_FILE "    parameter     $dfh_info[0]_BASE \t = $base_addr; \t parameter     $dfh_info[0]_SIZE \t= $addr_width\t; \n";
    
        # construct master and slave array variables
        if ($fabric eq "apf")
           {
           if ($interf eq "mst")
              {
               push(@apf_mst, [$device, $base_addr, $addr_width]);
              }
           elsif ($interf eq "slv")
              {
               push(@apf_slv, [$device, $base_addr, $addr_width]);
              }
           else
              {
               push(@apf_mst, [$device, $base_addr, $addr_width]);
               push(@apf_slv, [$device, $base_addr, $addr_width]);
              }
        }
        else
        {
            if ($interf eq "mst")
            {
                push(@bpf_mst, [$device, $base_addr, $addr_width]);
            }
            elsif ($interf eq "slv")
                {
                    push(@bpf_slv, [$device, $base_addr, $addr_width]);
                }
                else
                {
                    push(@bpf_mst, [$device, $base_addr, $addr_width]);
                    push(@bpf_slv, [$device, $base_addr, $addr_width]);
                }
        }
    }
    close PKG_FILE;
    close IN_FILE;
    print "\n";
    
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# Creates the Qsys tcl file for the Board Peripheral Fabric (BPF)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    open (TCL_FILE, "> bpf.tcl") || die "Can't open bpf.tcl file!\n";    
    print_HEADER("bpf");
    
    # add clock and reset for bpf fabric
    inst_clk_rst   ("bpf");
    conn_clk_rst   ("bpf");
    exp_clk_rst    ("bpf");
    
    # instantiate interfaces between apf and bpf fabrics
    
    inst_mst_if    ("apf"  , "bpf" , 19   );          # instantiate bpf_apf_master
    conn_dev_clkrst("apf"  , "bpf" , "mst");
    inst_slv_if    ("apf"  , "bpf" , 20   );          # instantiate bpf_apf_slave 
    conn_dev_clkrst("apf"  , "bpf" , "slv");
   
    # enumerate bpf devices
    for $idx (0 .. $#bpf_mst)
    {
     inst_mst_if($bpf_mst[$idx][0], "bpf", 20);
    }
    for $idx (0 .. $#bpf_slv)
    {
     inst_slv_if($bpf_slv[$idx][0], "bpf", $bpf_slv[$idx][2]);
    }
    
    # add connections to clkrst for bpf devices
    # add connections to bpf master to device slace, and device master to bpf slave

    for $idx (0 .. $#bpf_slv)
    {
    conn_dev_clkrst($bpf_slv[$idx][0], "bpf", "slv");
    conn_slv_dev   ($bpf_slv[$idx][0], "bpf", "apf", $bpf_slv[$idx][1]);
    }
    for $idx (0 .. $#bpf_mst)
    {
    conn_dev_clkrst($bpf_mst[$idx][0], "bpf", "mst"                   );
    conn_mst_dev   ($bpf_mst[$idx][0], "bpf", "apf", $bpf_mst[$idx][1]);
    }
                  
    # export external bpf interfaces to be connected by RTL
    for $idx (0 .. $#bpf_mst)
    {
        exp_dev_if($bpf_mst[$idx][0], "bpf", "mst" );
    }
    for $idx (0 .. $#bpf_slv)
    {
        exp_dev_if($bpf_slv[$idx][0], "bpf", "slv" );
    }
    exp_dev_if ("apf", "bpf", "slv");
    exp_dev_if ("apf", "bpf", "mst");
    
    print_FOOTER("bpf");
    close TCL_FILE;

##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
## Creates the Qsys tcl file for the AFU Peripheral Fabric (APF)
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
    open (TCL_FILE, "> apf.tcl") || die "Can't open apf.tcl file!\n";
    print_HEADER("apf");
    
    # add clock and reset for bpf fabric
    inst_clk_rst   ("apf"); 
    conn_clk_rst   ("apf");
    exp_clk_rst    ("apf");
    
    # instantiate interfaces between apf and bpf fabrics
    inst_mst_if    ("bpf", "apf", 21);
    conn_dev_clkrst("bpf", "apf", "mst");
    exp_dev_if     ("bpf", "apf", "mst");
    
    inst_slv_if    ("bpf", "apf", 19);
    conn_dev_clkrst("bpf", "apf", "slv");
    exp_dev_if     ("bpf", "apf", "slv");
    
    # instantiate interfaces st2mm master 
    inst_mst_if    ("st2mm", "apf", 21);
    conn_dev_clkrst("st2mm", "apf", "mst");
    exp_dev_if     ("st2mm", "apf", "mst");
    
    # instantiate outgoing soc_2_host port on apf (a[21]==0, forward to host)
    inst_slv_if    ("soc_2_host", "apf", 20);
    conn_dev_clkrst("soc_2_host", "apf", "slv");
    exp_dev_if     ("soc_2_host", "apf", "slv");
    
    # instantiate incoming host_2_soc port (a[21]==1, forwarded by host)
    inst_mst_if    ("host_2_soc", "apf", 20);
    conn_dev_clkrst("host_2_soc", "apf", "mst");
    exp_dev_if     ("host_2_soc", "apf", "mst");
    
    # enumerate/instantiate apf devices
    
    for $idx (0 .. $#apf_slv)
    {
     inst_slv_if($apf_slv[$idx][0], "apf", $apf_slv[$idx][2]);
    }
    for $idx (0 .. $#apf_mst)
    {
     inst_mst_if($apf_mst[$idx][0], "apf", $apf_mst[$idx][2]);
    }
    
    # connect apf/bpf link to st2mm
    conn_slv_dev   ("bpf", "apf", "st2mm"     , 0x000000);
    conn_mst_dev   ("bpf", "apf", "st2mm"     , 0x000000);
    conn_slv_dev   ("bpf", "apf", "soc_2_host", 0x100000);
    conn_mst_dev   ("bpf", "apf", "host_2_soc", 0x000000);
        
    # add connections to clkrst for each instance
    # add connections to apf master to device slace, and device master to apf slave

    for $idx (0 .. $#apf_slv)
    {
    conn_dev_clkrst($apf_slv[$idx][0], "apf", "slv");
    conn_slv_dev   ($apf_slv[$idx][0], "apf", "st2mm", $apf_slv[$idx][1]);
    conn_slv_dev   ($apf_slv[$idx][0], "apf", "host_2_soc", $apf_slv[$idx][1]);
    }
    for $idx (0 .. $#apf_mst)
    {
    conn_dev_clkrst($apf_mst[$idx][0], "apf", "mst"                   );
    conn_mst_dev   ($apf_mst[$idx][0], "apf", "st2mm", 0x0);
    }
                  
    # export external apf interfaces to be connected by RTL
    for $idx (0 .. $#apf_mst)
    {
        exp_dev_if($apf_mst[$idx][0], "apf", "mst" );
    }
    for $idx (0 .. $#apf_slv)
    {
        exp_dev_if($apf_slv[$idx][0], "apf", "slv" );
    }
    print_FOOTER("apf");
    close TCL_FILE;

    exit 0;

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
# tasks that includes the associated tcl snippets
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

# This function prints the TCL file header lines
sub print_HEADER
{
    my $fab = shift(@_);
    print TCL_FILE "package require -exact qsys 18.0

    # create the system
	create_system $fab
        set_project_property DEVICE $device
        set_project_property DEVICE_FAMILY $family
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}


    # add the components";
}

# This function instantiates the CLK and RST bridges
sub inst_clk_rst
{
    my $fab = shift(@_);
    print TCL_FILE "
	add_component ${fab}_clock_bridge ip/${fab}/${fab}_clock_bridge.ip altera_clock_bridge ${fab}_clock_bridge 
	load_component ${fab}_clock_bridge
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ${fab}_clock_bridge
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {0}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {false}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {0}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation

	add_component ${fab}_reset_bridge ip/${fab}/${fab}_reset_bridge.ip altera_reset_bridge ${fab}_reset_bridge 
	load_component ${fab}_reset_bridge
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ${fab}_reset_bridge
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
    ";
} 

# This function instantiates a SLV interface for a peripheral device
sub inst_slv_if
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $aw  = shift(@_);
    my $cap = 16       ;
    
    print TCL_FILE "
	add_component ${fab}_${dev}_slv ip/${fab}/${fab}_${dev}_slv.ip axi4lite_shim ${fab}_${dev}_slv 1.0
	load_component ${fab}_${dev}_slv
	set_component_parameter_value AW {$aw}
	set_component_parameter_value DW {64}
          set_component_parameter_value COMBINED_ISSUING_CAPABILITY {$cap}
          set_component_parameter_value READ_ISSUING_CAPABILITY {$cap}
          set_component_parameter_value WRITE_ISSUING_CAPABILITY {$cap/4}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ${fab}_${dev}_slv
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clock}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
	set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
	set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
	set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {$cap/4}
	set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
	set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {$cap/4}
	add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr $aw STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr $aw STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
	add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
	set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
	set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
	set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {$cap/4}
	set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
	set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {$cap/4}
	add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr $aw STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_araddr araddr $aw STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
	save_instantiation
    ";
}

# This function instantiates a MST interface for a peripheral device
sub inst_mst_if
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $aw  = shift(@_);
    my $cap = 16       ;

    print TCL_FILE "
	add_component ${fab}_${dev}_mst ip/${fab}/${fab}_${dev}_mst.ip axi4lite_shim ${fab}_${dev}_mst 1.0
	load_component ${fab}_${dev}_mst
	set_component_parameter_value AW {$aw}
	set_component_parameter_value DW {64}
          set_component_parameter_value COMBINED_ISSUING_CAPABILITY {$cap}
          set_component_parameter_value READ_ISSUING_CAPABILITY {$cap}
          set_component_parameter_value WRITE_ISSUING_CAPABILITY {$cap/4}
          set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ${fab}_${dev}_mst
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clock}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
	set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
	set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
	set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {$cap/4}
	set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {$cap/4}
	set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
	add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr $aw STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr $aw STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
	add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
	set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
	set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
	set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {$cap/4}
	set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {$cap}
	set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
	set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {$cap/4}
	add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr $aw STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_araddr araddr $aw STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
	save_instantiation
    ";
}

# This function adds the connections between CLK bridge and RST bridge
sub conn_clk_rst
{
    my $fab = shift(@_);

    # Connecting the CLK to the RST bridge
    print TCL_FILE "
	# add the connections
	add_connection ${fab}_clock_bridge.out_clk/${fab}_reset_bridge.clk
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_reset_bridge.clk clockDomainSysInfo {-1}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_reset_bridge.clk clockRateSysInfo {}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_reset_bridge.clk clockResetSysInfo {}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_reset_bridge.clk resetDomainSysInfo {-1}
    ";
}

sub conn_dev_clkrst
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $itf = shift(@_);

    # Connection to CLK and RST bridges
    print TCL_FILE "
	add_connection ${fab}_clock_bridge.out_clk/${fab}_${dev}_${itf}.clock
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_${dev}_${itf}.clock clockDomainSysInfo {-1}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_${dev}_${itf}.clock clockRateSysInfo {}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_${dev}_${itf}.clock clockResetSysInfo {}
	set_connection_parameter_value ${fab}_clock_bridge.out_clk/${fab}_${dev}_${itf}.clock resetDomainSysInfo {-1}
	add_connection ${fab}_reset_bridge.out_reset/${fab}_${dev}_${itf}.reset
	set_connection_parameter_value ${fab}_reset_bridge.out_reset/${fab}_${dev}_${itf}.reset clockDomainSysInfo {-1}
	set_connection_parameter_value ${fab}_reset_bridge.out_reset/${fab}_${dev}_${itf}.reset clockResetSysInfo {}
	set_connection_parameter_value ${fab}_reset_bridge.out_reset/${fab}_${dev}_${itf}.reset resetDomainSysInfo {-1}";
}

sub conn_slv_dev
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $mst = shift(@_);
    my $addr = shift(@_);

    # Connection to the default APF<->BPF interface    
    print TCL_FILE "
	add_connection ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave baseAddress {$addr}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave defaultConnection {0}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ${fab}_${mst}_mst.altera_axi4lite_master/${fab}_${dev}_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
    ";
}

sub conn_mst_dev
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $slv = shift(@_);
    my $addr = shift(@_);

    # Connection to the default APF<->BPF interface    
    print TCL_FILE "
	add_connection ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave baseAddress {$addr}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave defaultConnection {0}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ${fab}_${dev}_mst.altera_axi4lite_master/${fab}_${slv}_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
    ";
}

sub exp_clk_rst
{
    my $fab = shift(@_);

    print TCL_FILE "
	# add the exports
	set_interface_property clk EXPORT_OF ${fab}_clock_bridge.in_clk
	set_interface_property rst_n EXPORT_OF ${fab}_reset_bridge.in_reset";
}

sub exp_dev_if
{
    my $dev = shift(@_);
    my $fab = shift(@_);
    my $itf = shift(@_);

    my $dir = "";
    $dir = "master" if ($itf eq "slv");
    $dir = "slave" if ($itf eq "mst");

    print TCL_FILE "
	set_interface_property ${fab}_${dev}_${itf} EXPORT_OF ${fab}_${dev}_${itf}.altera_axi4lite_${dir}";
}

# This function prints the TCL file footer lines
sub print_FOOTER
{
    my $dev = shift(@_);
    print TCL_FILE "

    # set the the module properties
	set_module_property FILE {$dev.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {$dev}

    # save the system
    sync_sysinfo_parameters
    save_system $dev
    ";
}

