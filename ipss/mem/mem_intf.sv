// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// -----------------------------------------------------------------------------
// Create Date  : Jan 2021
// Module Name  : mem_intf_reorder
// Project      : OFS D5005
// Description  : Memory Channel Interleaving Module
// -----------------------------------------------------------------------------
//
// The main purpose of this module is to ensure responses from multi channel 
// EMIF are sent back in the same order as requests.
//
// This module receives memory requests from HE on a single AVMM interface and
// sends it out to the MC controller address-interleaved in either 1,2 or 4
// channels. The number of channels is specified by the MC_CHANNEL parameter.
//
// Memory Requests from HE are buffered in req_q. When req_q is full the AVMM
// interface is back pressured. Requests at the head of req_q are pushed to
// o_mc_* when i_mc_ready is 1.
// 
// To track the order of requests, the request channel no. is also buffered in
// req_trk_q every time HE sends a request.
//
// Read responses from EMIF are buffered in rsp_q. There is 1 rsp_q per channel.
//
// The ch no. at the head of req_trk_q decides which channel's rsp_q to wait 
// on. As soon as a response is available, it is pulled from the rsp_q and 
// returned on the o_he_readdata* interface. Simultaneously the ch no. from the 
// req_trk_q is also pulled and discarded.

//FUTURE_IMPROVEMENT: size response queue for burst size greater than one. 

module mem_intf_reorder #(
  parameter  MC_CHANNEL  = 1,
  parameter  DATA_WIDTH  = 576,
  parameter  ADDR_WIDTH  = 27,
  parameter  BURST_WIDTH = 7
)
(
  input  logic           clk                        ,
  input  logic           resetb                     ,

  ofs_fim_emif_avmm_if.user    mc_if    [MC_CHANNEL-1:0]  , //mem_intf to mem_controller
  ofs_fim_emif_avmm_if.emif    he_if                        //HE to mem_intf
);

localparam CH_W = (MC_CHANNEL == 1) ? 1 : $clog2(MC_CHANNEL); //CH_W is no. of bits to represent the channel

localparam BE_WIDTH               = DATA_WIDTH/8;

localparam REQ_FIFO_W             = DATA_WIDTH + BE_WIDTH + ADDR_WIDTH + BURST_WIDTH + 2; //read,write 
localparam REQ_FIFO_D_B2          = 4;                        
localparam REQ_FIFO_FULL_TH       = (2**REQ_FIFO_D_B2) - 8;

localparam REQ_TRK_FIFO_W         = CH_W+BURST_WIDTH;
localparam REQ_TRK_FIFO_D_B2      = 7;
localparam REQ_TRK_FIFO_FULL_TH   = (2**REQ_TRK_FIFO_D_B2) - 8;

localparam RSP_FIFO_W             = DATA_WIDTH; 
localparam RSP_FIFO_D_B2          = 6;
localparam RSP_FIFO_FULL_TH       = (2**RSP_FIFO_D_B2) - 8;   


logic [MC_CHANNEL-1:0]          i_mc_waitrequest                       ;//  input;   width = 1; 
logic [MC_CHANNEL-1:0]          o_mc_read                              ;// output;   width = 1; 
logic [MC_CHANNEL-1:0]          o_mc_write                             ;// output;   width = 1; 
logic [ADDR_WIDTH-1:0]          o_mc_address         [MC_CHANNEL-1:0]  ;// output;   width = 46; 
logic [DATA_WIDTH-1:0]          i_mc_readdata        [MC_CHANNEL-1:0]  ;//  input;   width = 512; 
logic [DATA_WIDTH-1:0]          o_mc_writedata       [MC_CHANNEL-1:0]  ;// output;   width = 512; 
logic [BE_WIDTH-1:0]            o_mc_byteenable      [MC_CHANNEL-1:0]  ;// output;   width = 64; 
logic [BURST_WIDTH-1:0]         o_mc_burstcount      [MC_CHANNEL-1:0]  ;// output;   width = 64; 
logic [MC_CHANNEL-1:0]          i_mc_readdatavalid                     ;//  input;   width = 1; 

