// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// MSIX Table + PBA
//-----------------------------------------------------------------------------



module  msix_csr #(
    parameter MM_ADDR_WIDTH   = 20, 
    parameter MM_DATA_WIDTH   = 64
)(
    input                               clk,
    input                               rst_n,
    
    input   logic                               avmm_m2s_write,
    input   logic                               avmm_m2s_read,
    input   logic   [MM_ADDR_WIDTH-1:0]         avmm_m2s_address,
    input   logic   [MM_DATA_WIDTH-1:0]         avmm_m2s_writedata,
    input   logic   [(MM_DATA_WIDTH>>3)-1:0]    avmm_m2s_byteenable,
    
    output  logic                               avmm_s2m_waitrequest,
    output  logic                               avmm_s2m_writeresponsevalid,
    output  logic                               avmm_s2m_readdatavalid,
    output  logic   [MM_DATA_WIDTH-1:0]         avmm_s2m_readdata,
    
    input   logic   [6:0]                       inp2cr_msix_pba,
    input   logic   [31:0]                      inp2cr_msix_count_vector,

    output  logic   [63:0]                      cr2out_msix_addr0,
    output  logic   [63:0]                      cr2out_msix_addr1,
    output  logic   [63:0]                      cr2out_msix_addr2,
    output  logic   [63:0]                      cr2out_msix_addr3,
    output  logic   [63:0]                      cr2out_msix_addr4,
    output  logic   [63:0]                      cr2out_msix_addr5,
    output  logic   [63:0]                      cr2out_msix_addr6,
    output  logic   [63:0]                      cr2out_msix_addr7,
    output  logic   [63:0]                      cr2out_msix_ctldat0,
    output  logic   [63:0]                      cr2out_msix_ctldat1,
    output  logic   [63:0]                      cr2out_msix_ctldat2,
    output  logic   [63:0]                      cr2out_msix_ctldat3,
    output  logic   [63:0]                      cr2out_msix_ctldat4,
    output  logic   [63:0]                      cr2out_msix_ctldat5,
    output  logic   [63:0]                      cr2out_msix_ctldat6,
    output  logic   [63:0]                      cr2out_msix_ctldat7,
    output  logic   [63:0]                      cr2out_msix_pba    
);
import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_csr_pkg::*;
import fme_csr_pkg::*;
//----------------------------------------------------------------------------
// Local parameters.
//----------------------------------------------------------------------------
localparam CSR_FEATURE_NUM          = 2;
localparam CSR_FEATURE_REG_NUM      = 23;

localparam MSIX_ADDR0               = 20'h0_3000;
localparam MSIX_CTLDAT0             = 20'h0_3008;
localparam MSIX_ADDR1               = 20'h0_3010;
localparam MSIX_CTLDAT1             = 20'h0_3018;
localparam MSIX_ADDR2               = 20'h0_3020;
localparam MSIX_CTLDAT2             = 20'h0_3028;
localparam MSIX_ADDR3               = 20'h0_3030;
localparam MSIX_CTLDAT3             = 20'h0_3038;
localparam MSIX_ADDR4               = 20'h0_3040;
localparam MSIX_CTLDAT4             = 20'h0_3048;
localparam MSIX_ADDR5               = 20'h0_3050;
localparam MSIX_CTLDAT5             = 20'h0_3058;
localparam MSIX_ADDR6               = 20'h0_3060;
localparam MSIX_CTLDAT6             = 20'h0_3068;
localparam MSIX_ADDR7               = 20'h0_3070;
localparam MSIX_CTLDAT7             = 20'h0_3078;
localparam MSIX_PBA                 = 20'h0_2000;
localparam MSIX_COUNT_CSR           = 20'h0_2008;

//----------------------------------------------------------------------------
// SIGNAL DEFINITIONS
//----------------------------------------------------------------------------
ofs_csr_hw_state_t          hw_state;                       // Hardware state during CSR updates
csr_access_type_t           write_type, write_type_reg;

logic [CSR_REG_WIDTH-1:0]   data_reg;
logic                       write_reg;

