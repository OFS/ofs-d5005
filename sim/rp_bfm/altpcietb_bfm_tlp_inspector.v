// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                           //
//    altpcietb_bfm_tlp_inspector : Extended config space to access TLP Inspector                                             //
//                                                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                           //
//     CSEB Bus Info Overview                                                                                                //
//                                                                                                                           //
//     |-------------------------------------------------------------------------|                                           //
//     |   CSEB address Space                                                    |                                           //
//     |-------------------------------------------------------------------------|                                           //
//     |   PCI/PCIe config space                              | Address value    |                                           //
//     |-------------------------------------------------------------------------|                                           //
//     |  Type0 or Type1 Configuration Registers (PCI Header) | 32'h000-32'h03Ch |                                           //
//     |  Reserved                                            | 32'h040          |                                           //
//     |  Reserved                                            | 32'h044          |                                           //
//     |  Reserved                                            | 32'h048-32'h04Ch |                                           //
//     |  MSI Capability Structure                            | 32'h050-32'h05Ch |                                           //
//     |  Reserved                                            | 32'h060-32'h064h |                                           //
//     |  MSI-X Capability Structure                          | 32'h068-32'h070h |                                           //
//     |  Power Management Capability Structure               | 32'h078-32'h07Ch |                                           //
//     |  PCI Express Capability Structure                    | 32'h080-32'h0BCh |                                           //
//     |  SSID/SSVID Capability Structure                     | 32'h0C0-32'h0C4h |                                           //
//     |  PCI Extensions (CSEB)***                            | 32'h0C8-32'h0FCh |                                           //
//     |  Virtual Channel Capability Structure                | 32'h100-32'h16Ch |                                           //
//     |  Reserved                                            | 32'h170-32'h1FCh |                                           //
//     |  Vendor Specific Extended Capability Structure       | 32'h200-32'h240h |                                           //
//     |  Secondary PciE Extended Capability Structure        | 32'h300-32'h318h |                                           //
//     |  Reserved                                            | 32'h31C-32'h7FCh |                                           //
//     |  AER                                                 | 32'h800-32'h834h |                                           //
//     |  PCI-E Extensions (CSEB)                             | 32'h900-32'hFFFh |                                           //
//     |-------------------------------------------------------------------------|                                           //
//                                                                                                                           //
//     __________________________________________________________________________________________________________________    //
//     |                                                                                                                |    //
//     | PCI Express Extended Capability Header                                                             Offset 8'h0 |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                                |    //
//     | 31                     20 |                  16|                                 0                             |    //
//     | Next Capability Offset    | Capability Version |PCI Express Extended Capability ID                             |    //
//     |                                                                                                                |    //
//     | 15:0  PCI Express Extended Capability ID : This field is a PCI-SIG defined ID number that indicates the nature |    //
//     |                                            and format of the Extended Capability.                              |    //
//     |                                            Extended Capability ID for the Vendor-Specific Capability is 000Bh. |    //
//     |                                            RO                                                                  |    //
//     | 19:16 Capability Version                 : This field is a PCI-SIG defined version number that indicates       |    //
//     |                                            the version of the Capability structure present.                    |    //
//     |                                            Must be 1h for this version of the specification                    |    //
//     | 31:20 Next Capability Offset             : This field contains the offset to the next PCI Express              |    //
//     |                                            Capability structure or 000h if no other items exist in             |    //
//     |                                            the linked list of Capabilities.                                    |    //
//     |                                            For Extended Capabilities implemented in Configuration Space,       |    //
//     |                                            this offset is relative to the beginning of PCI-compatible          |    //
//     |                                            Configuration Space and thus must always be either 000h             |    //
//     |                                            (for terminating list of Capabilities) or greater than 0FFh.        |    //
//     |                                                                                                                |    //
//     |________________________________________________________________________________________________________________|    //
//     |                                                                                                                |    //
//     | Vendor-Specific Header                                                                              Offset 04h |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                                |    //
//     | 31                     20 |                  16|                                 0                             |    //
//     | VSEC Length               | VSEC Rev           |                 VSEC ID                                       |    //
//     |                                                                                                                |    //
//     | 15:0  VSEC ID                            : This field is a vendor-defined ID number that indicates the nature  |    //
//     |                                            and format of the VSEC structure. Software must qualify the Vendor  |    //
//     |                                            ID before interpreting this field.                                  |    //
//     | 19:16 VSEC Rec                           : This field is a vendor-defined ID number that indicates             |    //
//     |                                            the nature and format of theVSEC structure.                         |    //
//     |                                            Software must qualify the Vendor ID before interpreting this field. |    //
//     |                                            This field is a PCI-SIG defined version number that indicates       |    //
//     | 31:20 VSEC Length                        : This field indicates the number of bytes in the entire VSEC         |    //
//     |                                            structure, including the PCI Express Extended Capability header,    |    //
//     |                                            the Vendor- Specific header, and the Vendor-Specific registers      |    //
//     |                                                                                                                |    //
//     |________________________________________________________________________________________________________________|    //
//     |                                                                                                                |    //
//     | Vendor-Specific Register - TLP Inspector Registers                                                             |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 08h |    //
//     | TRIGGER DWORD 1                                                                                   |____________|    //
//     |                                                                                                                |    //
//     | trigger [0]      | SOP         : When 1 trigger on first SOP                                                   |    //
//     |         [1]      | TX/RX       : When 1 trigger on RX AST, When 0 Trigger on TX AST                            |    //
//     |         [2]      | FMT_TLP     : When check trigger FMT_TLP                                                    |    //
//     |         [3]      | TAG         : When check trigger TAG                                                        |    //
//     |         [5:4]    | Address     : When check trigger Address Lower 24 bits                                      |    //
//     |                  |                    5:4 =2'b01, 8-bit addr LSB                                               |    //
//     |                  |                    5:4 =2'b10, 16-bit addr LSB                                              |    //
//     |                  |                    5:4 =2'b11, 32-bit addr LSB                                              |    //
//     |         [6]      | First BE    : When check trigger first BE                                                   |    //
//     |         [7]      | Last BE     : When check trigger last BE                                                    |    //
//     |         [8]      | Attr        : When check trigger Attr                                                       |    //
//     |         [9]      | Reset trigger only                                                                          |    //
//     |         [10]     | Reset reset Inspector                                                                       |    //
//     |         [11]     | Enable Trigger ON  : When set activate trigger logic                                        |    //
//     |         [12   ]  | Use CSEB trigger                                                                            |    //
//     |         [31:13]  | RESERVED                                                                                    |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 0Ch |    //
//     | TRIGGER DWORD 2                                                                                   |____________|    //
//     |                                                                                                                |    //
//     |         [ 7: 0]  |  [39:32]  | FMT TYPE: When trigger[2] set, trigger on                                       |    //
//     |                  |           |    _______________________________                                              |    //
//     |                  |           |    |                    |        |                                              |    //
//     |                  |           |    |  {FMT,TYPE}        |        |                                              |    //
//     |                  |           |    |____________________|________|                                              |    //
//     |                  |           |    | 8'b0000_0000       | MRd    |                                              |    //
//     |                  |           |    | 8'b0010_0000       | MRd    |                                              |    //
//     |                  |           |    | 8'b0000_0001       | MRdLk  |                                              |    //
//     |                  |           |    | 8'b0010_0001       | MRdLk  |                                              |    //
//     |                  |           |    | 8'b0100_0000       | MWr    |                                              |    //
//     |                  |           |    | 8'b0110_0000       | MWr    |                                              |    //
//     |                  |           |    | 8'b0000_0010       | IORd   |                                              |    //
//     |                  |           |    | 8'b0100_0010       | IOWr   |                                              |    //
//     |                  |           |    | 8'b0000_0100       | CfgRd0 |                                              |    //
//     |                  |           |    | 8'b0100_0100       | CfgWr0 |                                              |    //
//     |                  |           |    | 8'b0000_0101       | CfgRd1 |                                              |    //
//     |                  |           |    | 8'b0100_0101       | CfgWr1 |                                              |    //
//     |                  |           |    | 8'b0011_0XXX       | Msg    |                                              |    //
//     |                  |           |    | 8'b0111_0XXX       | MsgD   |                                              |    //
//     |                  |           |    | 8'b0000_1010       | Cpl    |                                              |    //
//     |                  |           |    | 8'b0100_1010       | CplD   |                                              |    //
//     |                  |           |    | 8'b0000_1011       | CplLk  |                                              |    //
//     |                  |           |    | 8'b0100_1011       | CplDLk |                                              |    //
//     |                  |           |    |_____________________________|                                              |    //
//     |                  |           |                                                                                 |    //
//     |                  |           |                                                                                 |    //
//     |         [15: 8]  |  [47:40]  | TAG : When trigger[3] set, trigger on TAG value                                 |    //
//     |         [19:16]  |  [51:48]  | First BE : When trigger[6] set, trigger on Last BE                              |    //
//     |         [23:20]  |  [55:52]  | Last BE : When trigger[7] set, trigger on Last BE                               |    //
//     |         [31:24]  |  [63:55]  | RESERVED                                                                        |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 10h |    //
//     | TRIGGER DWORD 3                                                                                   |____________|    //
//     |                                                                                                                |    //
//     |         [31:0]  |   [95:64]  | when trigger[5:4]>0 32 bit lower address trigger                                |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 14h |    //
//     | TRIGGER DWORD 4                                                                                   |____________|    //
//     |                                                                                                                |    //
//     |         [0]     | [96]     | When unset no stop trigger                                                        |    //
//     |         [1]     | [97]     | TX/RX       : When 1 stop-trigger on RX AST, When 0 Trigger on TX AST             |    //
//     |         [2]     | [98]     | FMT_TLP     : When check stop-trigger FMT_TLP                                     |    //
//     |         [3]     | [99]     | TAG         : When check stop-trigger TAG                                         |    //
//     |         [5:4]   | [101:100]| Address     : When check stop-trigger Address Lower 24 bits                       |    //
//     |                 |          |                    [101:100] =2'b01, 8-bit addr LSB                               |    //
//     |                 |          |                    [101:100] =2'b10, 16-bit addr LSB                              |    //
//     |                 |          |                    [101:100] =2'b11, 32-bit addr LSB                              |    //
//     |         [13:6]  | [109:102]| FMT TYPE: When stop-trigger[98] set,                                              |    //
//     |         [21:14] | [117:110]| TAG : When stop-trigger[99]                                                       |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 18h |    //
//     |                                                                                                   |____________|    //
//     | INSP_ADDRREADY_SOP_RX          {ast_cnt_rx_ready, ast_cnt_rx_sop}                                              |    //
//     | 31                                           16|                                 0                             |    //
//     | Number of times rx_ready de-assert on rx_valid | Number of of RX SOP                                           |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 1Ch |    //
//     | INSP_ADDRREADY_SOP_TX          {ast_cnt_tx_ready, ast_cnt_tx_sop}                                 |___________ |    //
//     | 31                                           16|                                 0                             |    //
//     | Number of times tx_ready de-assert on tx_valid | Number of of TX SOP                                           |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 20h |    //
//     | INSP_ADDRLATENCY_MRD_UPSTREAM  {PLD_CLK_IS_250MHZ,ast_max_read_latency, ast_min_read_latency}     |____________|    //
//     | 31                     30 |                  15|                                 0                             |    //
//     | When 1 pld clk is 250 MHz | Max read upstream  |  Min read upstream latency                                    |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 24h |    //
//     | INSP_ADDRMWR_THROUGHPUT_CLK    {PLD_CLK_IS_250MHZ,10'h0,ast_cnt_mwr_clk}                          |____________|    //
//     | 31                     30 |                  20|                                 0                             |    //
//     | When 1 pld clk is 250 MHz | RESERVED           |  Number of clock cycles for MWr upstream transfer             |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 28h |    //
//     | INSP_ADDRMWR_THROUGHPUT_DWORD  {12'h0                                   ,ast_cnt_mwr_dword}       |____________|    //
//     | 31                                           20|                                 0                             |    //
//     |                             RESERVED           |  Number of DWORD  MWr upstream transfer                       |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 2Ch |    //
//     | INSP_ADDRMRD_THROUGHPUT_CLK    {(PLD_CLK_IS_250MHZ==1)?2'b01:2'b00,10'h0,ast_cnt_mrd_clk}         |____________|    //
//     | 31                     30 |                  20|                                 0                             |    //
//     | When 1 pld clk is 250 MHz | RESERVED           |  Number of clock cycles for MRd upstream transfer             |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 30h |    //
//     | INSP_ADDRMRD_THROUGHPUT_DWORD  {12'h0                                   ,ast_cnt_mrd_dword}       |____________|    //
//     | 31                                           20|                                 0                             |    //
//     |                             RESERVED           |  Number of DWORD  MRd upstream transfer                       |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 34h |    //
//     | LTSSM  BLACK BOX Recording Retrieval                                                              |____________|    //
//     |                                                                                                                |    //
//     | [4:0] : LTSSM Transition                                                                                       |    //
//     | [5]   : perstn|npor                                                                                            |    //
//     | [13:6]: Is lock to data                                                                                        |    //
//     | [14]  : signaldetect                                                                                           |    //
//     | [16:15]: rate 1->G1, 2 -->G2, 3:G3                                                                             |    //
//     | [18:17]: Lanes : 0 ->x1, 0 ->x2, 0 ->x4,  0 ->x8,                                                              |    //
//     | [19   ]: RESERVED                                                                                              |    //
//     | [27:20]: Number of word in the black box                                                                       |    //
//     | [31:28]: RESERVED                                                                                              |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 38h |    //
//     | TLP BLACK BOX Recording Retrieval                                                                 |____________|    //
//     |                                                                                                                |    //
//     | Pop FIFO                                                                                                       |    //
//     | [0] RX Tlp when 1 else TX TLP                                                                                  |    //
//     | [8:1] TLP CNT                                                                                                  |    //
//     | [21:10] RESERVED                                                                                               |    //
//     | [26:22] fifo_used                                                                                              |    //
//     | [27]    fifo_empty                                                                                             |    //
//     | [28]    fifo_full                                                                                              |    //
//     | [31:29] RESERVED                                                                                               |    //
//     |                                                                                                                |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 3Ch |    //
//     | Retrieve H1 TLP                                                                                   |____________|    //
//     | [31:0] Header 1 TLP                                                                                            |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 40h |    //
//     | Retrieve H2 TLP                                                                                   |____________|    //
//     | [31:0] Header 2 TLP                                                                                            |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                   | Offset 44h |    //
//     | Retrieve H3 TLP                                                                                   |____________|    //
//     | [31:0] Header 3 TLP                                                                                            |    //
//     | _______________________________________________________________________________________________________________|    //
//     |                                                                                                                |    //
//     | RESERVED                       RESERVED                                                                        |    //
//     |                                                                                                                |    //
//     | _______________________________________________________________________________________________________________|    //
//                                                                                                                           //
//                                                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//


   //
   // DisplayTLP returns a string of the transaction layer packet layer type
   //
   function [64*8:1] DisplayTLP ;
      input  [31:0] h1 ;
      input  [31:0] h2 ;
      input  [31:0] h3 ;
      input         rx ;
      //input  [31:0] h4 ;
      reg    [7*8:1] tlp_type;
      reg    [8*5:1] tag;
      begin
         casex (h1[31:24])
            8'b0000_0000 : begin
                              tlp_type = "MRd"   ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0010_0000 : begin
                              tlp_type = "MRd"   ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0000_0001 : begin
                              tlp_type = "MRdLk" ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0010_0001 : begin
                              tlp_type = "MRdLk" ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0100_0000 : begin
                              tlp_type = "MWr"   ;
                              tag      = "     ";
                           end
            8'b0110_0000 : begin
                              tlp_type = "MWr"   ;
                              tag      = "     ";
                           end
            8'b0000_0010 : begin
                              tlp_type = "IORd"  ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0100_0010 : begin
                              tlp_type = "IOWr"  ;
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0000_0100 : begin
                              tlp_type = "CfgRd0";
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0100_0100 : begin
                              tlp_type = "CfgWr0";
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0000_0101 : begin
                              tlp_type = "CfgRd1";
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0100_0101 : begin
                              tlp_type = "CfgWr1";
                              tag      = {" (",dimage2(h2[15:8]),")"};
                           end
            8'b0011_0XXX : begin
                              tlp_type = "Msg"   ; //TODO Complete all Msg Cases
                              tag      = "     ";
                           end
            8'b0111_0XXX : begin
                              tlp_type = "MsgD"  ;
                              tag      = "     "   ;
                           end
            8'b0000_1010 : begin
                              tlp_type = "Cpl"   ;
                              tag      = {" (",dimage2(h3[15:8]),")"};
                           end
            8'b0100_1010 : begin
                              tlp_type = "CplD"  ;
                              tag      = {" (",dimage2(h3[15:8]),")"};
                           end
            8'b0000_1011 : begin
                              tlp_type = "CplLk" ;
                              tag      = {" (",dimage2(h3[15:8]),")"};
                           end
            8'b0100_1011 : begin
                              tlp_type = "CplDLk";
                              tag      = {" (",dimage2(h3[15:8]),")"};
                           end
            default      : begin
                              tlp_type = "TDB"  ;
                              tag      = "     ";
                           end
         endcase
         DisplayTLP={ tlp_type, tag, " | ", dimage4({h1[9:0],2'b00}) , "    | ", himage8(h1), "_", himage8(h2),  "_", himage8(h3)};
      end
   endfunction

   //
   // DisplayLTSSM returns a string of the LTSSM state
   //
   function [23*8:1] DisplayLTSSM ;
      input [4:0] ltssm;
      reg[(23)*8:1] ltssm_str;
      begin
         case (ltssm)
            5'b00000: ltssm_str = "DETECT.QUIET           ";
            5'b00001: ltssm_str = "DETECT.ACTIVE          ";
            5'b00010: ltssm_str = "POLLING.ACTIVE         ";
            5'b00011: ltssm_str = "POLLING.COMPLIANCE     ";
            5'b00100: ltssm_str = "POLLING.CONFIG         ";
            5'b00110: ltssm_str = "CONFIG.LINKWIDTH.START ";
            5'b00111: ltssm_str = "CONFIG.LINKWIDTH.ACCEPT";
            5'b01000: ltssm_str = "CONFIG.LANENUM.ACCEPT  ";
            5'b01001: ltssm_str = "CONFIG.LANENUM.WAIT    ";
            5'b01010: ltssm_str = "CONFIG.COMPLETE        ";
            5'b01011: ltssm_str = "CONFIG.IDLE            ";
            5'b01100: ltssm_str = "RECOVERY.RCVRLOCK      ";
            5'b01101: ltssm_str = "RECOVERY.RCVRCFG       ";
            5'b01110: ltssm_str = "RECOVERY.IDLE          ";
            5'b01111: ltssm_str = "L0                     ";
            5'b10000: ltssm_str = "DISABLE                ";
            5'b10001: ltssm_str = "LOOPBACK.ENTRY         ";
            5'b10010: ltssm_str = "LOOPBACK.ACTIVE        ";
            5'b10011: ltssm_str = "LOOPBACK.EXIT          ";
            5'b10100: ltssm_str = "HOT RESET              ";
            5'b10101: ltssm_str = "L0s                    ";
            5'b10110: ltssm_str = "L1.ENTRY               ";
            5'b10111: ltssm_str = "L1.IDLE                ";
            5'b11000: ltssm_str = "L2.IDLE                ";
            5'b11001: ltssm_str = "L2.TRANSMITWAKE        ";
            5'b11010: ltssm_str = "RECOVERY.SPEED         ";
            5'b11011: ltssm_str = "REC_EQULZ.PHASE0       ";
            5'b11100: ltssm_str = "REC_EQULZ.PHASE1       ";
            5'b11101: ltssm_str = "REC_EQULZ.PHASE2       ";
            5'b11110: ltssm_str = "REC_EQULZ.PHASE3       ";
            5'b11111: ltssm_str = "REC_EQULZ.DONE         ";
            default: ltssm_str =  "UNKNOWN                ";
         endcase
         DisplayLTSSM=ltssm_str;
      end
endfunction


task inspector_config_space_a10(
   input integer SANDBOX_RPMEM
   ) ;
   reg  [31:0] dword;
   reg  [2:0]  compl_status;
   reg  unused_result ;
   reg  [15:0] addr;
   reg  pld_clk_is_250MHz;
   reg  [19:0] nclk;
   reg  [19:0] ndword;
   reg  [31:0] nbytes;
   reg  [31:0] ellapse_timens;
   reg  [31:0] throughputMBps;
   reg  [7:0]  ltssmfifo_used;
   reg  empty;
   reg  full;
   reg  ast_rx;
   reg  [31:0] tlp_h1;
   reg  [31:0] tlp_h2;
   reg  [31:0] tlp_h3;
   reg  inspector_enabled;

   localparam [15:0] MAXTIMOUT=16'hFFFF_FFFF_FFFF_FF00;
   reg [15:0] timout_cnt;
   begin
         // Check if PCIe Inspector is enabled
         inspector_enabled = 1'b0;
         addr              = 16'h900;
         ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
         dword             = shmem_read(SANDBOX_RPMEM,4) ;
         if (dword[15:0]>16'h0) begin
            addr = 16'h904;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            if (dword[15:0] ==16'hFACE) begin
               inspector_enabled = 1'b1;
            end
         end

         timout_cnt = 16'h0;

         if (inspector_enabled==1'b1) begin

            addr = 16'h900;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;

            $display("___________________________________________________________________________________________________________________________________");
            $display("|                                                                                                                 |                ");
            $display("| PCI Express Extended Capability Header                                                             Offset 8'h0  |    0x%s        ", himage4(addr));
            $display("| ________________________________________________________________________________________________________________|________________");
            $display("|                                                                                                                 |                ");
            $display("| 31                     20 |                  16|                                 0                              |                ");
            $display("| Next Capability Offset    | Capability Version |PCI Express Extended Capability ID                              |                ");
            $display("|                                                                                                                 |                ");
            $display("| 15:0  PCI Express Extended Capability ID : This field is a PCI-SIG defined ID number that indicates the nature  |    0x%s        ", himage4(dword[15:0]));
            $display("|                                            and format of the Extended Capability.                               |                ");
            $display("|                                            Extended Capability ID for the Vendor-Specific Capability is 000Bh.  |                ");
            $display("|                                            RO                                                                   |                ");
            $display("| 19:16 Capability Version                 : This field is a PCI-SIG defined version number that indicates        |    0x%s        ", himage4(dword[19:16]));
            $display("|                                            the version of the Capability structure present.                     |                ");
            $display("|                                            Must be 1h for this version of the specification                     |                ");
            $display("| 31:20 Next Capability Offset             : This field contains the offset to the next PCI Express               |    0x%s        ", himage4(dword[31:20]));
            $display("|                                            Capability structure or 000h if no other items exist in              |                ");
            $display("|                                            the linked list of Capabilities.                                     |                ");
            $display("|                                            For Extended Capabilities implemented in Configuration Space,        |                ");
            $display("|                                            this offset is relative to the beginning of PCI-compatible           |                ");
            $display("|                                            Configuration Space and thus must always be either 000h              |                ");
            $display("|                                            (for terminating list of Capabilities) or greater than 0FFh.         |                ");

            addr = 16'h904;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("|_________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                                 |                 ");
            $display("| Vendor-Specific Header                                                                              Offset 04h  |    0x%s          ", himage4(addr));
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                                 |                 ");
            $display("| 31                     20 |                  16|                                 0                              |                 ");
            $display("| VSEC Length               | VSEC Rev           |                 VSEC ID                                        |                 ");
            $display("|                                                                                                                 |                 ");
            $display("| 15:0  VSEC ID                            : This field is a vendor-defined ID number that indicates the nature   |    0x%s         ", himage4(dword[15:0]));
            $display("|                                            and format of the VSEC structure. Software must qualify the Vendor   |                 ");
            $display("|                                            ID before interpreting this field.                                   |                 ");
            $display("| 19:16 VSEC Rec                           : This field is a vendor-defined ID number that indicates              |    0x%s         ", himage4(dword[19:16]));
            $display("|                                            the nature and format of theVSEC structure.                          |                 ");
            $display("|                                            Software must qualify the Vendor ID before interpreting this field.  |                 ");
            $display("|                                            This field is a PCI-SIG defined version number that indicates        |                 ");
            $display("| 31:20 VSEC Length                        : This field indicates the number of bytes in the entire VSEC          |     %s          ", dimage4(dword[31:20]));
            $display("|                                            structure, including the PCI Express Extended Capability header,     |                 ");
            $display("|                                            the Vendor- Specific header, and the Vendor-Specific registers       |                 ");
            $display("|                                                                                                                 |                 ");

            addr = 16'h918;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 18h  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("|                                                                                                                 |                 ");
            $display("| [15:0]  Number of of RX SOP                                                                                     |     %s          ", dimage4(dword[15:0]));
            $display("| [31:16] Number of times that HIP Avalon-St rx_ready de-assert when rx_valid is set                              |     %s          ", dimage4(dword[31:16]));

            addr = 16'h91C;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 1Ch  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("| [15:0]  Number of of TX SOP                                                                                     |     %s          ", dimage4(dword[15:0]));
            $display("| [31:16] Number of times that HIP Avalon St tx_ready de-assert when tx_valid is set                              |     %s          ", dimage4(dword[31:16]));

            addr = 16'h920;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 20h  |    0x%s          ", himage4(addr));
            $display("|  Upstream read to completion latency                                                              |_____________|_________________");
            $display("| pld clk is :                                                                                                    |     %d MHz      ", (dword[31:30]>2'b00)?250:125);
            $display("| [14:0]   Min Mrd to Cpl  upstream latency : number of clock cycles                                              |     %s          ", dimage4(dword[14:0]));
            $display("| [29:15]  Max Mrd to Cpl  upstream latency : number of clock cycles                                              |     %s          ", dimage4(dword[29:15]));

            pld_clk_is_250MHz = (dword[31:30]>2'b00)?1:0;

            addr = 16'h924;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 24h  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("| [19:0] Number of clock cycles for MWr upstream transfer                                                         |     %s          ", dimage4(dword[19:0]));
            nclk = dword[19:0];

            addr = 16'h928;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 28h  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("| [19:0]  Number of DWORD  MWr upstream transfer                                                                  |      %s          ", dimage4(dword[19:0]));
            $display("|                                                                                                                 |                  ");
            ndword = dword[19:0];

            ellapse_timens = (pld_clk_is_250MHz==1'b1)?nclk*4:nclk*8;
            nbytes         = ndword*4;
            throughputMBps = (nclk>0)? (nbytes*1000)  / ellapse_timens :0;
            $display("|                                                                                                                 |                  ");
            $display("| Write throughput                                                                                                |      %s MBps     ", dimage4(throughputMBps));
            $display("|                                                                                                                 |                  ");

            addr = 16'h92C;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 2Ch  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("| [19:0]  Number of  clock cycles for MRd upstream transfer                                                       |      %s          ", dimage4(dword[19:0]));
            $display("|                                                                                                                 |                  ");
            nclk = dword[19:0];

            addr = 16'h930;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 30h  |    0x%s          ", himage4(addr));
            $display("|                                                                                                   |_____________|_________________");
            $display("| [19:0]  Number of DWORD  MRd upstream transfer                                                                  |     %s          ", dimage4(dword[19:0]));
            $display("|                                                                                                                 |                  ");
            ndword = dword[19:0];

            ellapse_timens = (pld_clk_is_250MHz==1'b1)?nclk*4:nclk*8;
            nbytes         = ndword*4;
            throughputMBps = (nclk>0)? (nbytes*1000)  / ellapse_timens :0;
            $display("|                                                                                                                 |                  ");
            $display("| Read throughput                                                                                                 |      %s MBps     ", dimage4(throughputMBps));
            $display("|                                                                                                                 |                  ");

            addr = 16'h934;
            ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
            dword = shmem_read(SANDBOX_RPMEM,4) ;
            nclk  = (dword[18:17]==2'b00)?32'h1:
                    (dword[18:17]==2'b01)?32'h2:
                    (dword[18:17]==2'b10)?32'h4:32'h8;
            $display("| ________________________________________________________________________________________________________________|_________________");
            $display("|                                                                                                   | Offset 34h  |   0x%s          ", himage4(addr));
            $display("| LTSSM  BLACK BOX Recording Retrieval                                                              |_____________|_________________");
            $display("|                                                                                                                 |                 ");
            $display("| [4:0] : LTSSM Transition                                                                                        |   0x%s         ", himage4(dword[4:0]));
            $display("| [5]   : perstn|npor                                                                                             |     %s         ", dimage4(dword[5]));
            $display("| [13:6]: Is lock to data                                                                                         |   0x%s         ", himage4(dword[13:6]));
            $display("| [14]  : signaldetect                                                                                            |     %s         ", (dword[16:15]==2'b11)?"8.0Gb":(dword[16:15]==2'b10)?"5.0Gb":"2.5Gb");
            $display("| [16:15]: rate 1->G1, 2 -->G2, 3:G3                                                                              |     %s         ", dimage4(dword[16:15]));
            $display("| [18:17]: Number of lanes                                                                                        |     %s         ", dimage4(nclk[7:0]));
            $display("| [19   ]: RESERVED                                                                                               |                ");
            $display("| [27:20]: Number of word in the black box                                                                        |     %s         ", dimage4(dword[27:20]));
            $display("| [31:28]: RESERVED                                                                                               |                ");
            $display("|                                                                                                                 |                ");
            nbytes=0;
            nbytes[7:0]=dword[27:20];
            if (nbytes>0) begin
               $display("| --------------------------------------------------------------------------------------------------------------- |                ");
               $display("|                                                                                                                 |                ");
               $display("| LTSSM[4:0]                     |  Perstn  | Locktodata[7:0]  | Signaldetect   |  rate    | lane                 |");
               $display("|                                |          |                  |                |          |                      |");
               timout_cnt=16'h0;
               while ((nbytes > 0) && (timout_cnt<MAXTIMOUT)) begin
                  addr = 16'h934;
                  if (timout_cnt<MAXTIMOUT) begin
                     timout_cnt=timout_cnt+16'h1;
                  end
                  ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
                  dword = shmem_read(SANDBOX_RPMEM,4) ;
                  nclk  = (dword[18:17]==2'b00)?32'h1:
                          (dword[18:17]==2'b01)?32'h2:
                          (dword[18:17]==2'b10)?32'h4: 32'h8;
               $display("| %s  %s  |    %s  | %s             | %s           |  %s   | %s                 |", himage4(dword[4:0]),
                                                                                                             DisplayLTSSM(dword[4:0]),
                                                                                                             dimage4(dword[5]),
                                                                                                             himage4(dword[13:6]),
                                                                                                             dimage4(dword[14]),
                                                                                                             (dword[16:15]==2'b11)?"8.0Gb":
                                                                                                             (dword[16:15]==2'b10)?"5.0Gb":"2.5Gb",
                                                                                                             dimage4(nclk[7:0]  ));
                  nbytes=0;
                  nbytes[7:0]=dword[27:20];
               end
            end
            $display("|                                                                                                                 |                ");
            $display("| ________________________________________________________________________________________________________________|                ");
            addr = 16'h938;
            $display("|                                                                                                   | Offset 38h  |   0x%s          ", himage4(addr));
            $display("| TLP Dump                                                                                          |_____________|_________________");
            $display("|                                                                                                                 |                 ");
            $display("|     |  TLP Type (Tag)           |  Bytes  | H1_H2_H3                                                            |             ");
            empty=0;
            full=0;
            ast_rx=0;
            timout_cnt=16'h0;
            while ((empty == 0) && (timout_cnt<MAXTIMOUT)) begin
               addr = 16'h938;
               if (timout_cnt<MAXTIMOUT) begin
                  timout_cnt=timout_cnt+16'h1;
               end
               ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
               dword = shmem_read(SANDBOX_RPMEM,4) ;
               empty = dword[31];
               ast_rx = dword[0];
               addr = 16'h93C;
               ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
               tlp_h1 = shmem_read(SANDBOX_RPMEM,4) ;
               addr = 16'h940;
               ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
               tlp_h2 = shmem_read(SANDBOX_RPMEM,4) ;
               addr = 16'h944;
               ebfm_cfgrd_wait(  1, 1, 0, addr, 4, SANDBOX_RPMEM, compl_status);
               tlp_h3 = shmem_read(SANDBOX_RPMEM,4) ;
            $display("|  %s %s                                          |   0x%s             ", (ast_rx==1'b0)?"TX |":"RX |",DisplayTLP(tlp_h1, tlp_h2,tlp_h3, ast_rx), himage8(dword) );

            end
            $display("|                                                                                                                 |                ");
            $display("| ________________________________________________________________________________________________________________|                ");
      end
   end
endtask
