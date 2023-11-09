// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   PCIe TX arbiter arbitrates betwen the TLP packets from MMIO AXIS-TX channel, 
//   MSIX AXIS-TX channel and AFU AXIS-TX channel
//
//   The arbiter makes sure TLP packets which belong to the same TLP request/response
//   are sent contiguously upstream.
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;

module pcie_tx_arbiter #(
)(
   input logic                      clk,
   input logic                      rst_n,

   ofs_fim_pcie_tx_axis_if.slave    i_mmio_tx_st,
   ofs_fim_pcie_txs_axis_if.slave   i_afu_tx_st,
   ofs_fim_pcie_tx_axis_if.slave    i_msix_tx_st,

   ofs_fim_pcie_txs_axis_if.master  o_pcie_tx_st
);

t_axis_pcie_txs pcie_tx_q;
t_axis_pcie_tx  mmio_tx_st;
t_axis_pcie_txs afu_tx_st;
t_axis_pcie_tx  msix_tx_st;

logic mmio_tx_tready_q;
logic afu_tx_tready_q;
logic msix_tx_tready_q;

logic pcie_tx_tready;

//**************************
// Interface assignment
//**************************
// MMIO input
assign mmio_tx_st = i_mmio_tx_st.tx;
assign i_mmio_tx_st.tready = mmio_tx_tready_q;

// AFU input
assign afu_tx_st = i_afu_tx_st.tx;
assign i_afu_tx_st.tready = afu_tx_tready_q;

// MSIX input, not implemented yet
assign msix_tx_st = i_msix_tx_st.tx;
assign i_msix_tx_st.tready = msix_tx_tready_q;

// PCIe Tx output to upstream
assign o_pcie_tx_st.tx    = pcie_tx_q;
assign o_pcie_tx_st.clk   = clk;
assign o_pcie_tx_st.rst_n = rst_n;
assign pcie_tx_tready     = o_pcie_tx_st.tready;

// State definitions for user state machine
typedef enum logic [4:0] {
   ARB_FSM_RESET,
   ARB_FSM_IDLE,
   ARB_FSM_MMIO,
   ARB_FSM_AFU,
   ARB_FSM_MSIX
} t_arbiter_state;

(* syn_encoding = "one-hot" *) t_arbiter_state arbiter_state;

typedef enum logic [2:0] {
   ISTREAM_NONE,
   ISTREAM_MMIO,
   ISTREAM_AFU,
   ISTREAM_MSIX
} t_input_streams;

(* syn_encoding = "one-hot" *) t_input_streams istream_last;

// Favor the AFU path. Allow AFU traffic while the arbiter is idle as long as
// no other ports have requests.
logic no_fim_tx_is_valid;
logic afu_tx_grant_while_idle;
logic afu_tx_is_eop;
t_arbiter_state afu_tx_state_from_idle;

// Grant AFU traffic in idle when only AFU traffic is present
assign no_fim_tx_is_valid = ~mmio_tx_st.tvalid && ~msix_tx_st.tvalid;
assign afu_tx_grant_while_idle = pcie_tx_tready && no_fim_tx_is_valid;

// Is the incoming AFU traffic EOP?
assign afu_tx_is_eop = ((afu_tx_st.tdata[1].valid & afu_tx_st.tdata[1].eop) ||
                        (afu_tx_st.tdata[0].valid & afu_tx_st.tdata[0].eop & ~afu_tx_st.tdata[1].valid));

// Does the AFU traffic need to hold AFU arbitration now that it was granted
// during idle?
assign afu_tx_state_from_idle =
   (afu_tx_grant_while_idle && afu_tx_is_eop) ? ARB_FSM_IDLE : ARB_FSM_AFU;


