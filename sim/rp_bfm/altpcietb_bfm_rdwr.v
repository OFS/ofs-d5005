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


   // This constant defines how long to wait whenever waiting for some external event...
   localparam NUM_PS_TO_WAIT = 8000 ;

   // purpose: Sets the Max Payload size variables
   task req_intf_set_max_payload;
      input max_payload_size;
      integer max_payload_size;
      input ep_max_rd_req; // 0 means use max_payload_size
      integer ep_max_rd_req;
      input rp_max_rd_req;
      integer rp_max_rd_req;

      begin
         // 0 means use max_payload_size
         // set_max_payload
         bfm_req_intf_common.bfm_max_payload_size = max_payload_size;
         if (ep_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = ep_max_rd_req;
         end
         else
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = max_payload_size;
         end
         if (rp_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = rp_max_rd_req;
         end
         else
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = max_payload_size;
         end
      end
   endtask

   // purpose: Returns the stored max payload size
   function integer req_intf_max_payload_size;
   input dummy;
      begin
         req_intf_max_payload_size = bfm_req_intf_common.bfm_max_payload_size;
      end
   endfunction

   // purpose: Returns the stored end point max read request size
   function integer req_intf_ep_max_rd_req_size;
   input dummy;
      begin
         req_intf_ep_max_rd_req_size = bfm_req_intf_common.bfm_ep_max_rd_req;
      end
   endfunction

   // purpose: Returns the stored root port max read request size
   function integer req_intf_rp_max_rd_req_size;
   input dummy;
      begin
         req_intf_rp_max_rd_req_size = bfm_req_intf_common.bfm_rp_max_rd_req;
      end
   endfunction

   // purpose: procedure to wait until the root port is done being reset
   task req_intf_wait_reset_end;

      begin
         while (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            #NUM_PS_TO_WAIT;
         end
      end
   endtask

   // purpose: procedure to get a free tag from the pool. Waits for one
   // to be free if none available initially
   task req_intf_get_tag;
      output tag;
      integer tag;
      input need_handle;
      input lcl_addr;
      integer lcl_addr;

      integer tag_v;

      begin
         tag_v = EBFM_NUM_TAG ;
         while ((tag_v > EBFM_NUM_TAG - 1) & (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin : main_tloop
            // req_intf_get_tag
            // Find a tag to use
            begin : xhdl_0
               integer i;
               for(i = 0; i <= EBFM_NUM_TAG - 1; i = i + 1)
               begin : sub_tloop
                  if (((bfm_req_intf_common.tag_busy[i]) == 1'b0) &
                      ((bfm_req_intf_common.hnd_busy[i]) == 1'b0))
                  begin
                     bfm_req_intf_common.tag_busy[i] = 1'b1;
                     bfm_req_intf_common.hnd_busy[i] = need_handle;
                     bfm_req_intf_common.tag_lcl_addr[i] = lcl_addr;
                     tag_v = i;
                     disable main_tloop;
                  end
               end
            end // i
            #(NUM_PS_TO_WAIT);
         end
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            tag = EBFM_NUM_TAG;
         end
         else
         begin
            tag = tag_v;
         end
      end
   endtask

   // purpose: makes a request pending for the appropriate VC interface
   task req_intf_vc_req;
      input[192:0] info_v;

      integer vcnum;

      reg dummy ;

      begin
         // Get the Virtual Channel Number from the Traffic Class Number
         vcnum = bfm_req_intf_common.tc2vc_map[info_v[118:116]];
         if (vcnum >= EBFM_NUM_VC)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to transmit Packet with TC mapped to unsupported VC.",
                          "TC: ", dimage1(info_v[118:116]),
                          ", VC: ", dimage1(vcnum)});
         end
         // Make sure the ACK from any previous requests are cleared
         while (((bfm_req_intf_common.req_info_ack[vcnum]) == 1'b1) &
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT);
         end
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
           begin
              // Exit
              disable req_intf_vc_req ;
           end
         // Make the Request
         bfm_req_intf_common.req_info[vcnum] = info_v;
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b1;
         // Now wait for it to be acknowledged
         while ((bfm_req_intf_common.req_info_ack[vcnum] == 1'b0) &
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT);
         end
         // Clear the request
         bfm_req_intf_common.req_info[vcnum] = {193{1'b0}};
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b0;
      end
   endtask

   // purpose: Releases a reserved handle
   task req_intf_release_handle;
      input handle;
      integer handle;

      reg dummy ;

      begin
         // req_intf_release_handle
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to release Handle ",
                          dimage4(handle),
                          " that is not reserved."});
         end
         bfm_req_intf_common.hnd_busy[handle] = 1'b0;
      end
   endtask

   // purpose: Wait for completion on the specified handle
   task req_intf_wait_compl;
      input handle;
      integer handle;
      output[2:0] compl_status;
      input keep_handle;

      reg dummy ;

      begin
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to wait for completion on Handle ",
                          dimage4(handle),
                          " that is not reserved."});
         end
         while ((bfm_req_intf_common.reset_in_progress == 1'b0) &
                (bfm_req_intf_common.tag_busy[handle] == 1'b1))
         begin
            #(NUM_PS_TO_WAIT);
         end
         if ((bfm_req_intf_common.tag_busy[handle]) == 1'b0)
         begin
            compl_status = bfm_req_intf_common.tag_status[handle];
         end
         else
         begin
            compl_status = "UUU";
         end
         if (keep_handle != 1'b1)
         begin
            req_intf_release_handle(handle);
         end
      end
   endtask

   // purpose: This gets the pending request (if any) for the specified VC
   task vc_intf_get_req;
      input vc_num;
      integer vc_num;
      output req_valid;
      output[127:0] req_desc;
      output lcladdr;
      integer lcladdr;
      output imm_valid;
      output[31:0] imm_data;

      begin
         // vc_intf_get_req
         req_desc  = bfm_req_intf_common.req_info[vc_num][127:0];
         lcladdr   = bfm_req_intf_common.req_info[vc_num][159:128];
         imm_data  = bfm_req_intf_common.req_info[vc_num][191:160];
         imm_valid = bfm_req_intf_common.req_info[vc_num][192];
         req_valid = bfm_req_intf_common.req_info_valid[vc_num];
      end
   endtask

   // purpose: This sets the acknowledgement for a pending request
   task vc_intf_set_ack;
      input vc_num;
      integer vc_num;

      reg dummy ;

      begin
         if (bfm_req_intf_common.req_info_valid[vc_num] != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"VC Interface ",
                          dimage1(vc_num),
                          " tried to ACK a request that is not there."});
         end
         if (bfm_req_intf_common.req_info_ack[vc_num] != 1'b0)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"VC Interface ",
                          dimage1(vc_num),
                          " tried to ACK a request second time."});
         end
         bfm_req_intf_common.req_info_ack[vc_num] = 1'b1;
      end
   endtask

   // purpose: This conditionally clears the acknowledgement for a pending request
   //          It only clears the ack if the req valid has been cleared.
   //          Returns '1' if the Ack was cleared, else returns '0'.
   function [0:0] vc_intf_clr_ack;
      input vc_num;
      integer vc_num;

      begin
         if ((bfm_req_intf_common.req_info_valid[vc_num]) == 1'b0)
         begin
            bfm_req_intf_common.req_info_ack[vc_num] = 1'b0;
            vc_intf_clr_ack = 1'b1;
         end
         else
         begin
            vc_intf_clr_ack = 1'b0;
         end
      end
   endfunction

   // purpose: This routine is to record the completion of a previous non-posted request
   task vc_intf_rpt_compl;
      input tag;
      integer tag;
      input[2:0] status;

      reg dummy ;

      begin
         // vc_intf_rpt_compl
         bfm_req_intf_common.tag_status[tag] = status;
         if ((bfm_req_intf_common.tag_busy[tag]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Tried to clear a tag that was not busy. Tag: ",
                          dimage4(tag)});
         end
         bfm_req_intf_common.tag_busy[tag] = 1'b0;
      end
   endtask

   task vc_intf_reset_flag;
      input rstn;

      begin
         bfm_req_intf_common.reset_in_progress = ~rstn;
      end
   endtask

   function integer vc_intf_get_lcl_addr;
      input tag;
      integer tag;

      begin
         // vc_intf_get_lcl_addr
         if ((bfm_req_intf_common.tag_lcl_addr[tag] != -1) &
             ((bfm_req_intf_common.tag_busy[tag] == 1'b1) |
              (bfm_req_intf_common.hnd_busy[tag] == 1'b1)))
         begin
            vc_intf_get_lcl_addr = bfm_req_intf_common.tag_lcl_addr[tag];
         end
         else
         begin
            vc_intf_get_lcl_addr = -1 ;
         end
      end
   endfunction

   function integer vc_intf_sample_perf;
      input vc_num;
      integer vc_num;
      begin
         vc_intf_sample_perf = bfm_req_intf_common.perf_req[vc_num];
      end
   endfunction

  task vc_intf_set_perf;
  input [31:0] vc_num;
  input [31:0] tx_pkts;
  input [31:0] tx_qwords;
  input [31:0] rx_pkts;
  input [31:0] rx_qwords;
  begin
     bfm_req_intf_common.perf_tx_pkts[vc_num]   = tx_pkts ;
     bfm_req_intf_common.perf_tx_qwords[vc_num] = tx_qwords ;
     bfm_req_intf_common.perf_rx_pkts[vc_num]   = rx_pkts ;
     bfm_req_intf_common.perf_rx_qwords[vc_num] = rx_qwords ;
     bfm_req_intf_common.perf_ack[vc_num]       = 1'b1 ;
  end
  endtask

   task vc_intf_clr_perf;
      input vc_num;
      integer vc_num;
      begin
         bfm_req_intf_common.perf_ack[vc_num] = 1'b0;
      end
   endtask

   task req_intf_start_perf_sample;
   integer i;
   begin
      bfm_req_intf_common.perf_req = {EBFM_NUM_VC{1'b1}};
      bfm_req_intf_common.last_perf_timestamp = $time;
      while (bfm_req_intf_common.perf_req != {EBFM_NUM_VC{1'b0}})
      begin
         #NUM_PS_TO_WAIT;
         for (i = 1'b0 ; i < EBFM_NUM_VC ; i = i +1)
         begin
            if (bfm_req_intf_common.perf_ack[i] == 1'b1)
            begin
               bfm_req_intf_common.perf_req[i] = 1'b0;
            end
         end
      end
   end
   endtask

   task req_intf_disp_perf_sample;
   integer total_tx_qwords;
   integer total_tx_pkts;
   integer total_rx_qwords;
   integer total_rx_pkts;
   integer tx_mbyte_ps;
   integer rx_mbyte_ps;
   output  tx_mbit_ps;
   integer tx_mbit_ps;
   output  rx_mbit_ps;
   integer rx_mbit_ps;
   integer delta_time;
   integer delta_ns;
   output  bytes_transmitted;
   integer bytes_transmitted;
   reg   [EBFM_MSG_MAX_LEN*8:1] message;
   integer i;
   integer dummy;
   begin
      total_tx_qwords = 0;
      total_tx_pkts   = 0;
      total_rx_qwords = 0;
      total_rx_pkts   = 0;
      delta_time = $time - bfm_req_intf_common.last_perf_timestamp;
      delta_ns = delta_time / 1000;
      req_intf_start_perf_sample ;
      for (i = 0; i < EBFM_NUM_VC; i = i + 1)
      begin
         total_tx_qwords = total_tx_qwords + bfm_req_intf_common.perf_tx_qwords[i] ;
         total_tx_pkts   = total_tx_pkts   + bfm_req_intf_common.perf_tx_pkts[i];
         total_rx_qwords = total_rx_qwords + bfm_req_intf_common.perf_rx_qwords[i];
         total_rx_pkts   = total_rx_pkts   + bfm_req_intf_common.perf_rx_pkts[i];
      end
      tx_mbyte_ps = (total_tx_qwords * 8) / (delta_ns / 1000);
      rx_mbyte_ps = (total_rx_qwords * 8) / (delta_ns / 1000);
      tx_mbit_ps  = tx_mbyte_ps * 8;
      rx_mbit_ps  = rx_mbyte_ps * 8;
      bytes_transmitted = total_tx_qwords*8;

      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF: Sample Duration: ", delta_ns)," ns"});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Tx Packets: ", total_tx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Tx Bytes: ", total_tx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Tx MByte/sec: ", tx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Tx Mbit/sec: ", tx_mbit_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Rx Packets: ", total_rx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Rx Bytes: ", total_rx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Rx MByte/sec: ", rx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Rx Mbit/sec: ", rx_mbit_ps)});
   end
   endtask


   function [3:0] ebfm_calc_firstbe;
      input byte_address;
      integer byte_address;
      input byte_length;
      integer byte_length;

      begin
         case (byte_address % 4)
            0 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0001;
                           2 : ebfm_calc_firstbe = 4'b0011;
                           3 : ebfm_calc_firstbe = 4'b0111;
                           default : ebfm_calc_firstbe = 4'b1111;
                        endcase
                     end
            1 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0010;
                           2 : ebfm_calc_firstbe = 4'b0110;
                           default : ebfm_calc_firstbe = 4'b1110;
                        endcase
                     end
            2 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           1 : ebfm_calc_firstbe = 4'b0100;
                           default : ebfm_calc_firstbe = 4'b1100;
                        endcase
                     end
            3 :
                     begin
                        case (byte_length)
                           0 : ebfm_calc_firstbe = 4'b0000;
                           default : ebfm_calc_firstbe = 4'b1000;
                        endcase
                     end
            default :
                     begin
                        ebfm_calc_firstbe = 4'b0000;
                     end
         endcase
      end
   endfunction

   function [3:0] ebfm_calc_lastbe;
      input byte_address;
      integer byte_address;
      input byte_length;
      integer byte_length;

      begin
         if ((byte_address % 4) + byte_length > 4)
         begin
            case ((byte_address + byte_length) % 4)
               0 : ebfm_calc_lastbe = 4'b1111;
               3 : ebfm_calc_lastbe = 4'b0111;
               2 : ebfm_calc_lastbe = 4'b0011;
               1 : ebfm_calc_lastbe = 4'b0001;
               default : ebfm_calc_lastbe = 4'bXXXX;
            endcase
         end
         else
         begin
            ebfm_calc_lastbe = 4'b0000;
         end
      end
   endfunction

   // purpose: This is the full featured configuration read that has all
   // optional behavior via the arguments
   task ebfm_cfgrd;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;
      
      integer dummy;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, lcladdr);
         // Assemble the request
         if ((bus_num == RP_PRI_BUS_NUM) & (dev_num == RP_PRI_DEV_NUM))
         begin
            info_v[127:120] = 8'h04; // CfgRd0
            if (TL_BFM_MODE) begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL_TB_ERR, "ebfm_cfgrd:  RP CFG access not allowed in TL-only simulation");
            end
         end
         else
         begin
            info_v[127:120] = 8'h05; // CfgRd1
         end
         info_v[119:112] = 8'h00; // R, TC, RRRR fields all 0
         info_v[111:104] = 8'h00; // TD, EP, Attr, RR, LL all 0
         info_v[103:96] = 8'h01; // Length 1 DW
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = 4'h0; // Last DW BE
         info_v[67:64] = ebfm_calc_firstbe(regb_ad, regb_ln);
         info_v[63:56] = bus_num[7:0] ;
         info_v[55:51] = dev_num[4:0] ;
         info_v[50:48] = fnc_num[2:0] ;
         info_v[47:44] = 4'h0; // RRRR
         info_v[43:34] = (regb_ad / 4) ;
         info_v[33:32] = 2'b00; // RR
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   // purpose: Configuration Read that waits for completion automatically
   task ebfm_cfgrd_wait;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      output[2:0] compl_status;

      integer dum_hnd;

      begin
         ebfm_cfgrd(bus_num, dev_num, fnc_num, regb_ad, regb_ln, lcladdr,
         1'b1, 1'b0, compl_status, dum_hnd);
      end
   endtask

   // purpose: Configuration Read that does not wait, does not return handle
   //          Need to assume completes okay and is known to be done by the
   //          time a subsequent read completes.
   task ebfm_cfgrd_nowt;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;

      integer dum_hnd;
      reg[2:0] dum_sts;

      begin
         ebfm_cfgrd(bus_num, dev_num, fnc_num, regb_ad, regb_ln, lcladdr,
         1'b0, 1'b0, dum_sts, dum_hnd);
      end
   endtask

   // purpose: This is the full featured configuration write that has all
   // optional behavior via the arguments
   task ebfm_cfgwr;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input lcladdr;
      integer lcladdr;
      input imm_valid;
      input[31:0] imm_data;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;
      integer dummy;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, -1);
         // Assemble the request
         info_v[192] = imm_valid;
         info_v[191:160] = imm_data;
         info_v[159:128] = lcladdr;
         if ((bus_num == RP_PRI_BUS_NUM) & (dev_num == RP_PRI_DEV_NUM))
         begin
            info_v[127:120] = 8'h44; // CfgWr0
            if (TL_BFM_MODE) begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL_TB_ERR, "ebfm_cfgwr:  RP CFG access not allowed in TL-only simulation");
            end
         end
         else
         begin
            info_v[127:120] = 8'h45; // CfgWr1
         end
         info_v[119:112] = 8'h00; // R, TC, RRRR fields all 0
         info_v[111:104] = 8'h00; // TD, EP, Attr, RR, LL all 0
         info_v[103:96] = 8'h01; // Length 1 DW
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = 4'h0; // Last DW BE
         info_v[67:64] = ebfm_calc_firstbe(regb_ad, regb_ln);
         info_v[63:56] = bus_num[7:0] ;
         info_v[55:51] = dev_num[4:0] ;
         info_v[50:48] = fnc_num[2:0] ;
         info_v[47:44] = 4'h0; // RRRR
         info_v[43:34] = (regb_ad / 4) ;
         info_v[33:32] = 2'b00; // RR
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   // purpose: Configuration Write, Immediate Data, that waits for completion automatically
   task ebfm_cfgwr_imm_wait;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input[31:0] imm_data;
      output[2:0] compl_status;

      integer dum_hnd;

      begin
         ebfm_cfgwr(bus_num, dev_num, fnc_num, regb_ad, regb_ln, 0, 1'b1,
         imm_data, 1'b1, 1'b0, compl_status, dum_hnd);
      end
   endtask

   // purpose: Configuration Write, Immediate Data, no wait, no handle
   task ebfm_cfgwr_imm_nowt;
      input bus_num;
      integer bus_num;
      input dev_num;
      integer dev_num;
      input fnc_num;
      integer fnc_num;
      input regb_ad;
      integer regb_ad;
      input regb_ln;
      integer regb_ln;
      input[31:0] imm_data;

      reg[2:0] dum_sts;
      integer dum_hnd;

      begin
         ebfm_cfgwr(bus_num, dev_num, fnc_num, regb_ad, regb_ln, 0, 1'b1,
         imm_data, 1'b0, 1'b0, dum_sts, dum_hnd);
      end
   endtask

   function [9:0] calc_dw_len;
      input byte_adr;
      integer byte_adr;
      input byte_len;
      integer byte_len;

      integer adr_len;
      reg[9:0] dw_len;

      begin
         // calc_dw_len
         adr_len = byte_len + (byte_adr % 4);
         if (adr_len % 4 == 0)
         begin
            dw_len = (adr_len / 4);
         end
         else
         begin
            dw_len = ((adr_len / 4) + 1);
         end
         calc_dw_len = dw_len;
      end
   endfunction

   task ebfm_memwr;
      input[63:0] pcie_addr;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[192:0] info_v;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // ebfm_memwr
         baddr_v = pcie_addr[11:0] ;
         // Assemble the request
         info_v[159:128] = lcladdr ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h40; // 3DW Header w/Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h60; // 4DW Header w/Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = 8'h00;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
      end
   endtask

   task ebfm_memwr_imm;
      input[63:0] pcie_addr;
      input[31:0] imm_data;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[192:0] info_v;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // ebfm_memwr_imm
         baddr_v = pcie_addr[11:0];
         // Assemble the request
         info_v[192] = 1'b1;
         info_v[191:160] = imm_data ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h40; // 3DW Header w/Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h60; // 4DW Header w/Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass ;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = 8'h00 ;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
      end
   endtask

   // purpose: This is the full featured memory read that has all
   // optional behavior via the arguments
   task ebfm_memrd;
      input[63:0] pcie_addr;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[192:0] info_v;
      integer tag_v;
      reg i_need_handle;
      integer baddr_v;

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, lcladdr);
         baddr_v = pcie_addr[11:0];
         // Assemble the request
         info_v[159:128] = lcladdr ;
         if (pcie_addr[63:32] == 32'h00000000)
         begin
            info_v[127:120] = 8'h00; // 3DW Header w/o Data MemWr
            info_v[63:34] = pcie_addr[31:2];
            info_v[31:0] = {32{1'b0}};
         end
         else
         begin
            info_v[127:120] = 8'h20; // 4DW Header w/o Data MemWr
            info_v[63:2] = pcie_addr[63:2];
         end
         info_v[119] = 1'b0; // Reserved bit
         info_v[118:116] = tclass ;
         info_v[115:112] = 4'h0; // Reserved bits all 0
         info_v[111:106] = 6'b000000; // TD, EP, Attr, RR all 0
         info_v[105:96] = calc_dw_len(baddr_v, byte_len);
         info_v[95:80] = RP_REQ_ID; // Requester ID
         info_v[79:72] = tag_v ;
         info_v[71:68] = ebfm_calc_lastbe(baddr_v, byte_len);
         info_v[67:64] = ebfm_calc_firstbe(baddr_v, byte_len);
         // Make the request
         req_intf_vc_req(info_v);
         // Wait for completion if specified to do so
         if (compl_wait == 1'b1)
         begin
            req_intf_wait_compl(tag_v, compl_status, need_handle);
         end
         else
         begin
            compl_status = "UUU";
         end
         // Return the handle
         if (need_handle == 1'b0)
         begin
            handle = -1;
         end
         else
         begin
            handle = tag_v;
         end
      end
   endtask

   task ebfm_barwr;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[63:0] cbar;
      integer rem_len;
      integer offset;
      integer cur_len;
      reg[63:0] paddr;

      reg dummy ;

      begin
         rem_len = byte_len ;
         offset = 0 ;
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         paddr = ({cbar[63:4], 4'b0000}) + pcie_offset;
         while (rem_len > 0)
         begin
            if ((cbar[0]) == 1'b1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
            end
            else
            begin
               cur_len = req_intf_max_payload_size(1'b0) - paddr[1:0];
               if (cur_len > rem_len)
               begin
                  cur_len = rem_len;
               end
               if (((paddr % 4096) + cur_len) > 4096)
               begin
                  cur_len = 4096 - (paddr % 4096);
               end
               ebfm_memwr( paddr, lcladdr + offset, cur_len, tclass);
            end
            offset = offset + cur_len;
            rem_len = rem_len - cur_len;
            paddr = paddr + cur_len;
         end
      end
   endtask

   task ebfm_barwr_imm;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input[31:0] imm_data;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[63:0] cbar;

      reg dummy ;

      begin
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         if ((cbar[0]) == 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
         end
         else
         begin
            cbar[3:0] = 4'b0000;
            cbar = cbar + pcie_offset;
            ebfm_memwr_imm(cbar, imm_data, byte_len,
            tclass);
         end
      end
   endtask

   task ebfm_barrd;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;
      input compl_wait;
      input need_handle;
      output[2:0] compl_status;
      output handle;
      integer handle;

      reg[2:0] dum_status;
      integer dum_handle;
      reg[63:0] cbar;
      integer rem_len;
      integer offset;
      integer cur_len;
      reg[63:0] paddr;

      reg dummy ;

      begin
         rem_len = byte_len ;
         offset = 0 ;
         // ebfm_barrd
         cbar = shmem_read(bar_table + (bar_num * 4), 8);
         if (((cbar[0]) == 1'b1) | ((cbar[2]) == 1'b0))
         begin
            cbar[63:32] = {32{1'b0}};
         end
         paddr = ({cbar[63:4], 4'b0000}) + pcie_offset;
         while (rem_len > 0)
         begin
            if ((cbar[0]) == 1'b1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "Accessing I/O or Expansion ROM BAR is unsupported");
            end
            else
            begin
               // Need to make sure we don't cross a DW boundary
               cur_len = req_intf_rp_max_rd_req_size(1'b0) - paddr[1:0];
               if (cur_len > rem_len)
               begin
                  cur_len = rem_len;
               end
               if (((paddr % 4096) + cur_len) > 4096)
               begin
                  cur_len = 4096 - (paddr % 4096);
               end
               if (rem_len == cur_len)
               begin
                  // If it is the last one use the passed in compl/handle parms
                  ebfm_memrd(paddr, lcladdr + offset,
                             cur_len, tclass, compl_wait, need_handle, compl_status,
                             handle);
               end
               else
               begin
                  // Otherwise no wait, assume it all completes and the final one
                  // pushes ahead
                  ebfm_memrd(paddr, lcladdr + offset,
                             cur_len, tclass, 1'b0, 1'b0, dum_status, dum_handle);
               end
            end
            offset = offset + cur_len;
            rem_len = rem_len - cur_len;
            paddr = paddr + cur_len;
         end
      end
   endtask

   task ebfm_barrd_wait;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[2:0] dum_status;
      integer dum_handle;

      begin
         // ebfm_barrd_wait
         ebfm_barrd(bar_table, bar_num, pcie_offset, lcladdr, byte_len,
         tclass, 1'b1, 1'b0, dum_status, dum_handle);
      end
   endtask

   task ebfm_barrd_nowt;
      input bar_table;
      integer bar_table;
      input bar_num;
      integer bar_num;
      input pcie_offset;
      integer pcie_offset;
      input lcladdr;
      integer lcladdr;
      input byte_len;
      integer byte_len;
      input tclass;
      integer tclass;

      reg[2:0] dum_status;
      integer dum_handle;

      begin
         // ebfm_barrd_nowt
         ebfm_barrd(bar_table, bar_num, pcie_offset, lcladdr, byte_len,
         tclass, 1'b0, 1'b0, dum_status, dum_handle);
      end
   endtask

   task rdwr_start_perf_sample;
   begin
        req_intf_start_perf_sample;
   end
   endtask

   task rdwr_disp_perf_sample;
   output tx_mbit_ps;
   integer tx_mbit_ps;
   output rx_mbit_ps;
   integer rx_mbit_ps;
   output bytes_transmitted;
   integer bytes_transmitted;
   begin
        req_intf_disp_perf_sample(tx_mbit_ps, rx_mbit_ps, bytes_transmitted);
   end
   endtask

