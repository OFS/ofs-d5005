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


`timescale 1 ps / 1 ps
`default_nettype wire
//-----------------------------------------------------------------------------
// Title         : PCI Express LTSSM monitor
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_pipe_phy.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This function interconnects two PIPE MAC interfaces for a single lane.
// For now this uses a common PCLK for both interfaces, an enhancement woudl be
// to support separate PCLK's for each interface with the requisite elastic
// buffer.
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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




module altpcietb_ltssm_mon (
             rp_clk,
             rstn,
             rp_ltssm,
             ep_ltssm,
             dummy_out
);

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

   // purpose: sets the suppressed_msg_mask
   task ebfm_log_set_suppressed_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_suppressed_msg_mask
         bfm_log_common.suppressed_msg_mask = msg_mask;
      end
   endtask

   // purpose: sets the stop_on_msg_mask
   task ebfm_log_set_stop_on_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_stop_on_msg_mask
         bfm_log_common.stop_on_msg_mask = msg_mask;
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_open;
      input [200*8:1] fn; // Log File Name

      begin
         bfm_log_common.log_file = $fopen(fn);
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_close;

      begin
         // ebfm_log_close
         $fclose(bfm_log_common.log_file);
         bfm_log_common.log_file = 0;
      end
   endtask

   // purpose: stops the simulation, with flag to indicate success or not
   function ebfm_log_stop_sim;
      input success;
      integer success;

      begin
         if (success == 1)
         begin
            $display("SUCCESS: Simulation stopped due to successful completion!");
            $display("Simulation passed");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         else
         begin
            $display("FAILURE: Simulation stopped due to error!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         ebfm_log_stop_sim = 1'b0 ;
      end
   endfunction

   // purpose: This displays a message of the specified type
   function ebfm_display;
      input msg_type;
      integer msg_type;
      input [EBFM_MSG_MAX_LEN*8:1] message;

      reg [9*8:1]  prefix ;
      reg [80*8:1] amsg;
      reg sup;
      reg stp;
      reg dummy ;
      integer i ;
      time ctime ;
      integer itime ;

      begin
         for (i = 0 ; i < EBFM_MSG_MAX_LEN ; i = i + 1)
           begin : msg_shift
              if (message[(EBFM_MSG_MAX_LEN*8)-:8] != 8'h00)
                begin
                   disable msg_shift ;
                end
              message = message << 8 ;
           end
         if (msg_type > EBFM_MSG_ERROR_CONTINUE)
           begin
              sup = 1'b0;
              stp = 1'b1;
              case (msg_type)
                EBFM_MSG_ERROR_FATAL :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to Fatal error!" ;
                     prefix = "FATAL:   ";
                  end
                EBFM_MSG_ERROR_FATAL_TB_ERR :
                  begin
                     amsg   = "FAILURE: Simulation stopped due error in Testbench/BFM design!";
                     prefix = "FATAL:   ";
                  end
                default :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to unknown message type!";
                     prefix = "FATAL:   ";
                  end
              endcase
           end
         else
           begin
              sup = bfm_log_common.suppressed_msg_mask[msg_type];
              stp = bfm_log_common.stop_on_msg_mask[msg_type];
              if (stp == 1'b1)
                begin
                   amsg   = "FAILURE: Simulation stopped due to enabled error!";
                end
              if (msg_type < EBFM_MSG_INFO)
                begin
                     prefix = "DEBUG:   ";
                end
              else
                begin
                   if (msg_type < EBFM_MSG_WARNING)
                     begin
                        prefix = "INFO:    ";
                     end
                   else
                     begin
                        if (msg_type > EBFM_MSG_WARNING)
                          begin
                             prefix = "ERROR:   ";
                          end
                        else
                          begin
                             prefix = "WARNING: ";
                          end
                     end
                end
           end // else: !if(msg_type > EBFM_MSG_ERROR_CONTINUE)
         itime = ($time/1000) ;
         // Display the message if not suppressed
         if (sup != 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file,"%s %d %s %s",prefix,itime,"ns",message);
                end
              $display("%s %d %s %s",prefix,itime,"ns",message);
           end
         // Stop if requested
         if (stp == 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file, "%s", amsg);
                end
              $display("%s",amsg);
              dummy = ebfm_log_stop_sim(0);
           end
         // Dummy function return so we can call from other functions
         ebfm_display = 1'b0 ;
      end
   endfunction

   // purpose: produce 1-digit hexadecimal string from a vector
   function [8:1] himage1;
      input [3:0] vec;

      begin
         case (vec)
           4'h0 : himage1 = "0" ;
           4'h1 : himage1 = "1" ;
           4'h2 : himage1 = "2" ;
           4'h3 : himage1 = "3" ;
           4'h4 : himage1 = "4" ;
           4'h5 : himage1 = "5" ;
           4'h6 : himage1 = "6" ;
           4'h7 : himage1 = "7" ;
           4'h8 : himage1 = "8" ;
           4'h9 : himage1 = "9" ;
           4'hA : himage1 = "A" ;
           4'hB : himage1 = "B" ;
           4'hC : himage1 = "C" ;
           4'hD : himage1 = "D" ;
           4'hE : himage1 = "E" ;
           4'hF : himage1 = "F" ;
           4'bzzzz : himage1 = "Z" ;
           default : himage1 = "X" ;
         endcase
      end
   endfunction // himage1

   // purpose: produce 2-digit hexadecimal string from a vector
   function [16:1] himage2 ;
      input [7:0] vec;
      begin
         himage2 = {himage1(vec[7:4]),himage1(vec[3:0])} ;
      end
   endfunction // himage2

   // purpose: produce 4-digit hexadecimal string from a vector
   function [32:1] himage4 ;
      input [15:0] vec;
      begin
         himage4 = {himage2(vec[15:8]),himage2(vec[7:0])} ;
      end
   endfunction // himage4

   // purpose: produce 8-digit hexadecimal string from a vector
   function [64:1] himage8 ;
      input [31:0] vec;
      begin
         himage8 = {himage4(vec[31:16]),himage4(vec[15:0])} ;
      end
   endfunction // himage8

   // purpose: produce 16-digit hexadecimal string from a vector
   function [128:1] himage16 ;
      input [63:0] vec;
      begin
         himage16 = {himage8(vec[63:32]),himage8(vec[31:0])} ;
      end
   endfunction // himage16

   // purpose: produce 1-digit decimal string from an integer
   function [8:1] dimage1 ;
      input [31:0] num ;
      begin
         case (num)
           0 : dimage1 = "0" ;
           1 : dimage1 = "1" ;
           2 : dimage1 = "2" ;
           3 : dimage1 = "3" ;
           4 : dimage1 = "4" ;
           5 : dimage1 = "5" ;
           6 : dimage1 = "6" ;
           7 : dimage1 = "7" ;
           8 : dimage1 = "8" ;
           9 : dimage1 = "9" ;
           16: dimage1 = "16" ;
           default : dimage1 = "U" ;
         endcase // case(num)
      end
   endfunction // dimage1

   // purpose: produce 2-digit decimal string from an integer
   function [16:1] dimage2 ;
      input [31:0] num ;
      begin
         dimage2 = {dimage1(num/10),dimage1(num % 10)} ;
      end
   endfunction // dimage2

   // purpose: produce 3-digit decimal string from an integer
   function [24:1] dimage3 ;
      input [31:0] num ;
      begin
         dimage3 = {dimage1(num/100),dimage2(num % 100)} ;
      end
   endfunction // dimage3

   // purpose: produce 4-digit decimal string from an integer
   function [32:1] dimage4 ;
      input [31:0] num ;
      begin
         dimage4 = {dimage1(num/1000),dimage3(num % 1000)} ;
      end
   endfunction // dimage4

   // purpose: produce 5-digit decimal string from an integer
   function [40:1] dimage5 ;
      input [31:0] num ;
      begin
         dimage5 = {dimage1(num/10000),dimage4(num % 10000)} ;
      end
   endfunction // dimage5

   // purpose: produce 6-digit decimal string from an integer
   function [48:1] dimage6 ;
      input [31:0] num ;
      begin
         dimage6 = {dimage1(num/100000),dimage5(num % 100000)} ;
      end
   endfunction // dimage6

   // purpose: produce 7-digit decimal string from an integer
   function [56:1] dimage7 ;
      input [31:0] num ;
      begin
         dimage7 = {dimage1(num/1000000),dimage6(num % 1000000)} ;
      end
   endfunction // dimage7

  // purpose: select the correct dimage call for ascii conversion
  function  [800:1] image ;
     input  [800:1] msg ;
     input  [32:1]  num ;
     begin
        if (num <= 10)
        begin
           image = {msg, dimage1(num)};
        end
        else if (num <= 100)
        begin
           image = {msg, dimage2(num)};
        end
        else if (num <= 1000)
        begin
           image = {msg, dimage3(num)};
        end
        else if (num <= 10000)
        begin
           image = {msg, dimage4(num)};
        end
        else if (num <= 100000)
        begin
           image = {msg, dimage5(num)};
        end
        else if (num <= 1000000)
        begin
           image = {msg, dimage6(num)};
        end
        else image = {msg, dimage7(num)};
     end
   endfunction


   parameter SHMEM_FILL_ZERO = 0;
   parameter SHMEM_FILL_BYTE_INC = 1;
   parameter SHMEM_FILL_WORD_INC = 2;
   parameter SHMEM_FILL_DWORD_INC = 4;
   parameter SHMEM_FILL_QWORD_INC = 8;
   parameter SHMEM_FILL_ONE = 15;
   parameter SHMEM_SIZE = 2 ** SHMEM_ADDR_WIDTH;
   parameter BAR_TABLE_SIZE = 64;
   parameter BAR_TABLE_POINTER = SHMEM_SIZE - BAR_TABLE_SIZE;
   parameter SCR_SIZE = 64;
   parameter CFG_SCRATCH_SPACE = SHMEM_SIZE - BAR_TABLE_SIZE - SCR_SIZE;

   task shmem_write;
      input addr;
      integer addr;
      input [63:0] data;
      input leng;
      integer leng;

      integer rleng;
      integer i ;

      reg dummy ;

      begin
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_WRITE only accepts write lengths up to 8") ;
              rleng = 8 ;
           end
         else if ( addr < BAR_TABLE_POINTER + BAR_TABLE_SIZE & addr >= CFG_SCRATCH_SPACE & bfm_shmem_common.protect_bfm_shmem )
            begin
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Task SHMEM_WRITE attempted to overwrite the write protected area of the shared memory") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"This protected area contains the following data critical to the operation of the BFM:") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BFM internal memory area, 64B located at ", himage8(CFG_SCRATCH_SPACE)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BAR Table, 64B located at ", himage8(BAR_TABLE_POINTER)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"All other locations in the shared memory are available from 0 to ", himage8(CFG_SCRATCH_SPACE - 1)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Please change your SHMEM_WRITE call to a different memory location") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Halting Simulation") ;
            end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              bfm_shmem_common.shmem[addr + i] = data[(i*8)+:8];
           end
      end
   endtask

   function [63:0] shmem_read;
      input addr;
      integer addr;
      input leng;
      integer leng;

      reg[63:0] rdata;
      integer rleng ;
      integer i ;

      reg dummy ;

      begin
         rdata = {64{1'b0}} ;
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_READ only accepts read lengths up to 8") ;
              rleng = 8 ;
           end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              rdata[(i * 8)+:8] = bfm_shmem_common.shmem[addr + i];
           end
         shmem_read = rdata;
      end
   endfunction

   // purpose: display shared memory data
   function shmem_display;
      input addr;
      integer addr;
      input leng;
      integer leng;
      input word_size;
      integer word_size;
      input flag_addr;
      integer flag_addr;
      input msg_type;
      integer msg_type;

      integer iaddr;
      reg [60*8:1] oneline ;
      reg [128:1] data_str[0:15] ;
      reg [8*5:1] flag ;
      integer i ;

      reg dummy ;

      begin
         // shmem_display
         iaddr = addr ;
         // Backup address to beginning of word if needed
         if (iaddr % word_size > 0)
           begin
              iaddr = iaddr - (iaddr % word_size);
           end
         dummy = ebfm_display(msg_type, "");
         dummy = ebfm_display(msg_type, "Shared Memory Data Display:");
         dummy = ebfm_display(msg_type, "Address  Data");
         dummy = ebfm_display(msg_type, "-------  ----");
         while (iaddr < (addr + leng))
           begin
              for (i = 0; i < 16 ; i = i + word_size)
                begin : one_line
                   if ( (iaddr + i) > (addr + leng) )
                     begin
                        data_str[i] = "        " ;
                     end
                   else
                     begin
                        case (word_size)
                          8       : data_str[i] = himage16(shmem_read(iaddr + i,8)) ;
                          4       : data_str[i] = {"            ",himage8(shmem_read(iaddr + i,4))} ;
                          2       : data_str[i] = {"                ",himage4(shmem_read(iaddr + i,2))} ;
                          default : data_str[i] = {"                  ",himage2(shmem_read(iaddr + i,1))} ;
                        endcase // case(word_size)
                     end
                end // block: one_line
              if ((flag_addr >= iaddr) & (flag_addr < (iaddr + 16)))
                begin
                   flag = " <===" ;
                end
              else
                begin
                   flag = "     " ;
                end
              // Now compile the whole line
              oneline = {480{1'b0}} ;
              case (word_size)
                8 : oneline = {himage8(iaddr),
                               " ",data_str[0]," ",data_str[8],flag} ;
                4 : oneline = {himage8(iaddr),
                               " ",data_str[0][64:1]," ",data_str[4][64:1],
                               " ",data_str[8][64:1]," ",data_str[12][64:1],
                               flag} ;
                2 : oneline = {himage8(iaddr),
                               " ",data_str[0][32:1]," ",data_str[2][32:1],
                               " ",data_str[4][32:1]," ",data_str[6][32:1],
                               " ",data_str[8][32:1]," ",data_str[10][32:1],
                               " ",data_str[12][32:1]," ",data_str[14][32:1],
                               flag} ;
                default : oneline = {himage8(iaddr),
                               " ",data_str[0][16:1]," ",data_str[1][16:1],
                               " ",data_str[2][16:1]," ",data_str[3][16:1],
                               " ",data_str[4][16:1]," ",data_str[5][16:1],
                               " ",data_str[6][16:1]," ",data_str[7][16:1],
                               " ",data_str[8][16:1]," ",data_str[9][16:1],
                               " ",data_str[10][16:1]," ",data_str[11][16:1],
                               " ",data_str[12][16:1]," ",data_str[13][16:1],
                               " ",data_str[14][16:1]," ",data_str[15][16:1],
                               flag} ;
              endcase
              dummy = ebfm_display(msg_type, oneline);
              iaddr = iaddr + 16;
           end // while (iaddr < (addr + leng))
         // Dummy return so we can call from other functions
         shmem_display = 1'b0 ;
      end
   endfunction

   task shmem_fill;
      input addr;
      integer addr;
      input mode;
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init;

      integer rembytes;
      reg[63:0] data;
      integer uaddr;
      parameter[7:0] ZDATA = {8{1'b0}};
      parameter[7:0] ODATA = {8{1'b1}};

      begin
         rembytes = leng ;
         data = init ;
         uaddr = addr ;
         while (rembytes > 0)
         begin
            case (mode)
               SHMEM_FILL_ZERO :
                        begin
                           shmem_write(uaddr, ZDATA,1);
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               SHMEM_FILL_BYTE_INC :
                        begin
                           shmem_write(uaddr, data, 1);
                           data[7:0] = data[7:0] + 1;
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               SHMEM_FILL_WORD_INC :
                        begin
                           begin : xhdl_3
                              integer i;
                              for(i = 0; i <= 1; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[15:0] = data[15:0] + 1;
                        end
               SHMEM_FILL_DWORD_INC :
                        begin
                           begin : xhdl_4
                              integer i;
                              for(i = 0; i <= 3; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[31:0] = data[31:0] + 1 ;
                        end
               SHMEM_FILL_QWORD_INC :
                        begin
                           begin : xhdl_5
                              integer i;
                              for(i = 0; i <= 7; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[63:0] = data[63:0] + 1;
                        end
               SHMEM_FILL_ONE :
                        begin
                           shmem_write(uaddr, ODATA, 1);
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               default :
                        begin
                        end
            endcase
         end
      end
   endtask

   // Returns 1 if okay
   function [0:0] shmem_chk_ok;
      input addr;
      integer addr;
      input mode;
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init;
      input display_error;
      integer display_error;

      reg dummy ;

      integer rembytes;
      reg[63:0] data;
      reg[63:0] actual;
      integer uaddr;
      integer daddr;
      integer dlen;
      integer incr_count;
      parameter[7:0] ZDATA = {8{1'b0}};
      parameter[7:0] ODATA = {8{1'b1}};
      reg [36*8:1] actline;
      reg [36*8:1] expline;
      integer word_size;

      begin
         rembytes = leng ;
         uaddr = addr ;
         data = init ;
         actual = init ;
         incr_count = 0 ;
         case (mode)
            SHMEM_FILL_WORD_INC :
                     begin
                        word_size = 2;
                     end
            SHMEM_FILL_DWORD_INC :
                     begin
                        word_size = 4;
                     end
            SHMEM_FILL_QWORD_INC :
                     begin
                        word_size = 8;
                     end
            default :
                     begin
                        word_size = 1;
                     end
         endcase // case(mode)
         begin : compare_loop
         while (rembytes > 0)
         begin
            case (mode)
               SHMEM_FILL_ZERO :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != ZDATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ZDATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_BYTE_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[7:0])
                      begin
                         expline = {"    Expected Data: ", himage2(data[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    data[7:0] = data[7:0] + 1;
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_WORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 1)
                      begin
                         data[15:0] = data[15:0] + 1 ;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_DWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 3)
                      begin
                         data[31:0] = data[31:0] + 1;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_QWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 7)
                      begin
                         data[63:0] = data[63:0] + 1;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_ONE :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != ODATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ODATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               default :
                 begin
                 end
            endcase
         end
         end // block: compare_loop
         if (rembytes > 0)
         begin
            if (display_error == 1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, "");
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, {"Shared memory data miscompare at address: ", himage8(uaddr)});
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, expline);
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, actline);
               // Backup and display a little before the miscompare
               // Figure amount to backup
               daddr = uaddr % 32; // Back up no more than 32 bytes
               // There was a miscompare, display an error message
               if (daddr < 16)
               begin
                  // But at least 16
                  daddr = daddr + 16;
               end
               // Backed up display address
               daddr = uaddr - daddr;
               // Don't backup more than start of compare
               if (daddr < addr)
               begin
                  daddr = addr;
               end
               // Try to display 64 bytes
               dlen = 64;
               // But don't display beyond the end of the compare
               if (daddr + dlen > addr + leng)
               begin
                  dlen = (addr + leng) - daddr;
               end
               dummy = shmem_display(daddr, dlen, word_size, uaddr, EBFM_MSG_ERROR_INFO);
            end
            shmem_chk_ok = 0;
         end
         else
         begin
            shmem_chk_ok = 1;
         end
      end
   endfunction
//`endif
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

      begin
         info_v = {193{1'b0}} ;
         // Get a TAG
         i_need_handle = compl_wait | need_handle;
         req_intf_get_tag(tag_v, i_need_handle, lcladdr);
         // Assemble the request
         if ((bus_num == RP_PRI_BUS_NUM) & (dev_num == RP_PRI_DEV_NUM))
         begin
            info_v[127:120] = 8'h04; // CfgRd0
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


input rp_clk;
input rstn;
input [4:0] rp_ltssm;
input [5:0] ep_ltssm;
output       dummy_out;

reg [4:0] rp_ltssm_r;
reg [5:0] ep_ltssm_r;

task conv_ltssm;
   input device;
   input detect_timout;
   input [5:0] ltssm;
   reg[(23)*8:1] ltssm_str;
   reg dummy, dummy2 ;
   begin

   if (device == 0)
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
   end
   else
   begin
      case (ltssm)
      6'b000000: ltssm_str = "DETECT.QUIET           ";
      6'b000001: ltssm_str = "DETECT.ACTIVE          ";
      6'b000010: ltssm_str = "POLLING.ACTIVE         ";
      6'b000011: ltssm_str = "POLLING.COMPLIANCE     ";
      6'b000100: ltssm_str = "POLLING.CONFIG         ";
      6'b000101: ltssm_str = "PRE.DETECT.QUIET       ";
      6'b000110: ltssm_str = "DETECT.WAIT";
      6'b000111: ltssm_str = "CONFIG.LINKWIDTH.START ";
      6'b001000: ltssm_str = "CONFIG.LINKWIDTH.ACCEPT";
      6'b001001: ltssm_str = "CONFIG.LANENUM.WAIT    ";
      6'b001010: ltssm_str = "CONFIG.LANENUM.ACCEPT  ";
      6'b001011: ltssm_str = "CONFIG.COMPLETE        ";
      6'b001100: ltssm_str = "CONFIG.IDLE            ";
      6'b001101: ltssm_str = "RECOVERY.RCVRLOCK      ";
      6'b001110: ltssm_str = "RECOVERY.SPEED         ";
      6'b001111: ltssm_str = "RECOVERY.RCVRCFG       ";
      6'b010000: ltssm_str = "RECOVERY.IDLE          ";
      6'b100000: ltssm_str = "REC_EQULZ.PHASE0       ";
      6'b100001: ltssm_str = "REC_EQULZ.PHASE1       ";
      6'b100010: ltssm_str = "REC_EQULZ.PHASE2       ";
      6'b100011: ltssm_str = "REC_EQULZ.PHASE3       ";
      6'b010001: ltssm_str = "L0                     ";
      6'b010010: ltssm_str = "L0s                    ";
      6'b010011: ltssm_str = "L123_SEND_IDLE         ";
      6'b010100: ltssm_str = "L1.IDLE                ";
      6'b010101: ltssm_str = "L2.IDLE                ";
      6'b010110: ltssm_str = "L2.TRANSMITWAKE        ";
      6'b010111: ltssm_str = "DISABLED.ENTRY         ";
      6'b011000: ltssm_str = "DISABLED.IDLE          ";
      6'b011001: ltssm_str = "DISABLED               ";
      6'b011010: ltssm_str = "LOOPBACK.ENTRY         ";
      6'b011011: ltssm_str = "LOOPBACK.ACTIVE        ";
      6'b011100: ltssm_str = "LOOPBACK.EXIT          ";
      6'b011101: ltssm_str = "LOOPBACK.EXIT.TIMEOUT  ";
      6'b011110: ltssm_str = "HOT RESET.ENTRY        ";
      6'b011111: ltssm_str = "HOT RESET              ";
      default  : ltssm_str = "UNKNOWN                ";
      endcase
   end


   if (detect_timout==1)
     dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, { " LTSSM does not change from DETECT.QUIET"});
   else if (device == 0)
     dummy = ebfm_display(EBFM_MSG_INFO, { " RP LTSSM State: ", ltssm_str});
   else
     dummy = ebfm_display(EBFM_MSG_INFO, { " EP LTSSM State: ", ltssm_str});
   end

endtask
reg [3:0] detect_cnt;

always @(posedge rp_clk)
  begin
  rp_ltssm_r <= rp_ltssm;
  ep_ltssm_r <= ep_ltssm;
  if (rp_ltssm_r != rp_ltssm)
    conv_ltssm(0,0,rp_ltssm);
  if (ep_ltssm_r != ep_ltssm)
    conv_ltssm(1,0,ep_ltssm);
  end

always @ (posedge rp_clk or negedge rstn) begin
   if (rstn==1'b0) begin
      detect_cnt <= 4'h0;
   end
   else begin
      if (rp_ltssm_r != rp_ltssm) begin
         if (detect_cnt == 4'b1100) begin
            conv_ltssm(1,1,rp_ltssm);
         end
         else if (rp_ltssm==5'b01111) begin
            detect_cnt <= 4'h0;
         end
         else if (rp_ltssm==5'b00000) begin
            detect_cnt <= detect_cnt + 4'h1;
         end
      end
   end
end

endmodule

