Following is the diretory structure of the TB ENV Folders and its files present


├── tb_config.svh         - Config file which details of the TB Config.
├── tb_env.svh            - Top level TB Env - Consists of all env components. 
├── tb_pkg.svh            - Top level TB package file which includes are env files and defines.
├── tb_top.sv             - TB Top which has DUT instances and other env instances.
├── virtual_sequencer.svh - Top level Virtual sequencer which instance other env sequencer
├── pcie_pipe32_connection.sv - PCIE PIPE32 file
├── ral                       - Related to RAL    
│   ├── README                - README file for ral folder
│   ├── ral_afu_intf.sv       - RAL file for AFU INTF
│   ├── ral_afu_intf_cov.sv   - RAL Coverage file for AFU INTF
│   ├── ral.sv                - RAL Block which has all registers
│   ├── ral_fme.sv            - RAL file for FME  
│   ├── ral_he_mem.sv         - RAL file for HE_MEM
│   ├── ral_hssi.sv           - RAL file for HSSI
│   ├── ral_hssi_ss_csr.sv    - RAL file for HSSI SS
│   ├── ral_loop.sv           - RAL file for HE_LPBK
│   ├── ral_pcie.sv           - RAL file for PCIE
│   ├── ral_port_gasket.sv    - RAL file for PORT GASKET
│   ├── ral_pr.sv             - RAL file for PR
│   ├── ral_spi.sv            - RAL file for SPI
│   ├── ral_st2mm.sv          - RAL file for ST2MM
│   └── reg2pcie.svh          - REG2PCIE Adapter
├── tb_axis
│   ├── axi_config.cfg                       - Details of AXI Config 
│   ├── axi_rd_mmio_acc_wrapper.sv           - AXI MMIO Access Wrapper.
│   ├── axi_reset_if.svi                     - AXI Reset Interface
│   ├── axi_virtual_sequencer.sv             - AXI Virtual Sequencer
│   ├── axi_wrapper_if.svi                   - AXI Wrapper interface
│   └── cust_svt_axi_system_configuration.sv - AXI VIP Cust System  Configuration
└── tb_pcie
    ├── pcie_hip_defines.svh  - Has PCIE HIP Defines 
    └── pcie_shared_cfg.sv    - PCIE Shared Config 

