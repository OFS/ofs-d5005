Folder Structure:

-- fabric                                              // Contains AFU Peripheral Fabric (APF) & Board Peripheral Fabric (BPF) Qsys interconnect fabric
|   |-- apf                                            // Quartus generated APF interconnect fabric output products (Dont Touch)
|   |-- apf.qsys                                       // Quartus generated APF interconnect fabric (Dont Touch)
|   |-- apf.tcl                                        // APF Subsystem generation script, generated as part of the flow (Dont Touch)
|   |-- axi4lite_shim_hw.tcl                           // AXI Lite bridhe HW TCL Script used to export AXI Lite interface in QSYS
|   |-- bpf                                            // Quartus generated BPF interconnect fabric output products (Dont Touch)
|   |-- bpf.qsys                                       // Quartus generated BPF interconnect fabric (Dont Touch)
|   |-- bpf.tcl                                        // BPF Subsystem generation script, generated as part of the flow (Dont Touch)
|   |-- fpga_bars.pkg                                  // APF & BPF BAR parameters package, This is a script generated file (Dont Touch)
|   |-- gen_fabrics.sh                                 // QSYS Generation bash script. See the usage below.
|   |-- hdk.qpf                                        // Quartus project file
|   |-- hdk.qsf                                        // Quartus project setting file
|   |-- iofs_dfl.txt                                   // APF & QPF Configuration setting. This file is input to QSYS bash script. Modify this file if user need a change in interconnect fabric
|   |-- ip                                             // Quartus Generated IPs
|   `-- qdb                                            // Not used
`-- spi_bridge                                         // Avalon MM slave to SPI master bridge to enable the communication with the MAX10 BMC
    |-- ip                                             // Qsys generated IPs & output products
    |-- spi_bridge                                     // Qsys generated output products
    `-- spi_bridge.qsys                                // AVMM slave to SPI Bridge. This is manually generated interconnect fabric.


APF/BPF Qsys Interconect fabric generation using Bash script:

  1. Initial Setup
  
  cd to ./fabric/
  Update iofs_dfl.txt with your required setting
  Header fields in iofs_dfl.txt are interpreted as below   .
      * REGISTER_NAME : DFH register name
      * FABRIC        : {BPF-SLV, BPF-MST, BPF-BID, APF-SLV, APF-MST, APF-BID}
            * BPF-SLV : Device feature is a BPF slave
            * BPF-MST : Device feature is a BPF master
            * BPF-BID : Device feature is a BPF master and slave
            * APF-SLV : Device feature is a APF slave
            * APF-MST : Device feature is a APF master
            * APF-BID : Device feature is a APF master and slave
      * BASE ADDRESS  : Device feature base address
      * ADDRESS WIDTH : Device feature address width
  Currently only 1 master and 1 slave interface is supported per device feature
      
  2. Run gen_fabrics.sh
  
  Script will use iofs_sfl.txt as the input, generating the TCL files for the APF & BPF fabric, and finally generate the Quartus output for both.
  If no errors are encountered, the script will complete with a message "Finished: Platform Designer system generation"
  Following files will be generated as part of APF Fabric: apf.qsys,apf,apf.tcl,fpga_bars.pkg
  Following files will be generated as part of BPF Fabric: bpf.qsys,bpf,bpf.tcl,fpga_bars.pkg
