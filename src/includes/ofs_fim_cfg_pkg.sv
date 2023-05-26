// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// This package defines the global parameters of CoreFIM
//
//----------------------------------------------------------------------------
`ifndef __OFS_FIM_CFG_PKG_SV__
`define __OFS_FIM_CFG_PKG_SV__

package ofs_fim_cfg_pkg;

localparam PORTS = 1;

//*****************
// PCIe host parameters
//*****************
localparam NUM_PCIE_HOST      = 1;
localparam PCIE_HOST_WIDTH    = $clog2(NUM_PCIE_HOST);

localparam PCIE_RP_MAX_TAGS   = 64;
localparam PCIE_RP_TAG_WIDTH  = $clog2(PCIE_RP_MAX_TAGS);

localparam PCIE_TDATA_WIDTH  = 512;
localparam PCIE_TUSER_WIDTH  = 10;

localparam FIM_NUM_PF         = 2;
localparam FIM_NUM_VF         = 4;
localparam FIM_PF_WIDTH       = (FIM_NUM_PF < 2) ? 1 : $clog2(FIM_NUM_PF);
localparam FIM_VF_WIDTH       = (FIM_NUM_VF < 2) ? 1 : $clog2(FIM_NUM_VF);

localparam FIM_NUM_MMIO_BAR   = 1; // FME, Port

localparam MAX_PAYLOAD_SIZE    = 64;
localparam MAX_RD_REQ_SIZE     = 64;

//*****************
// MMIO parameters
//*****************
localparam MMIO_TID_WIDTH          = PCIE_HOST_WIDTH + PCIE_RP_TAG_WIDTH; // Matches PCIe TLP tag width 
localparam MMIO_DATA_WIDTH         = 64;

localparam MMIO_REGION_WIDTH       = $clog2(FIM_NUM_MMIO_BAR); // Number of bits to encode MMIO region (e.g. FME, Port)
localparam FEAT_ADDR_WIDTH         = 20; // Feature address width for MMIO region
localparam MMIO_ADDR_WIDTH         = MMIO_REGION_WIDTH + FEAT_ADDR_WIDTH; // Full MMIO address width 

localparam FME_FEAT_ADDR_WIDTH     = 20; // Feature address width for FME MMIO region
localparam VFME_FEAT_ADDR_WIDTH    = 14; // Feature address width for VFME MMIO region
localparam PORT_FEAT_ADDR_WIDTH    = 19; // Feature address width for Port MMIO region (not including AFU)

localparam FEAT_REGION_UNIT_WIDTH  = 12; // 4KB block unit
localparam FEAT_REGION_ADDR_START  = 12; // 4KB block unit
localparam FEAT_REGION_WIDTH       = FEAT_ADDR_WIDTH - FEAT_REGION_UNIT_WIDTH; // Number of bits to address 4KB feature region within a MMIO region
localparam VFME_FEAT_REGION_WIDTH  = VFME_FEAT_ADDR_WIDTH - FEAT_REGION_UNIT_WIDTH; // Number of bits to address 4KB feature region within vFME MMIO region


// CSR region
enum logic [MMIO_REGION_WIDTH-1:0] {
   FME_MMIO_REGION,
   PORT_MMIO_REGION
} e_mmio_region;

// CoreFIM FME address range (0x0 - 0x3FFFF)
localparam FME_FEAT_REGION_START     = 'h0;
//External FME address range (0x40000 - 0x7FFFF)
localparam EXT_FME_FEAT_REGION_START = 'h40;

// Address range: CoreFIM Port0 (0x0 - 0x1FFFF), External Port0 (0x20000 - 0x3FFFF)
localparam PORT_FEAT_REGION_START     = 'h0;
localparam EXT_PORT_FEAT_REGION_START = 'h20;

// Address range: AFU (Port 0) (0x40000 - 0xBFFFF)
localparam AFU_FEAT_REGION_START      = 'h40;

// FME and Port function number
localparam FME_PF_NUM   = 3'd0;
localparam VFME_VF_NUM  = 13'd0;
localparam bit [PORTS-1:0][2:0] PORT_PF_NUM = {3'd0};
localparam bit [PORTS-1:0][2:0] PORT_VF_NUM = {3'd0};

// FME and Port function BAR
localparam FME_PF_BAR   = 3'd0; // BAR 0
localparam VFME_BAR     = 3'd4; // BAR 4
localparam bit [PORTS-1:0][2:0] PORT_PF_BAR = {3'd2};
localparam bit [PORTS-1:0][2:0] PORT_VF_BAR = {3'd0};


//MSIX
`ifdef NUM_AFUS
localparam   NUM_AFUS    = 2;
`else
localparam   NUM_AFUS    = 1;
`endif
localparam LNUM_AFUS = NUM_AFUS>1?$clog2(NUM_AFUS):1'h1;
localparam NUM_AFU_INTERRUPTS = 7;
localparam L_NUM_AFU_INTERRUPTS = $clog2(NUM_AFU_INTERRUPTS);


endpackage

`endif // __OFS_FIM_CFG_PKG_SV__
