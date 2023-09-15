// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// MSIX top level module
//    * Receive AFU interrupt requests on i_afu_msix_req
//    * Send out PCIe interrupt TLP for FME/Port interrupts and AFU interrupts
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_hdr_def::*;


module msix_top 
    # ( parameter VF_NUM    = 1 )
(
   // AFU interrupt interface (incoming AFU interrupt requests)
   ofs_fim_pcie_txs_axis_if.slave      i_afu_msix_req,

   // MSIX TX channel interface (outgoing PCIe interrupt TLP packets)
   ofs_fim_pcie_tx_axis_if.master      o_msix_tx_st,

   // AFU interrupt response interface
   ofs_fim_afu_irq_rsp_axis_if.master  o_msix_rsp,

   //FME to MSIX signals
// fme_csr_io_if                       msix_fme_io,  
// vfme_csr_io_if.interrupt            msix_vfme_io,    
// port_csr_io_if                      msix_port_io,
   
   //MSIX table + PBA
   output  logic   [6:0]               inp2cr_msix_pba,

   input   logic   [63:0]              cr2out_msix_addr0,
   input   logic   [63:0]              cr2out_msix_addr1,
   input   logic   [63:0]              cr2out_msix_addr2,
   input   logic   [63:0]              cr2out_msix_addr3,
   input   logic   [63:0]              cr2out_msix_addr4,
   input   logic   [63:0]              cr2out_msix_addr5,
   input   logic   [63:0]              cr2out_msix_addr6,
   input   logic   [63:0]              cr2out_msix_addr7,
   input   logic   [63:0]              cr2out_msix_ctldat0,
   input   logic   [63:0]              cr2out_msix_ctldat1,
   input   logic   [63:0]              cr2out_msix_ctldat2,
   input   logic   [63:0]              cr2out_msix_ctldat3,
   input   logic   [63:0]              cr2out_msix_ctldat4,
   input   logic   [63:0]              cr2out_msix_ctldat5,
   input   logic   [63:0]              cr2out_msix_ctldat6,
   input   logic   [63:0]              cr2out_msix_ctldat7,
   input   logic   [63:0]              cr2out_msix_pba,
   
   output  logic   [6:0]               inp2cr_msix_vpba,

   input   logic   [63:0]              cr2out_msix_vaddr0,
   input   logic   [63:0]              cr2out_msix_vaddr1,
   input   logic   [63:0]              cr2out_msix_vaddr2,
   input   logic   [63:0]              cr2out_msix_vaddr3,
   input   logic   [63:0]              cr2out_msix_vaddr4,
   input   logic   [63:0]              cr2out_msix_vaddr5,
   input   logic   [63:0]              cr2out_msix_vaddr6,
   input   logic   [63:0]              cr2out_msix_vaddr7,
   input   logic   [63:0]              cr2out_msix_vctldat0,
   input   logic   [63:0]              cr2out_msix_vctldat1,
   input   logic   [63:0]              cr2out_msix_vctldat2,
   input   logic   [63:0]              cr2out_msix_vctldat3,
   input   logic   [63:0]              cr2out_msix_vctldat4,
   input   logic   [63:0]              cr2out_msix_vctldat5,
   input   logic   [63:0]              cr2out_msix_vctldat6,
   input   logic   [63:0]              cr2out_msix_vctldat7,
   input   logic   [63:0]              cr2out_msix_vpba,
   
   //PCIE sideband signals
   input  t_sideband_from_pcie         i_pcie_p2c_sideband,
   output t_sideband_to_pcie           o_pcie_c2p_sideband,

   //Port access control
// input  logic [PORTS-1:0]            i_port_access_ctrl,

   input                               clk,
   input                               rst_n,
   input logic                         afu_softreset
   );

   localparam [7:0] PCIE_FMTTYPE_MEM_WRITE32 = 8'h40,
                    PCIE_FMTTYPE_MEM_WRITE64 = 8'h60;

   logic                               o_intr_valid,o_vintr_valid;     
   logic [L_NUM_AFU_INTERRUPTS-1:0]    o_intr_id, o_vintr_id;         
   logic [95:0]                        i_msix_table_entry;
   logic [L_NUM_AFU_INTERRUPTS:0]      i_intr_id; 
   logic                               i_intr_val;        
   logic                               fme_irq;
   logic [NUM_AFU_INTERRUPTS -1:0]     pf_mask_vector;
   logic [NUM_AFU_INTERRUPTS -3:0]     vf_mask_vector;
   logic [PORTS-1:0]                   vf_active;
   logic [PORTS-1:0]                   vf_active_reg;

   logic afu_msix_req_tready;
   logic afu_irq_valid;
   logic afu_irq;
   logic msix_mask,rsp_ack;
   logic pf_user_irq,vf_user_irq;
   logic user_irq_valid;                        // *NEW*
   logic [3:0] user_irq_in, user_irq_out;
   logic [FIM_NUM_PF-1:0] a2c_msix_en_pf;
   logic [FIM_NUM_PF-1:0] a2c_msix_fn_mask_pf;
   logic vf_msix_mask;
   logic port_irq_in;
   logic cr2out_port_error_clear;
   logic [3:0] mask_vector;
