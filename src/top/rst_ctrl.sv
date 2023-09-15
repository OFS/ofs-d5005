// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
//   System reset controller
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Module ports
//-----------------------------------------------------------------------------
import ofs_fim_if_pkg::*;
import ofs_fim_cfg_pkg::*;

module rst_ctrl #(
   parameter  SYNC_RESET_MIN_WIDTH = 256,
   parameter  PF0_NUM_VF = FIM_NUM_VF,
   parameter  PF1_NUM_VF = 0
)(
input         clk_1x,              // Global clock
input         clk_div2,            // Global clock divide by 2
input         clk_100M,            // Clock 100 MHz
input         pll_locked,          // PLL locked flag
input         pcie_reset_n,        // PCIe pin_perst (active low)
input         pcie_reset_status,   // PCIe SRC reset status
              
output        ninit_done,          // FPGA initialization done (active low)
output        npor,                // PCIe PowerOn reset (active low)
output  reg   rst_n,               // Asynchronous system reset
output  reg   pwr_good_clk_n,      // power good reset synchronous to clk_1x
output  reg   rst_n_1x,            // System reset synchronous to clk_1x
output  reg   rst_n_div2,          // System reset synchronous to clk_div2
output  reg   rst_n_100M,          // System reset synchronous to clk_100M

// Function Level Reset sideband
input  t_sideband_from_pcie p2c_sideband,
output t_sideband_to_pcie   c2p_sideband,

// Function Level Reset request
output logic [PF0_NUM_VF:0] pf0_flrst_n,
output logic [PF1_NUM_VF:0] pf1_flrst_n
);
wire          rst_n_d;              
wire          rst_n_1x_d;           
wire          rst_n_div2_d;         
wire          rst_n_100M_d;
logic         pll_locked_w;
        
// pwr_good_clk_n did not simulate well. Only one clock went by before pll_locked went hi. So we added the below.
`ifdef SIM_MODE
   initial begin
      pll_locked_w = 1'b0;
      #127ns;
      pll_locked_w = 1'b1;
   end
`else
   assign pll_locked_w = pll_locked;
`endif

assign npor = pcie_reset_n && ~ninit_done; 
assign rst_n = npor && pll_locked_w && ~pcie_reset_status;

//-----------------------------------------------------------------------------
// Modules instances
//-----------------------------------------------------------------------------

// Configuration reset release IP

`ifdef SIM_MODE
assign ninit_done = 1'b0;
`else
cfg_mon cfg_mon (
    .ninit_done (ninit_done)
);
`endif

// Reset syncronizers

