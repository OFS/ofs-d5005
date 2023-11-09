// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

`timescale 1 ps / 1 ps
import ofs_fim_eth_if_pkg::*;
import hssi_csr_pkg::*;

module altera_eth_10g_mac_base_r_wrap (
	// clock and reset
	input wire 			csr_clk,
	input wire			csr_rst_n,
	input wire			tx_clk_312,
	input wire			tx_clk_156,
	input wire			sync_tx_rst_n,
	input wire			rx_clk_312,
	input wire			rx_clk_156,
	input wire			sync_rx_rst_n,
	
	input wire			ref_clk_clk,
	
	//avlon_st tx interface
	input wire			avalon_st_tx_startofpacket,
	input wire			avalon_st_tx_endofpacket,
	input wire			avalon_st_tx_valid,
	input wire	[31:0]	avalon_st_tx_data,
	input wire 	[1:0]	avalon_st_tx_empty,
	input wire			avalon_st_tx_error,
	output wire			avalon_st_tx_ready,
	
	// avalon_st rx interface
	output wire			avalon_st_rx_startofpacket,
	output wire			avalon_st_rx_endofpacket,
	output wire			avalon_st_rx_valid,
	output wire	[31:0]	avalon_st_rx_data,
	output wire [1:0]	avalon_st_rx_empty,
	input wire 			avalon_st_rx_ready,
	output wire [5:0]	avalon_st_rx_error,
		
	// additional st interface
	input wire	[1:0]	avalon_st_pause_data,
    input  wire [15:0] avalon_st_tx_pfc_gen_data,       //  avalon_st_tx_pfc_gen_data.export
    output wire [7:0]  avalon_st_rx_pfc_pause_data,  
	output wire        	avalon_st_txstatus_valid,
	output wire [39:0] 	avalon_st_txstatus_data, 
	output wire [6:0]  	avalon_st_txstatus_error,
	
	output wire        	avalon_st_rxstatus_valid,                                  
	output wire [6:0]  	avalon_st_rxstatus_error,                                  
	output wire [39:0] 	avalon_st_rxstatus_data,

	output wire [1:0]  	link_fault_status_xgmii_rx_data,
	
	// reset controller
	output wire			tx_ready_export,
	output wire			rx_ready_export,
	output wire			block_lock,
    input wire          atx_pll_locked,
	
	output wire			tx_serial_data,
	input wire			rx_serial_data,
    
    input  wire			mac_csr_read,
    input  wire			mac_csr_write,
    output wire	[31:0]	mac_csr_readdata,
    input  wire [31:0]	mac_csr_writedata,
    output wire         mac_csr_waitrequest,
    input  wire [9:0]   mac_csr_address,
    
    input  wire         phy_csr_read,
    input  wire         phy_csr_write,
    output wire [31:0]  phy_csr_readdata,
    input  wire [31:0]  phy_csr_writedata,
    output wire         phy_csr_waitrequest,
    input  wire [10:0]  phy_csr_address,

    input  wire         tx_serial_clk,
    input  wire         final_channel_rst,
    input  wire         final_reconfig_rst,
    output hssi_stats_struct_t   hssi_stats
   
);


wire [7:0]		xgmii_tx_control;
wire [63:0]		xgmii_tx_data;
wire [71:0]     xgmii_tx;

wire [7:0]		xgmii_rx_control;
wire [63:0]		xgmii_rx_data;
wire [71:0]     xgmii_rx;

reg  [71:0]     xgmii_tx_reg;
reg  [71:0]     xgmii_rx_reg;

//reset controller
wire            tx_analogreset;
wire            tx_digitalreset;	
wire            rx_analogreset;
wire            rx_digitalreset;	
wire            rx_analogreset_stat;  
wire            rx_digitalreset_stat; 
wire            tx_analogreset_stat;  
wire            tx_digitalreset_stat; 
wire            tx_transfer_ready;
wire            rx_transfer_ready;
wire            tx_fifo_ready;    
wire            rx_fifo_ready; 
wire            rx_digitalreset_timeout;
wire            tx_digitalreset_timeout;
wire            rx_is_lockedtoref;
wire            rx_is_lockedtodata;	
wire			tx_cal_busy;
wire			rx_cal_busy;

wire			tx_clkout;
wire			rx_clkout;



        // Map HSSI stats signals to structs
        assign hssi_stats.rx_ready                    = rx_ready_export;
        assign hssi_stats.tx_ready                    = tx_ready_export;
        assign hssi_stats.rx_is_lockedtoref           = rx_is_lockedtoref ;
        assign hssi_stats.rx_is_lockedtodata          = rx_is_lockedtodata;
        assign hssi_stats.rx_cal_busy                 = rx_cal_busy;
        assign hssi_stats.tx_cal_busy                 = tx_cal_busy;
        assign hssi_stats.rx_transfer_ready           = rx_transfer_ready;      
        assign hssi_stats.tx_transfer_ready           = tx_transfer_ready;      
        assign hssi_stats.rx_fifo_ready               = rx_fifo_ready;          
        assign hssi_stats.tx_fifo_ready               = tx_fifo_ready;          
        assign hssi_stats.rx_digitalreset_timeout     = rx_digitalreset_timeout;
        assign hssi_stats.tx_digitalreset_timeout     = tx_digitalreset_timeout;
        assign hssi_stats.rx_digitalreset_stat        = rx_digitalreset_stat;
        assign hssi_stats.rx_analogreset_stat         = rx_analogreset_stat;
        assign hssi_stats.tx_digitalreset_stat        = tx_digitalreset_stat;
        assign hssi_stats.tx_analogreset_stat         = tx_analogreset_stat;
        


assign xgmii_tx_data = {
   xgmii_tx_reg[70:63],
   xgmii_tx_reg[61:54],
   xgmii_tx_reg[52:45],
   xgmii_tx_reg[43:36],
   xgmii_tx_reg[34:27],
   xgmii_tx_reg[25:18],
   xgmii_tx_reg[16:9],
   xgmii_tx_reg[7:0]
};

assign xgmii_tx_control = {
   xgmii_tx_reg[71],
   xgmii_tx_reg[62],
   xgmii_tx_reg[53],
   xgmii_tx_reg[44],
   xgmii_tx_reg[35],
   xgmii_tx_reg[26],
   xgmii_tx_reg[17],
   xgmii_tx_reg[8]
};

assign xgmii_rx = {
   xgmii_rx_control[7], xgmii_rx_data[63:56],
   xgmii_rx_control[6], xgmii_rx_data[55:48],
   xgmii_rx_control[5], xgmii_rx_data[47:40],
   xgmii_rx_control[4], xgmii_rx_data[39:32],
   xgmii_rx_control[3], xgmii_rx_data[31:24],
   xgmii_rx_control[2], xgmii_rx_data[23:16],
   xgmii_rx_control[1], xgmii_rx_data[15:8],
   xgmii_rx_control[0], xgmii_rx_data[7:0]};
   
always @(posedge tx_clk_156)
begin
    xgmii_tx_reg <= xgmii_tx;
end
    
always @(posedge rx_clk_156)
begin
    xgmii_rx_reg <= xgmii_rx;
end

altera_eth_10g_mac mac_inst (

	.csr_read					(mac_csr_read),                       
	.csr_write					(mac_csr_write),                      
	.csr_writedata				(mac_csr_writedata),                  
	.csr_readdata				(mac_csr_readdata),                   
	.csr_waitrequest			(mac_csr_waitrequest),                
	.csr_address				(mac_csr_address),                    
	.csr_clk					(csr_clk),                                               
	.csr_rst_n					(~final_reconfig_rst),                      
	.tx_rst_n					(sync_tx_rst_n),                       
	.rx_rst_n					(sync_rx_rst_n),                       
	.avalon_st_tx_startofpacket	(avalon_st_tx_startofpacket),     
	.avalon_st_tx_endofpacket	(avalon_st_tx_endofpacket),       
	.avalon_st_tx_valid			(avalon_st_tx_valid),             
	.avalon_st_tx_data			(avalon_st_tx_data),              
	.avalon_st_tx_empty			(avalon_st_tx_empty),             
	.avalon_st_tx_error			(avalon_st_tx_error),             
	.avalon_st_tx_ready			(avalon_st_tx_ready),             
	.avalon_st_pause_data		(avalon_st_pause_data),        
    .avalon_st_tx_pfc_gen_data  (avalon_st_tx_pfc_gen_data  ), 
    .avalon_st_rx_pfc_pause_data(avalon_st_rx_pfc_pause_data),   
	.avalon_st_txstatus_valid	(avalon_st_txstatus_valid),       
	.avalon_st_txstatus_data	(avalon_st_txstatus_data),        
	.avalon_st_txstatus_error	(avalon_st_txstatus_error),       
	.link_fault_status_xgmii_rx_data	(link_fault_status_xgmii_rx_data),
	.avalon_st_rx_data			(avalon_st_rx_data),              
	.avalon_st_rx_startofpacket	(avalon_st_rx_startofpacket),     
	.avalon_st_rx_valid			(avalon_st_rx_valid),             
	.avalon_st_rx_empty			(avalon_st_rx_empty),             
	.avalon_st_rx_error			(avalon_st_rx_error),             
	.avalon_st_rx_ready			(avalon_st_rx_ready),             
	.avalon_st_rx_endofpacket	(avalon_st_rx_endofpacket),       
	.avalon_st_rxstatus_valid	(avalon_st_rxstatus_valid),       
	.avalon_st_rxstatus_data	(avalon_st_rxstatus_data),        
	.avalon_st_rxstatus_error	(avalon_st_rxstatus_error),       

    .rx_156_25_clk          (rx_clk_156),
    .rx_312_5_clk           (rx_clk_312),
    .tx_156_25_clk          (tx_clk_156),
    .tx_312_5_clk           (tx_clk_312),

	.xgmii_rx				(xgmii_rx_reg),                 
	.xgmii_tx				(xgmii_tx)             	
	
);


altera_eth_10gbaser_phy baser_inst (

	.tx_analogreset				(tx_analogreset),
    .tx_digitalreset			(tx_digitalreset),
    .rx_analogreset				(rx_analogreset),
    .rx_digitalreset			(rx_digitalreset),
    .tx_transfer_ready          (tx_transfer_ready),              
	.rx_transfer_ready          (rx_transfer_ready),    
    .tx_fifo_ready              (tx_fifo_ready), 
	.rx_fifo_ready              (rx_fifo_ready), 
    .tx_cal_busy				(tx_cal_busy),
    .rx_cal_busy				(rx_cal_busy),
    .tx_serial_clk0				(tx_serial_clk),
    .rx_cdr_refclk0				(ref_clk_clk),
    .tx_serial_data				(tx_serial_data),
    .rx_serial_data				(rx_serial_data),
    .rx_is_lockedtoref			(rx_is_lockedtoref),
    .rx_is_lockedtodata			(rx_is_lockedtodata),
    .tx_coreclkin				(tx_clk_156),
    .rx_coreclkin				(rx_clk_156),
    .tx_clkout					(),
    .rx_clkout					(),
    .tx_parallel_data			(xgmii_tx_data),
    .rx_parallel_data			(xgmii_rx_data),
    .tx_control					(xgmii_tx_control),
    .tx_err_ins					(1'b0),
    .unused_tx_parallel_data	(6'b0),
     // .unused_tx_control			(9'b0),
    .rx_control					(xgmii_rx_control),
     // .tx_enh_data_valid			(xgmii_tx_valid),
     // .rx_enh_data_valid			(xgmii_rx_valid),
    .rx_enh_highber				(),
    .rx_enh_blk_lock			(block_lock),
    .unused_rx_parallel_data	(),
    // .unused_rx_control			(),    
    .rx_analogreset_stat  (rx_analogreset_stat),  //  rx_analogreset_stat.rx_analogreset_stat
    .rx_digitalreset_stat (rx_digitalreset_stat), // rx_digitalreset_stat.rx_digitalreset_stat
    .tx_analogreset_stat  (tx_analogreset_stat),  //  tx_analogreset_stat.tx_analogreset_stat
    .tx_digitalreset_stat (tx_digitalreset_stat), // tx_digitalreset_stat.tx_digitalreset_stat
    .tx_digitalreset_timeout           (tx_digitalreset_timeout),   
	.rx_digitalreset_timeout           (rx_digitalreset_timeout),   
    .reconfig_clk				(csr_clk),
    .reconfig_reset				(final_reconfig_rst),
    .reconfig_write				(phy_csr_write),
    .reconfig_read				(phy_csr_read),
    .reconfig_address			(phy_csr_address),
    .reconfig_writedata			(phy_csr_writedata),
    .reconfig_readdata			(phy_csr_readdata),
	.reconfig_waitrequest		(phy_csr_waitrequest)
    // .rx_pma_div_clkout          (),
    // .tx_pma_div_clkout          (),
    // .rx_enh_fifo_del            (),
    // .rx_enh_fifo_empty          (),
    // .rx_enh_fifo_full           (),
    // .rx_enh_fifo_insert         (),
    // .tx_enh_fifo_empty          (),
    // .tx_enh_fifo_full           (),
    // .tx_enh_fifo_pempty         (),
    // .tx_enh_fifo_pfull          ()

);



reset_control	reset_controller_inst(
    .clock				(csr_clk),              
    .reset				(final_channel_rst),  
    .tx_analogreset		(tx_analogreset),     
    .tx_digitalreset	(tx_digitalreset),    
    .tx_ready			(tx_ready_export),           
    .pll_locked			(atx_pll_locked),         
    .pll_select			(1'b0),         
    .tx_cal_busy		(tx_cal_busy),        
    .rx_analogreset		(rx_analogreset),     
    .rx_digitalreset	(rx_digitalreset),    
    .rx_analogreset_stat  (rx_analogreset_stat), 
    .rx_digitalreset_stat (rx_digitalreset_stat),
    .tx_analogreset_stat  (tx_analogreset_stat), 
    .tx_digitalreset_stat (tx_digitalreset_stat), 
    .rx_ready			(rx_ready_export),           
    .rx_is_lockedtodata	(rx_is_lockedtodata), 
    .rx_cal_busy 		(rx_cal_busy)        

);

endmodule 
