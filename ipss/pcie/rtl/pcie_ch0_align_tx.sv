// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// Realign the AXI-S PCIe TX stream so that SOP typically begins on ch0.
// The PCIe SS adapter tends to put SOP in ch1 and the downstream PCIe
// bridge is more efficient when SOP is in ch0.
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"

module pcie_ch0_align_tx
   (
    input  logic clk,
    input  logic rst_n,

    ofs_fim_pcie_txs_axis_if.slave axis_tx_st_in,
    ofs_fim_pcie_txs_axis_if.master axis_tx_st_out
    );

    import ofs_fim_if_pkg::*;
    import ofs_fim_pcie_pkg::*;

    assign axis_tx_st_out.clk = axis_tx_st_in.clk;
    assign axis_tx_st_out.rst_n = axis_tx_st_in.rst_n;

    t_axis_pcie_txs tx_in;
    assign tx_in = axis_tx_st_in.tx;

    generate
        if (FIM_PCIE_TLP_CH != 2)
        begin
            // The code in this module is optimized for two parallel TLP
            // channels. If the configuration is something else, just pass
            // the messages straight through.
            assign axis_tx_st_in.tready = axis_tx_st_out.tready;
            assign axis_tx_st_out.tx = tx_in;
        end
        else
        begin
            // Preserved TX message from previous cycle, not yet forwarded
            // if prev_tx.tvalid is set.
            t_axis_pcie_txs prev_tx;

            // Construct the output stream, either from the input directly or
            // by shifting the input using a combination of state from the previous
            // message plus the current input.
            always_comb
            begin
                axis_tx_st_in.tready = 1'b0;

                axis_tx_st_out.tx = tx_in;
                axis_tx_st_out.tx.tvalid = 1'b0;

                if (prev_tx.tvalid)
                begin
                    if (prev_tx.tdata[1].eop)
                    begin
                        // Previous message saved, but it is the end of a command.
                        // Send just the EOP and don't consume the input stream.
                        axis_tx_st_in.tready = 1'b0;
                        axis_tx_st_out.tx.tvalid = 1'b1;
                        axis_tx_st_out.tx.tlast = 1'b1;
                        axis_tx_st_out.tx.tdata[0] = prev_tx.tdata[1];
                        axis_tx_st_out.tx.tdata[1] = '0;
                        axis_tx_st_out.tx.tuser[0] = prev_tx.tuser[1];
                        axis_tx_st_out.tx.tuser[1] = '0;
                    end
                    else
                    begin
                        // Shift the input, combining the previous message and
                        // the new one. The part of the new message that doesn't
                        // fit will be stored in prev_tx below.
                        axis_tx_st_in.tready = axis_tx_st_out.tready;
                        axis_tx_st_out.tx.tvalid = tx_in.tvalid;
                        axis_tx_st_out.tx.tlast = tx_in.tdata[0].eop;
                        axis_tx_st_out.tx.tdata[0] = prev_tx.tdata[1];
                        axis_tx_st_out.tx.tdata[1] = tx_in.tdata[0];
                        axis_tx_st_out.tx.tuser[0] = prev_tx.tuser[1];
                        axis_tx_st_out.tx.tuser[1] = tx_in.tuser[0];
                    end
                end
                else if (tx_in.tvalid)
                begin
                    if (tx_in.tdata[0].valid)
                    begin
                        // Slot 0 is used and no previous state recorded. Pass through.
                        axis_tx_st_in.tready = axis_tx_st_out.tready;
                        axis_tx_st_out.tx.tvalid = 1'b1;
                    end
                    else if (tx_in.tdata[1].valid &&
                             tx_in.tdata[1].sop && !tx_in.tdata[1].eop)
                    begin
                        // Consume the input, but it will only be saved in prev_tx
                        // below. The channel 1 SOP will be moved to channel 0.
                        axis_tx_st_in.tready = 1'b1;
                        axis_tx_st_out.tx.tvalid = 1'b0;
                    end
                    else
                    begin
                        // If a message exists in the input stream, it is only
                        // in channel 1 and is also eop. Shift it to channel 0.
                        axis_tx_st_in.tready = axis_tx_st_out.tready;
                        axis_tx_st_out.tx.tvalid = tx_in.tdata[1].valid;
                        axis_tx_st_out.tx.tdata[0] = tx_in.tdata[1];
                        axis_tx_st_out.tx.tuser[0] = tx_in.tuser[1];
                        axis_tx_st_out.tx.tdata[1].valid = 1'b0;
                        axis_tx_st_out.tx.tdata[1].sop = 1'b0;
                        axis_tx_st_out.tx.tdata[1].eop = 1'b0;
                    end
                end
            end

            always_ff @(posedge clk)
            begin
                // A message was passed to the outbound interface, so whatever
                // was in prev_tx is now gone.
                if (axis_tx_st_out.tready && axis_tx_st_out.tx.tvalid)
                begin
                    prev_tx.tvalid <= 1'b0;
                end

                // Something came from the input stream. Does it need to be stored
                // in prev_tx or was it forwarded completely to the output stream?
                if (axis_tx_st_in.tready && tx_in.tvalid)
                begin
                    prev_tx <= tx_in;
                    // Slot 1 is not forwarded immediately if:
                    //  - There was previously buffered state. In this case, slot
                    //    0 will be forwarded directly, but slot 1 won't fit so
                    //    must be saved.
                    //  - Slot 0 of the input is empty and slot 1 begins but does
                    //    not end a new command.
                    prev_tx.tvalid <= tx_in.tdata[1].valid &&
                                      (prev_tx.tvalid ||
                                       (!tx_in.tdata[0].valid && tx_in.tdata[1].valid &&
                                        tx_in.tdata[1].sop && !tx_in.tdata[1].eop));
                end

                if (!rst_n)
                begin
                    prev_tx.tvalid <= 1'b0;
                end
            end
        end
    endgenerate

endmodule // pcie_ch0_align_tx
