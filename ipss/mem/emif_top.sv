// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// EMIF subsystem containing EMIF IP, AVMM bridge and AVMM checker
//
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

`include "fpga_defines.vh"
import ofs_fim_emif_cfg_pkg::*;

module emif_top #(
  parameter NUM_LOCAL_MEM_BANKS = 1
)
(
   input  logic              emif_rst_n,
   input  logic              afu_reset,
   input  logic              pr_freeze,

   // CSR interface
   ofs_fim_axi_mmio_if.slave csr_if,

   // Interrupt interface
   ofs_fim_irq_axis_if.master   fme_irq_if,

   //  Avalon-MM interface for each EMIF.
   ofs_fim_emif_avmm_if.emif ddr4_avmm [NUM_LOCAL_MEM_BANKS-1:0],

   // EMIF 4 Interfaces DDR4 x72 RDIMM (x8)
   ofs_fim_emif_mem_if.emif  ddr4_mem [NUM_LOCAL_MEM_BANKS-1:0]
);

   // EMIF AVMM interface
   ofs_fim_emif_avmm_if     ddr4_avmm_emif [NUM_LOCAL_MEM_BANKS-1:0]();

   // AVMM checker interface
   ofs_fim_emif_avmm_if     ddr4_avmm_chkr [NUM_LOCAL_MEM_BANKS-1:0]();

   // Misc EMIF ctrl/status signals
   ofs_fim_emif_sideband_if ddr4_sideband_sigs [NUM_LOCAL_MEM_BANKS-1:0]();

   // PR freeze
   logic [NUM_LOCAL_MEM_BANKS-1:0] ddr4_pr_freeze;
   // AFU reset
   logic [NUM_LOCAL_MEM_BANKS-1:0] ddr4_afu_reset;
   // AVMM write signal to EMIF  
   logic [NUM_LOCAL_MEM_BANKS-1:0] ddr4_pr_avmm_write;
   // AVMM read signal to EMIF
   logic [NUM_LOCAL_MEM_BANKS-1:0] ddr4_pr_avmm_read;
   // Synchronous reset to EMIF
   logic [NUM_LOCAL_MEM_BANKS-1:0] ddr4_rst_n_sync;

`ifdef ENABLE_DDR_AVMM_CHKR
   // Control signal to clear external memory (set memory content to 0s)
   logic [NUM_LOCAL_MEM_BANKS-1:0] clear_ext_mem_req_n;
