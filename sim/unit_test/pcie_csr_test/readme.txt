***Test Description***
This is the unit test for PCIE CSR access
The PCIE CSR implements full RW,RO,RW1C registers.

It covers the following test scenarios:
   * MMIO write 32-bit address and 64-bit address (PCIE_CSR)
   * MMIO read 32-bit address and 64-bit address (PCIE_CSR)
   * Illegal MMIO access - write is blocked and CPL is returned for read

   
Description of test modules:
   * test_csr_defs.sv   - Defines CSR addresses. 
   * tester_tests.sv    - Defines all the test cases for current test. 
   * script/Makefile_VCS.mk       - Script to run the test in VCS only
   * script/Makefile.mk           - Script to run the test in VCS & Questasim. MSIM_D5005=1 option to be given for Questasim else will be for VCS.

***Running the test***
To run the test in VCS:
  1) Make sure the shell environment is set up to run VCS/VCSMX.

  2) IP Simulation Model Generation
     The script required to compile the Quartus IPs is located here: $OFS_ROOTDIR/ofs-common/scripts/common/sim/gen_sim_files.sh
     To compile all IPs:
        cd $OFS_ROOTDIR/ofs-common/scripts/common/sim
        sh gen_sim_files.sh d5005
     The IPs are generated here..................: $OFS_ROOTDIR/sim/scripts/qip_gen
     The IP simulation filelist is generated here: $OFS_ROOTDIR/sim/scripts/ip_flist.f
     Once the IPs are generated, they can be used for any unit test.

  3) RTL & Test Bench Compile Setup
     The RTL file list for unit_test is located here: $OFS_ROOTDIR/sim/scripts/rtl_comb.f
     The directory: $OFS_ROOTDIR/sim/scripts contains most of the important files outside of the test directories.
     Again, the directory: $OFS_ROOTDIR/sim/scripts/qip_gen contains the directories of the compiled IP.
     The common Bus-Functional Models used by the Unit Tests are contained in the directories: 
        - $OFS_ROOTDIR/sim/bfm
        - $OFS_ROOTDIR/sim/rp_bfm

  4) Simulation
     Simulations are run in the $OFS_ROOTDIR/sim/unit_test/<test_name>/scripts directory.
     To run a Synopsys VCS simulation:
        cd $OFS_ROOTDIR/sim/unit_test/<test_name>/script/sim/unit_test/<test_name>/scripts
        sh run_sim.sh

  5) View Waveform
        cd $OFS_ROOTDIR/sim/unit_test/<test_name>/script/sim/unit_test/<test_name>/scripts/sim_vcs
        dve -full64 -vpd vcdplus.vpd &

To run the test in QuestaSim:
  1) Make sure the shell environment is set up to run Questasim.

  2) IP Simulation Model Generation
     The script required to compile the Quartus IPs is located here: $OFS_ROOTDIR/ofs-common/scripts/common/sim/gen_sim_files.sh
     To compile all IPs:
        cd $OFS_ROOTDIR/ofs-common/scripts/common/sim
        sh gen_sim_files.sh d5005
     The IPs are generated here..................: $OFS_ROOTDIR/sim/scripts/qip_gen
     The IP simulation filelist is generated here: $OFS_ROOTDIR/sim/scripts/ip_flist.f
     Once the IPs are generated, they can be used for any unit test.

  3) RTL & Test Bench Compile Setup
     The RTL file list for unit_test is located here: $OFS_ROOTDIR/sim/scripts/rtl_comb.f
     The directory: $OFS_ROOTDIR/sim/scripts contains most of the important files outside of the test directories.
     Again, the directory: $OFS_ROOTDIR/sim/scripts/qip_gen contains the directories of the compiled IP.
     The common Bus-Functional Models used by the Unit Tests are contained in the directories: 
        - $OFS_ROOTDIR/sim/bfm
        - $OFS_ROOTDIR/sim/rp_bfm

  4) Simulation
     Simulations are run in the $OFS_ROOTDIR/sim/unit_test/<test_name>/scripts directory.
     To run a Mentor Graphics QuestaSim simulation:
        cd $OFS_ROOTDIR/sim/unit_test/<test_name>/script/sim/unit_test/<test_name>/scripts
        sh run_sim.sh MSIM=1

  5) View Waveform
        cd $OFS_ROOTDIR/sim/unit_test/<test_name>/script/sim/unit_test/<test_name>/scripts/sim_msim
        vsim -view vsim.wlf &