logic                           req_wen; 
logic [REQ_FIFO_W-1:0]          req_din;
logic                           req_ren; 
logic [REQ_FIFO_W-1:0]          req_dout; 
logic                           req_full;
logic                           req_nemp; 
logic [1:0]                     req_ecc;
logic                           req_err;
logic                           req_wen_p; 
logic [REQ_FIFO_W-1:0]          req_din_p;
logic                           req_full_q;

logic                           req_trk_wen; 
logic [REQ_TRK_FIFO_W-1:0]      req_trk_din;
logic                           req_trk_ren; 
logic [REQ_TRK_FIFO_W-1:0]      req_trk_dout; 
logic                           req_trk_full;
logic                           req_trk_nemp; 
logic [1:0]                     req_trk_ecc;
logic                           req_trk_err;
logic                           req_trk_wen_p; 
logic [REQ_TRK_FIFO_W-1:0]      req_trk_din_p;
logic                           req_trk_full_q;

logic [MC_CHANNEL-1:0]          rsp_wen                   ;
logic [RSP_FIFO_W-1:0]          rsp_din  [MC_CHANNEL-1:0] ;
logic [MC_CHANNEL-1:0]          rsp_ren                   ;
logic [RSP_FIFO_W-1:0]          rsp_dout [MC_CHANNEL-1:0] ;
logic [MC_CHANNEL-1:0]          rsp_full                  ;
logic [MC_CHANNEL-1:0]          rsp_nemp                  ;
logic [1:0]                     rsp_ecc  [MC_CHANNEL-1:0] ; 
logic [MC_CHANNEL-1:0]          rsp_err                   ;

logic                           req_dout_read         ; 
logic                           req_dout_write        ;    
logic [ADDR_WIDTH-1:0]          req_dout_addr         ;   
logic [BURST_WIDTH-1:0]         req_dout_burstcount   ;   
logic [BE_WIDTH-1:0]            req_dout_be           ;      
logic [DATA_WIDTH-1:0]          req_dout_writedata    ;     

logic [MC_CHANNEL-1:0]          s0_waitrequest                     ;
logic [DATA_WIDTH-1:0]          s0_readdata      [MC_CHANNEL-1:0]  ;
logic [MC_CHANNEL-1:0]          s0_readdatavalid                   ;
logic [BURST_WIDTH-1:0]         s0_burstcount    [MC_CHANNEL-1:0]  ;
logic [DATA_WIDTH-1:0]          s0_writedata     [MC_CHANNEL-1:0]  ;
logic [ADDR_WIDTH-1:0]          s0_address       [MC_CHANNEL-1:0]  ;
logic [MC_CHANNEL-1:0]          s0_write                           ; 
logic [MC_CHANNEL-1:0]          s0_read                            ; 
logic [BE_WIDTH-1:0]            s0_byteenable    [MC_CHANNEL-1:0]  ;


logic [MC_CHANNEL-1:0]          i_mc_readdatavalid_T0                 ;
logic [DATA_WIDTH-1:0]          i_mc_readdata_T0      [MC_CHANNEL-1:0];

logic [MC_CHANNEL-1:0]          i_mc_readdatavalid_T1                 ;
logic [DATA_WIDTH-1:0]          i_mc_readdata_T1      [MC_CHANNEL-1:0];

logic [DATA_WIDTH-1:0]          o_he_readdata_T0; 
logic                           o_he_readdatavalid_T0;

logic [DATA_WIDTH-1:0]          o_he_readdata_T1; 
logic                           o_he_readdatavalid_T1;

logic [7:0]                     ErrorVector;

logic [BURST_WIDTH-1:0]         rdburstcount;

integer i, j, k;
genvar c;

//Convert interface to signals
for(c=0; c<MC_CHANNEL; c++)
begin: CH
  assign i_mc_waitrequest   [c]  = mc_if[c].waitrequest  ;     
  assign i_mc_readdata      [c]  = mc_if[c].readdata      ;   
  assign i_mc_readdatavalid [c]  = mc_if[c].readdatavalid ;  

  assign mc_if[c].read           = o_mc_read         [c]  ; 
  assign mc_if[c].write          = o_mc_write        [c]  ; 
  assign mc_if[c].address        = o_mc_address      [c]  ; 
  assign mc_if[c].writedata      = o_mc_writedata    [c]  ; 
  assign mc_if[c].byteenable     = o_mc_byteenable   [c]  ;
  assign mc_if[c].burstcount     = o_mc_burstcount   [c]  ;
