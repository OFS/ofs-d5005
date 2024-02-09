// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// This package defines the parameters used in top level module 
//
//-----------------------------------------------------------------------------
`ifndef __TOP_CFG_PKG_SV__ 
`define __TOP_CFG_PKG_SV__

`include "fpga_defines.vh"

package top_cfg_pkg;

enum { 
      PCIE_CSR_ID,
      SPI_CSR_ID
   `ifdef INCLUDE_DDR4
      ,EMIF_CSR_ID
   `endif
   `ifdef INCLUDE_HSSI
      ,HSSI_CSR_ID
   `endif
   `ifdef INCLUDE_USER_CLOCK
      ,USER_CLOCK_CSR_ID
   `endif
      ,MAX_CSR_ID
} csr_id;

localparam EXT_CSR_SLAVES    = MAX_CSR_ID;
localparam EXT_FME_IRQ_IFS   = MAX_CSR_ID;
localparam EXT_PORT0_IRQ_IFS = MAX_CSR_ID;

// FME CSR memory size in 4KB unit
// The array index follows csr_id enum index, e.g. PCIe CSR is located at index 0
localparam bit [EXT_CSR_SLAVES-1:0][63:0] EXT_FME_CSR_MEM_SIZE = {
   `ifdef INCLUDE_USER_CLOCK
      64'h0,  // User Clock FME CSR
   `endif
   `ifdef INCLUDE_SPI_BRIDGE
      64'h1,  // SPI Bridge FME CSR
   `endif
   `ifdef INCLUDE_HSSI
      64'h1,  // HSSI FME CSR
   `endif
   `ifdef INCLUDE_DDR4
      64'h1,  // EMIF FME CSR
   `endif
   64'h1      // PCIe FME CSR (PCIE_CSR_ID = 0)
};

// Port CSR memory size in 4KB unit
// The array index follows csr_id enum index, e.g. PCIe CSR is located at index 0
localparam bit [EXT_CSR_SLAVES-1:0][63:0] EXT_PORT0_CSR_MEM_SIZE = {
   `ifdef INCLUDE_USER_CLOCK
      64'h1,  // User Clock Port CSR
   `endif
   `ifdef INCLUDE_SPI_BRIDGE
      64'h0,  // SPI Bridge Port CSR
   `endif
   `ifdef INCLUDE_HSSI
      64'h0,  // HSSI Port CSR 
   `endif
   `ifdef INCLUDE_DDR4
      64'h0,  // EMIF Port CSR
   `endif
   64'h0      // PCIe Port CSR (PCIE_CSR_ID = 0)
};

// CSR slave priority (0/1), 0:higher priority 1:lower priority
// The array index follows csr_id enum index, e.g. PCIe CSR is located at index 0
localparam bit [EXT_CSR_SLAVES-1:0][63:0] EXT_CSR_PRIORITY = {
   `ifdef INCLUDE_USER_CLOCK
      64'h0,  // User Clock CSR
   `endif
   `ifdef INCLUDE_SPI_BRIDGE
      64'h0,  // SPI Bridge CSR
   `endif
   `ifdef INCLUDE_HSSI
      64'h0,  // HSSI CSR
   `endif 
   `ifdef INCLUDE_DDR4
      64'h0,  // EMIF CSR
   `endif
   64'h0      // PCIe CSR 
};      
 
//---------------------------------------------------------------------------------//--------------------------------------
//                               Simulation Display Message Options                //                                      
//---------------------------------------------------------------------------------//--------------------------------------
              `define    MUX_MSG                                                   // Enable PF/VF_MUX    Tracker Message  
           // `define    HE_LB_MSG                                                 // Enable HE Loopback  Tracker Message  
           // `define    HSSI_MSG                                                  // Enable HSSI         Tracker Message  
           // `define    PR_MSG                                                    // Enable PR           Tracker Message  
//---------------------------------------------------------------------------------//--------------------------------------
//                                   FPGA Component Inclusion                      //                                      
//---------------------------------------------------------------------------------//--------------------------------------
           // `define    INCLUDE_HSSI                                              // Instantiate   HSSI IP                
           // `define    INCLUDE_DDR4                                              // Instantiate   DDR4 IP                
           // `define    INCLUDE_PCIE                                              // Instantiate   PCIE IP                
           // `define    INCLUDE_SPI_BRIDGE                                        // Instantiate   SPI  Bridge IP         
           // `define    INCLUDE_USER_CLOCK                                        // Instantiate   User Clock             
//---------------------------------------------------------------------------------//--------------------------------------
//                                    FPGA Debug Singaltaps                        //                                      
//---------------------------------------------------------------------------------//--------------------------------------
              `define    DEBUG_MUX                                                 // Add PF/VF Mux Debug Signals          
              `define    DEBUG_APF                                                 // Add APF CSR   Debug Signals          
           // `define    DEBUG_BPF                                                 // Add BPF CSR   Debug Signals          
           // `define    DEBUG_PCIE                                                // Add PCIE      Debug Signals          
           // `define    DEBUG_HSSI                                                // Add HSSI      Debug Signals          
           // `define    DEBUG_MEM                                                 // Add EMIF/MEM  Debug Signals          