// Fair arbiter between MMIO, AFU, and MSIX interrupt streams
always_ff @(posedge clk) begin : ARB_FSM
   case (arbiter_state)
      // ---------------------------------------------------
      ARB_FSM_RESET:
      begin
         arbiter_state                 <= ARB_FSM_RESET;
         istream_last                  <= ISTREAM_NONE;
         if (rst_n) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_IDLE:
      begin
         arbiter_state                 <= ARB_FSM_IDLE;
         case (istream_last)
            ISTREAM_MMIO:
            begin
               if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
            ISTREAM_AFU:
            begin
               if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
            default:
            begin
               if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
         endcase
      end
      // ---------------------------------------------------
      ARB_FSM_MMIO:
      begin
         arbiter_state                 <= ARB_FSM_MMIO;
         istream_last                  <= ISTREAM_MMIO;
         if (pcie_tx_tready & mmio_tx_st.tvalid & mmio_tx_st.tdata.valid & mmio_tx_st.tdata.eop) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_AFU:
      begin
         arbiter_state                 <= ARB_FSM_AFU;
         istream_last                  <= ISTREAM_AFU;
         if (pcie_tx_tready & afu_tx_st.tvalid & afu_tx_is_eop) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_MSIX:
      begin
         arbiter_state                 <= ARB_FSM_MSIX;
         istream_last                  <= ISTREAM_MSIX;
         if (pcie_tx_tready & msix_tx_st.tvalid & msix_tx_st.tdata.valid & msix_tx_st.tdata.eop) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      default:
      begin
         // something went wrong
         arbiter_state                 <= ARB_FSM_RESET;
      end
   endcase // arbiter_state

   if(~rst_n) begin
      arbiter_state                    <= ARB_FSM_RESET;
   end
end : ARB_FSM

always_comb begin 
   // Arbitrate
   case (arbiter_state)
      ARB_FSM_MMIO:
      begin
         afu_tx_tready_q                     = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         mmio_tx_tready_q                    = pcie_tx_tready;
         pcie_tx_q.tvalid                    = mmio_tx_st.tvalid;
         pcie_tx_q.tlast                     = mmio_tx_st.tlast;
         pcie_tx_q.tdata[0]                  = mmio_tx_st.tdata;
         pcie_tx_q.tuser[0]                  = mmio_tx_st.tuser;
         if (FIM_PCIE_TLP_CH > 1) begin
            pcie_tx_q.tdata[1]               = '0;
            pcie_tx_q.tuser[1]               = '0;
         end
      end
      ARB_FSM_AFU:
      begin
         mmio_tx_tready_q                    = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = pcie_tx_tready;
         pcie_tx_q.tvalid                    = afu_tx_st.tvalid;
         pcie_tx_q.tlast                     = afu_tx_st.tlast;
         pcie_tx_q.tdata                     = afu_tx_st.tdata;
         pcie_tx_q.tuser                     = afu_tx_st.tuser;
      end
      ARB_FSM_MSIX:
      begin
         mmio_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = 1'b0;
         msix_tx_tready_q                    = pcie_tx_tready;
         pcie_tx_q.tvalid                    = msix_tx_st.tvalid;
         pcie_tx_q.tlast                     = msix_tx_st.tlast;
         pcie_tx_q.tdata[0]                  = msix_tx_st.tdata;
         pcie_tx_q.tuser[0]                  = msix_tx_st.tuser;
         if (FIM_PCIE_TLP_CH > 1) begin
            pcie_tx_q.tdata[1]               = '0;
            pcie_tx_q.tuser[1]               = '0;
         end
      end
      default:
      begin
         mmio_tx_tready_q                    = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = afu_tx_grant_while_idle;
         pcie_tx_q.tvalid                    = afu_tx_st.tvalid && no_fim_tx_is_valid;
         pcie_tx_q.tlast                     = afu_tx_st.tlast;
         pcie_tx_q.tdata                     = afu_tx_st.tdata;
         pcie_tx_q.tuser                     = afu_tx_st.tuser;
      end
   endcase
end

endmodule