end

assign he_if.clk           = clk;
assign he_if.rst_n         = resetb;
assign he_if.ecc_interrupt = 1'b0;

//Incoming requests from HE are buffered in req_q
assign he_if.waitrequest = req_full | req_trk_full;

always @ (posedge clk)
begin
  req_wen        <= (he_if.read | he_if.write) & (he_if.waitrequest == 1'b0);
  
  req_din        <= { he_if.read,                
                      he_if.write,               
                      he_if.address,             
                      he_if.burstcount,
                      he_if.byteenable,          
                      he_if.writedata           
                    };       

  //The channel number of each request is buffered in req_trk_q so that we
  //remember the order in which requests were received.
  //They are read when responses arrive so that response order is same as the
  //order of requests.
  req_trk_wen    <= he_if.read & (he_if.waitrequest == 1'b0);
  req_trk_din    <= (MC_CHANNEL > 1) ? {he_if.burstcount,he_if.address[CH_W-1:0]} : 0 ; //Stores the Ch no.


  //req_full_q       <= req_full;
  //req_trk_full_q   <= req_trk_full;

  //he_if.waitrequest <= req_full_q | req_trk_full_q;

  if(!resetb)
  begin
    req_wen       <= 1'b0;
    req_trk_wen   <= 1'b0;
  end
end //always_comb

// HA Request FIFO Output
assign {req_dout_read,           
        req_dout_write,         
        req_dout_addr,         
        req_dout_burstcount,  
        req_dout_be,         
        req_dout_writedata}  = req_dout;


        
// Request path to Memory controller 
// Check CH_NUM of head of req FIFO. Pop/drive if channel is free
// AVMM Pipeline Bridge used per channel to help with timing
generate 

if(MC_CHANNEL == 1)
begin

assign req_ren = (!resetb) ? 1'b0 : (req_nemp && (s0_waitrequest[0] == 1'b0)); 

//Assert read/write only for the CH that matches 
assign s0_read       [0] = req_nemp && req_dout_read;   
assign s0_write      [0] = req_nemp && req_dout_write;   
assign s0_burstcount [0] = req_dout_burstcount;//'h1;
assign s0_writedata  [0] = req_dout_writedata;
assign s0_address    [0] = req_dout_addr;
assign s0_byteenable [0] = req_dout_be;

end

else // (MC_CHANNEL > 1)
begin

assign req_ren = (!resetb) ? 1'b0 : (req_nemp && (s0_waitrequest[req_dout_addr[CH_W-1:0]] == 1'b0));

for(c=0; c<MC_CHANNEL; c++)
begin:MC_CH
  //Assert read/write only for the CH that matches 
  assign s0_read       [c] = req_nemp && req_dout_read  && (c == req_dout_addr[CH_W-1:0]);   
  assign s0_write      [c] = req_nemp && req_dout_write && (c == req_dout_addr[CH_W-1:0]);   
  assign s0_burstcount [c] = req_dout_burstcount;//'h1;
  assign s0_writedata  [c] = req_dout_writedata;
  assign s0_address    [c] = req_dout_addr >> CH_W;
  assign s0_byteenable [c] = req_dout_be;
end //for

end //if(MC_CHANNEL)

endgenerate


