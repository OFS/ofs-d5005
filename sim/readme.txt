Initial Setup:
1)	Get a "bash" shell (e.g. xterm)
2)	Go to the OFS Repo root directory.
3)  Set all tool paths vcs, python etc. Please make sure Tool versions used are as follows:
    VCS : vcsmx/Q-2020.03-SP2
    Python : python/3.7.7
    Quartus : 21.4
    #Not needed for unit test# SNPS VIP Portfolio Version : vip_Q-2020.03A
    #Not needed for unit test# PCIe VIP : Q-2020.03
    #Not needed for unit test# AXI VIP : Q-2020.03
    #Not needed for unit test# Ethernet VIP : Q-2020.03
4)	Set the required environment and directory Structure variables (as shown below)
    export OFS_ROOTDIR=<pwd>
    export QUARTUS_HOME=<Quartus Installation path upto /quartus>
    export QUARTUS_INSTALL_DIR=$QUARTUS_HOME
    export IMPORT_IP_ROOTDIR=$QUARTUS_HOME/../ip
5) Generate the sim files. 
   The sim files are not checked in and are generated on the fly. In order to do this, run the following steps
    a. Got to $OFS_ROOTDIR/sim/scripts/common
    b  Run the script "sh gen_sim_files.sh <target>" for e.g. "sh gen_sim_files.sh d5005"


5) **Running Test******
    Unit tests are placed under $OFS_ROOTDIR/sim/unit_test/<test name> 
    For example, the DFH Walker Unit Test may be found at $OFS_ROOTDIR/sim/unit_test/dfh_walker
    Under each test directory, the simulation shell script, "run_sim.sh", may be found in the subdirectory "scripts".
    For example, for the DFH Walker Unit Test, the simulation script may be found at: 
        $OFS_ROOTDIR/sim/unit_test/dfh_walker/script/run_sim.sh
    To run the simulation under for test:
        VCS  : sh run_sim.sh
        VCSMX: sh run_sim.sh VCSMX=1
        QuestaSim: sh run_sim.sh MSIM=1
    Please refer to the README for each respective Unit Test for more information.