/*
   //MSIX Table signals
   logic [63:0] inp2cr_msix_pba,inp2cr_msix_vpba;
   logic [63:0] cr2out_msix_pba,cr2out_msix_vpba;
   logic [63:0] cr2out_msix_addr0, cr2out_msix_addr1, cr2out_msix_addr2, cr2out_msix_addr3;
   logic [63:0] cr2out_msix_addr4, cr2out_msix_addr5, cr2out_msix_addr6, cr2out_msix_addr7;
   logic [63:0] cr2out_msix_ctldat0, cr2out_msix_ctldat1, cr2out_msix_ctldat2, cr2out_msix_ctldat3;
   logic [63:0] cr2out_msix_ctldat4, cr2out_msix_ctldat5, cr2out_msix_ctldat6, cr2out_msix_ctldat7;
   logic [63:0] cr2out_msix_vaddr0, cr2out_msix_vaddr1, cr2out_msix_vaddr2, cr2out_msix_vaddr3, cr2out_msix_vaddr4;
   logic [63:0] cr2out_msix_vctldat0, cr2out_msix_vctldat1, cr2out_msix_vctldat2, cr2out_msix_vctldat3, cr2out_msix_vctldat4;
*/   

   // MSI-X to PCIe                              
   logic [63:0]            o_msix_addr;                
   logic                   o_msix_valid;                
   logic [31:0]            o_msix_data;
   
   logic                   i_msix_st_tready;
   logic [16:0]            addr_64b;

   t_axis_pcie_txs         mwr_packet;
   t_axis_pcie_tx          tx_st, tx_st_q;
   t_axis_irq_rsp          pf_irq_rsp, vf_irq_rsp;
   t_tlp_mem_req_hdr [1:0] mwr_hdr;
   t_sideband_from_pcie    pcie_p2c_sideband;

   localparam DATA_WIDTH = $bits(i_pcie_p2c_sideband.cfg_ctl); 
   
   //Sync pcie sideband signals to msix clk
   fim_resync # (
   .WIDTH(DATA_WIDTH),
   .NO_CUT(0)        )
   sync (
      .clk     (clk), 
      .reset   (~rst_n),  
      .d       (i_pcie_p2c_sideband.cfg_ctl),  
      .q       (pcie_p2c_sideband.cfg_ctl)
   ); 

   assign i_msix_st_tready       = o_msix_tx_st.tready; 
   assign i_afu_msix_req.tready  = afu_msix_req_tready;
   assign afu_irq                = i_afu_msix_req.tx.tdata[0].valid ?
                                      i_afu_msix_req.tx.tuser[0].afu_irq :
                                      i_afu_msix_req.tx.tuser[1].afu_irq;
   assign afu_irq_valid          = i_afu_msix_req.tx.tvalid;
   assign user_irq_in            = i_afu_msix_req.tx.tdata[0].valid ?
                                      i_afu_msix_req.tx.tdata[0].hdr[19:16] :
                                      i_afu_msix_req.tx.tdata[1].hdr[19:16];

   //PCIE Sideband signals
   assign a2c_msix_fn_mask_pf    = pcie_p2c_sideband.cfg_ctl.msix_pf_mask_en;
   assign a2c_msix_en_pf         = pcie_p2c_sideband.cfg_ctl.msix_enable; 
   assign vf_msix_mask           = pcie_p2c_sideband.cfg_ctl.vf0_msix_mask;