//1 AVMM pipeline bridge per channel to help with timing
generate
for(genvar c=0; c<MC_CHANNEL; c++)
begin: MEM_CH
  avmm_pipeline_bridge avmm_bridge_inst (
    .clk              ( clk                  ),//   clk.clk
    .reset            ( !resetb              ),// reset.reset
    .s0_waitrequest   ( s0_waitrequest   [c] ),//    s0.waitrequest
    .s0_readdata      (                      ),//      .readdata
    .s0_readdatavalid (                      ),//      .readdatavalid
    .s0_burstcount    ( s0_burstcount    [c] ),//      .burstcount
    .s0_writedata     ( s0_writedata     [c] ),//      .writedata
    .s0_address       ( s0_address       [c] ),//      .address
    .s0_write         ( s0_write         [c] ),//      .write
    .s0_read          ( s0_read          [c] ),//      .read
    .s0_byteenable    ( s0_byteenable    [c] ),//      .byteenable
    .s0_debugaccess   ( 0                    ),//      .debugaccess
  
    .m0_waitrequest   ( i_mc_waitrequest [c] ),//    m0.waitrequest
    .m0_readdata      ( 'h0                  ),//      .readdata
    .m0_readdatavalid ( 1'b0                 ),//      .readdatavalid
    .m0_burstcount    ( o_mc_burstcount  [c] ),//      .burstcount
    .m0_writedata     ( o_mc_writedata   [c] ),//      .writedata
    .m0_address       ( o_mc_address     [c] ),//      .address
    .m0_write         ( o_mc_write       [c] ),//      .write
    .m0_read          ( o_mc_read        [c] ),//      .read
    .m0_byteenable    ( o_mc_byteenable  [c] ),//      .byteenable
    .m0_debugaccess   (                      ) //      .debugaccess
  );
end //for
endgenerate

// Read Response Path
// Pipeline for timing
always @ (posedge clk)
begin
  for(k=0; k<MC_CHANNEL; k++)
  begin
    i_mc_readdatavalid_T0 [k] <=  i_mc_readdatavalid [k];   
    i_mc_readdata_T0      [k] <=  i_mc_readdata      [k];
    
    i_mc_readdatavalid_T1 [k] <=  i_mc_readdatavalid_T0 [k];
    i_mc_readdata_T1      [k] <=  i_mc_readdata_T0      [k];

    if(!resetb)
      i_mc_readdatavalid_T1 [k] <= 1'b0;
  end
end

// Response from each channel goes into a channel specific FIFO
always_comb
begin
  for(j=0; j<MC_CHANNEL; j++)
  begin
    //Store responses from EMIF in RSP FIFO
    rsp_wen[j] = i_mc_readdatavalid_T1[j];
    rsp_din[j] = i_mc_readdata_T1     [j];

    // Check if response for the channel at head of Req trk FIFO is available
    // in the response FIFOs. If yes, read both and pass response to HE
    rsp_ren[j] = 1'b0;

    //if( req_trk_nemp & rsp_nemp[j] & (j == req_trk_dout[0 +: CH_W]) )
    if( rsp_nemp[j] & (j == req_trk_dout[0 +: CH_W]) )
    begin
      rsp_ren[j] = 1'b1;
    end
  end //for
      
  req_trk_ren = |rsp_ren && (rdburstcount == 1);
end //always_comb

always @ (posedge clk) begin
  if( req_trk_nemp && req_trk_ren) begin
    rdburstcount <= req_trk_dout[CH_W +: BURST_WIDTH];
  end else begin
    if(|rsp_ren)
      rdburstcount <= rdburstcount - 1;
  end

  if(!resetb)
    rdburstcount <= 1;
end

always @ (posedge clk)
begin
  o_he_readdatavalid_T0 <= |rsp_ren;

  for(i=0; i<MC_CHANNEL; i++)
  begin
    if(rsp_ren[i])
    begin
      o_he_readdata_T0 <= rsp_dout[i];  
    end
  end

  //Pipeline stages
  o_he_readdatavalid_T1 <= o_he_readdatavalid_T0;
  o_he_readdata_T1      <= o_he_readdata_T0;  

  he_if.readdatavalid   <= o_he_readdatavalid_T1;
  he_if.readdata        <= o_he_readdata_T1;

  if(!resetb)
    he_if.readdatavalid <= 1'b0;
end

// ---------------------------------------------------------------------------
// REQ QUEUE
// Requests from HE - Requests buffered in this queue
// ---------------------------------------------------------------------------
quartus_bfifo
#(.WIDTH             ( REQ_FIFO_W       ),
  .DEPTH             ( REQ_FIFO_D_B2    ),
  .FULL_THRESHOLD    ( REQ_FIFO_FULL_TH ),
  .REG_OUT           ( 1                ), 
  .RAM_STYLE         ( "AUTO"           ), 
  .ECC_EN            ( 0                )
)
req_q
(
  .fifo_din          ( req_din          ),
  .fifo_wen          ( req_wen          ),
  .fifo_ren          ( req_ren          ),

  .clk               ( clk              ),
  .Resetb            ( resetb           ),
                 
  .fifo_dout         ( req_dout         ),       
  .fifo_count        (                  ),
  .full              (                  ),
  .almost_full       ( req_full         ),
  .not_empty         ( req_nemp         ),
  .almost_empty      (                  ),

  .fifo_eccstatus    ( req_ecc          ),
  .fifo_err          ( req_err          )
);


// ---------------------------------------------------------------------------
// REQ MDATA QUEUE
// Requests from HE - Mdata buffered in this queue
// ---------------------------------------------------------------------------
quartus_bfifo
#(.WIDTH             ( REQ_TRK_FIFO_W       ),
  .DEPTH             ( REQ_TRK_FIFO_D_B2    ),
  .FULL_THRESHOLD    ( REQ_TRK_FIFO_FULL_TH ),
  .REG_OUT           ( 1                    ), 
  .RAM_STYLE         ( "AUTO"               ), 
  .ECC_EN            ( 0                    )
)
req_mdata_q
(
  .fifo_din          ( req_trk_din          ),
  .fifo_wen          ( req_trk_wen          ),
  .fifo_ren          ( req_trk_ren          ),

  .clk               ( clk                  ),
  .Resetb            ( resetb               ),
                 
  .fifo_dout         ( req_trk_dout         ),       
  .fifo_count        (                      ),
  .full              (                      ),
  .almost_full       ( req_trk_full         ),
  .not_empty         ( req_trk_nemp         ),
  .almost_empty      (                      ),

  .fifo_eccstatus    ( req_trk_ecc          ),
  .fifo_err          ( req_trk_err          )
);


