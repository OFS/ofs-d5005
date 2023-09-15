// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// Description : FLR reset sequence

`ifndef FLR_RST_SEQ_SV
`define FLR_RST_SEQ_SV

class flr_rst_seq extends enumerate_seq;
    `uvm_object_utils(flr_rst_seq)

     rand bit unset;
     rand bit debug;
     rand int bdf; // 0: pf0
                   // 1: vf0
		   // 2: vf1
		   // 3: vf2

     constraint debug_c { soft debug == 0; }
     constraint bdf_c { soft bdf == 0; }

    function new(string name = "flr_rst_seq");
        super.new(name);
    endfunction : new

    virtual task body();
       	bit [31:0] rdata, wdata;
       	if(debug) begin
	    cfg_rd(bdf, 'h10, rdata);
	end
	else begin
	    if(!unset) begin
	        cfg_rd(bdf, 'h78, rdata);
	        wdata = rdata | 32'h0000_8000;
	        cfg_wr(bdf, 'h78, wdata);
	    end
	    else begin
	        cfg_rd(bdf, 'h78, rdata);
	        rdata[15] = 0;
	        cfg_wr(bdf, 'h78, rdata);
	    end
	end
    endtask : body

endclass : flr_rst_seq

`endif // FLR_RST_SEQ_SV