altera_std_synchronizer_nocut rst_clk1x_sync (
   .clk     (clk_1x     ),
// .reset_n (rst_n      ),
// .din     (1'b1       ),
   .reset_n (1'b1       ),
   .din     (rst_n      ),
   .dout    (rst_n_1x_d )
);
always @(posedge clk_1x) rst_n_1x <= rst_n_1x_d;

altera_std_synchronizer_nocut rst_clkdiv2_sync (
   .clk     (clk_div2   ),
// .reset_n (rst_n      ),
// .din     (1'b1       ),
   .reset_n (1'b1       ),
   .din     (rst_n      ),
   .dout    (rst_n_div2_d)
);
always @(posedge clk_div2) rst_n_div2 <= rst_n_div2_d;

altera_std_synchronizer_nocut rst_clk100M_sync (
   .clk     (clk_100M   ),
// .reset_n (rst_n      ),
// .din     (1'b1       ),
   .reset_n (1'b1       ),
   .din     (rst_n      ),
   .dout    (rst_n_100M_d)
);
always @(posedge clk_100M) rst_n_100M <= rst_n_100M_d;

// FLR loopback

typedef enum {
    RESET_HOLD_BIT,
    RESET_SET_BIT,
    RESET_DEACT_BIT,
    RESET_CLEAR_BIT, 
    RESET_STATE_MAX
} reset_control_idx;		

typedef enum logic [RESET_STATE_MAX-1:0] {
    RESET_HOLD  = (1 << RESET_HOLD_BIT),
    RESET_SET   = (1 << RESET_SET_BIT),
    RESET_DEACT = (1 << RESET_DEACT_BIT),
    RESET_CLEAR = (1 << RESET_CLEAR_BIT)
} t_fsm_reset;

t_fsm_reset     vf_fsm_reset, vf_fsm_reset_next,
                pf0_fsm_reset, pf0_fsm_reset_next,
                pf1_fsm_reset, pf1_fsm_reset_next;
                
logic           vf_softreset, vf_softreset_next,
                pf0_softreset, pf0_softreset_next,
                pf1_softreset, pf1_softreset_next;
                
logic [$clog2(SYNC_RESET_MIN_WIDTH):0]
                vf_reset_pulse_width, vf_reset_pulse_width_next,
                pf0_reset_pulse_width, pf0_reset_pulse_width_next,
                pf1_reset_pulse_width, pf1_reset_pulse_width_next;
                
logic           vf_reset_done_state,
                pf0_reset_done_state,
                pf1_reset_done_state;
                
logic           flr_active_vf,
                flr_active_pf0,
                flr_active_pf1;

logic                       flr_rcvd_vf_flag;
logic   [FIM_VF_WIDTH-1:0]  flr_rcvd_vf_num;
logic   [FIM_PF_WIDTH-1:0]  flr_rcvd_pf_num;

integer i;

always_comb
begin
    flr_active_vf   = flr_rcvd_vf_flag;   
    flr_active_pf0  = p2c_sideband.flr_active_pf[0];
    flr_active_pf1  = p2c_sideband.flr_active_pf[1];
    
    c2p_sideband.flr_completed_vf_num
                    = flr_rcvd_vf_num;
    c2p_sideband.flr_completed_pf_num
                    = flr_rcvd_pf_num;
    c2p_sideband.flr_completed_vf
                    = vf_reset_done_state && flr_rcvd_vf_flag;

    c2p_sideband.flr_completed_pf
                    = '0;
    c2p_sideband.flr_completed_pf[0]
                    = pf0_reset_done_state && p2c_sideband.flr_active_pf[0];
    c2p_sideband.flr_completed_pf[1]
                    = pf1_reset_done_state && p2c_sideband.flr_active_pf[1];                    
end

always_ff @ ( posedge clk_1x )
begin
    vf_reset_done_state     = vf_fsm_reset[RESET_DEACT_BIT];
    pf0_reset_done_state    = pf0_fsm_reset[RESET_DEACT_BIT];
    pf1_reset_done_state    = pf1_fsm_reset[RESET_DEACT_BIT];
end

always_ff @ ( posedge clk_1x )
begin
    if ( !rst_n_1x )
    begin
        flr_rcvd_vf_flag    <= 1'b0;
        flr_rcvd_vf_num     <= '0;
        flr_rcvd_pf_num     <= '0;
    end
    else
    if ( p2c_sideband.flr_rcvd_vf )
    begin
        flr_rcvd_vf_flag    <= 1'b1;
        flr_rcvd_vf_num     <= p2c_sideband.flr_rcvd_vf_num;
        flr_rcvd_pf_num     <= p2c_sideband.flr_rcvd_pf_num;
    end
    else
    if ( c2p_sideband.flr_completed_vf )
    begin
        flr_rcvd_vf_flag    <= 1'b0;
        flr_rcvd_vf_num     <= '0;
        flr_rcvd_pf_num     <= '0;
    end
end

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!                  ASSUMPTION                        !!
// !! ONLY (1) FLR_RCVD_VF -> FLR_COMPLETED_VF AT A TIME !!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

always_ff @ ( posedge clk_1x )
begin
    if ( !rst_n_1x )
    begin
        pf0_flrst_n         <= '0;
        pf1_flrst_n         <= '0;
    end
    else
    begin
        pf0_flrst_n         <= '{default:'1};
        pf1_flrst_n         <= '{default:'1};
            
        pf0_flrst_n[0]      <= p2c_sideband.flr_active_pf[0]
                                            && pf0_softreset ?  1'b0 :
                                                                1'b1;
                                                                
        pf1_flrst_n[0]      <= p2c_sideband.flr_active_pf[1]
                                            && pf1_softreset ?  1'b0 :
                                                                1'b1;

        if ( vf_softreset )
        begin          
            case ( flr_rcvd_pf_num )
            
                0:
                begin
                    for ( i = 0 ; i < PF0_NUM_VF ; i++ )
                        pf0_flrst_n[i+1]    <= ( flr_rcvd_vf_num == i ) ?   1'b0 :
                                                                            1'b1;
                end
                
                1:
                begin
                    for ( i = 0 ; i < PF1_NUM_VF ; i++ )
                        pf1_flrst_n[i+1]    <= ( flr_rcvd_vf_num == i ) ?   1'b0 :
                                                                            1'b1;
                end
                
            endcase
        end
    end
end

always_ff @ ( posedge clk_1x )
begin
    if ( !rst_n_1x )
    begin
        vf_fsm_reset           <= RESET_HOLD;
        vf_reset_pulse_width   <= '0;
        vf_softreset           <= 1'b1;
    end
    else
    begin
        vf_fsm_reset           <= vf_fsm_reset_next;
        vf_reset_pulse_width   <= vf_reset_pulse_width_next;
        vf_softreset           <= vf_softreset_next;
    end
end

always_comb
begin
    vf_fsm_reset_next          = vf_fsm_reset;
    vf_reset_pulse_width_next  = vf_reset_pulse_width;
    vf_softreset_next          = vf_softreset;
      
    unique case ( 1'b1 )
    
        vf_fsm_reset[RESET_HOLD_BIT] :
        begin
            if ( vf_reset_pulse_width[$clog2(SYNC_RESET_MIN_WIDTH)] )
            begin
                vf_fsm_reset_next          = RESET_DEACT;
            end
            else
            begin
                vf_reset_pulse_width_next  = vf_reset_pulse_width + 1'b1;
            end
        end
        
        vf_fsm_reset[RESET_DEACT_BIT] :
        begin
            vf_softreset_next          = 1'b0;
            
            if ( !flr_active_vf )
                vf_fsm_reset_next          = RESET_CLEAR;
        end
        
        vf_fsm_reset[RESET_CLEAR_BIT] :
        begin
            if ( flr_active_vf )
                vf_fsm_reset_next          = RESET_SET;
        end
        
        vf_fsm_reset[RESET_SET_BIT] :
        begin
            vf_softreset_next          = 1'b1;            
            vf_reset_pulse_width_next  = '0;
            
            // Stall logic to not terminate multi-CL write?
            vf_fsm_reset_next          = RESET_HOLD;
        end
        
    endcase
end

always_ff @ ( posedge clk_1x )
begin
    if ( !rst_n_1x )
    begin
        pf0_fsm_reset           <= RESET_HOLD;
        pf0_reset_pulse_width   <= '0;
        pf0_softreset           <= 1'b1;
    end
    else
    begin
        pf0_fsm_reset           <= pf0_fsm_reset_next;
        pf0_reset_pulse_width   <= pf0_reset_pulse_width_next;
        pf0_softreset           <= pf0_softreset_next;
    end
end

always_comb
begin
    pf0_fsm_reset_next          = pf0_fsm_reset;
    pf0_reset_pulse_width_next  = pf0_reset_pulse_width;
    pf0_softreset_next          = pf0_softreset;
      
    unique case ( 1'b1 )
    
        pf0_fsm_reset[RESET_HOLD_BIT] :
        begin
            if ( pf0_reset_pulse_width[$clog2(SYNC_RESET_MIN_WIDTH)] )
            begin
                pf0_fsm_reset_next          = RESET_DEACT;
            end
            else
            begin
                pf0_reset_pulse_width_next  = pf0_reset_pulse_width + 1'b1;
            end
        end
        
        pf0_fsm_reset[RESET_DEACT_BIT] :
        begin
            pf0_softreset_next          = 1'b0;
            
            if ( !flr_active_pf0 )
                pf0_fsm_reset_next          = RESET_CLEAR;
        end
        
        pf0_fsm_reset[RESET_CLEAR_BIT] :
        begin
            if ( flr_active_pf0 )
                pf0_fsm_reset_next          = RESET_SET;
        end
        
        pf0_fsm_reset[RESET_SET_BIT] :
        begin
            pf0_softreset_next          = 1'b1;            
            pf0_reset_pulse_width_next  = '0;
            
            // Stall logic to not terminate multi-CL write?
            pf0_fsm_reset_next          = RESET_HOLD;
        end
        
    endcase
end

always_ff @ ( posedge clk_1x )
begin
    if ( !rst_n_1x )
    begin
        pf1_fsm_reset           <= RESET_HOLD;
        pf1_reset_pulse_width   <= '0;
        pf1_softreset           <= 1'b1;
    end
    else
    begin
        pf1_fsm_reset           <= pf1_fsm_reset_next;
        pf1_reset_pulse_width   <= pf1_reset_pulse_width_next;
        pf1_softreset           <= pf1_softreset_next;
    end
end

always_comb
begin
    pf1_fsm_reset_next          = pf1_fsm_reset;
    pf1_reset_pulse_width_next  = pf1_reset_pulse_width;
    pf1_softreset_next          = pf1_softreset;
      
    unique case ( 1'b1 )
    
        pf1_fsm_reset[RESET_HOLD_BIT] :
        begin
            if ( pf1_reset_pulse_width[$clog2(SYNC_RESET_MIN_WIDTH)] )
            begin
                pf1_fsm_reset_next          = RESET_DEACT;
            end
            else
            begin
                pf1_reset_pulse_width_next  = pf1_reset_pulse_width + 1'b1;
            end
        end
        
        pf1_fsm_reset[RESET_DEACT_BIT] :
        begin
            pf1_softreset_next          = 1'b0;
            
            if ( !flr_active_pf1 )
                pf1_fsm_reset_next          = RESET_CLEAR;
        end
        
        pf1_fsm_reset[RESET_CLEAR_BIT] :
        begin
            if ( flr_active_pf1 )
                pf1_fsm_reset_next          = RESET_SET;
        end
        
        pf1_fsm_reset[RESET_SET_BIT] :
        begin
            pf1_softreset_next          = 1'b1;            
            pf1_reset_pulse_width_next  = '0;
            
            // Stall logic to not terminate multi-CL write?
            pf1_fsm_reset_next          = RESET_HOLD;
        end
        
    endcase
end

// FIM power good reset synchronous to clk_1x
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) pwr_good_clk_n_resync (
   .clk   (clk_1x),
   .reset (~pll_locked_w | ninit_done),
   .d     (1'b1),
   .q     (pwr_good_clk_n)
);

endmodule
