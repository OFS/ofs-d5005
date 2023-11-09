Initial Setup:
1)  Get a "bash" shell (e.g. xterm)
2)  Go to the OFS Repo root directory.
3)  Set all tool paths vcs, python etc. Please make sure Tool versions used are as follows:
    VCS : vcsmx/Q-2020.03-SP2
    Python : python/3.7.7
    Quartus : 21.4
    #Not needed for unit test# SNPS VIP Portfolio Version : vip_Q-2020.03A
    #Not needed for unit test# PCIe VIP : Q-2020.03
    #Not needed for unit test# AXI VIP : Q-2020.03
    #Not needed for unit test# Ethernet VIP : Q-2020.03
4)  Set the required environment and directory Structure variables (as shown below)
    export OFS_ROOTDIR=<pwd>
    export QUARTUS_HOME=<Quartus Installation path upto /quartus>
    export QUARTUS_INSTALL_DIR=$QUARTUS_HOME
    export IMPORT_IP_ROOTDIR=$QUARTUS_HOME/../ip
5)  Generate the sim files. 
    The sim files are not checked in and are generated on the fly. These files need to be generated before a simulation can be run successfully.
    In order to do this, run the following steps
     a. Got to $OFS_ROOTDIR/ofs-common/scripts/common/sim
     b. Run the script "sh gen_sim_files.sh <target>" for e.g. "sh gen_sim_files.sh d5005"


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
    Please refer readme under respective testcase for more info.

*****How to Run Unit level Regressions?******

** usage : python regress_run.py --help

 -l, --local Run regression locally, or run it on Farm. (Default:False)
 -n[N], --n_procs [N] Maximum number of processes/UVM tests to run in parallel when run locally. This has no effect on Farm run. (Default #CPUs-1: 11)
 -k, --pack [{'all','dfh','fme','he_hssi','he_lb','he_mem','list'}] Test package to run during regression (Default: %(default)s)')
 -s [{vcs,msim,vcsmx}], --sim [{vcs,msim,vcsmx}] Simulator used for regression test. (Default: vcs)
 -g, --gen_sim_files, Generate IP simulation files. This should only be done once per repo update.  (Default: %(default)s)
 -e, --email_list Sends the regression results on email provided in list (Default : It will send it to regression Owner)

1)  cd $VERDIR/../sim/unit_test/scripts 

###run locally, with 8 processes, for adp platform, using package of "all" tests, using VCS, to generate IP simulation files.  
python regress_run.py -l -n 8 -k all -s vcs -g

###Same as above, but run on Intel Farm (no --local):   
python regress_run.py --local --n_procs 8 --pack all --sim vcs -g

###Running script using defaults: run on Farm, adp platform, using package of "all" tests, to generate IP simulation files using VCS and sends result to owner 
python regress_run.py -g

2)  Results are created in individual testcase scripts dir

