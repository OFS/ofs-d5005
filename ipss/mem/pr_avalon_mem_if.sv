// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef __PR_AVALON_MM_IF_SV__
`define __PR_AVALON_MM_IF_SV__

//
// This is a private interface defining the platform-specific local memory
// controller interface.  This interface is used in the transition across
// the PR boundary inside Intel-provided logic.  The interface is subject
// to change.
//

interface pr_avalon_mem_if
  #(
    parameter ADDR_WIDTH = 27,
    parameter DATA_WIDTH = 576,
    parameter BURSTCOUNT_WIDTH = 7
    )
    ();

    // Number of bytes in a data line
    localparam DATA_N_BYTES = DATA_WIDTH / 8;

    // There is no reset -- just clk.  Waitrequest will be active when no requests
    // are permitted.
    logic                        clk;

    // Signals
    logic                        waitrequest;
    logic [DATA_WIDTH-1:0]       readdata;
    logic                        readdatavalid;

    logic [BURSTCOUNT_WIDTH-1:0] burstcount;
    logic [DATA_WIDTH-1:0]       writedata;
    logic [ADDR_WIDTH-1:0]       address;
    logic                        write;
    logic                        read;
    logic [DATA_N_BYTES-1:0]     byteenable;

    logic                        ecc_interrupt;

    //
    // Connection to the platform (FPGA Interface Manager)
    //
    modport to_fiu
       (
        input  clk,

        input  waitrequest,
        input  readdata,
        input  readdatavalid,

        output burstcount,
        output writedata,
        output address,
        output write,
        output read,
        output byteenable,

	input  ecc_interrupt
        );


    //
    // Connection to the AFU (user logic)
    //
    modport to_afu
       (
        output clk,

        output waitrequest,
        output readdata,
        output readdatavalid,

        input  burstcount,
        input  writedata,
        input  address,
        input  write,
        input  read,
        input  byteenable,

        output ecc_interrupt
        );


    //
    // Monitoring port -- all signals are input
    //
    modport monitor
       (
        input  waitrequest,
        input  readdata,
        input  readdatavalid,

        input  burstcount,
        input  writedata,
        input  address,
        input  write,
        input  read,
        input  byteenable,

	input  ecc_interrupt
        );

endinterface // pr_avalon_mem_if

`endif // __PR_AVALON_MM_IF_SV__