//=========================================================================================================================
//                         OFS Configuration Parameters                                                                 
//=========================================================================================================================
     parameter NUM_MEM_CH     = 4                                                 ,// Number of Memory/DDR Channel         
               NUM_HOST       = 1                                                 ,// Number of Host/Upstream Ports        
               NUM_PORT       = 4                                                 ,// Number of Functions/Downstream Ports 
               DATA_WIDTH     = 512                                               ,// Data Width of Interface              
               TOTAL_BAR_SIZE = 20                                                ,// Total Space for APF/BPF BARs (2^N) 
           //------------+-------------+-------------+-----------------+           //--------------------------------------
           // VF Active  |     PF #    |     VF #    |  Mux Port Map   |           //  PF/VF Mapping Parameters            
           //------------+-------------+-------------+-----------------+           //--------------------------------------
             CFG_VA = 0  , CFG_PF = 0  , CFG_VF =  0 ,  CFG_PID = 3    ,           //  Configuration Register Block        
             HLB_VA = 1  , HLB_PF = 0  , HLB_VF =  0 ,  HLB_PID = 0    ,           //  HE Loopback Engine                  
             PRG_VA = 1  , PRG_PF = 0  , PRG_VF =  1 ,  PRG_PID = 1    ,           //  Partial Reconfiguration Gasket      
             HSI_VA = 1  , HSI_PF = 0  , HSI_VF =  2 ,  HSI_PID = 2    ;           //  HSSI interface 

//=========================================================================================================================
//                           PF/VF Mux Routing Table
//=========================================================================================================================

localparam NUM_RTABLE_ENTRIES = 5;
localparam pf_vf_mux_pkg::t_pfvf_rtable_entry PFVF_ROUTING_TABLE[NUM_RTABLE_ENTRIES] = '{
    '{ pfvf_port:HLB_PID, pf:HLB_PF, vf:HLB_VF, vf_active:HLB_VA },
    '{ pfvf_port:PRG_PID, pf:PRG_PF, vf:PRG_VF, vf_active:PRG_VA },
    '{ pfvf_port:HSI_PID, pf:HSI_PF, vf:HSI_VF, vf_active:HSI_VA },
    '{ pfvf_port:CFG_PID, pf:-1,     vf:-1,     vf_active:0 },
    '{ pfvf_port:CFG_PID, pf:-1,     vf:-1,     vf_active:1 }
     };


localparam NID_WIDTH     = $clog2(NUM_PORT)                                       ,// ID field width for targeting mux ports
           MID_WIDTH     = $clog2(NUM_HOST)                                       ;// ID field width for targeting host ports

      //-------------------------------+----------------------------+              //======================================
      //  Device CSR BAR Base Address  | Device CSR BAR Size (2^N)  |              // APF/BPF BAR Base Address & Size      
      //-------------------------------+----------------------------+              //=======================================
     parameter FME_BASE   = 'h000000   , FME_SIZE      =  16        ,              //  FME         BAR                     
               PMCI_BASE  = 'h010000   , PMCI_SIZE     =  16        ,              //  PMCI        BAR                     
               PCIE_BASE  = 'h020000   , PCIE_SIZE     =  16        ,              //  PCIE        BAR                     
               HSSI_BASE  = 'h030000   , HSSI_SIZE     =  16        ,              //  HSSI        BAR                     
               EMIF_BASE  = 'h040000   , EMIF_SIZE     =  16        ,              //  EMIF        BAR                     
               RSV_5_BASE = 'h050000   , RSV_5_SIZE    =  16        ,              //  RSV_5       Reserved Space          
               RSV_6_BASE = 'h060000   , RSV_6_SIZE    =  16        ,              //  RSV_6       Reserved Space          
               RSV_7_BASE = 'h070000   , RSV_7_SIZE    =  16        ,              //  RSV_7       Reserved Space          
               ST2MM_BASE = 'h080000   , ST2MM_SIZE    =  16        ,              //  RST2MM      BAR                     
               PGSK_BASE  = 'h090000   , PGSK_SIZE     =  16        ,              //  PR Gasket   BAR                     
               ACHK_BASE  = 'h0a0000   , ACHK_SIZE     =  16        ,              //  AFU Checker BAR                     
               RSV_b_BASE = 'h0b0000   , RSV_b_SIZE    =  16        ,              //  RSV_b       Reserved Space          
               RSV_c_BASE = 'h0c0000   , RSV_c_SIZE    =  16        ,              //  RSV_c       Reserved Space          
               RSV_d_BASE = 'h0d0000   , RSV_d_SIZE    =  16        ,              //  RSV_d       Reserved Space          
               RSV_e_BASE = 'h0e0000   , RSV_e_SIZE    =  16        ,              //  RSV_e       Reserved Space          
               RSV_f_BASE = 'h0f0000   , RSV_f_SIZE    =  16        ;              //  RSV_f       Reserved Space          
                                                                                                           

     //
     // A subset of the multiplexed PF/VF ports are passed through the port
     // gasket to afu_main(). The following arrays indicate the PF/VF numbers
     // associated with an equal-sized array of AXI TLP interfaces passed
     // to afu_main().
     //

     // Number of PCIe ports passed to afu_main()
     localparam PG_AFU_NUM_PORTS = 2;

     // Mux port ID of each AFU port (index 0 on the left)
     localparam int PG_AFU_MUX_PID[PG_AFU_NUM_PORTS]           = '{ PRG_PID, HSI_PID };

     // PF/VF mapping for each port
     localparam logic [10:0] PG_AFU_PORTS_VF_NUM[PG_AFU_NUM_PORTS]    = '{ PRG_VF, HSI_VF };
     localparam logic        PG_AFU_PORTS_VF_ACTIVE[PG_AFU_NUM_PORTS] = '{ PRG_VA, HSI_VA };
     localparam logic [2:0]  PG_AFU_PORTS_PF_NUM[PG_AFU_NUM_PORTS]    = '{ PRG_PF, HSI_PF };

endpackage : top_cfg_pkg

`endif // __TOP_CFG_PKG_SV__ 
