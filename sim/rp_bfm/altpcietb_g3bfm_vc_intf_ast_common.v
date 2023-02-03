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



//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port VC Interface Common Tasks
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf_ast_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This file contains tasks common to the 64 and 128 bit Avalon-ST vc_intf files:
// altpcietb_bfm_vc_intf_64.v and altpcietb_bfm_vc_intf_128.v
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------


   function [0:0] is_request;
      input[135:0] rx_desc;

      reg dummy ;

      begin
         case (rx_desc[124:120])
            5'b00000 :
                     begin
                        is_request = 1'b1; // Memory Read or Write
                     end
            5'b00010 :
                     begin
                        is_request = 1'b1; // I/O Read or Write
                     end
            5'b01010 :
                     begin
                        is_request = 1'b0; // Completion
                     end
            default :
                     begin
                        // "00001" Memory Read Locked
                        // "00100" Config Type 0 Read or Write
                        // "00101" Config Type 1 Read or Write
                        // "10rrr" Message (w/Data)
                        // "01011" Completion Locked
                        dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                     {"Root Port VC", dimage1(VC_NUM),
                                      " Recevied unsupported TLP, Fmt/Type: ", himage2(rx_desc[127:120])});
                        is_request = 1'b0;
                     end
         endcase
      end
   endfunction

   function [0:0] is_3dw_nonaligned;
      input[127:0] desc;

      begin
         is_3dw_nonaligned = (desc[125]==1'b0) && (desc[34]==1'b1);

      end
   endfunction

   function [0:0] is_non_posted;
      input[127:0] desc;

      begin
         case (desc[124:120])
            5'b00000 :
                     begin
                        // Memory Read or Write
                        if ((desc[126]) == 1'b0)
                        begin
                           // No Data, Must be non-posted read
                           is_non_posted = 1'b1;
                        end
                        else
                        begin
                           is_non_posted = 1'b0;
                        end
                     end
            5'b00100 :
                     begin
                        is_non_posted = 1'b1; // Config Type 0 Read or Write
                     end
            5'b00101 :
                     begin
                        is_non_posted = 1'b1; // Config Type 1 Read or Write
                     end
            5'b00010 :
                     begin
                        is_non_posted = 1'b1; // I/O Read or Write
                     end
            5'b01010 :
                     begin
                        is_non_posted = 1'b0; // Completion
                     end
            default :
                     begin
                        // "00001" Memory Read Locked
                        // "10rrr" Message (w/Data)
                        // "01011" Completion Locked
                        is_non_posted = 1'b0;
                     end
         endcase
      end
   endfunction

   function [0:0] has_data;
      input[127:0] desc;

      begin
         if ((desc[126]) == 1'b1)
         begin
            has_data = 1'b1;
         end
         else
         begin
            has_data = 1'b0;
         end
      end
   endfunction

   function integer calc_byte_count;
      input[127:0] desc;

      integer bcount;

      begin
         // Number of DWords * 4 gives bytes
         bcount = desc[105:96] * 4;
         if (bcount > 4)
         begin
            if ((desc[71]) == 1'b0)
            begin
               bcount = bcount - 1;
               if ((desc[70]) == 1'b0)
               begin
                  bcount = bcount - 1;
                  // If more than 1 DW
                  if ((desc[69]) == 1'b0)
                  begin
                     bcount = bcount - 1;
                     // Adjust if the last Dword is not full
                     if ((desc[68]) == 1'b0)
                     begin
                        // Handle the case of no bytes in last DW
                        bcount = bcount - 1;
                     end
                  end
               end
            end
            if ((desc[64]) == 1'b0)
            begin
               bcount = bcount - 1;
               if ((desc[65]) == 1'b0)
               begin
                  bcount = bcount - 1;
                  if ((desc[66]) == 1'b0)
                  begin
                     bcount = bcount - 1;
                     // Now adjust if the first Dword is not full
                     if ((desc[67]) == 1'b0)
                     begin
                        // Handle the case of no bytes in first DW
                        bcount = bcount - 1;
                     end
                  end
               end
            end
         end
         else
         begin
            // Only one DW, need to adjust based on
            // First Byte Enables could be any subset
            if ((desc[64]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[65]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[66]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
            if ((desc[67]) == 1'b0)
            begin
               bcount = bcount - 1;
            end
         end
         calc_byte_count = bcount;
      end
   endfunction

   function [7:0] calc_first_byte_enb;
      input[127:0] desc;

      reg[7:0] byte_enb;

      begin
         // calc_first_byte_enb
         if ((((desc[125]) == 1'b1) & ((desc[2]) == 1'b1)) | (((desc[125]) == 1'b0) & ((desc[34]) == 1'b1)))
         begin
            byte_enb = {desc[67:64], 4'b0000};
         end
         else
         begin
            byte_enb = {4'b1111, desc[67:64]};
         end
         calc_first_byte_enb = byte_enb;
      end
   endfunction

   function integer calc_lcl_addr;
      input[135:0] rx_desc;

      reg[63:0] req_addr;

      begin
         // We just use the lower bits of the address to for the memory address
         if ((rx_desc[125]) == 1'b1)
         begin
            // 4 DW Header
            req_addr[63:2] = rx_desc[63:2];
         end
         else
         begin
            // 3 DW Header
            req_addr[31:2] = rx_desc[63:34];
         end
         if ((rx_desc[64]) == 1'b1)
         begin
            req_addr[1:0] = 2'b00;
         end
         else
         begin
            if ((rx_desc[65]) == 1'b1)
            begin
               req_addr[1:0] = 2'b01;
            end
            else
            begin
               // Calculate Byte Address from Byte Enables
               if ((rx_desc[66]) == 1'b1)
               begin
                  req_addr[1:0] = 2'b10;
               end
               else
               begin
                  // Last Byte should be enabled (or we are not accessing anything so
                  // it is a don't care)
                  req_addr[1:0] = 2'b11;
               end
            end
         end
         calc_lcl_addr = req_addr[SHMEM_ADDR_WIDTH - 1:0];
      end
   endfunction

   task rx_write_req_setup;
      input[135:0] rx_desc;
      output addr;
      integer addr;
      output[7:0] byte_enb;
      output bcount;
      integer bcount;

      begin
         addr = calc_lcl_addr(rx_desc);
         byte_enb = calc_first_byte_enb(rx_desc[127:0]);
         bcount = calc_byte_count(rx_desc[127:0]);
      end
   endtask

   task rx_compl_setup;
      input[135:0] rx_desc;
      output base_addr;
      integer base_addr;
      output[7:0] byte_enb;
      output bcount;
      integer bcount;
      output tag;
      integer tag;
      output[2:0] status;

      integer tagi;
      integer bcounti;

      begin
         // lcl_compl_addr
         tagi = rx_desc[47:40];
         if ((rx_desc[126]) == 1'b1)
         begin
            base_addr = vc_intf_get_lcl_addr(tagi);
         end
         else
         begin
            base_addr = 2 ** SHMEM_ADDR_WIDTH;
         end
         tag = tagi;
         // Calculate the byte-count from Length field
         bcounti = rx_desc[105:96] * 4;
         // Calculate the byte-enables from the Lower Address field
         // Also modify the byte count
         case (rx_desc[34:32])
            3'b111 :
                     begin
                        byte_enb = 8'b10000000;
                        bcounti = bcounti - 3;
                     end
            3'b110 :
                     begin
                        byte_enb = 8'b11000000;
                        bcounti = bcounti - 2;
                     end
            3'b101 :
                     begin
                        byte_enb = 8'b11100000;
                        bcounti = bcounti - 1;
                     end
            3'b100 :
                     begin
                        byte_enb = 8'b11110000;
                        bcounti = bcounti - 0;
                     end
            3'b011 :
                     begin
                        byte_enb = 8'b11111000;
                        bcounti = bcounti - 3;
                     end
            3'b010 :
                     begin
                        byte_enb = 8'b11111100;
                        bcounti = bcounti - 2;
                     end
            3'b001 :
                     begin
                        byte_enb = 8'b11111110;
                        bcounti = bcounti - 1;
                     end
            default :
                     begin
                        byte_enb = {8{1'b1}};
                        bcounti = bcounti - 0;
                     end
         endcase
         // Now if the remaining byte-count from the header is less than that
         // calculated above, that means there are some last data phase
         // byte enables that are not on, update bcounti to reflect that
         if (rx_desc[75:64] < bcounti)
         begin
            bcounti = rx_desc[75:64];
         end
         bcount = bcounti;
         status = rx_desc[79:77];
      end
   endtask


   // Setup the Completion Info for the received request
   task rx_nonp_req_setup_compl;
      input[135:0] rx_desc;
      output[127:0] rx_tx_desc;
      output rx_tx_shmem_addr;
      integer rx_tx_shmem_addr;
      output[7:0] rx_tx_byte_enb;
      output rx_tx_bcount;
      integer rx_tx_bcount;

      integer temp_bcount;
      integer temp_shmem_addr;

      logic [9:0] rx_len;
      logic [7:0] rx_byte_enb;
      logic       hdr_3dw;
      logic       zero_length_read;

      begin
         rx_len      = rx_desc[105:96];
         rx_byte_enb = rx_desc[71:64];
         hdr_3dw = ~rx_desc[125];

         zero_length_read = (rx_len == 10'h1) && (rx_byte_enb == 8'h0);

         if (zero_length_read) 
         begin
            temp_bcount = 4;
            temp_shmem_addr = hdr_3dw ? rx_desc[63:32] : rx_desc[63:0]; 
            rx_tx_byte_enb = 8'h0;
            rx_tx_bcount = 4'd4;
         end 
         else begin
            temp_bcount = calc_byte_count(rx_desc[127:0]);
            temp_shmem_addr = calc_lcl_addr(rx_desc[135:0]);
            rx_tx_byte_enb = calc_first_byte_enb(rx_desc[127:0]);
            rx_tx_bcount = temp_bcount;
         end

         rx_tx_shmem_addr = temp_shmem_addr;
         rx_tx_desc = {128{1'b0}};
         rx_tx_desc[126] = ~rx_desc[126]; // Completion Data is opposite of Request
         rx_tx_desc[125] = 1'b0; // FMT bit 0 always 0
         rx_tx_desc[124:120] = 5'b01010; // Completion
         // TC,TD,EP,Attr,Length (and reserved bits) same as request:
         rx_tx_desc[119:96] = rx_desc[119:96];
         rx_tx_desc[95:80] = RP_REQ_ID; // Completer ID
         rx_tx_desc[79:77] = 3'b000; // Completion Status
         rx_tx_desc[76] = 1'b0; // Byte Count Modified
         rx_tx_desc[75:64] = temp_bcount;
         rx_tx_desc[63:48] = rx_desc[95:80]; // Requester ID
         rx_tx_desc[47:40] = rx_desc[79:72]; // Tag
         // Lower Address:
         rx_tx_desc[38:32] = temp_shmem_addr;
      end
   endtask

   function [0:0] tx_fc_check;
      input[127:0] desc;
      input[21:0] cred;

      integer data_cred;

      begin
         // tx_fc_check
         case (desc[126:120])
            7'b1000100, 7'b0000100 :
                     begin
                        // Config Write Type 0
                        // Config Read Type 0
                        // Type 0 Config issued to RP get handled internally,
                        // so we can issue even if no Credits
                        tx_fc_check = 1'b1;
                     end
            7'b0000000, 7'b0100000, 7'b0000010, 7'b0000101 :
                     begin
                        // Memory Read (3DW, 4DW)
                        // IO Read
                        // Config Read Type 1
                        // Non-Posted Request without Data
                        if ((cred[17:15]>0) == 1'b1)
                        begin
                           tx_fc_check = 1'b1;
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            7'b1000010, 7'b1000101 :
                     begin
                        // IO Write
                        // Config Write Type 1
                        // Non-Posted Request with Data
                        if ((cred[17:15]>0) & ((cred[20:18]>0)))
                        begin
                           tx_fc_check = 1'b1;
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            7'b1000000, 7'b1100000 :
                     begin
                        // check for Posted header cred
                        if (cred[2:0]>1)
                        begin
                           data_cred = desc[105:96];
                           // MemWr
                           // check for Posted data creds
                           if (data_cred <= cred[14:3])
                           begin
                              tx_fc_check = 1'b1;
                           end
                           else
                           begin
                              tx_fc_check = 1'b0;
                           end
                        end
                        else
                        begin
                           tx_fc_check = 1'b0;
                        end
                     end
            default :
                     begin
                        tx_fc_check = 1'b0;
                     end
         endcase

      end
   endfunction

   task tx_setup_data;
      input lcl_addr;
      integer lcl_addr;
      input bcount;
      integer bcount;
      input[7:0] byte_enb;
      output[32767:0] data_pkt;
      output dphases;
      integer dphases;
      input imm_valid;
      input[31:0] imm_data;

      reg [63:0] data_pkt_xhdl ;
      reg        zero_length_read;

      integer dphasesi;
      integer bcount_v;
      integer lcl_addr_v;
      integer nb;
      integer fb;

      integer i ;

      begin
         dphasesi = 0 ;
         zero_length_read = (bcount == 4 && ~|byte_enb);

         // tx_setup_data
         if (imm_valid == 1'b1)
           begin
              lcl_addr_v = 0 ;
           end
         else
           begin
              lcl_addr_v = lcl_addr;
           end
         bcount_v = bcount;
         // Setup the first data phase, find the first byte
         begin : xhdl_0
            if (zero_length_read) begin // zero-length read
               fb = 0;
            end else begin
               integer i;
               for(i = 0; i <= 7; i = i + 1)
               begin : byte_loop
                  if ((byte_enb[i]) == 1'b1)
                  begin
                     fb = i;
                     disable xhdl_0 ;
                  end
               end
            end
         end
         // first data phase figure out number of bytes
         nb = 8 - fb;
         if (nb > bcount_v)
         begin
            nb = bcount_v;
         end
         // first data phase get bytes
         data_pkt_xhdl = {64{1'b0}};
         for (i = 0 ; i < nb ; i = i + 1)
           begin
              if (imm_valid == 1'b1 || zero_length_read)
                begin
                   data_pkt_xhdl[((fb+i) * 8)+:8] = imm_data[(i*8)+:8];
                end
              else
                begin
                   data_pkt_xhdl[((fb+i) * 8)+:8] = shmem_read((lcl_addr_v+i), 1);
                end
           end
         data_pkt[(dphasesi*64)+:64] = data_pkt_xhdl;
         bcount_v = bcount_v - nb;
         lcl_addr_v = lcl_addr_v + nb;
         dphasesi = dphasesi + 1;
         // Setup the remaining data phases
         while (bcount_v > 0)
         begin
            data_pkt_xhdl = {64{1'b0}};
            if (bcount_v < 8)
            begin
               nb = bcount_v;
            end
            else
            begin
               nb = 8;
            end
            for (i = 0 ; i < nb ; i = i + 1 )
              begin
                 if (imm_valid == 1'b1)
                   begin
                      // Offset into remaining immediate data
                      data_pkt_xhdl[(i*8)+:8] = imm_data[(lcl_addr_v + (i*8))+:8];
                   end
                 else
                   begin
                      data_pkt_xhdl[(i*8)+:8] = shmem_read(lcl_addr_v + i, 1);
                   end
              end
            data_pkt[(dphasesi*64)+:64] = data_pkt_xhdl;
            bcount_v = bcount_v - nb;
            lcl_addr_v = lcl_addr_v + nb;
            dphasesi = dphasesi + 1;
         end
         dphases = dphasesi;
      end
   endtask

   task tx_setup_req;
      input[127:0] req_desc;
      input lcl_addr;
      integer lcl_addr;
      input imm_valid;
      input[31:0] imm_data;
      output[32767:0] data_pkt;
      output dphases;
      integer dphases;

      integer bcount_v;
      reg[7:0] byte_enb_v;

      begin
         // tx_setup_req
         if (has_data(req_desc))
         begin
            bcount_v = calc_byte_count(req_desc);
            byte_enb_v = calc_first_byte_enb(req_desc);
            tx_setup_data(lcl_addr, bcount_v, byte_enb_v, data_pkt, dphases, imm_valid, imm_data);
         end
         else
         begin
            dphases = 0;
         end
      end
   endtask



   // purpose: This reflects the reset value in shared variables
   always @(rstn)
   begin : reset_flag
      // process reset_flag
      if (VC_NUM > 0)
      begin
         forever #100000; // Only one VC needs to do this
      end
      else
      begin
`ifdef IPD_DEBUG
         ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT55789");
`endif
         vc_intf_reset_flag(rstn);
      end
  //    @(rstn);
   end

  integer tx_pkts ;
  integer tx_qwords ;
  integer tx_dwords ;
  integer rx_pkts ;
  integer rx_qwords ;
  integer rx_dwords ;
  reg clr_pndg ;

/*
  initial
  begin
    clr_pndg = 1;
    @ (posedge clk_in);
    @ (posedge clk_in);
    @ (posedge clk_in);
    clr_pndg = 0;
  end
*/

  always@(posedge clk_in)
  begin
     if (vc_intf_sample_perf(VC_NUM) == 1'b1)
     begin
        if (clr_pndg == 1'b0)
        begin
           vc_intf_set_perf(VC_NUM,tx_pkts,tx_qwords,rx_pkts,rx_qwords);
           tx_pkts   = 0 ;
           tx_qwords = 0 ;
           tx_dwords = 0;
           rx_pkts   = 0 ;
           rx_qwords = 0 ;
           rx_dwords = 0 ;
           clr_pndg  = 1'b1 ;
        end
     end
     else
     begin
        if (clr_pndg == 1'b1)
           begin
              vc_intf_clr_perf(VC_NUM) ;
              clr_pndg = 1'b0 ;
           end
     end
     if (tx_update_pkt_count == 1'b1)
     begin
        tx_dwords = tx_dwords + tx_payld_length;
        tx_qwords = tx_dwords/2;
     end
     if (tx_update_pkt_count == 1'b1)
     begin
        tx_pkts = tx_pkts + 1;
     end
     if (rx_update_pkt_count == 1'b1)
     begin
        rx_dwords = rx_dwords + rx_payld_length;
        rx_qwords = rx_dwords/2;
     end
     if (rx_update_pkt_count == 1'b1)
     begin
        rx_pkts = rx_pkts + 1;
     end
  end


