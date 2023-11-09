# D5005 Source Code Directory

This directory contains the source code specific to the D5005 FIM.  The complete set of source code needed to build the D5005 FIM will include code from the following:
   - The D5005 Source Code Directory (this directory) (***.***)
   - The OFS-Common directory (***../ofs-common***)
   - The D5005 IP Subsystem directory (***../ipss***)
   - More information may be found in the D5005 top-level README file at:
* [D5005 Repo Main README](../README.md) Contains the top-level description for the directories in the D5005 repository.

## Directories

### Accelerated Functional Unit (AFU) Top (***./afu\_top***)
   - Resources in this directory support the AFU top level which joins the user's accelerated function/application and the FPGA Interface Manager (FIM).
   - Contains:
      - Control and Status Register (CSR) definitions are contained in the top directory which has full-register definitions, bit-field definitions, and individual-bit definitions where applicable.
      - AFU top-level RTL is contained in the top directory.
      - MUX configuration package is contained in the subdirectory ***./afu\_top/mux***.
### Includes (***./includes***)
   - Parameter definitions and packages used for the D5005 FIM configuration reside in this directory.
### Platform Designer (PD) Qsys (***./pd\_qsys***)
   - D5005-specific subsystems created with Platform Designer exist in this directory.
   - Contains:
      - Bus Connection Fabric (***./pd\_qsys/fabric***)
         - This is the connection fabric stitching together the various memory-mapped resources inside the FIM.
      - SPI Bridge (***./pd\_qsys/spi\_bridge***)
         - This is the SPI bridge used primarily to connect the Board Management Controller (BMC) with the resources inside the FPGA.
   - Please consult the following README file for more detailed information:
* [Platform Designer/Qsys Contents Detailed README](pd_qsys/readme.txt) Contains detailed information on the directory structure as well as the instructions for configuring and generating the memory-mapped bus fabric:
      - AFU Peripheral Fabric (APF)
      - Board Peripheral Fabric (BPF)
### Top-level RTL and Resource (***./top***)
   - This directory contains the top-level RTL which provides the overall structure of the FIM.
   - Also included is the reset controller for the FIM.
   - Please see the following README:
* [Top-level README](top/readme.txt) Contains detailed information on the directory structure and the contents of these directories.