//----------------------------------------------------------------------------
// CSR registers are implemented in a two dimensional array according to the
// features and the number of registers per feature.  This allows the most
// flexibility addressing the registers as well as using the least resources.
//----------------------------------------------------------------------------
//....[63:0 packed width].....reg[10:0 - #Features   ][22:0 - #Regs in Feature]  <<= Unpacked dimensions.
logic [CSR_REG_WIDTH-1:0] csr_reg[CSR_FEATURE_NUM-1:0][CSR_FEATURE_REG_NUM-1:0];    // CSR Registers
logic                     csr_write[CSR_FEATURE_NUM-1:0][CSR_FEATURE_REG_NUM-1:0];  // Arrayed like the CSR registers

//---------------------------------------------------------------------------------
// Define the register bit attributes for each of the CSRs
//---------------------------------------------------------------------------------
fme_csr_msix_addr_attr_t msix_addr0_attr;
assign msix_addr0_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr0_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat0_attr;
assign msix_ctldat0_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat0_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr1_attr;
assign msix_addr1_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr1_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat1_attr;
assign msix_ctldat1_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat1_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr2_attr;
assign msix_addr2_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr2_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat2_attr;
assign msix_ctldat2_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat2_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr3_attr;
assign msix_addr3_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr3_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat3_attr;
assign msix_ctldat3_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat3_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr4_attr;
assign msix_addr4_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr4_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat4_attr;
assign msix_ctldat4_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat4_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr5_attr;
assign msix_addr5_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr5_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat5_attr;
assign msix_ctldat5_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat5_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr6_attr;
assign msix_addr6_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr6_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat6_attr;
assign msix_ctldat6_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat6_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_addr_attr_t msix_addr7_attr;
assign msix_addr7_attr.msix_addr.msg_addr_upp = {32{RW}};
assign msix_addr7_attr.msix_addr.msg_addr_low = {32{RW}};
fme_csr_msix_ctldat_attr_t msix_ctldat7_attr;
assign msix_ctldat7_attr.msix_ctldat.msg_control = {32{RW}};
assign msix_ctldat7_attr.msix_ctldat.msg_data    = {32{RW}};
fme_csr_msix_pba_attr_t msix_pba_attr;
assign msix_pba_attr.msix_pba.reserved7 = {57{RsvdZ}};
assign msix_pba_attr.msix_pba.msix_pba  = {7{RO}};
fme_csr_msix_count_csr_attr_t msix_count_csr_attr;
assign msix_count_csr_attr.msix_count_csr.reserved32                 = {32{RsvdZ}};
assign msix_count_csr_attr.msix_count_csr.afu_2_sync_fifo_msix_count = {8{RO}};
assign msix_count_csr_attr.msix_count_csr.sync_fifo_2_msix_count     = {8{RO}};
assign msix_count_csr_attr.msix_count_csr.msix_2_cdc_msix_count      = {8{RO}};
assign msix_count_csr_attr.msix_count_csr.cdc_2_avl_msix_count       = {8{RO}};

//----------------------------------------------------------------------------
//  Assignment/Update Overlays:
//     These structure overlays help map out the fields for the status register 
//     "update" inputs used by the function "update_reg" to determine the 
//     next values stored in the FME status CSRs.
//----------------------------------------------------------------------------
fme_csr_msix_addr_t                fme_csr_msix_addr0_reset, fme_csr_msix_addr0_update, fme_csr_msix_addr1_reset, fme_csr_msix_addr1_update, fme_csr_msix_addr2_reset, fme_csr_msix_addr2_update, fme_csr_msix_addr3_reset, fme_csr_msix_addr3_update, fme_csr_msix_addr4_reset, fme_csr_msix_addr4_update, fme_csr_msix_addr5_reset, fme_csr_msix_addr5_update, fme_csr_msix_addr6_reset, fme_csr_msix_addr6_update, fme_csr_msix_addr7_reset, fme_csr_msix_addr7_update;
fme_csr_msix_ctldat_t              fme_csr_msix_ctldat0_reset, fme_csr_msix_ctldat0_update, fme_csr_msix_ctldat1_reset, fme_csr_msix_ctldat1_update, fme_csr_msix_ctldat2_reset, fme_csr_msix_ctldat2_update, fme_csr_msix_ctldat3_reset, fme_csr_msix_ctldat3_update, fme_csr_msix_ctldat4_reset, fme_csr_msix_ctldat4_update, fme_csr_msix_ctldat5_reset, fme_csr_msix_ctldat5_update, fme_csr_msix_ctldat6_reset, fme_csr_msix_ctldat6_update, fme_csr_msix_ctldat7_reset, fme_csr_msix_ctldat7_update;
fme_csr_msix_pba_t                 fme_csr_msix_pba_reset, fme_csr_msix_pba_update;
fme_csr_msix_count_csr_t           fme_csr_msix_count_csr_reset, fme_csr_msix_count_csr_update;

