# Copyright 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# PCIe
src/pcie/qip/s10/pcie_ep_g3x16

# FME
src/fme/qip/s10/fme_id_rom/fme_id_rom

# System PLL
src/top/qip/s10/sys_pll

# SPI
src/spi/qsys/s10/spi_bridge/ip/spi_bridge/spi_bridge_clock_in
src/spi/qsys/s10/spi_bridge/ip/spi_bridge/spi_bridge_reset_in
src/spi/qsys/s10/spi_bridge/ip/spi_bridge/spi_bridge_spi_0
src/spi/qsys/s10/spi_bridge/spi_bridge

# AFU
src/afu/qip/s10/avst_mux
src/afu/qip/s10/avst_demux

# HE
src/afu/qip/s10/lpbk1_RdRspRAM2PORT
src/afu/qip/s10/req_C1TxRAM2PORT
src/afu/qip/s10/mode7_TxC0_TID_queue

# HSSI
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_clk_csr
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_master_0
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_merlin_master_translator_0
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_mac
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_mm_to_phy
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_rx_xcvr_clk
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_clk
src/eth/s10/ip/address_decoder/ip/address_decode/address_decode_tx_xcvr_half_clk
src/eth/s10/ip/address_decoder/address_decode
src/eth/s10/ip/mac/altera_eth_10g_mac
src/eth/s10/ip/phy/altera_eth_10gbaser_phy
src/eth/s10/ip/pll_mpll/pll
src/eth/s10/ip/pll_atxpll/altera_xcvr_atx_pll_ip
src/eth/s10/ip/xcvr_reset_controller/reset_control

#BPF
src/fabric/qip/s10/ip/bpf/bpf_apf_mst
src/fabric/qip/s10/ip/bpf/bpf_clock_bridge
src/fabric/qip/s10/ip/bpf/bpf_fme_slv
src/fabric/qip/s10/ip/bpf/bpf_pmci_slv
src/fabric/qip/s10/ip/bpf/bpf_pcie_slv
src/fabric/qip/s10/ip/bpf/bpf_reset_bridge
src/fabric/qip/s10/ip/bpf/bpf_dummy_slv
src/fabric/qip/s10/ip/bpf/bpf_fme_mst
src/fabric/qip/s10/ip/bpf/bpf_apf_slv
src/fabric/qip/s10/bpf

#APF
src/fabric/qip/s10/ip/apf/apf_bpf_slv
src/fabric/qip/s10/ip/apf/apf_clock_bridge
src/fabric/qip/s10/ip/apf/apf_hssi_slv
src/fabric/qip/s10/ip/apf/apf_pr_slv
src/fabric/qip/s10/ip/apf/apf_reset_bridge
src/fabric/qip/s10/ip/apf/apf_st2mm_mst
src/fabric/qip/s10/ip/apf/apf_st2mm_slv
src/fabric/qip/s10/ip/apf/apf_dummy_slv
src/fabric/qip/s10/apf

#MEM
src/mem/qip/s10/emif_8GB_2400/emif_8GB_2400
src/mem/qip/s10/reqfifo/reqfifo
src/mem/qip/s10/rspfifo/rspfifo