// ---------------------------------------------------------------------------
// RSP QUEUE
// Responses from EMIF - 1 FIFO per channel
// ---------------------------------------------------------------------------
generate
genvar u;

for(u=0; u<MC_CHANNEL; u++)
begin: RSP_Q

quartus_bfifo
#(.WIDTH             ( RSP_FIFO_W       ),
  .DEPTH             ( RSP_FIFO_D_B2    ),
  .FULL_THRESHOLD    ( RSP_FIFO_FULL_TH ),
  .REG_OUT           ( 1                ), 
  .RAM_STYLE         ( "AUTO"           ), 
  .ECC_EN            ( 0                )
)
rsp_q
(
  .fifo_din          ( rsp_din[u]       ),
  .fifo_wen          ( rsp_wen[u]       ),
  .fifo_ren          ( rsp_ren[u]       ),

  .clk               ( clk              ),
  .Resetb            ( resetb           ),
                 
  .fifo_dout         ( rsp_dout[u]      ),       
  .fifo_count        (                  ),
  .full              ( rsp_full[u]      ),
  .almost_full       (                  ),
  .not_empty         ( rsp_nemp[u]      ),
  .almost_empty      (                  ),

  .fifo_eccstatus    ( rsp_ecc[u]       ),
  .fifo_err          ( rsp_err[u]       )
);

end //for
endgenerate

// ---------------------------------------------------------------------------
// Error Flags
// ---------------------------------------------------------------------------
always @ (posedge clk)
begin
  if(!resetb)
  begin
    ErrorVector <= '0;
  end
  else
  begin
    if( req_err | req_trk_err | (|rsp_err) )
    begin
      ErrorVector[0]  <= 1;
      /*synthesis translate_off */
      $display("======================================================================================================");
      $display("*** ERROR: MEM_INTF: FIFO ERROR   ***");
      $display("======================================================================================================");
      /*synthesis translate_on */
    end
  end // (!resetb)

  /*synthesis translate_off */
  if(|ErrorVector)
  begin
    #100      ;
    $finish() ;
  end
  /*synthesis translate_on */    
end

endmodule   