/*
   //FME to MSIX Signals
   assign cr2out_msix_pba     = msix_fme_io.cr2out_msix_pba;
   assign cr2out_msix_addr0   = msix_fme_io.cr2out_msix_addr0;
   assign cr2out_msix_addr1   = msix_fme_io.cr2out_msix_addr1;  
   assign cr2out_msix_addr2   = msix_fme_io.cr2out_msix_addr2;  
   assign cr2out_msix_addr3   = msix_fme_io.cr2out_msix_addr3; 
   assign cr2out_msix_addr4   = msix_fme_io.cr2out_msix_addr4;  
   assign cr2out_msix_addr5   = msix_fme_io.cr2out_msix_addr5;  
   assign cr2out_msix_addr6   = msix_fme_io.cr2out_msix_addr6;  
   assign cr2out_msix_addr7   = msix_fme_io.cr2out_msix_addr7; 
   assign cr2out_msix_ctldat0 = msix_fme_io.cr2out_msix_ctldat0; 
   assign cr2out_msix_ctldat1 = msix_fme_io.cr2out_msix_ctldat1;
   assign cr2out_msix_ctldat2 = msix_fme_io.cr2out_msix_ctldat2;
   assign cr2out_msix_ctldat3 = msix_fme_io.cr2out_msix_ctldat3;
   assign cr2out_msix_ctldat4 = msix_fme_io.cr2out_msix_ctldat4;
   assign cr2out_msix_ctldat5 = msix_fme_io.cr2out_msix_ctldat5;
   assign cr2out_msix_ctldat6 = msix_fme_io.cr2out_msix_ctldat6;
   assign cr2out_msix_ctldat7 = msix_fme_io.cr2out_msix_ctldat7;
   
*/ 
   assign fme_irq             = i_afu_msix_req.tx.tvalid &&
                                  ( ( i_afu_msix_req.tx.tdata[0].hdr[19:16] == 4'h6 )
                                            && i_afu_msix_req.tx.tdata[0].valid ) ||
                                  ( ( i_afu_msix_req.tx.tdata[1].hdr[19:16] == 4'h6 )
                                            && i_afu_msix_req.tx.tdata[1].valid );  // *NEW*   
   
   //Port to MSIX
   assign port_irq_in             = i_afu_msix_req.tx.tvalid &&                     // WAS |msix_port_io.cr2out_port_error;
                                  ( ( i_afu_msix_req.tx.tdata[0].hdr[19:16] == 4'h4 )
                                            && i_afu_msix_req.tx.tdata[0].valid ) ||
                                  ( ( i_afu_msix_req.tx.tdata[1].hdr[19:16] == 4'h4 )
                                            && i_afu_msix_req.tx.tdata[1].valid );   
                                            
   assign cr2out_port_error_clear = 1'b0;                                           // WAS msix_port_io.cr2out_port_error_clear;
   assign vf_active               = i_afu_msix_req.tx.tdata[0].valid ?              // WAS i_port_access_ctrl;
                                      i_afu_msix_req.tx.tuser[0].vf_active :
                                    i_afu_msix_req.tx.tdata[1].valid ?   
                                      i_afu_msix_req.tx.tuser[1].vf_active :
                                      vf_active_reg;

   // Register to hold vf_active until next valid
   always_ff @ ( posedge clk )
      vf_active_reg     <= vf_active;

   //MSIX to FME and vFME Signals
   //assign msix_fme_io.inp2cr_msix_pba = inp2cr_msix_pba;
   //assign msix_vfme_io.inp2cr_msix_vpba = inp2cr_msix_vpba;
/*
   //vFME to MSIX Signals
   assign cr2out_msix_vpba     = msix_vfme_io.cr2out_msix_vpba;
   assign cr2out_msix_vaddr0   = msix_vfme_io.cr2out_msix_vaddr0;
   assign cr2out_msix_vaddr1   = msix_vfme_io.cr2out_msix_vaddr1;  
   assign cr2out_msix_vaddr2   = msix_vfme_io.cr2out_msix_vaddr2;  
   assign cr2out_msix_vaddr3   = msix_vfme_io.cr2out_msix_vaddr3; 
   assign cr2out_msix_vaddr4   = msix_vfme_io.cr2out_msix_vaddr4;  
   assign cr2out_msix_vctldat0 = msix_vfme_io.cr2out_msix_vctldat0; 
   assign cr2out_msix_vctldat1 = msix_vfme_io.cr2out_msix_vctldat1;
   assign cr2out_msix_vctldat2 = msix_vfme_io.cr2out_msix_vctldat2;
   assign cr2out_msix_vctldat3 = msix_vfme_io.cr2out_msix_vctldat3;
   assign cr2out_msix_vctldat4 = msix_vfme_io.cr2out_msix_vctldat4;
*/   
   assign pf_user_irq = ((o_intr_id == 4'h0 || o_intr_id == 4'h1 ||o_intr_id == 4'h2 ||o_intr_id == 4'h3) && o_intr_valid)? 'b1 :'b0;
   assign vf_user_irq = ((o_vintr_id == 4'h0 || o_vintr_id == 4'h1 ||o_vintr_id == 4'h2 ||o_vintr_id == 4'h3) && o_vintr_valid) ? 'b1:'b0;
   assign mask_vector = vf_active [0] ? vf_mask_vector[3:0] : pf_mask_vector[3:0];
   assign msix_mask   = vf_active [0] ? vf_msix_mask : a2c_msix_fn_mask_pf;
   
   //Interface assignment
   assign  o_msix_tx_st.tx     = tx_st;
   assign  o_msix_tx_st.clk    = clk;
   assign  o_msix_tx_st.rst_n  = rst_n;
   
   //Response Interface
   assign  o_msix_rsp.clk      = clk;
   assign  o_msix_rsp.rst_n    = rst_n;
   assign  o_msix_rsp.tvalid   = vf_active[0] ? vf_irq_rsp.tvalid : pf_irq_rsp.tvalid;
   assign  o_msix_rsp.tdata    = vf_active[0] ? vf_irq_rsp.tdata  : pf_irq_rsp.tdata;

   assign rsp_ack              = o_msix_rsp.tvalid && o_msix_rsp.tready;

   assign  addr_64b            = |o_msix_addr[48:32];
  
   // MWR packet
   always_comb begin
      mwr_hdr[0] = '0;
      mwr_hdr[0].dw0.fmttype = addr_64b ? PCIE_FMTTYPE_MEM_WRITE64: PCIE_FMTTYPE_MEM_WRITE32;
      mwr_hdr[0].dw0.length = 10'd1;
      mwr_hdr[0].first_be = 4'hf;
      mwr_hdr[0].last_be = 4'h0;
      mwr_hdr[0].addr = addr_64b ? o_msix_addr[63:32]: o_msix_addr[31:0];
      mwr_hdr[0].lsb_addr = addr_64b ? o_msix_addr[31:0]: '0;
      mwr_hdr[0].requester_id = vf_active[0] ? {VF_NUM,4'd0} : '0;

      mwr_packet = '0;
      mwr_packet.tdata[0].hdr = mwr_hdr[0];
      mwr_packet.tdata[0].payload = o_msix_data;
      mwr_packet.tdata[0].valid = 1'b1;
      mwr_packet.tdata[0].eop = 1'b1;
      mwr_packet.tdata[0].sop = 1'b1;
      mwr_packet.tuser[0].afu_irq = 1'b0;
      mwr_packet.tuser[0].vf_active = vf_active[0] ? 1'b1:1'b0;
   end

   //MSIX to AFU Response for PF User IRQ
   always_ff @(posedge clk) begin
      if(~rst_n) begin
         pf_irq_rsp.tvalid <= '0;
         pf_irq_rsp.tdata  <= '0;
      end else if(!pf_irq_rsp.tvalid || o_msix_rsp.tready) begin
         pf_irq_rsp.tvalid <= '0;
         pf_irq_rsp.tdata  <= '0;
         if(pf_user_irq) begin
            pf_irq_rsp.tvalid       <= 1'b1;
            pf_irq_rsp.tdata        <= '0;
            pf_irq_rsp.tdata[19:16] <= o_intr_id;
         end else begin
            pf_irq_rsp.tvalid <= '0;
            pf_irq_rsp.tdata  <= '0;
         end 
      end
   end

   //MSIX to AFU Response for VF User IRQ
   always_ff @(posedge clk) begin
      if(~rst_n) begin
         vf_irq_rsp.tvalid <= '0;
         vf_irq_rsp.tdata  <= '0;
      end else if(!vf_irq_rsp.tvalid || o_msix_rsp.tready) begin
         vf_irq_rsp.tvalid <= '0;
         vf_irq_rsp.tdata  <= '0;
         if(vf_user_irq) begin
            vf_irq_rsp.tvalid       <= 1'b1;
            vf_irq_rsp.tdata        <= '0;
            vf_irq_rsp.tdata[19:16] <= o_vintr_id;
         end else begin
            vf_irq_rsp.tvalid <= '0;
            vf_irq_rsp.tdata  <= '0;
         end
      end
   end

   always_comb begin
      tx_st.tvalid      = o_msix_valid;
      tx_st.tdata       = mwr_packet.tdata[0];
      tx_st.tuser       = mwr_packet.tuser[0];
      tx_st.tlast       = o_msix_valid;
      tx_st.tdata.sop   = o_msix_valid;
      tx_st.tdata.eop   = o_msix_valid;
      tx_st.tdata.valid = o_msix_valid;
   end
   
   //Module Instantiation
   msix_wrapper msix_wrapper_inst(
      .clk                     (clk), 
      .rst_n                   (rst_n),                                                  
      .o_msix_addr             (o_msix_addr),          
      .o_msix_valid            (o_msix_valid),          
      .o_msix_data             (o_msix_data),      

      .a2c_msix_en_pf          (a2c_msix_en_pf),  
      .a2c_msix_fn_mask_pf     (a2c_msix_fn_mask_pf),
      .vf_msix_mask            (vf_msix_mask),
      
      .o_intr_valid            (o_intr_valid),
      .o_intr_id               (o_intr_id), 
      .o_vintr_valid           (o_vintr_valid),    
      .o_vintr_id              (o_vintr_id),

      .i_msix_st_tready        (i_msix_st_tready),
      .i_msix_table_entry      (i_msix_table_entry),       
      .i_intr_id               (i_intr_id), 
      .i_intr_val              (i_intr_val),   

      .fme_irq                 (fme_irq), 
      .port_irq_in             (port_irq_in), 
      .user_irq                (user_irq_out),
      .vf_active               (vf_active),

      .pf_mask_vector          (pf_mask_vector),
      .vf_mask_vector          (vf_mask_vector),
      .pba_sclr                ({1'b0,1'b0,
                                 cr2out_port_error_clear,
                                 {4{afu_softreset}}}),

      .inp2cr_msix_pba         (inp2cr_msix_pba),   
      .cr2out_msix_pba         (cr2out_msix_pba),
      .inp2cr_msix_vpba        (inp2cr_msix_vpba),     
      .cr2out_msix_vpba        (cr2out_msix_vpba)
   );

   //User IRQ valid - *NEW*
   assign user_irq_valid        = i_afu_msix_req.tx.tvalid &&  
                                  ( ( i_afu_msix_req.tx.tdata[0].hdr[19:16] < 4'h4 )
                                            && i_afu_msix_req.tx.tdata[0].valid ) ||
                                  ( ( i_afu_msix_req.tx.tdata[1].hdr[19:16] < 4'h4 )
                                            && i_afu_msix_req.tx.tdata[1].valid ); 

   //User IRQ -> vector
   msix_user_irq msix_user_irq_inst (
      .clk                     (clk),
      .rst_n                   (rst_n),
      .i_afu_irq               (afu_irq),
      .i_msix_mask             (msix_mask),
      .i_mask_vector           (mask_vector),
      .i_rsp_ack               (rsp_ack),
      .o_afu_msix_req_tready   (afu_msix_req_tready),
      .i_afu_irq_valid         (user_irq_valid),            // WAS (afu_irq_valid),
      .i_user_irq              (user_irq_in),
      .user_irq_out            (user_irq_out)
   );

   //FME MSIX Table
   fme_msix_table fme_msix_table(
      .clk                      (clk),
      .rst_n                    (rst_n),
      .cr2out_msix_addr0        (cr2out_msix_addr0),
      .cr2out_msix_ctldat0      (cr2out_msix_ctldat0),
      .cr2out_msix_addr1        (cr2out_msix_addr1),
      .cr2out_msix_ctldat1      (cr2out_msix_ctldat1),
      .cr2out_msix_addr2        (cr2out_msix_addr2),
      .cr2out_msix_ctldat2      (cr2out_msix_ctldat2),
      .cr2out_msix_addr3        (cr2out_msix_addr3),
      .cr2out_msix_ctldat3      (cr2out_msix_ctldat3),
      .cr2out_msix_addr4        (cr2out_msix_addr4),
      .cr2out_msix_ctldat4      (cr2out_msix_ctldat4),
      .cr2out_msix_addr5        (cr2out_msix_addr5),
      .cr2out_msix_ctldat5      (cr2out_msix_ctldat5),
      .cr2out_msix_addr6        (cr2out_msix_addr6),
      .cr2out_msix_ctldat6      (cr2out_msix_ctldat6),
      .cr2out_msix_addr7        (cr2out_msix_addr7),
      .cr2out_msix_ctldat7      (cr2out_msix_ctldat7),
      .cr2out_msix_vaddr0       (cr2out_msix_vaddr0),
      .cr2out_msix_vctldat0     (cr2out_msix_vctldat0),
      .cr2out_msix_vaddr1       (cr2out_msix_vaddr1),
      .cr2out_msix_vctldat1     (cr2out_msix_vctldat1),
      .cr2out_msix_vaddr2       (cr2out_msix_vaddr2),
      .cr2out_msix_vctldat2     (cr2out_msix_vctldat2),
      .cr2out_msix_vaddr3       (cr2out_msix_vaddr3),
      .cr2out_msix_vctldat3     (cr2out_msix_vctldat3),
      .cr2out_msix_vaddr4       (cr2out_msix_vaddr4),
      .cr2out_msix_vctldat4     (cr2out_msix_vctldat4),
      //MSI-X
      .pf_mask_vector           (pf_mask_vector),   
      .vf_mask_vector           (vf_mask_vector),   
      .i_vintr_id               (o_vintr_id),       
      .i_vintr_valid            (o_vintr_valid),    
      .i_intr_id                (o_intr_id),        
      .i_intr_valid             (o_intr_valid),     
      .o_msix_table_entry       (i_msix_table_entry),
      .o_intr_id                (i_intr_id),         
      .o_intr_val               (i_intr_val)
      );

endmodule