`endif

//----------------------------------------------------------------------

// synopsys translate_off
`ifdef SIM_MODE
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge csr_if.clk);

      wait (csr_if.rst_n === 1'b0);
      wait (csr_if.rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   //  Assertion: assert_pr_freeze_undif
   //
   //  Check that pr_freeze is assigned a known value when afu_reset signal is deasserted.
   //
   assert_pr_freeze_undif:
      assert property (@(posedge csr_if.clk) disable iff (~csr_if.rst_n || ~enable_assertion) (!$isunknown(pr_freeze)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, pr_freeze is unknown", $time));
`endif
// synopsys translate_on

// Tie off unused interrupt interface
assign fme_irq_if.tvalid = 1'b0;

// Resets - Split for timing
// synthesis preserve_syn_only - Prevents removal of registers during synthesis. 
// This setting does not affect retiming or other optimizations in the Fitter.
logic [NUM_LOCAL_MEM_BANKS-1:0] emif_rst_n_q /* synthesis preserve_syn_only */ ;

always @ (posedge csr_if.clk)
begin
    for(int c = 0; c < NUM_LOCAL_MEM_BANKS; c = c + 1)
    begin
        emif_rst_n_q[c] <= emif_rst_n;  
    end
end


// CSR for status and error logging
emif_csr #(
  .NUM_LOCAL_MEM_BANKS(NUM_LOCAL_MEM_BANKS)
)
emif_csr (
   .emif_csr_sigs (ddr4_sideband_sigs),
   .csr_if        (csr_if)
);

logic emif_prt_error = 1'b0; 
logic ddr_clear_busy;

genvar b;
generate
    for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1)
    begin : mem_bank

        // Add reset synchronizer to cater for 
	// long delay on DDR reset signal from EMIF due to global signal promotion
	fim_resync #(
            .SYNC_CHAIN_LENGTH(3),
            .WIDTH(1),
            .INIT_VALUE(0),
            .NO_CUT(1)
        ) ddr4_reset_sync (
            .clk(ddr4_avmm[b].clk),
            .reset(~ddr4_avmm[b].rst_n),
            .d(1'b1),
            .q(ddr4_rst_n_sync[b])
        );
        
        // Use the pr_freeze signal to mask the rd/wr inputs to the bridge/EMIF.
        fim_resync #(
            .SYNC_CHAIN_LENGTH(2),
            .WIDTH(1),
            .INIT_VALUE(0),
            .NO_CUT(1)
        ) ddr4_pr_freeze_sync (
            .clk(ddr4_avmm[b].clk),
            .reset(1'b0),
            .d(pr_freeze),
            .q(ddr4_pr_freeze[b])
        );

        assign ddr4_pr_avmm_write[b] = ddr4_pr_freeze[b] ? 'b0 : ddr4_avmm[b].write;
        assign ddr4_pr_avmm_read[b]  = ddr4_pr_freeze[b] ? 'b0 : ddr4_avmm[b].read;

        //sync the AFU's ddr-reset-request signal to each local clock.
        fim_resync #(
            .SYNC_CHAIN_LENGTH(2),
            .WIDTH(1),
            .INIT_VALUE(0),
            .NO_CUT(1)
        ) ddr4_afu_reset_sync (
            .clk(ddr4_avmm[b].clk),
            .reset(1'b0),
            .d(afu_reset),
            .q(ddr4_afu_reset[b])
        );

`ifdef ENABLE_DDR_AVMM_CHKR       
        //sync the AFU's ddr-reset-request signal to each local clock.
        fim_resync #(
            .SYNC_CHAIN_LENGTH(2),
            .WIDTH(1),
            .INIT_VALUE(0),
            .NO_CUT(1)
        ) ddr4_afu_clear_n_sync (
            .clk(ddr4_avmm[b].clk),
            .reset(1'b0),
            .d(ddr4_sideband_sigs[b].chkr_clear_n),
            .q(clear_ext_mem_req_n[b])
        );
`endif

        // --------------------------------------------------
        // DDR4 datapath:
        //
        //   AFU -> AVMM pipeline bridge -> Clear FSM ->
        //       AVMM protocol checker -> DDR EMIF IP
        // --------------------------------------------------

        // ------------------
        // AVMM Pipeline Bridge
        // ------------------
        ddr_avmm_bridge #(
           .DATA_WIDTH(AVMM_DATA_WIDTH),
           .SYMBOL_WIDTH(8),
           .ADDR_WIDTH(AVMM_ADDR_WIDTH),
           .BURSTCOUNT_WIDTH(AVMM_BURSTCOUNT_WIDTH)
        ) ddr4_bridge (
           .clk              (ddr4_avmm[b].clk),
           .m0_waitrequest   (ddr4_avmm_chkr[b].waitrequest),
           .m0_readdata      (ddr4_avmm_chkr[b].readdata),
           .m0_readdatavalid (ddr4_avmm_chkr[b].readdatavalid),
           .m0_burstcount    (ddr4_avmm_chkr[b].burstcount),
           .m0_writedata     (ddr4_avmm_chkr[b].writedata),
           .m0_address       (ddr4_avmm_chkr[b].address),
           .m0_write         (ddr4_avmm_chkr[b].write),
           .m0_read          (ddr4_avmm_chkr[b].read),
           .m0_byteenable    (ddr4_avmm_chkr[b].byteenable),
           .reset            (ddr4_afu_reset[b]),
           .s0_waitrequest   (ddr4_avmm[b].waitrequest),
           .s0_readdata      (ddr4_avmm[b].readdata),
           .s0_readdatavalid (ddr4_avmm[b].readdatavalid),
           .s0_burstcount    (ddr4_avmm[b].burstcount),
           .s0_writedata     (ddr4_avmm[b].writedata),
           .s0_address       (ddr4_avmm[b].address),
           .s0_write         (ddr4_pr_avmm_write[b]), 
           .s0_read          (ddr4_pr_avmm_read[b]),  
           .s0_byteenable    (ddr4_avmm[b].byteenable)
        );

`ifdef ENABLE_DDR_AVMM_CHKR
        // AVMM Protocol Checker
        avmm_chkr #(
           .ADDRESS_W(AVMM_ADDR_WIDTH),
           .DATA_W(AVMM_DATA_WIDTH)
        ) ddr4_avmm_chkr_inst (
           .ddr_clear_en      (~clear_ext_mem_req_n[b]),
           .ddr_clear_busy    (ddr4_sideband_sigs[b].clear_busy),

           .afu_reset         (ddr4_afu_reset[b]),
           .emif_prt_error    (ddr4_sideband_sigs[b].chkr_error),

           .avm_read          (ddr4_avmm_emif[b].read),
           .avm_write         (ddr4_avmm_emif[b].write),
           .avm_address       (ddr4_avmm_emif[b].address),
           .avm_waitrequest   (~ddr4_avmm_emif[b].waitrequest),
           .avm_byteenable    (ddr4_avmm_emif[b].byteenable),
           .avm_burstcount    (ddr4_avmm_emif[b].burstcount),
           .avm_writedata     (ddr4_avmm_emif[b].writedata),
           .avm_readdata      (ddr4_avmm_emif[b].readdata),
           .avm_readdatavalid (ddr4_avmm_emif[b].readdatavalid),
           
           .avs_read          (ddr4_avmm_chkr[b].read),
           .avs_write         (ddr4_avmm_chkr[b].write),
           .avs_address       (ddr4_avmm_chkr[b].address),
           .avs_waitrequest   (ddr4_avmm_chkr[b].waitrequest),
           .avs_byteenable    (ddr4_avmm_chkr[b].byteenable),
           .avs_burstcount    (ddr4_avmm_chkr[b].burstcount),
           .avs_writedata     (ddr4_avmm_chkr[b].writedata),
           .avs_readdata      (ddr4_avmm_chkr[b].readdata),
           .avs_readdatavalid (ddr4_avmm_chkr[b].readdatavalid),

           .clk               (ddr4_avmm[b].clk),
           .rst_n             (ddr4_rst_n_sync[b])
        );
`else
        // Bypass AVMM protocol checker
        // Tie-off
        assign ddr4_sideband_sigs[b].chkr_error = 1'b0;
        assign ddr4_sideband_sigs[b].clear_busy = 1'b0;

        // Invert ddr4_avmm_emif[b].waitrequest because it is connected to ready signal on EMIF IP
        // which is the invert of waitrequest, i.e. waitrequest=1 when ready=0 and vice versa
        assign ddr4_avmm_chkr[b].waitrequest    =  ~ddr4_avmm_emif[b].waitrequest;

        assign ddr4_avmm_chkr[b].readdata       =  ddr4_avmm_emif[b].readdata;
        assign ddr4_avmm_chkr[b].readdatavalid  =  ddr4_avmm_emif[b].readdatavalid;
        assign ddr4_avmm_emif[b].read           =  ddr4_avmm_chkr[b].read;
        assign ddr4_avmm_emif[b].write          =  ddr4_avmm_chkr[b].write;
        assign ddr4_avmm_emif[b].address        =  ddr4_avmm_chkr[b].address;
        assign ddr4_avmm_emif[b].byteenable     =  ddr4_avmm_chkr[b].byteenable;
        assign ddr4_avmm_emif[b].burstcount     =  ddr4_avmm_chkr[b].burstcount;
        assign ddr4_avmm_emif[b].writedata      =  ddr4_avmm_chkr[b].writedata;
`endif

        // ------------------
        // DDR4 EMIF IP
        // ------------------
        assign ddr4_avmm[b].ecc_interrupt = 'b0;
        emif_ddr4_no_ecc emif_ddr4_inst (
            .amm_ready_0             (ddr4_avmm_emif[b].waitrequest),
            .amm_read_0              (ddr4_avmm_emif[b].read),
            .amm_write_0             (ddr4_avmm_emif[b].write),
            .amm_address_0           (ddr4_avmm_emif[b].address),
            .amm_readdata_0          (ddr4_avmm_emif[b].readdata),
            .amm_writedata_0         (ddr4_avmm_emif[b].writedata),
            .amm_burstcount_0        (ddr4_avmm_emif[b].burstcount),
            .amm_byteenable_0        (ddr4_avmm_emif[b].byteenable),
            .amm_readdatavalid_0     (ddr4_avmm_emif[b].readdatavalid),
            .emif_usr_clk            (ddr4_avmm[b].clk),
            .emif_usr_reset_n        (ddr4_avmm[b].rst_n),
            .local_reset_req         (~emif_rst_n_q[b]),
            .local_reset_done        (ddr4_sideband_sigs[b].local_reset_done),
            .mem_ck                  (ddr4_mem[b].ck),
            .mem_ck_n                (ddr4_mem[b].ck_n),
            .mem_a                   (ddr4_mem[b].a),
            .mem_act_n               (ddr4_mem[b].act_n),
            .mem_ba                  (ddr4_mem[b].ba),
            .mem_bg                  (ddr4_mem[b].bg),
            .mem_cke                 (ddr4_mem[b].cke),
            .mem_cs_n                (ddr4_mem[b].cs_n),
            .mem_odt                 (ddr4_mem[b].odt),
            .mem_reset_n             (ddr4_mem[b].reset_n),
            .mem_par                 (ddr4_mem[b].par),
            .mem_alert_n             (ddr4_mem[b].alert_n),
            .mem_dqs                 (ddr4_mem[b].dqs),
            .mem_dqs_n               (ddr4_mem[b].dqs_n),
            .mem_dq                  (ddr4_mem[b].dq),
            .mem_dbi_n               (ddr4_mem[b].dbi_n),
            .oct_rzqin               (ddr4_mem[b].oct_rzqin),
            .pll_locked              (ddr4_sideband_sigs[b].pll_locked),
            .pll_ref_clk             (ddr4_mem[b].ref_clk),
            .pll_ref_clk_out         (),
            .local_cal_success       (ddr4_sideband_sigs[b].cal_success),
            .local_cal_fail          (ddr4_sideband_sigs[b].cal_failure)
        );

    end : mem_bank

endgenerate

endmodule : emif_top
