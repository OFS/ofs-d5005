# UART
#src/uart/ip/uart.ip

# EMIF
ipss/mem/ip/avmm_cdc.ip
ipss/mem/ip/avmm_pipeline_bridge.ip
ipss/mem/ip/emif_ddr4_no_ecc.ip
ipss/mem/axi_bridge/ofs_ddr_axi_bridge.qsys
ipss/mem/axi_bridge/ip/ofs_ddr_axi_bridge/amm_clock.ip
ipss/mem/axi_bridge/ip/ofs_ddr_axi_bridge/amm_reset.ip
#ipss/mem/axi_bridge/ip/ofs_ddr_axi_bridge/avmm_ep.ip
#ipss/mem/axi_bridge/ip/ofs_ddr_axi_bridge/axi_ep.ip


# ETH
ipss/hssi/s10/ip/address_decoder/address_decode.qsys
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_clk_csr.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_master_0.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_merlin_master_translator_0.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_mac.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_phy.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_rx_xcvr_clk.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_clk.ip
ipss/hssi/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_half_clk.ip
ipss/hssi/s10/ip/mac/altera_eth_10g_mac.ip
ipss/hssi/s10/ip/phy/altera_eth_10gbaser_phy.ip
ipss/hssi/s10/ip/pll_atxpll/altera_xcvr_atx_pll_ip.ip
ipss/hssi/s10/ip/pll_mpll/pll.ip
ipss/hssi/s10/ip/xcvr_reset_controller/reset_control.ip

# PCIE
ipss/pcie/qip/pcie_ep_g3x16.ip

# APF
src/pd_qsys/fabric/apf.qsys
src/pd_qsys/fabric/ip/apf/apf_achk_slv.ip
src/pd_qsys/fabric/ip/apf/apf_bpf_slv.ip
src/pd_qsys/fabric/ip/apf/apf_bpf_mst.ip
src/pd_qsys/fabric/ip/apf/apf_clock_bridge.ip
src/pd_qsys/fabric/ip/apf/apf_pgsk_slv.ip
src/pd_qsys/fabric/ip/apf/apf_reset_bridge.ip
src/pd_qsys/fabric/ip/apf/apf_rsv_b_slv.ip
src/pd_qsys/fabric/ip/apf/apf_rsv_c_slv.ip
src/pd_qsys/fabric/ip/apf/apf_rsv_d_slv.ip
src/pd_qsys/fabric/ip/apf/apf_rsv_e_slv.ip
src/pd_qsys/fabric/ip/apf/apf_rsv_f_slv.ip
src/pd_qsys/fabric/ip/apf/apf_st2mm_mst.ip
src/pd_qsys/fabric/ip/apf/apf_st2mm_slv.ip


# BPF
src/pd_qsys/fabric/bpf.qsys
src/pd_qsys/fabric/ip/bpf/bpf_apf_mst.ip
src/pd_qsys/fabric/ip/bpf/bpf_apf_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_clock_bridge.ip
src/pd_qsys/fabric/ip/bpf/bpf_emif_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_fme_mst.ip
src/pd_qsys/fabric/ip/bpf/bpf_fme_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_hssi_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_pcie_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_pmci_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_reset_bridge.ip
src/pd_qsys/fabric/ip/bpf/bpf_rsv_5_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_rsv_6_slv.ip
src/pd_qsys/fabric/ip/bpf/bpf_rsv_7_slv.ip
src/pd_qsys/spi_bridge/spi_bridge.qsys
src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_clock_in.ip
src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_reset_in.ip
src/pd_qsys/spi_bridge/ip/spi_bridge/spi_bridge_spi_0.ip


# PLL
ofs-common/src/common/fme_id_rom/fme_id_rom.ip
ofs-common/src/fpga_family/stratix10/sys_pll/sys_pll.ip

# Port Gasket
ofs-common/src/fpga_family/stratix10/pr/PR_IP.ip
ofs-common/src/fpga_family/stratix10/user_clock/qph_user_clk_iopll_s10_RF100M.ip
ofs-common/src/fpga_family/stratix10/user_clock/qph_user_clk_iopll_reconfig.ip

# Remote STP
ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/host_if.ip
ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/jop_blaster.ip
ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/remote_debug_jtag_only_clock_in.ip
ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/remote_debug_jtag_only_reset_in.ip
ofs-common/src/fpga_family/stratix10/remote_stp/ip/remote_debug_jtag_only/sys_clk.ip
ofs-common/src/fpga_family/stratix10/remote_stp/AFU_debug/scjio_agilex.ip
ofs-common/src/fpga_family/stratix10/remote_stp/AFU_debug/config_reset_release.ip
ofs-common/src/fpga_family/stratix10/remote_stp/remote_debug_jtag_only.qsys

ofs-common/src/fpga_family/stratix10/cfg_mon/cfg_mon.ip
ofs-common/src/fpga_family/stratix10/avst_pipeline/avst_pipeline_st_pipeline_stage_0.ip
ofs-common/src/fpga_family/stratix10/avst_pipeline/avst_pipeline_st_pipeline_stage_1.ip