//----------------------------------------------------------------------------
//  Breakout Overlays:
//     These structure overlays Help break out the CSR control register 
//     outputs to their destinations.
//----------------------------------------------------------------------------
fme_csr_msix_addr_t                fme_csr_msix_addr0, fme_csr_msix_addr1, fme_csr_msix_addr2, fme_csr_msix_addr3, fme_csr_msix_addr4, fme_csr_msix_addr5, fme_csr_msix_addr6, fme_csr_msix_addr7;
fme_csr_msix_ctldat_t              fme_csr_msix_ctldat0, fme_csr_msix_ctldat1, fme_csr_msix_ctldat2, fme_csr_msix_ctldat3, fme_csr_msix_ctldat4, fme_csr_msix_ctldat5, fme_csr_msix_ctldat6, fme_csr_msix_ctldat7;
fme_csr_msix_pba_t                 fme_csr_msix_pba;

//----------------------------------------------------------------------------
// Register Reset/Update Structure Overlays.
//----------------------------------------------------------------------------
assign fme_csr_msix_addr0_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr0_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr1_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr1_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr2_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr2_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr3_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr3_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr4_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr4_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr5_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr5_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr6_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr6_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr7_reset.data    = 64'h0000_0000_0000_0000;
assign fme_csr_msix_addr7_update.data   = 64'h0000_0000_0000_0000;
assign fme_csr_msix_ctldat0_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat0_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat1_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat1_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat2_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat2_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat3_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat3_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat4_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat4_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat5_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat5_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat6_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat6_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat7_reset.data  = 64'h0000_0001_0000_0000;
assign fme_csr_msix_ctldat7_update.data = 64'h0000_0001_0000_0000;
assign fme_csr_msix_pba_reset.data                   = fme_csr_msix_pba_update.data;
assign fme_csr_msix_pba_update.msix_pba.reserved7    = {57{1'b0}};
assign fme_csr_msix_pba_update.msix_pba.msix_pba     = inp2cr_msix_pba[6:0];
assign fme_csr_msix_count_csr_reset.data             = fme_csr_msix_count_csr_update.data;
assign fme_csr_msix_count_csr_update.msix_count_csr.reserved32                 = {32{1'b0}};
assign fme_csr_msix_count_csr_update.msix_count_csr.afu_2_sync_fifo_msix_count = inp2cr_msix_count_vector[31:24];
assign fme_csr_msix_count_csr_update.msix_count_csr.sync_fifo_2_msix_count     = inp2cr_msix_count_vector[23:16];
assign fme_csr_msix_count_csr_update.msix_count_csr.msix_2_cdc_msix_count      = inp2cr_msix_count_vector[15:8];
assign fme_csr_msix_count_csr_update.msix_count_csr.cdc_2_avl_msix_count       = inp2cr_msix_count_vector[ 7:0];

//----------------------------------------------------------------------------
// Register Output Breakout Structure Overlays/Maps.
//----------------------------------------------------------------------------
assign fme_csr_msix_addr0.data     = csr_reg[MSIX_ADDR0      [12]][MSIX_ADDR0      [7:3]];
assign fme_csr_msix_addr1.data     = csr_reg[MSIX_ADDR1      [12]][MSIX_ADDR1      [7:3]];
assign fme_csr_msix_addr2.data     = csr_reg[MSIX_ADDR2      [12]][MSIX_ADDR2      [7:3]];
assign fme_csr_msix_addr3.data     = csr_reg[MSIX_ADDR3      [12]][MSIX_ADDR3      [7:3]];
assign fme_csr_msix_addr4.data     = csr_reg[MSIX_ADDR4      [12]][MSIX_ADDR4      [7:3]];
assign fme_csr_msix_addr5.data     = csr_reg[MSIX_ADDR5      [12]][MSIX_ADDR5      [7:3]];
assign fme_csr_msix_addr6.data     = csr_reg[MSIX_ADDR6      [12]][MSIX_ADDR6      [7:3]];
assign fme_csr_msix_addr7.data     = csr_reg[MSIX_ADDR7      [12]][MSIX_ADDR7      [7:3]];
assign fme_csr_msix_ctldat0.data   = csr_reg[MSIX_CTLDAT0    [12]][MSIX_CTLDAT0    [7:3]];
assign fme_csr_msix_ctldat1.data   = csr_reg[MSIX_CTLDAT1    [12]][MSIX_CTLDAT1    [7:3]];
assign fme_csr_msix_ctldat2.data   = csr_reg[MSIX_CTLDAT2    [12]][MSIX_CTLDAT2    [7:3]];
assign fme_csr_msix_ctldat3.data   = csr_reg[MSIX_CTLDAT3    [12]][MSIX_CTLDAT3    [7:3]];
assign fme_csr_msix_ctldat4.data   = csr_reg[MSIX_CTLDAT4    [12]][MSIX_CTLDAT4    [7:3]];
assign fme_csr_msix_ctldat5.data   = csr_reg[MSIX_CTLDAT5    [12]][MSIX_CTLDAT5    [7:3]];
assign fme_csr_msix_ctldat6.data   = csr_reg[MSIX_CTLDAT6    [12]][MSIX_CTLDAT6    [7:3]];
assign fme_csr_msix_ctldat7.data   = csr_reg[MSIX_CTLDAT7    [12]][MSIX_CTLDAT7    [7:3]];
assign fme_csr_msix_pba.data       = csr_reg[MSIX_PBA        [12]][MSIX_PBA        [7:3]];

//----------------------------------------------------------------------------
// FME Outputs into the FME Interface for distribution.
//----------------------------------------------------------------------------
assign cr2out_msix_addr0    = fme_csr_msix_addr0.data;
assign cr2out_msix_addr1    = fme_csr_msix_addr1.data;
assign cr2out_msix_addr2    = fme_csr_msix_addr2.data;
assign cr2out_msix_addr3    = fme_csr_msix_addr3.data;
assign cr2out_msix_addr4    = fme_csr_msix_addr4.data;
assign cr2out_msix_addr5    = fme_csr_msix_addr5.data;
assign cr2out_msix_addr6    = fme_csr_msix_addr6.data;
assign cr2out_msix_addr7    = fme_csr_msix_addr7.data;
assign cr2out_msix_ctldat0  = fme_csr_msix_ctldat0.data;
assign cr2out_msix_ctldat1  = fme_csr_msix_ctldat1.data;
assign cr2out_msix_ctldat2  = fme_csr_msix_ctldat2.data;
assign cr2out_msix_ctldat3  = fme_csr_msix_ctldat3.data;
assign cr2out_msix_ctldat4  = fme_csr_msix_ctldat4.data;
assign cr2out_msix_ctldat5  = fme_csr_msix_ctldat5.data;
assign cr2out_msix_ctldat6  = fme_csr_msix_ctldat6.data;
assign cr2out_msix_ctldat7  = fme_csr_msix_ctldat7.data;
assign cr2out_msix_pba      = fme_csr_msix_pba.data;

//----------------------------------------------------------------------------
// HW State is a data struct used to pass the resets, write data, and write
// type to the CSR "update_reg" function.
//----------------------------------------------------------------------------
assign hw_state.reset_n      = rst_n;
assign hw_state.pwr_good_n   = 1'b1;
assign hw_state.wr_data.data = data_reg;
assign hw_state.write_type   = write_type_reg;

//----------------------------------------------------------------------------
// Combinatorial logic to define what type of write is occurring:
//     1.) UPPER32 = Upper 32 bits of register from lower 32 bits of the write
//         data bus.
//     2.) LOWER32 = Lower 32 bits of register from lower 32 bits of the write
//         data bus.
//     3.) FULL64 = All 64 bits of the register from all 64 bits of the write
//         data bus.
//     4.) NONE = No write will be performed on register.
// Logic must be careful to detect simultaneous awvalid and wvalid OR awvalid
// leading wvalid.  A write address with bit #2 set decides whether 32-bit
// write is to upper or lower word.
//----------------------------------------------------------------------------
always_comb
begin
    write_type              =   ( !avmm_m2s_write )         ?   NONE    :
                                ( &avmm_m2s_byteenable )    ?   FULL64  : 
                                ( !avmm_m2s_address[2] )    ?   LOWER32 :
                                                                UPPER32;
end

//----------------------------------------------------------------------------
// Sequential logic to capture some transaction-qualifying signals during
// writes on the write-data bus.  Values are sampled on the transition into
// "DATA" states in the write state machine.
//----------------------------------------------------------------------------
always_ff @ ( posedge clk )
begin
    if ( !rst_n )
    begin
        write_type_reg          <= NONE;
        write_reg               <= 1'b0;
        data_reg                <= {64{1'b0}};
        csr_write               <= '{default:0};
    end
    else
    begin
        write_type_reg                  <= write_type;
        write_reg                       <= avmm_m2s_write;
        data_reg                        <= avmm_m2s_writedata; 
        
        csr_write                       <= '{default:0};
        csr_write
          [ avmm_m2s_address[12] ]
          [ avmm_m2s_address[7:3] ]     <= avmm_m2s_write;
    end
end

//----------------------------------------------------------------------------
// Register Update Logic using "update_reg" function in "ofs_csr_pkg.sv"
// SystemVerilog package.  Function inputs are "named" for ease of
// understanding the use.
//     - Register bit attributes are set in array input above.  Attribute
//       functions are defined in SAS.
//     - Reset Value is appied at reset except for RO, *D, and Rsvd{Z}.
//     - Update Value is used as status bit updates for RO, RW1C*, and RW1S*.
//     - Current Value is used to determine next register value.  This must be
//       done due to scoping rules using SystemVerilog package.
//     - "Write" is the decoded write signal for that particular register.
//     - State is a hardware state structure to pass input signals to
//       "update_reg" function.  See just above.
//----------------------------------------------------------------------------
always_ff @ ( posedge clk )
begin

   csr_reg[MSIX_ADDR0[12]][MSIX_ADDR0[7:3]]     <= update_reg(.attr(msix_addr0_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr0_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr0_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR0[12]][MSIX_ADDR0[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR0[12]][MSIX_ADDR0[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR1[12]][MSIX_ADDR1[7:3]]     <= update_reg(.attr(msix_addr1_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr1_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr1_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR1[12]][MSIX_ADDR1[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR1[12]][MSIX_ADDR1[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR2[12]][MSIX_ADDR2[7:3]]     <= update_reg(.attr(msix_addr2_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr2_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr2_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR2[12]][MSIX_ADDR2[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR2[12]][MSIX_ADDR2[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR3[12]][MSIX_ADDR3[7:3]]     <= update_reg(.attr(msix_addr3_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr3_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr3_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR3[12]][MSIX_ADDR3[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR3[12]][MSIX_ADDR3[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR4[12]][MSIX_ADDR4[7:3]]     <= update_reg(.attr(msix_addr4_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr4_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr4_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR4[12]][MSIX_ADDR4[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR4[12]][MSIX_ADDR4[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR5[12]][MSIX_ADDR5[7:3]]     <= update_reg(.attr(msix_addr5_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr5_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr5_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR5[12]][MSIX_ADDR5[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR5[12]][MSIX_ADDR5[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR6[12]][MSIX_ADDR6[7:3]]     <= update_reg(.attr(msix_addr6_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr6_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr6_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR6[12]][MSIX_ADDR6[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR6[12]][MSIX_ADDR6[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_ADDR7[12]][MSIX_ADDR7[7:3]]     <= update_reg(.attr(msix_addr7_attr.data),
                                                               .reg_reset_val( fme_csr_msix_addr7_reset.data),
                                                               .reg_update_val(fme_csr_msix_addr7_update.data),
                                                               .reg_current_val(csr_reg[MSIX_ADDR7[12]][MSIX_ADDR7[7:3]]),
                                                               .write(        csr_write[MSIX_ADDR7[12]][MSIX_ADDR7[7:3]]),
                                                               .state(hw_state)
                                                               );

   csr_reg[MSIX_CTLDAT0[12]][MSIX_CTLDAT0[7:3]]     <= update_reg(.attr(msix_ctldat0_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat0_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat0_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT0[12]][MSIX_CTLDAT0[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT0[12]][MSIX_CTLDAT0[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT1[12]][MSIX_CTLDAT1[7:3]]     <= update_reg(.attr(msix_ctldat1_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat1_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat1_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT1[12]][MSIX_CTLDAT1[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT1[12]][MSIX_CTLDAT1[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT2[12]][MSIX_CTLDAT2[7:3]]     <= update_reg(.attr(msix_ctldat2_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat2_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat2_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT2[12]][MSIX_CTLDAT2[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT2[12]][MSIX_CTLDAT2[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT3[12]][MSIX_CTLDAT3[7:3]]     <= update_reg(.attr(msix_ctldat3_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat3_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat3_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT3[12]][MSIX_CTLDAT3[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT3[12]][MSIX_CTLDAT3[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT4[12]][MSIX_CTLDAT4[7:3]]     <= update_reg(.attr(msix_ctldat4_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat4_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat4_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT4[12]][MSIX_CTLDAT4[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT4[12]][MSIX_CTLDAT4[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT5[12]][MSIX_CTLDAT5[7:3]]     <= update_reg(.attr(msix_ctldat5_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat5_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat5_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT5[12]][MSIX_CTLDAT5[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT5[12]][MSIX_CTLDAT5[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT6[12]][MSIX_CTLDAT6[7:3]]     <= update_reg(.attr(msix_ctldat6_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat6_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat6_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT6[12]][MSIX_CTLDAT6[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT6[12]][MSIX_CTLDAT6[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_CTLDAT7[12]][MSIX_CTLDAT7[7:3]]     <= update_reg(.attr(msix_ctldat7_attr.data),
                                                                  .reg_reset_val( fme_csr_msix_ctldat7_reset.data),
                                                                  .reg_update_val(fme_csr_msix_ctldat7_update.data),
                                                                  .reg_current_val(csr_reg[MSIX_CTLDAT7[12]][MSIX_CTLDAT7[7:3]]),
                                                                  .write(        csr_write[MSIX_CTLDAT7[12]][MSIX_CTLDAT7[7:3]]),
                                                                  .state(hw_state)
                                                                  );

   csr_reg[MSIX_PBA[12]][MSIX_PBA[7:3]]             <= update_reg(.attr(msix_pba_attr.data),
                                                                 .reg_reset_val( fme_csr_msix_pba_reset.data),
                                                                 .reg_update_val(fme_csr_msix_pba_update.data),
                                                                 .reg_current_val(csr_reg[MSIX_PBA[12]][MSIX_PBA[7:3]]),
                                                                 .write(        csr_write[MSIX_PBA[12]][MSIX_PBA[7:3]]),
                                                                 .state(hw_state)
                                                                 );

   csr_reg[MSIX_COUNT_CSR[12]][MSIX_COUNT_CSR[7:3]] <= update_reg(.attr(msix_count_csr_attr.data),
                                                                 .reg_reset_val( fme_csr_msix_count_csr_reset.data),
                                                                 .reg_update_val(fme_csr_msix_count_csr_update.data),
                                                                 .reg_current_val(csr_reg[MSIX_COUNT_CSR[12]][MSIX_COUNT_CSR[7:3]]),
                                                                 .write(        csr_write[MSIX_COUNT_CSR[12]][MSIX_COUNT_CSR[7:3]]),
                                                                 .state(hw_state)
                                                                 );
end

always_ff @ ( posedge clk )
begin
    avmm_s2m_readdata               <= csr_reg[ avmm_m2s_address[12] ][ avmm_m2s_address[7:3] ];
    avmm_s2m_readdatavalid          <= avmm_m2s_read;
end

always_ff @ ( posedge clk )
begin
    avmm_s2m_waitrequest            <= 1'b0;
    avmm_s2m_writeresponsevalid     <= write_reg;
end

endmodule
