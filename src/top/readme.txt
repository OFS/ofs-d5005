Folder Structure:

├── d5005
│   ├── afu
│   │   ├── AFU_INTF_CSR.xls                       // list of CSR details 
│   │   ├── afu_intf.sv                            // AFU interface module between PCIe and PF-VF mux module
│   │   ├── afu_intf_csr.sv                        // AFU interface to CSR register
│   │   ├── afu_top.sv                             // AFU top wrapper
│   │   ├── he_mem
│   │   │   └── he_mem_top.sv                      // HE MEM top level wrapper
│   │   ├── mmio_handler.sv                        // handles mmio timeout and unexpected read response 
│   │   ├── pf_vf_mux_top
│   │   │   └── mux
│   │   │       └── top_cfg_pkg.sv                 // this is a package define the parameters used in top level module
│   │   ├── port_traffic_control.sv                // Controls AFU TX traffic going upstream
│   │   ├── port_tx_fifo.sv                        // FIFO with store and forward capability to buffer AFU TX packets
│   │   ├── protocol_checker.sv                    // Considers DM PCIe packet sizes/widths
│   │   ├── prtcl_chkr_pkg.sv                      // Package contains the localparams used in the protocol checker 
│   │   └── tx_filter.sv                           // Handles MMIO timeout response and block AXI TX traffic on an error
│   ├── includes
│   │   ├── fpga_defines.vh                        // FPGA defines parameters for D5005
│   │   ├── ofs_fim_cfg_pkg.sv                     // This package defines the global parameters of CoreFIM
│   │   ├── ofs_pcie_ss_plat_cfg.vh                // to associate a version tag with the values in ofs_pcie_ss_plat_cfg_pkg
│   │   └── ofs_pcie_ss_plat_cfg_pkg.sv            // platform-specific PCIe configuration package
│   ├── iofs_top.sv                                // IOFS top wrapper file which has ethernet, pcie, pmci, fme, afu, bpf interconnect, emif, system rst controller and clk_pll modules
│   ├── ofs_d5005.ini                              // Platform interface manager configuration
│   ├── pmci
│   │   └── pmci_top.sv                            // platform management controller with SPI master bridge and SPI CSR
│   ├── rst_ctrl.sv                                // system reset controller
│   └── spi
│       ├── SPI_CSR.xls                            // SPI Configuration and Status Register details
│       ├── spi_bridge_csr.sv                      // SPI CSR register module
│       └── spi_bridge_top.sv                      // SPI top with SPI master bridge and SPI CSR instatantiated
