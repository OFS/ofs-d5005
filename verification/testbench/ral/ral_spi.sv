// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_SPI
`define RAL_SPI

import uvm_pkg::*;

class ral_reg_spi_SPI_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "spi_SPI_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h10000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'he, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_DFH)

endclass : ral_reg_spi_SPI_DFH


class ral_reg_spi_SPI_CORE_PARAM extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PeripheralLd;
	uvm_reg_field SPIclockRateInMHZ;
	rand uvm_reg_field Reserved_1;
	uvm_reg_field SynchronizerStages;
	uvm_reg_field ClockPhase;
	uvm_reg_field ClockPolarity;
	uvm_reg_field NumberOfSelectSS_nSignals;
	uvm_reg_field DaqtaRegisterWidth;
	uvm_reg_field ShiftDirection;
	uvm_reg_field MasterMode;

	function new(string name = "spi_SPI_CORE_PARAM");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 16, 48, "WO", 0, 16'h0, 1, 0, 1);
      this.PeripheralLd = uvm_reg_field::type_id::create("PeripheralLd",,get_full_name());
      this.PeripheralLd.configure(this, 16, 32, "RO", 0, 16'h0, 1, 0, 1);
      this.SPIclockRateInMHZ = uvm_reg_field::type_id::create("SPIclockRateInMHZ",,get_full_name());
      this.SPIclockRateInMHZ.configure(this, 10, 22, "RO", 0, 10'h19, 1, 0, 0);
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 4, 18, "WO", 0, 4'h0, 1, 0, 0);
      this.SynchronizerStages = uvm_reg_field::type_id::create("SynchronizerStages",,get_full_name());
      this.SynchronizerStages.configure(this, 2, 16, "RO", 0, 2'h0, 1, 0, 0);
      this.ClockPhase = uvm_reg_field::type_id::create("ClockPhase",,get_full_name());
      this.ClockPhase.configure(this, 1, 15, "RO", 0, 1'h1, 1, 0, 0);
      this.ClockPolarity = uvm_reg_field::type_id::create("ClockPolarity",,get_full_name());
      this.ClockPolarity.configure(this, 1, 14, "RO", 0, 1'h0, 1, 0, 0);
      this.NumberOfSelectSS_nSignals = uvm_reg_field::type_id::create("NumberOfSelectSS_nSignals",,get_full_name());
      this.NumberOfSelectSS_nSignals.configure(this, 6, 8, "RO", 0, 6'h1, 1, 0, 0);
      this.DaqtaRegisterWidth = uvm_reg_field::type_id::create("DaqtaRegisterWidth",,get_full_name());
      this.DaqtaRegisterWidth.configure(this, 6, 2, "RO", 0, 6'h20, 1, 0, 0);
      this.ShiftDirection = uvm_reg_field::type_id::create("ShiftDirection",,get_full_name());
      this.ShiftDirection.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.MasterMode = uvm_reg_field::type_id::create("MasterMode",,get_full_name());
      this.MasterMode.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_CORE_PARAM)

endclass : ral_reg_spi_SPI_CORE_PARAM


class ral_reg_spi_SPI_CONTROL_ADDR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field ReadCommand;
	rand uvm_reg_field WriteCommand;
	rand uvm_reg_field Reserved_1;
	rand uvm_reg_field SpiBridgeAddr;

	function new(string name = "spi_SPI_CONTROL_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 54, 10, "WO", 0, 54'h000000000, 1, 0, 0);
      this.ReadCommand = uvm_reg_field::type_id::create("ReadCommand",,get_full_name());
      this.ReadCommand.configure(this, 1, 9, "W1S", 0, 1'h0, 1, 0, 0);
      this.WriteCommand = uvm_reg_field::type_id::create("WriteCommand",,get_full_name());
      this.WriteCommand.configure(this, 1, 8, "W1S", 0, 1'h0, 1, 0, 0);
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 5, 3, "WO", 0, 5'h0, 1, 0, 0);
      this.SpiBridgeAddr = uvm_reg_field::type_id::create("SpiBridgeAddr",,get_full_name());
      this.SpiBridgeAddr.configure(this, 3, 0, "RW", 0, 3'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_CONTROL_ADDR)

endclass : ral_reg_spi_SPI_CONTROL_ADDR


class ral_reg_spi_SPI_READDATA extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field ReadData;

	function new(string name = "spi_SPI_READDATA");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.ReadData = uvm_reg_field::type_id::create("ReadData",,get_full_name());
      this.ReadData.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_READDATA)

endclass : ral_reg_spi_SPI_READDATA


class ral_reg_spi_SPI_WRITEDATA extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field WriteData;

	function new(string name = "spi_SPI_WRITEDATA");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.WriteData = uvm_reg_field::type_id::create("WriteData",,get_full_name());
      this.WriteData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_WRITEDATA)

endclass : ral_reg_spi_SPI_WRITEDATA


class ral_reg_spi_SPI_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Reserved;

	function new(string name = "spi_SPI_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_spi_SPI_SCRATCHPAD)

endclass : ral_reg_spi_SPI_SCRATCHPAD


class ral_block_spi extends uvm_reg_block;
	rand ral_reg_spi_SPI_DFH SPI_DFH;
	rand ral_reg_spi_SPI_CORE_PARAM SPI_CORE_PARAM;
	rand ral_reg_spi_SPI_CONTROL_ADDR SPI_CONTROL_ADDR;
	rand ral_reg_spi_SPI_READDATA SPI_READDATA;
	rand ral_reg_spi_SPI_WRITEDATA SPI_WRITEDATA;
	rand ral_reg_spi_SPI_SCRATCHPAD SPI_SCRATCHPAD;
	uvm_reg_field SPI_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field SPI_DFH_Reserved;
	uvm_reg_field SPI_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field SPI_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field SPI_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field SPI_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field SPI_CORE_PARAM_Reserved;
	uvm_reg_field SPI_CORE_PARAM_PeripheralLd;
	uvm_reg_field PeripheralLd;
	uvm_reg_field SPI_CORE_PARAM_SPIclockRateInMHZ;
	uvm_reg_field SPIclockRateInMHZ;
	rand uvm_reg_field SPI_CORE_PARAM_Reserved_1;
	uvm_reg_field SPI_CORE_PARAM_SynchronizerStages;
	uvm_reg_field SynchronizerStages;
	uvm_reg_field SPI_CORE_PARAM_ClockPhase;
	uvm_reg_field ClockPhase;
	uvm_reg_field SPI_CORE_PARAM_ClockPolarity;
	uvm_reg_field ClockPolarity;
	uvm_reg_field SPI_CORE_PARAM_NumberOfSelectSS_nSignals;
	uvm_reg_field NumberOfSelectSS_nSignals;
	uvm_reg_field SPI_CORE_PARAM_DaqtaRegisterWidth;
	uvm_reg_field DaqtaRegisterWidth;
	uvm_reg_field SPI_CORE_PARAM_ShiftDirection;
	uvm_reg_field ShiftDirection;
	uvm_reg_field SPI_CORE_PARAM_MasterMode;
	uvm_reg_field MasterMode;
	rand uvm_reg_field SPI_CONTROL_ADDR_Reserved;
	rand uvm_reg_field SPI_CONTROL_ADDR_ReadCommand;
	rand uvm_reg_field ReadCommand;
	rand uvm_reg_field SPI_CONTROL_ADDR_WriteCommand;
	rand uvm_reg_field WriteCommand;
	rand uvm_reg_field SPI_CONTROL_ADDR_Reserved_1;
	rand uvm_reg_field SPI_CONTROL_ADDR_SpiBridgeAddr;
	rand uvm_reg_field SpiBridgeAddr;
	rand uvm_reg_field SPI_READDATA_Reserved;
	uvm_reg_field SPI_READDATA_ReadData;
	uvm_reg_field ReadData;
	rand uvm_reg_field SPI_WRITEDATA_Reserved;
	rand uvm_reg_field SPI_WRITEDATA_WriteData;
	rand uvm_reg_field WriteData;
	rand uvm_reg_field SPI_SCRATCHPAD_Reserved;

	function new(string name = "spi");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.SPI_DFH = ral_reg_spi_SPI_DFH::type_id::create("SPI_DFH",,get_full_name());
      this.SPI_DFH.configure(this, null, "");
      this.SPI_DFH.build();
      this.default_map.add_reg(this.SPI_DFH, `UVM_REG_ADDR_WIDTH'h10000, "RW", 0);
		this.SPI_DFH_FeatureType = this.SPI_DFH.FeatureType;
		this.FeatureType = this.SPI_DFH.FeatureType;
		this.SPI_DFH_Reserved = this.SPI_DFH.Reserved;
		this.SPI_DFH_EOL = this.SPI_DFH.EOL;
		this.EOL = this.SPI_DFH.EOL;
		this.SPI_DFH_NextDfhByteOffset = this.SPI_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.SPI_DFH.NextDfhByteOffset;
		this.SPI_DFH_FeatureRev = this.SPI_DFH.FeatureRev;
		this.FeatureRev = this.SPI_DFH.FeatureRev;
		this.SPI_DFH_FeatureID = this.SPI_DFH.FeatureID;
		this.FeatureID = this.SPI_DFH.FeatureID;
      this.SPI_CORE_PARAM = ral_reg_spi_SPI_CORE_PARAM::type_id::create("SPI_CORE_PARAM",,get_full_name());
      this.SPI_CORE_PARAM.configure(this, null, "");
      this.SPI_CORE_PARAM.build();
      this.default_map.add_reg(this.SPI_CORE_PARAM, `UVM_REG_ADDR_WIDTH'h10008, "RW", 0);
		this.SPI_CORE_PARAM_Reserved = this.SPI_CORE_PARAM.Reserved;
		this.SPI_CORE_PARAM_PeripheralLd = this.SPI_CORE_PARAM.PeripheralLd;
		this.PeripheralLd = this.SPI_CORE_PARAM.PeripheralLd;
		this.SPI_CORE_PARAM_SPIclockRateInMHZ = this.SPI_CORE_PARAM.SPIclockRateInMHZ;
		this.SPIclockRateInMHZ = this.SPI_CORE_PARAM.SPIclockRateInMHZ;
		this.SPI_CORE_PARAM_Reserved_1 = this.SPI_CORE_PARAM.Reserved_1;
		this.SPI_CORE_PARAM_SynchronizerStages = this.SPI_CORE_PARAM.SynchronizerStages;
		this.SynchronizerStages = this.SPI_CORE_PARAM.SynchronizerStages;
		this.SPI_CORE_PARAM_ClockPhase = this.SPI_CORE_PARAM.ClockPhase;
		this.ClockPhase = this.SPI_CORE_PARAM.ClockPhase;
		this.SPI_CORE_PARAM_ClockPolarity = this.SPI_CORE_PARAM.ClockPolarity;
		this.ClockPolarity = this.SPI_CORE_PARAM.ClockPolarity;
		this.SPI_CORE_PARAM_NumberOfSelectSS_nSignals = this.SPI_CORE_PARAM.NumberOfSelectSS_nSignals;
		this.NumberOfSelectSS_nSignals = this.SPI_CORE_PARAM.NumberOfSelectSS_nSignals;
		this.SPI_CORE_PARAM_DaqtaRegisterWidth = this.SPI_CORE_PARAM.DaqtaRegisterWidth;
		this.DaqtaRegisterWidth = this.SPI_CORE_PARAM.DaqtaRegisterWidth;
		this.SPI_CORE_PARAM_ShiftDirection = this.SPI_CORE_PARAM.ShiftDirection;
		this.ShiftDirection = this.SPI_CORE_PARAM.ShiftDirection;
		this.SPI_CORE_PARAM_MasterMode = this.SPI_CORE_PARAM.MasterMode;
		this.MasterMode = this.SPI_CORE_PARAM.MasterMode;
      this.SPI_CONTROL_ADDR = ral_reg_spi_SPI_CONTROL_ADDR::type_id::create("SPI_CONTROL_ADDR",,get_full_name());
      this.SPI_CONTROL_ADDR.configure(this, null, "");
      this.SPI_CONTROL_ADDR.build();
      this.default_map.add_reg(this.SPI_CONTROL_ADDR, `UVM_REG_ADDR_WIDTH'h10010, "RW", 0);
		this.SPI_CONTROL_ADDR_Reserved = this.SPI_CONTROL_ADDR.Reserved;
		this.SPI_CONTROL_ADDR_ReadCommand = this.SPI_CONTROL_ADDR.ReadCommand;
		this.ReadCommand = this.SPI_CONTROL_ADDR.ReadCommand;
		this.SPI_CONTROL_ADDR_WriteCommand = this.SPI_CONTROL_ADDR.WriteCommand;
		this.WriteCommand = this.SPI_CONTROL_ADDR.WriteCommand;
		this.SPI_CONTROL_ADDR_Reserved_1 = this.SPI_CONTROL_ADDR.Reserved_1;
		this.SPI_CONTROL_ADDR_SpiBridgeAddr = this.SPI_CONTROL_ADDR.SpiBridgeAddr;
		this.SpiBridgeAddr = this.SPI_CONTROL_ADDR.SpiBridgeAddr;
      this.SPI_READDATA = ral_reg_spi_SPI_READDATA::type_id::create("SPI_READDATA",,get_full_name());
      this.SPI_READDATA.configure(this, null, "");
      this.SPI_READDATA.build();
      this.default_map.add_reg(this.SPI_READDATA, `UVM_REG_ADDR_WIDTH'h10018, "RW", 0);
		this.SPI_READDATA_Reserved = this.SPI_READDATA.Reserved;
		this.SPI_READDATA_ReadData = this.SPI_READDATA.ReadData;
		this.ReadData = this.SPI_READDATA.ReadData;
      this.SPI_WRITEDATA = ral_reg_spi_SPI_WRITEDATA::type_id::create("SPI_WRITEDATA",,get_full_name());
      this.SPI_WRITEDATA.configure(this, null, "");
      this.SPI_WRITEDATA.build();
      this.default_map.add_reg(this.SPI_WRITEDATA, `UVM_REG_ADDR_WIDTH'h10020, "RW", 0);
		this.SPI_WRITEDATA_Reserved = this.SPI_WRITEDATA.Reserved;
		this.SPI_WRITEDATA_WriteData = this.SPI_WRITEDATA.WriteData;
		this.WriteData = this.SPI_WRITEDATA.WriteData;
      this.SPI_SCRATCHPAD = ral_reg_spi_SPI_SCRATCHPAD::type_id::create("SPI_SCRATCHPAD",,get_full_name());
      this.SPI_SCRATCHPAD.configure(this, null, "");
      this.SPI_SCRATCHPAD.build();
      this.default_map.add_reg(this.SPI_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h10028, "RW", 0);
		this.SPI_SCRATCHPAD_Reserved = this.SPI_SCRATCHPAD.Reserved;
   endfunction : build

	`uvm_object_utils(ral_block_spi)

endclass : ral_block_spi



`endif
