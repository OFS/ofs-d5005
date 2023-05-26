// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef fpga_defines
`define fpga_defines

   //--------------------------------------------------------------------
   //  Technology
   //--------------------------------------------------------------------
   `define FAMILY  "Stratix 10" // Targeted Device Family
   `define DEVICE_FAMILY_IS_S10
   `define HTILE
   `define INCLUDE_MSIX
   `define INCLUDE_REMOTE_STP
   
   //--------------------------------------------------------------------
   //  HEs
   //--------------------------------------------------------------------
   `define INCLUDE_HSSI
   `define INCLUDE_HE_HSSI

   //--------------------------------------------------------------------
   //  Simulation 
   //--------------------------------------------------------------------
   `define CYCLE_MSG          // TX/RX Messages on host AXI-ST Interface
   //`define R1_UNIT_TEST_ENV // Temporary define needed for unit level tests
                              // with Intel BFM. Deals with a diff in
                              // completer ID field in axi_s_adapter.  
`endif
