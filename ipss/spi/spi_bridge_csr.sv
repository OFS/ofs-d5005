// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
// Module Name: spi_bridge_csr.sv
//
// ***************************************************************************

module spi_bridge_csr #(
   parameter END_OF_LIST        = 1'b0,
   parameter NEXT_DFH_OFFSET    = 24'h01_0000
)(
   ofs_fim_axi_mmio_if.slave axi,
   
   input  wire         spi_readdata_valid,
   input  wire [31:00] spi_readdata,
   output reg          spi_rden,
   output reg          spi_wren,
   output reg  [02:00] spi_address,
   output reg  [31:00] spi_writedata,
   output reg          spi_miso_sel
   );
   
   import ofs_fim_cfg_pkg::*;
   import ofs_fim_if_pkg::*;
   import ofs_csr_pkg::*;
   
   //----------------------------------------------------------------------------
   // Local parameters
   //----------------------------------------------------------------------------
   localparam   CSR_FEATURE_NUM     = 1;  // Only one feature.
   localparam   CSR_FEATURE_REG_NUM = 5;  // Only 5 registers here.
   
   //----------------------------------------------------------------------------
   // Here we define each registers address...
   //----------------------------------------------------------------------------
   localparam SPI_DFH          = 6'h00;
   localparam SPI_CORE_PARAM   = 6'h08;
   localparam SPI_CONTROL_ADDR = 6'h10;
   localparam SPI_READDATA     = 6'h18;
   localparam SPI_WRITEDATA    = 6'h20;
   localparam SPI_SCRATCHPAD   = 6'h28;
   
   //---------------------------------------------------------------------------------
   // Define the register bit attributes for each of the CSRs
   //---------------------------------------------------------------------------------
   csr_bit_attr_t [63:0] SPI_DFH_ATTR          = {64{RO}};
   csr_bit_attr_t [63:0] SPI_CORE_PARAM_ATTR   = {64{RO}};
   csr_bit_attr_t [63:0] SPI_CONTROL_ADDR_ATTR = {{54{RsvdZ}}, {2{RW}}, {5{RsvdZ}}, {3{RW}}};
   csr_bit_attr_t [63:0] SPI_READDATA_ATTR     = {{31{RsvdZ}}, {1{RW}}, {32{RO}}};
   csr_bit_attr_t [63:0] SPI_WRITEDATA_ATTR    = {{32{RsvdZ}}, {32{RW}}};
   csr_bit_attr_t [63:0] SPI_SCRATCHPAD_ATTR   = {64{RW}};
   
   //----------------------------------------------------------------------------
   // Here are the state definitions for the read and write state machines.
   // Both state machines are coded one-hot using a reverse case statement.
   // (Quartus recommended coding style.)
   //----------------------------------------------------------------------------
   
   //----------------------------------------------------------------------------
   // Write State Machine Definitions
   //----------------------------------------------------------------------------
   enum                {
                        WR_RESET_BIT             = 0,
                        WR_READY_BIT             = 1,
                        WR_GOT_ADDR_BIT          = 2,
                        WR_GOT_DATA_BIT          = 3,
                        WR_GOT_ADDR_AND_DATA_BIT = 4,
                        WRITE_RESP_BIT           = 5,
                        WRITE_COMPLETE_BIT       = 6
                        } wr_state_bit;
   
   enum                logic [6:0] {
                                    WR_RESET             = 7'b0000001<<WR_RESET_BIT,
                                    WR_READY             = 7'b0000001<<WR_READY_BIT,
                                    WR_GOT_ADDR          = 7'b0000001<<WR_GOT_ADDR_BIT,
                                    WR_GOT_DATA          = 7'b0000001<<WR_GOT_DATA_BIT,
                                    WR_GOT_ADDR_AND_DATA = 7'b0000001<<WR_GOT_ADDR_AND_DATA_BIT,
                                    WRITE_RESP           = 7'b0000001<<WRITE_RESP_BIT,
                                    WRITE_COMPLETE       = 7'b0000001<<WRITE_COMPLETE_BIT
                                    } wr_state, wr_next;
   
   //----------------------------------------------------------------------------
   // Read State Machine Definitions
   //----------------------------------------------------------------------------
   enum                {
                        RD_RESET_BIT      = 0,
                        RD_READY_BIT      = 1,
                        RD_GOT_ADDR_BIT   = 2,
                        RD_GOT_DATA_BIT   = 3,
                        RD_DRIVE_BUS_BIT  = 4,
                        READ_COMPLETE_BIT = 5
                        } rd_state_bit;
   
   enum                logic [5:0] {
                                    RD_RESET      = 6'b000001<<RD_RESET_BIT,
                                    RD_READY      = 6'b000001<<RD_READY_BIT,
                                    RD_GOT_ADDR   = 6'b000001<<RD_GOT_ADDR_BIT,
                                    RD_GOT_DATA   = 6'b000001<<RD_GOT_DATA_BIT,
                                    RD_DRIVE_BUS  = 6'b000001<<RD_DRIVE_BUS_BIT,
                                    READ_COMPLETE = 6'b000001<<READ_COMPLETE_BIT
                                    } rd_state, rd_next;
   

   //----------------------------------------------------------------------------
   // SIGNAL DEFINITIONS
   //----------------------------------------------------------------------------
   // Do NOT use initialization for following signals!  Interface initialization
   // and variable initialization will cause a race condition, resulting in
   // simulation errors.
   //----------------------------------------------------------------------------
   logic               clk;
   logic               reset_n;
   assign clk     = axi.clk;
   assign reset_n = axi.rst_n;
   
   reg [31:0]                              spi_readdata_to_reg;
   reg                                     spi_readdata_valid_r1;
   reg                                     wait_for_readdata_valid;
   
   
   //----------------------------------------------------------------------------
   // CSR register are implemented in a two dimensional array according to the
   // features and the number of registers per feature.  This allows the most
   // flexibility addressing the registers as well as using the least resources.
   //----------------------------------------------------------------------------
   //....[63:0 packed width].....reg[7:0 - #Features    ][1:0 - #Regs in Feature ]  <<= Unpacked dimensions.
   logic [CSR_REG_WIDTH-1:0]               csr_reg[7:0]; // Registers
   
   //----------------------------------------------------------------------------
   // AXI CSR WRITE VARIABLES
   //----------------------------------------------------------------------------
   logic                                   csr_write[7:0]; // Register Write Strobes - Arrayed like the registers.
   ofs_csr_hw_state_t hw_state; // Hardware state during CSR updates.  This simplifies the CSR Register Update function call.
   
   logic                                   wr_range_valid, wr_range_valid_reg, awsize_valid, awsize_valid_reg, wstrb_valid, wstrb_valid_reg;
   logic [CSR_REG_WIDTH-1:0]               data_reg;
   csr_access_type_t write_type, write_type_reg;
   
   logic [2:0]                             wr_feature_id;
   logic                                   wr_reg_offset;
   assign wr_feature_id = axi.awaddr[14:12];
   assign wr_reg_offset = axi.awaddr[3];
   
   logic [MMIO_TID_WIDTH-1:0]              awid_reg;
   logic [MMIO_ADDR_WIDTH-1:0]             awaddr_reg;
   logic [2:0]                             awsize_reg;
   logic [7:0]                             wstrb_reg;
   

   //----------------------------------------------------------------------------
   // AXI CSR READ VARIABLES
   //----------------------------------------------------------------------------
   logic                                   rd_range_valid, rd_range_valid_reg, arsize_valid, arsize_valid_reg;
   ofs_csr_reg_generic_t read_data_reg;
   logic [CSR_REG_WIDTH-1:0]               read_data;
   csr_access_type_t read_type, read_type_reg;
   
   logic [2:0]                             rd_feature_id;
   logic                                   rd_reg_offset;
   assign rd_feature_id = axi.araddr[14:12];
   assign rd_reg_offset = axi.araddr[3];
   
   logic [MMIO_TID_WIDTH-1:0]              arid_reg;
   logic [MMIO_ADDR_WIDTH-1:0]             araddr_reg;
   logic [2:0]                             arsize_reg;
   

   //----------------------------------------------------------------------------
   // AXI MMIO CSR WRITE LOGIC
   //----------------------------------------------------------------------------
   
   //----------------------------------------------------------------------------
   // REGISTER INTERFACE LOGIC
   //----------------------------------------------------------------------------
   assign wr_range_valid = (wr_reg_offset < 5);
   
   //----------------------------------------------------------------------------
   // Combinatorial logic for valid write access sizes:
   //     2^2 = 4B(32-bit) or
   //     2^3 = 8B(64-bit).
   //----------------------------------------------------------------------------
   always_comb begin : wr_size_valid_comb
      if ((axi.awsize == 3'b011) || (axi.awsize == 3'b010)) begin
         awsize_valid = 1'b1;
      end else begin
         awsize_valid = 1'b0;
      end
   end
   
   //----------------------------------------------------------------------------
   // Combinatorial logic to ensure correct write access size is paired with
   // correct write strobe:
   //     2^2 = 4B(32-bit) with data in lower word 8'h0F or
   //     2^3 = 8B(64-bit) with data in whole word 8'hFF.
   // Logic must be careful to detect simultaneous awvalid and wvalid OR awvalid
   // leading wvalid.  Signal awvalid alone will not cause a wstrb evaluation.
   //----------------------------------------------------------------------------
   always_comb begin : wstrb_valid_comb
      if (          axi.awvalid && axi.wvalid) begin
         wstrb_valid = (((axi.awsize == 3'b010) && (axi.wstrb == 8'h0F || axi.wstrb == 8'hF0)) || ((axi.awsize == 3'b011) && (axi.wstrb == 8'hFF))) ? 1'b1 : 1'b0;
      end else if (!axi.awvalid && axi.wvalid) begin
         wstrb_valid = (((awsize_reg == 3'b010) && (axi.wstrb == 8'h0F || axi.wstrb == 8'hF0)) || ((awsize_reg == 3'b011) && (axi.wstrb == 8'hFF))) ? 1'b1 : 1'b0;
      end else begin
         wstrb_valid = 1'b0;
      end
   end
   

   //----------------------------------------------------------------------------
   // Combinatorial logic to define what type of write is occurring:
   //     1.) UPPER32 = Upper 32 bits of register from lower 32 bits of the write
   //         data bus.
   //     2.) LOWER32 = Lower 32 bits of register from lower 32 bits of the write
   //         data bus.
   //     3.) FULL64 = All 64 bits of the register from all 64 bits of the write
   //         data bus.
   //     4.) NONE = No write will be performed on register.
   // Logic must be careful to detect simultaneous awvalid and wvalid OR awvalid
   // leading wvalid.  A write address with bit #2 set decides whether 32-bit
   // write is to upper or lower word.
   //----------------------------------------------------------------------------
   always_comb begin : write_type_comb
      if (axi.awvalid && axi.wvalid) begin // When address and data are simultaneously presented on AXI Bus.
         if (         (axi.awsize == 3'b010) && (axi.wstrb == 8'hF0) && (axi.awaddr[2] == 1'b1)) begin
            write_type = UPPER32;
         end else if ((axi.awsize == 3'b010) && (axi.wstrb == 8'h0F) && (axi.awaddr[2] == 1'b0)) begin
            write_type = LOWER32;
         end else if ((axi.awsize == 3'b011) && (axi.wstrb == 8'hFF)) begin
            write_type = FULL64;
         end else begin
            write_type = NONE;
         end
      end else begin
         if (!axi.awvalid && axi.wvalid) begin // When address sent prior to data on AXI Bus, use stored "awsize" value.
            if (         (awsize_reg == 3'b010) && (axi.wstrb == 8'hF0) && (awaddr_reg[2] == 1'b1)) begin
               write_type = UPPER32;
            end else if ((awsize_reg == 3'b010) && (axi.wstrb == 8'h0F) && (awaddr_reg[2] == 1'b0)) begin
               write_type = LOWER32;
            end else if ((awsize_reg == 3'b011) && (axi.wstrb == 8'hFF)) begin
               write_type = FULL64;
            end else begin
               write_type = NONE;
            end
         end else begin
            write_type = NONE; // Otherwise, do nothing.
         end
      end
   end
   

   //----------------------------------------------------------------------------
   // Write State Machine Logic
   //
   // Top "always_ff" simply switches the state of the state machine registers.
   //
   // Following "always_comb" contains all of the next-state decoding logic.
   //
   // NOTE: The state machine is coded in a one-hot style with a "reverse-case"
   // statement.  This style compiles with the highest performance in Quartus.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : wr_sm_seq
      if (!reset_n) begin
         wr_state <= WR_RESET;
      end else begin
         wr_state <= wr_next;
      end
   end
   
   always_comb begin : wr_sm_comb
      wr_next = wr_state;
      unique case (1'b1) //Reverse Case Statement
         wr_state[WR_RESET_BIT]:
            if (!reset_n) begin
               wr_next = WR_RESET;
            end else begin
               wr_next = WR_READY;
            end

         wr_state[WR_READY_BIT]:
            if (!axi.awvalid && !axi.wvalid) begin
               wr_next = WR_READY;
            end else if (!axi.awvalid && axi.wvalid) begin
               wr_next = WR_GOT_DATA;
            end else if (axi.awvalid && !axi.wvalid) begin
               wr_next = WR_GOT_ADDR;
            end else begin
               wr_next = WR_GOT_ADDR_AND_DATA;
            end

         wr_state[WR_GOT_ADDR_BIT]:
            if (!axi.awvalid && !axi.wvalid) begin
               wr_next = WR_READY;
            end else if (!axi.awvalid && axi.wvalid) begin
               wr_next = WR_GOT_DATA;
            end else if (axi.awvalid && !axi.wvalid) begin
               wr_next = WR_GOT_ADDR;
            end else begin
               wr_next = WR_GOT_ADDR_AND_DATA;
            end

         wr_state[WR_GOT_DATA_BIT]:
            wr_next = WRITE_RESP;

         wr_state[WR_GOT_ADDR_AND_DATA_BIT]:
            wr_next = WRITE_RESP;

         wr_state[WRITE_RESP_BIT]:
            if (!axi.bready) begin
               wr_next = WRITE_RESP;
            end else begin
               wr_next = WRITE_COMPLETE;
            end

         wr_state[WRITE_COMPLETE_BIT]:
            wr_next = WR_READY;
      endcase
   end
   

   //----------------------------------------------------------------------------
   // Sequential logic to capture some transaction-qualifying signals during
   // writes on the write-data bus.  Values are sampled on the transition into
   // "DATA" states in the write state machine.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : wr_data_seq_var
      if (!reset_n) begin
         wstrb_reg       <= 8'h00;
         wstrb_valid_reg <= 1'b0;
         write_type_reg  <= NONE;
         data_reg        <= {64{1'b0}};
         csr_write       <= '{default:0};
      end else begin
         if ((wr_state[WR_READY_BIT] && (axi.wvalid)) || (wr_state[WR_GOT_ADDR_BIT] && (axi.wvalid))) begin
            wstrb_reg                  <= axi.wstrb;
            wstrb_valid_reg            <= wstrb_valid;
            write_type_reg             <= write_type;
            data_reg                   <= axi.wdata;
            csr_write                  <= '{default:0};
            csr_write[axi.awaddr[5:3]] <= 1'b1;
         end else if (wr_state[WRITE_COMPLETE_BIT]) begin
            wstrb_reg       <= 8'h00;
            wstrb_valid_reg <= 1'b0;
            write_type_reg  <= NONE;
            data_reg        <= {64{1'b0}};
            csr_write       <= '{default:0};
         end
      end
   end
   

   //----------------------------------------------------------------------------
   // Sequential logic to capture some transaction-qualifying signals during
   // writes on the write-address bus.  Values are sampled on the transition into
   // "ADDR" states in the write state machine.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : wr_addr_seq_var
      if (!reset_n) begin
         awid_reg           <= {MMIO_TID_WIDTH{1'b0}};
         awaddr_reg         <= {MMIO_ADDR_WIDTH{1'b0}};
         awsize_reg         <= 3'b000;
         wr_range_valid_reg <= 1'b0;
         awsize_valid_reg   <= 1'b0;
      end else begin
         if ((wr_state[WR_READY_BIT] && axi.awvalid) || (wr_state[WR_GOT_ADDR_BIT] && (axi.awvalid))) begin
            awid_reg           <= axi.awid;
            awaddr_reg         <= axi.awaddr;
            awsize_reg         <= axi.awsize;
            wr_range_valid_reg <= wr_range_valid;
            awsize_valid_reg   <= awsize_valid;
         end else begin
            if (wr_state[WRITE_COMPLETE_BIT]) begin
               awid_reg           <= {MMIO_TID_WIDTH{1'b0}};
               awaddr_reg         <= {MMIO_ADDR_WIDTH{1'b0}};
               awsize_reg         <= 3'b000;
               wr_range_valid_reg <= 1'b0;
               awsize_valid_reg   <= 1'b0;
            end
         end
      end
   end
   
   //----------------------------------------------------------------------------
   // Logic for interface and handshaking signals controlled mostly
   // by the write state machine to sequence events.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : drive_axi_wr
      axi.awready <= (wr_next[WR_READY_BIT] || wr_next[WR_GOT_ADDR_BIT]);
      axi.wready  <= (wr_next[WR_READY_BIT] || wr_next[WR_GOT_ADDR_BIT]);
      axi.bvalid  <=  wr_next[WRITE_RESP_BIT];
      axi.bid     <=  wr_next[WRITE_RESP_BIT] ? awid_reg : {MMIO_TID_WIDTH{1'b0}};
      axi.bresp   <= (wr_next[WRITE_RESP_BIT] && (wr_range_valid_reg) && (awsize_valid_reg) && (wstrb_valid_reg)) ? RESP_OKAY : RESP_SLVERR;
   end
   
   //----------------------------------------------------------------------------
   // HW State is a data struct used to pass the resets, write data, and write
   // type to the CSR "update_reg" function.
   //----------------------------------------------------------------------------
   assign hw_state.reset_n      = reset_n;
   assign hw_state.pwr_good_n   = 1'b1; // SPI has no stickey bits.
   assign hw_state.wr_data.data = data_reg;
   assign hw_state.write_type   = write_type_reg;
   
   //----------------------------------------------------------------------------
   // Register Update Logic using "update_reg" function in "ofs_csr_pkg.sv"
   // SystemVerilog package.  Function inputs are "named" for ease of
   // understanding the use.
   //     - Register bit attributes are set in array input above.  Attribute
   //       functions are defined in SAS.
   //     - Reset Value is appied at reset except for RO, *D, and Rsvd{Z}.
   //     - Update Value is used as status bit updates for RO, RW1C*, and RW1S*.
   //     - Current Value is used to determine next register value.  This must be
   //       done due to scoping rules using SystemVerilog package.
   //     - "Write" is the decoded write signal for that particular register.
   //     - State is a hardware state structure to pass input signals to
   //       "update_reg" function.  See just above.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : update_reg_seq
      
      csr_reg[SPI_DFH[5:3]]          <= update_reg   (
                                                      .attr            (SPI_DFH_ATTR),
                                                      .reg_reset_val   ({4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h00E}),
                                                      .reg_update_val  ({4'h3,8'h00,4'h0,7'h00,END_OF_LIST,NEXT_DFH_OFFSET,4'h0,12'h00E}),
                                                      .reg_current_val (csr_reg[SPI_DFH[5:3]]),
                                                      .write           (csr_write[SPI_DFH[5:3]]),
                                                      .state           (hw_state)
                                                      );
      
      csr_reg[SPI_CORE_PARAM[5:3]]   <= update_reg   (
                                                      .attr            (SPI_CORE_PARAM_ATTR),
                                                      .reg_reset_val   (64'h0000_0000_0640_81_81),
                                                      .reg_update_val  (64'h0000_0000_0640_81_81),
                                                      .reg_current_val (csr_reg[SPI_CORE_PARAM[5:3]]),
                                                      .write           (csr_write[SPI_CORE_PARAM[5:3]]),
                                                      .state           (hw_state)
                                                      );
      
      csr_reg[SPI_CONTROL_ADDR[5:3]] <= update_reg   (
                                                      .attr            (SPI_CONTROL_ADDR_ATTR),
                                                      .reg_reset_val   (64'h0),
                                                      .reg_update_val  (64'h0),
                                                      .reg_current_val ((csr_reg[SPI_CONTROL_ADDR[5:3]] & 64'hFFFF_FFFF_FFFF_FCFF)),
                                                      .write           (csr_write[SPI_CONTROL_ADDR[5:3]]),
                                                      .state           (hw_state)
                                                      );
      
      csr_reg[SPI_READDATA[5:3]]     <= update_reg   (
                                                      .attr            (SPI_READDATA_ATTR),
                                                      .reg_reset_val   (64'h0000_0000_0000_0000),
                                                      .reg_update_val  ({{32{1'b0}}, spi_readdata_to_reg}),
                                                      .reg_current_val (csr_reg[SPI_READDATA[5:3]]),
                                                      .write           (csr_write[SPI_READDATA[5:3]]),
                                                      .state           (hw_state)
                                                      );
      
      csr_reg[SPI_WRITEDATA[5:3]]     <= update_reg  (
                                                      .attr            (SPI_WRITEDATA_ATTR),
                                                      .reg_reset_val   (64'h0000_0000_0000_0000),
                                                      .reg_update_val  (64'h0000_0000_0000_0000),
                                                      .reg_current_val (csr_reg[SPI_WRITEDATA[5:3]]),
                                                      .write           (csr_write[SPI_WRITEDATA[5:3]]),
                                                      .state           (hw_state)
                                                      ); 
      
      csr_reg[SPI_SCRATCHPAD[5:3]]    <= update_reg  (
                                                      .attr            (SPI_SCRATCHPAD_ATTR),
                                                      .reg_reset_val   (64'h0000_0000_0000_0000),
                                                      .reg_update_val  (64'h0000_0000_0000_0000),
                                                      .reg_current_val (csr_reg[SPI_SCRATCHPAD[5:3]]),
                                                      .write           (csr_write[SPI_SCRATCHPAD[5:3]]),
                                                      .state           (hw_state)
                                                      ); 
      // unused registers should return 0's
//    csr_reg[3'h5]                   <= 64'h0;
      csr_reg[3'h6]                   <= 64'h0;
      csr_reg[3'h7]                   <= 64'h0;
   end
   
   //----------------------------------------------------------------------------
   // AXI MMIO CSR READ LOGIC
   //----------------------------------------------------------------------------
   
   //----------------------------------------------------------------------------
   // REGISTER INTERFACE LOGIC
   //----------------------------------------------------------------------------
   assign rd_range_valid = (rd_reg_offset < 5);
   
   //----------------------------------------------------------------------------
   // Combinatorial logic for valid read access sizes:
   //     2^2 = 4B(32-bit) or
   //     2^3 = 8B(64-bit).
   //----------------------------------------------------------------------------
   always_comb begin : rd_size_valid_comb
      if ((axi.arsize == 3'b011) || (axi.arsize == 3'b010)) begin
         arsize_valid = 1'b1;
      end else begin
         arsize_valid = 1'b0;
      end
   end
   

   //----------------------------------------------------------------------------
   // Combinatorial logic to define what type of read is occurring:
   //     1.) UPPER32 = Upper 32 bits of register to lower 32 bits of the AXI
   //         data bus. Top 32 bits of bus are zero-filled.
   //     2.) LOWER32 = Lower 32 bits of register to lower 32 bits of the AXI
   //         data bus. Top  32 bits of bus are zero-filled.
   //     3.) FULL64 = All 64 bits of the register to all 64 bits of the AXI
   //         data bus.
   //     4.) NONE = No read will be performed.  AXI data bus will be zero-filled.
   // A read address with bit #2 set decides whether 32-bit read is to upper or
   // lower word.
   //----------------------------------------------------------------------------
   always_comb begin : read_type_comb
      if (axi.arvalid) begin
         if (         (axi.arsize == 3'b010) && (axi.araddr[2] == 1'b1)) begin
            read_type = UPPER32;
         end else if ((axi.arsize == 3'b010) && (axi.araddr[2] == 1'b0)) begin
            read_type = LOWER32;
         end else if (axi.arsize == 3'b011) begin
            read_type = FULL64;
         end else begin
            read_type = NONE;
         end
      end else begin
         read_type = NONE;
      end
   end
   

   //----------------------------------------------------------------------------
   // Read State Machine Logic
   //
   // Top "always_ff" simply switches the state of the state machine registers.
   //
   // Following "always_comb" contains all of the next-state decoding logic.
   //
   // NOTE: The state machine is coded in a one-hot style with a "reverse-case"
   // statement.  This style compiles with the highest performance in Quartus.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : rd_sm_seq
      if (!reset_n) begin
         rd_state <= RD_RESET;
      end else begin
         rd_state <= rd_next;
      end
   end
   

   always_comb begin : rd_sm_comb
      rd_next = rd_state;
      unique case (1'b1) //Reverse Case Statement
         rd_state[RD_RESET_BIT]:
            if (!reset_n) begin
               rd_next = RD_RESET;
            end else begin
               rd_next = RD_READY;
            end

         rd_state[RD_READY_BIT]:
            if (axi.arvalid) begin
               rd_next = RD_GOT_ADDR;
            end else begin
               rd_next = RD_READY;
            end

         rd_state[RD_GOT_ADDR_BIT]:
            if (wait_for_readdata_valid) begin
               rd_next = RD_GOT_ADDR;
            end else begin
               rd_next = RD_GOT_DATA;
            end
        

         rd_state[RD_GOT_DATA_BIT]:
            rd_next = RD_DRIVE_BUS;

         rd_state[RD_DRIVE_BUS_BIT]:
            if (!axi.rready) begin
               rd_next = RD_DRIVE_BUS;
            end else begin
               rd_next = READ_COMPLETE;
            end

         rd_state[READ_COMPLETE_BIT]:
            rd_next = RD_READY;
      endcase
   end
   
   //----------------------------------------------------------------------------
   // Sequential logic to capture some transaction-qualifying signals during
   // reads on the read-address bus.  Values are sampled on the transition into
   // the "RD_GOT_ADDR" state in the read state machine.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : rd_addr_seq_var
      if (!reset_n) begin
         arid_reg           <= {MMIO_TID_WIDTH{1'b0}};
         araddr_reg         <= {MMIO_ADDR_WIDTH{1'b0}};
         arsize_reg         <= 3'b000;
         read_type_reg      <= NONE;
         rd_range_valid_reg <= 1'b0;
         arsize_valid_reg   <= 1'b0;
      end else begin
         if (rd_state[RD_READY_BIT] && axi.arvalid) begin
            arid_reg           <= axi.arid;
            araddr_reg         <= axi.araddr;
            arsize_reg         <= axi.arsize;
            read_type_reg      <= read_type;
            rd_range_valid_reg <= rd_range_valid;
            arsize_valid_reg   <= arsize_valid;
         end else begin
            if (rd_state[READ_COMPLETE_BIT]) begin
               arid_reg           <= {MMIO_TID_WIDTH{1'b0}};
               araddr_reg         <= {MMIO_ADDR_WIDTH{1'b0}};
               arsize_reg         <= 3'b000;
               read_type_reg      <= NONE;
               rd_range_valid_reg <= 1'b0;
               arsize_valid_reg   <= 1'b0;
            end
         end
      end
   end
   

   //----------------------------------------------------------------------------
   // Sequential logic to fetch the CSR register contents during an AXI read.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : rd_data_reg_seq
      if (!reset_n) begin
         read_data_reg.data <= {CSR_REG_WIDTH{1'b0}};
      end else begin
         if (rd_state[RD_GOT_ADDR_BIT]) begin
            read_data_reg.data <= csr_reg[araddr_reg[5:3]];
         end
      end
   end
   

   //----------------------------------------------------------------------------
   // Combinatorial logic to format the read data according to the read acccess
   // being executed on the AXI bus.
   //----------------------------------------------------------------------------
   always_comb begin : rd_data_comb
      if (read_type_reg == FULL64) begin
         read_data = read_data_reg.data;
      end else if (read_type_reg == UPPER32) begin
         read_data = {read_data_reg.word.upper32, 32'h0};
      end else if (read_type_reg == LOWER32) begin
         read_data = {32'h0, read_data_reg.word.lower32};
      end else begin
         read_data = {64{1'b0}};
      end
   end
   

   //----------------------------------------------------------------------------
   // Logic for interface and handshaking signals controlled mostly
   // by the read state machine to sequence events.
   //----------------------------------------------------------------------------
   always_ff @(posedge clk) begin : drive_axi_rd
      axi.arready <=  rd_next[RD_READY_BIT] ? 1'b1 : 1'b0;
      axi.rid     <=  rd_next[RD_DRIVE_BUS_BIT] ? arid_reg  : {MMIO_TID_WIDTH{1'b0}};
      axi.rdata   <=  rd_next[RD_DRIVE_BUS_BIT] ? read_data : {MMIO_DATA_WIDTH{1'b0}};
      axi.rresp   <= (rd_next[RD_DRIVE_BUS_BIT] && (rd_range_valid_reg) && (arsize_valid_reg)) ? RESP_OKAY : RESP_SLVERR;
      axi.rlast   <=  rd_next[RD_DRIVE_BUS_BIT] ? 1'b1 : 1'b0;
      axi.rvalid  <=  rd_next[RD_DRIVE_BUS_BIT] ? 1'b1 : 1'b0;
   end
   

   // Code specific to spi_bridge...
   
   always_ff @(posedge clk) begin
      if (!reset_n) begin
         spi_wren <= 1'b0;
         spi_rden <= 1'b0;
      end else begin
         if ( wr_state[WRITE_COMPLETE_BIT] & (csr_write[SPI_CONTROL_ADDR[5:3]])) begin // Updated by SW
            if ((write_type_reg == FULL64) | (write_type_reg == LOWER32)) begin // bit 8 and 9 are being written
               spi_wren <= data_reg[8];
               spi_rden <= data_reg[9];
            end else begin // bits 8 and 9 are not valid
               spi_wren <= 1'b0;
               spi_rden <= 1'b0;
            end
         end else begin
            spi_wren <= 1'b0;
            spi_rden <= 1'b0;
         end // else: !if( wr_state[WRITE_COMPLETE_BIT] & (csr_write[SPI_CONTROL_ADDR[5:3]]))
      end // else: !if(!reset_n)
   end // always_ff @ (posedge clk)
   
   always_ff @(posedge clk) begin
      spi_readdata_valid_r1 <= spi_readdata_valid;
      if (!reset_n) begin
         wait_for_readdata_valid <= 1'b0;
      end else begin
         wait_for_readdata_valid <= spi_rden |
                                    wait_for_readdata_valid  & ~spi_readdata_valid_r1;
      end
   end
   
         
   always_ff @(posedge clk) begin
      if (!reset_n) begin
         spi_readdata_to_reg <= '0;
      end else begin
        spi_address   <= csr_reg[SPI_CONTROL_ADDR[5:3]][2:0];
        spi_miso_sel  <= csr_reg[SPI_READDATA[5:3]][32];
        spi_writedata <= csr_reg[SPI_WRITEDATA[5:3]][31:0];
        if (spi_readdata_valid) begin
           spi_readdata_to_reg <= spi_readdata;
        end
      end
   end
   
endmodule
