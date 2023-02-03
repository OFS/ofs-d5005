# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#--------------------
# IPs
#--------------------

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/afu_top/afu_top.sv

#--------------------
# MUX modules
#--------------------

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/axi_avl_st_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/arbiter/fair_arbiter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/Nmux.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/switch.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/pf_vf_mux_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/pcie_mux_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/mux/pcie_ss_axis_mux.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/afu_top/pcie_arb_local_commit.sv

#--------------------
# AFU INTF module
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/fifo/fifo_w_rewind.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/fifo/bypass_fifo.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/fifo/altera_ram_reg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/fifo/altera_ram.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/afu_intf.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/protocol_checker_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/port_tx_fifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/port_traffic_control.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/prtcl_chkr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/protocol_checker.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/tx_filter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/protocol_checker/mmio_handler.sv

#--------------------
# MSIX modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/fme_msix_table.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_filter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_fme_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_pba_update.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_user_irq.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_wrapper.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/interrupt/msix_csr.sv

#--------------------
# ST2MM modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/pfa/pfa_master.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/pfa/pfa_slave.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/avst_rx_mmio_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/avst_tx_mmio_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/axis_rx_mmio_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/axis_tx_mmio_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/axis_tx_msix_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/csr/axil_bridge_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/avst_axil_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/bridges/axis_axil_bridge.sv

#--------------------
# Port Gasket modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/axi/axi_mmio_register.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/axi/axi_read_register.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/axi/axi_register.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/axi/axi_write_register.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/avmm/avmm_if_reg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/pr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/pg_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/pr_ctrl_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/pr_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/pg_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/port_gasket/pr_slot.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/port_reset_fsm.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/port_gasket/port_gasket.sv

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/user_clock/includes/qph_user_clk_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/user_clock/user_clk/qph_user_clk.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/user_clock/qph_user_clk_freq.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/user_clock/qph_user_clk_rcfg_fsm.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/port_gasket/user_clock/user_clock_resync.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/user_clock/user_clk/user_clock.sv


set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/remote_stp/remote_stp_top.sv

set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/pr/PR_IP.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/user_clock/qph_user_clk_iopll_s10_RF100M.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/user_clock/qph_user_clk_iopll_reconfig.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/remote_debug_jtag_only_clock_in.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/host_if.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/jop_blaster.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/remote_debug_jtag_only_reset_in.ip
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/sys_clk.ip
set_global_assignment -name QSYS_FILE ../ip_lib/ofs-common/src/fpga_family/stratix10/remote_stp/remote_debug_jtag_only.qsys
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/port_gasket/pr_slot.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/port_gasket/port_gasket.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/user_clock/user_clk/qph_user_clk.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/stratix10/user_clock/user_clk/user_clock.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/remote_stp/remote_stp/remote_stp_top.sv

# SDC
set_global_assignment -name SDC_FILE ../setup/user_clock.sdc
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/setup/user_clock.sdc
#--------------------
# Stubs
#--------------------
#set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/fims/d5005/afu/virtio_top.sv

#--------------------
#HE_HSSI modules
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/he_hssi_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/eth_traffic_csr_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/top_direct_green_bs/eth_traffic_pcie_tlp_to_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/top_direct_green_bs/pcie_tlp_to_csr_no_dma.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/eth_traffic_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/multi_port_axi_traffic_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/multi_port_traffic_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/common/traffic_controller_wrapper.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/eth_std_traffic_controller_top.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_gen.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback.sv
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_loopback_csr.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_mon.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/avalon_st_prtmux.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/eth_std_traffic_controller_top.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/shiftreg_ctrl.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/shiftreg_data.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/avalon_st_to_crc_if_bridge.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/bit_endian_converter.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/byte_endian_converter.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc_checksum_aligner.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc_comparator.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_calculator.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_chk.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_gen.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc_ethernet.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc_register.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat8.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat16.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat24.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat32.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat32_any_byte.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat40.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat48.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat56.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat64.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/crc32_dat64_any_byte.v
set_global_assignment -name VERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/eth_traffic_controller/crc32/crc32_lib/xor6.v
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/par/he_hssi.sdc

set_global_assignment -name VERILOG_FILE       $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_aeuex_pkt_gen_sync.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_data_block_buffer.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_data_synchronizer.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_frame_buffer.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_loopback_client.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_pointer_synchronizer.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_ready_skid.sv
set_global_assignment -name VERILOG_FILE       $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_aeuex_packet_client_tx.v
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/he_hssi/pkt_client_100g/alt_e100s10_packet_client.sv
set_global_assignment -name IP_FILE ../ip_lib/ofs-common/src/common/lib/fifo/sc_fifo_tx_sc_fifo.ip

