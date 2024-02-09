# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# DDR pin and location assignments
#
#-----------------------------------------------------------------------------
#=========================================================
#             DDR4 CH0 (Lower 2) - A/C 
#=========================================================
set_location_assignment PIN_AU22 -to ddr4_mem[0].ck
set_location_assignment PIN_AV22 -to ddr4_mem[0].ck_n
set_location_assignment PIN_AR22 -to ddr4_mem[0].act_n
set_location_assignment PIN_AV23 -to ddr4_mem[0].cke
set_location_assignment PIN_AT22 -to ddr4_mem[0].cs_n
set_location_assignment PIN_BB23 -to ddr4_mem[0].odt
set_location_assignment PIN_AY22 -to ddr4_mem[0].reset_n
set_location_assignment PIN_AW23 -to ddr4_mem[0].par
set_location_assignment PIN_AY23 -to ddr4_mem[0].alert_n
set_location_assignment PIN_BA21 -to ddr4_mem[0].oct_rzqin
set_location_assignment PIN_AY19 -to ddr4_mem[0].ref_clk
set_location_assignment PIN_AM25 -to ddr4_mem[0].a[0]
set_location_assignment PIN_AN25 -to ddr4_mem[0].a[1]
set_location_assignment PIN_AP24 -to ddr4_mem[0].a[2]
set_location_assignment PIN_AP25 -to ddr4_mem[0].a[3]
set_location_assignment PIN_AL24 -to ddr4_mem[0].a[4]
set_location_assignment PIN_AM24 -to ddr4_mem[0].a[5]
set_location_assignment PIN_AL26 -to ddr4_mem[0].a[6]
set_location_assignment PIN_AL25 -to ddr4_mem[0].a[7]
set_location_assignment PIN_AP23 -to ddr4_mem[0].a[8]
set_location_assignment PIN_AN23 -to ddr4_mem[0].a[9]
set_location_assignment PIN_AR23 -to ddr4_mem[0].a[10]
set_location_assignment PIN_AR24 -to ddr4_mem[0].a[11]
set_location_assignment PIN_AY21 -to ddr4_mem[0].a[12]
set_location_assignment PIN_BB19 -to ddr4_mem[0].a[13]
set_location_assignment PIN_BA19 -to ddr4_mem[0].a[14]
set_location_assignment PIN_AW21 -to ddr4_mem[0].a[15]
set_location_assignment PIN_AV21 -to ddr4_mem[0].a[16]
set_location_assignment PIN_BB20 -to ddr4_mem[0].a[17]
set_location_assignment PIN_AW20 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_BA20 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_BA22 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_AV20 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_AH18 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_AJ18 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_AJ19 -to ddr4_mem[0].dqs[9]
set_location_assignment PIN_AK22 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_AK21 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_AJ24 -to ddr4_mem[0].dqs[10]
set_location_assignment PIN_AM18 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_AN18 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_AR18 -to ddr4_mem[0].dqs[11]
set_location_assignment PIN_BB18 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_BB17 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_AV16 -to ddr4_mem[0].dqs[12]
set_location_assignment PIN_BB25 -to ddr4_mem[0].dqs[4]
set_location_assignment PIN_BA25 -to ddr4_mem[0].dqs_n[4]
set_location_assignment PIN_BA27 -to ddr4_mem[0].dqs[13]
set_location_assignment PIN_AT27 -to ddr4_mem[0].dqs[5]
set_location_assignment PIN_AU27 -to ddr4_mem[0].dqs_n[5]
set_location_assignment PIN_AV25 -to ddr4_mem[0].dqs[14]
set_location_assignment PIN_AP29 -to ddr4_mem[0].dqs[6]
set_location_assignment PIN_AR30 -to ddr4_mem[0].dqs_n[6]
set_location_assignment PIN_AL30 -to ddr4_mem[0].dqs[15]
set_location_assignment PIN_AK28 -to ddr4_mem[0].dqs[7]
set_location_assignment PIN_AK27 -to ddr4_mem[0].dqs_n[7]
set_location_assignment PIN_AK29 -to ddr4_mem[0].dqs[16]
set_location_assignment PIN_AU19 -to ddr4_mem[0].dqs[8]
set_location_assignment PIN_AU20 -to ddr4_mem[0].dqs_n[8]
set_location_assignment PIN_AT21 -to ddr4_mem[0].dqs[17]
set_location_assignment PIN_AL17 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_AL19 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_AM17 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_AK17 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_AK19 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_AM20 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_AN17 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_AM19 -to ddr4_mem[0].dq[7]
set_location_assignment PIN_AL22 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_AJ23 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_AJ26 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_AK23 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_AL20 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_AH24 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_AJ25 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_AL21 -to ddr4_mem[0].dq[15]
set_location_assignment PIN_AT17 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_AR16 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_AT16 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_AP18 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_AU17 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_AP19 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_AT19 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_AR19 -to ddr4_mem[0].dq[23]
set_location_assignment PIN_AY17 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_AY16 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_AU18 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_AY18 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_AV18 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_AW16 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_AW18 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_BA17 -to ddr4_mem[0].dq[31]
set_location_assignment PIN_BB24 -to ddr4_mem[0].dq[32]
set_location_assignment PIN_BA26 -to ddr4_mem[0].dq[33]
set_location_assignment PIN_AV27 -to ddr4_mem[0].dq[34]
set_location_assignment PIN_AY27 -to ddr4_mem[0].dq[35]
set_location_assignment PIN_BA24 -to ddr4_mem[0].dq[36]
set_location_assignment PIN_AY26 -to ddr4_mem[0].dq[37]
set_location_assignment PIN_AV26 -to ddr4_mem[0].dq[38]
set_location_assignment PIN_AW26 -to ddr4_mem[0].dq[39]
set_location_assignment PIN_AW24 -to ddr4_mem[0].dq[40]
set_location_assignment PIN_AT26 -to ddr4_mem[0].dq[41]
set_location_assignment PIN_AT24 -to ddr4_mem[0].dq[42]
set_location_assignment PIN_AU24 -to ddr4_mem[0].dq[43]
set_location_assignment PIN_AY24 -to ddr4_mem[0].dq[44]
set_location_assignment PIN_AU25 -to ddr4_mem[0].dq[45]
set_location_assignment PIN_AT25 -to ddr4_mem[0].dq[46]
set_location_assignment PIN_AR27 -to ddr4_mem[0].dq[47]
set_location_assignment PIN_AT29 -to ddr4_mem[0].dq[48]
set_location_assignment PIN_AR29 -to ddr4_mem[0].dq[49]
set_location_assignment PIN_AP30 -to ddr4_mem[0].dq[50]
set_location_assignment PIN_AN30 -to ddr4_mem[0].dq[51]
set_location_assignment PIN_AP28 -to ddr4_mem[0].dq[52]
set_location_assignment PIN_AR28 -to ddr4_mem[0].dq[53]
set_location_assignment PIN_AT30 -to ddr4_mem[0].dq[54]
set_location_assignment PIN_AT31 -to ddr4_mem[0].dq[55]
set_location_assignment PIN_AM28 -to ddr4_mem[0].dq[56]
set_location_assignment PIN_AL29 -to ddr4_mem[0].dq[57]
set_location_assignment PIN_AN28 -to ddr4_mem[0].dq[58]
set_location_assignment PIN_AP26 -to ddr4_mem[0].dq[59]
set_location_assignment PIN_AL27 -to ddr4_mem[0].dq[60]
set_location_assignment PIN_AM29 -to ddr4_mem[0].dq[61]
set_location_assignment PIN_AN27 -to ddr4_mem[0].dq[62]
set_location_assignment PIN_AM27 -to ddr4_mem[0].dq[63]
set_location_assignment PIN_AN22 -to ddr4_mem[0].dq[64]
set_location_assignment PIN_AN20 -to ddr4_mem[0].dq[65]
set_location_assignment PIN_AM22 -to ddr4_mem[0].dq[66]
set_location_assignment PIN_AR21 -to ddr4_mem[0].dq[67]
set_location_assignment PIN_AM23 -to ddr4_mem[0].dq[68]
set_location_assignment PIN_AP20 -to ddr4_mem[0].dq[69]
set_location_assignment PIN_AN21 -to ddr4_mem[0].dq[70]
set_location_assignment PIN_AP21 -to ddr4_mem[0].dq[71]
#=========================================================
#             DDR4 CH1 (Upper 2) - A/C 
#=========================================================
set_location_assignment PIN_K31  -to ddr4_mem[1].ck
set_location_assignment PIN_L30  -to ddr4_mem[1].ck_n
set_location_assignment PIN_L29  -to ddr4_mem[1].act_n
set_location_assignment PIN_M30  -to ddr4_mem[1].cke
set_location_assignment PIN_M29  -to ddr4_mem[1].cs_n
set_location_assignment PIN_K30  -to ddr4_mem[1].odt
set_location_assignment PIN_P31  -to ddr4_mem[1].reset_n
set_location_assignment PIN_P29  -to ddr4_mem[1].par
set_location_assignment PIN_P30  -to ddr4_mem[1].alert_n
set_location_assignment PIN_J30  -to ddr4_mem[1].oct_rzqin
set_location_assignment PIN_D27  -to ddr4_mem[1].ref_clk
set_location_assignment PIN_M28  -to ddr4_mem[1].a[0]
set_location_assignment PIN_N28  -to ddr4_mem[1].a[1]
set_location_assignment PIN_R26  -to ddr4_mem[1].a[2]
set_location_assignment PIN_P26  -to ddr4_mem[1].a[3]
set_location_assignment PIN_P28  -to ddr4_mem[1].a[4]
set_location_assignment PIN_R27  -to ddr4_mem[1].a[5]
set_location_assignment PIN_K26  -to ddr4_mem[1].a[6]
set_location_assignment PIN_K27  -to ddr4_mem[1].a[7]
set_location_assignment PIN_N26  -to ddr4_mem[1].a[8]
set_location_assignment PIN_N27  -to ddr4_mem[1].a[9]
set_location_assignment PIN_L27  -to ddr4_mem[1].a[10]
set_location_assignment PIN_M27  -to ddr4_mem[1].a[11]
set_location_assignment PIN_J29  -to ddr4_mem[1].a[12]
set_location_assignment PIN_J28  -to ddr4_mem[1].a[13]
set_location_assignment PIN_K28  -to ddr4_mem[1].a[14]
set_location_assignment PIN_H31  -to ddr4_mem[1].a[15]
set_location_assignment PIN_H30  -to ddr4_mem[1].a[16]
set_location_assignment PIN_H28  -to ddr4_mem[1].a[17]
set_location_assignment PIN_G27  -to ddr4_mem[1].ba[1]
set_location_assignment PIN_H27  -to ddr4_mem[1].ba[0]
set_location_assignment PIN_N30  -to ddr4_mem[1].bg[1]
set_location_assignment PIN_F27  -to ddr4_mem[1].bg[0]
set_location_assignment PIN_T23  -to ddr4_mem[1].dqs[0]
set_location_assignment PIN_R24  -to ddr4_mem[1].dqs_n[0]
set_location_assignment PIN_K23  -to ddr4_mem[1].dqs[9]
set_location_assignment PIN_N25  -to ddr4_mem[1].dqs[1]
set_location_assignment PIN_P25  -to ddr4_mem[1].dqs_n[1]
set_location_assignment PIN_L25  -to ddr4_mem[1].dqs[10]
set_location_assignment PIN_B24  -to ddr4_mem[1].dqs[2]
set_location_assignment PIN_B25  -to ddr4_mem[1].dqs_n[2]
set_location_assignment PIN_C27  -to ddr4_mem[1].dqs[11]
set_location_assignment PIN_C23  -to ddr4_mem[1].dqs[3]
set_location_assignment PIN_C22  -to ddr4_mem[1].dqs_n[3]
set_location_assignment PIN_D24  -to ddr4_mem[1].dqs[12]
set_location_assignment PIN_D8   -to ddr4_mem[1].dqs[4]
set_location_assignment PIN_C8   -to ddr4_mem[1].dqs_n[4]
set_location_assignment PIN_C10  -to ddr4_mem[1].dqs[13]
set_location_assignment PIN_N17  -to ddr4_mem[1].dqs[5]
set_location_assignment PIN_M17  -to ddr4_mem[1].dqs_n[5]
set_location_assignment PIN_M18  -to ddr4_mem[1].dqs[14]
set_location_assignment PIN_R17  -to ddr4_mem[1].dqs[6]
set_location_assignment PIN_P18  -to ddr4_mem[1].dqs_n[6]
set_location_assignment PIN_M15  -to ddr4_mem[1].dqs[15]
set_location_assignment PIN_E14  -to ddr4_mem[1].dqs[7]
set_location_assignment PIN_F14  -to ddr4_mem[1].dqs_n[7]
set_location_assignment PIN_D15  -to ddr4_mem[1].dqs[16]
set_location_assignment PIN_J23  -to ddr4_mem[1].dqs[8]
set_location_assignment PIN_H23  -to ddr4_mem[1].dqs_n[8]
set_location_assignment PIN_E21  -to ddr4_mem[1].dqs[17]
set_location_assignment PIN_N23  -to ddr4_mem[1].dq[0]
set_location_assignment PIN_P23  -to ddr4_mem[1].dq[1]
set_location_assignment PIN_M22  -to ddr4_mem[1].dq[2]
set_location_assignment PIN_M23  -to ddr4_mem[1].dq[3]
set_location_assignment PIN_P24  -to ddr4_mem[1].dq[4]
set_location_assignment PIN_N22  -to ddr4_mem[1].dq[5]
set_location_assignment PIN_L22  -to ddr4_mem[1].dq[6]
set_location_assignment PIN_M24  -to ddr4_mem[1].dq[7]
set_location_assignment PIN_G25  -to ddr4_mem[1].dq[8]
set_location_assignment PIN_H26  -to ddr4_mem[1].dq[9]
set_location_assignment PIN_J24  -to ddr4_mem[1].dq[10]
set_location_assignment PIN_J25  -to ddr4_mem[1].dq[11]
set_location_assignment PIN_G24  -to ddr4_mem[1].dq[12]
set_location_assignment PIN_H25  -to ddr4_mem[1].dq[13]
set_location_assignment PIN_L24  -to ddr4_mem[1].dq[14]
set_location_assignment PIN_K24  -to ddr4_mem[1].dq[15]
set_location_assignment PIN_E26  -to ddr4_mem[1].dq[16]
set_location_assignment PIN_D26  -to ddr4_mem[1].dq[17]
set_location_assignment PIN_D25  -to ddr4_mem[1].dq[18]
set_location_assignment PIN_C25  -to ddr4_mem[1].dq[19]
set_location_assignment PIN_F26  -to ddr4_mem[1].dq[20]
set_location_assignment PIN_F25  -to ddr4_mem[1].dq[21]
set_location_assignment PIN_A24  -to ddr4_mem[1].dq[22]
set_location_assignment PIN_A25  -to ddr4_mem[1].dq[23]
set_location_assignment PIN_B23  -to ddr4_mem[1].dq[24]
set_location_assignment PIN_G23  -to ddr4_mem[1].dq[25]
set_location_assignment PIN_E23  -to ddr4_mem[1].dq[26]
set_location_assignment PIN_B22  -to ddr4_mem[1].dq[27]
set_location_assignment PIN_D23  -to ddr4_mem[1].dq[28]
set_location_assignment PIN_F24  -to ddr4_mem[1].dq[29]
set_location_assignment PIN_A21  -to ddr4_mem[1].dq[30]
set_location_assignment PIN_A22  -to ddr4_mem[1].dq[31]
set_location_assignment PIN_D11  -to ddr4_mem[1].dq[32]
set_location_assignment PIN_D9   -to ddr4_mem[1].dq[33]
set_location_assignment PIN_F12  -to ddr4_mem[1].dq[34]
set_location_assignment PIN_G12  -to ddr4_mem[1].dq[35]
set_location_assignment PIN_E12  -to ddr4_mem[1].dq[36]
set_location_assignment PIN_D10  -to ddr4_mem[1].dq[37]
set_location_assignment PIN_E11  -to ddr4_mem[1].dq[38]
set_location_assignment PIN_F11  -to ddr4_mem[1].dq[39]
set_location_assignment PIN_H16  -to ddr4_mem[1].dq[40]
set_location_assignment PIN_L17  -to ddr4_mem[1].dq[41]
set_location_assignment PIN_F17  -to ddr4_mem[1].dq[42]
set_location_assignment PIN_F16  -to ddr4_mem[1].dq[43]
set_location_assignment PIN_H17  -to ddr4_mem[1].dq[44]
set_location_assignment PIN_K17  -to ddr4_mem[1].dq[45]
set_location_assignment PIN_E16  -to ddr4_mem[1].dq[46]
set_location_assignment PIN_G17  -to ddr4_mem[1].dq[47]
set_location_assignment PIN_K16  -to ddr4_mem[1].dq[48]
set_location_assignment PIN_L15  -to ddr4_mem[1].dq[49]
set_location_assignment PIN_P16  -to ddr4_mem[1].dq[50]
set_location_assignment PIN_N16  -to ddr4_mem[1].dq[51]
set_location_assignment PIN_J16  -to ddr4_mem[1].dq[52]
set_location_assignment PIN_L16  -to ddr4_mem[1].dq[53]
set_location_assignment PIN_P15  -to ddr4_mem[1].dq[54]
set_location_assignment PIN_R16  -to ddr4_mem[1].dq[55]
set_location_assignment PIN_H15  -to ddr4_mem[1].dq[56]
set_location_assignment PIN_F15  -to ddr4_mem[1].dq[57]
set_location_assignment PIN_G13  -to ddr4_mem[1].dq[58]
set_location_assignment PIN_G14  -to ddr4_mem[1].dq[59]
set_location_assignment PIN_J15  -to ddr4_mem[1].dq[60]
set_location_assignment PIN_G15  -to ddr4_mem[1].dq[61]
set_location_assignment PIN_E13  -to ddr4_mem[1].dq[62]
set_location_assignment PIN_D13  -to ddr4_mem[1].dq[63]
set_location_assignment PIN_C21  -to ddr4_mem[1].dq[64]
set_location_assignment PIN_D21  -to ddr4_mem[1].dq[65]
set_location_assignment PIN_J21  -to ddr4_mem[1].dq[66]
set_location_assignment PIN_H21  -to ddr4_mem[1].dq[67]
set_location_assignment PIN_F22  -to ddr4_mem[1].dq[68]
set_location_assignment PIN_E22  -to ddr4_mem[1].dq[69]
set_location_assignment PIN_H22  -to ddr4_mem[1].dq[70]
set_location_assignment PIN_G22  -to ddr4_mem[1].dq[71]
#=========================================================
#             DDR4 CH1 (Lower 2) - A/C 
#=========================================================
#set_location_assignment PIN_AP10 -to mem_ck       [2]
#set_location_assignment PIN_AP11 -to mem_ck_n     [2]
#set_location_assignment PIN_AR7  -to mem_act_n    [2]
#set_location_assignment PIN_AT6  -to mem_cke      [2]
#set_location_assignment PIN_AR8  -to mem_cs_n     [2]
#set_location_assignment PIN_AP8  -to mem_odt      [2]
#set_location_assignment PIN_AP9  -to mem_reset_n  [2]
#set_location_assignment PIN_AP5  -to mem_par      [2]
#set_location_assignment PIN_AP6  -to mem_alert_n  [2]
#set_location_assignment PIN_AN3  -to mem_oct_rzqin[2]
#set_location_assignment PIN_AL5  -to mem_ref_clk  [2]
#set_location_assignment PIN_AT4  -to mem_a     [2][0]
#set_location_assignment PIN_AT5  -to mem_a     [2][1]
#set_location_assignment PIN_AR2  -to mem_a     [2][2]
#set_location_assignment PIN_AR1  -to mem_a     [2][3]
#set_location_assignment PIN_AR3  -to mem_a     [2][4]
#set_location_assignment PIN_AR4  -to mem_a     [2][5]
#set_location_assignment PIN_AP1  -to mem_a     [2][6]
#set_location_assignment PIN_AN1  -to mem_a     [2][7]
#set_location_assignment PIN_AP4  -to mem_a     [2][8]
#set_location_assignment PIN_AP3  -to mem_a     [2][9]
#set_location_assignment PIN_AT2  -to mem_a     [2][10]
#set_location_assignment PIN_AT1  -to mem_a     [2][11]
#set_location_assignment PIN_AN2  -to mem_a     [2][12]
#set_location_assignment PIN_AN5  -to mem_a     [2][13]
#set_location_assignment PIN_AM5  -to mem_a     [2][14]
#set_location_assignment PIN_AM2  -to mem_a     [2][15]
#set_location_assignment PIN_AM3  -to mem_a     [2][16]
#set_location_assignment PIN_AM4  -to mem_a     [2][17]
#set_location_assignment PIN_AL1  -to mem_ba    [2][1]
#set_location_assignment PIN_AL4  -to mem_ba    [2][0]
#set_location_assignment PIN_AR9  -to mem_bg    [2][1]
#set_location_assignment PIN_AL2  -to mem_bg    [2][0]
#set_location_assignment PIN_AH5  -to mem_dqs   [2][0]
#set_location_assignment PIN_AG5  -to mem_dqs_n [2][0]
#set_location_assignment PIN_AG4  -to mem_dbi_n [2][0]
#set_location_assignment PIN_AK6  -to mem_dqs   [2][1]
#set_location_assignment PIN_AK7  -to mem_dqs_n [2][1]
#set_location_assignment PIN_AJ6  -to mem_dbi_n [2][1]
#set_location_assignment PIN_AL11 -to mem_dqs   [2][2]
#set_location_assignment PIN_AL10 -to mem_dqs_n [2][2]
#set_location_assignment PIN_AK12 -to mem_dbi_n [2][2]
#set_location_assignment PIN_AH10 -to mem_dqs   [2][3]
#set_location_assignment PIN_AJ11 -to mem_dqs_n [2][3]
#set_location_assignment PIN_AH11 -to mem_dbi_n [2][3]
#set_location_assignment PIN_AV6  -to mem_dqs   [2][4]
#set_location_assignment PIN_AV5  -to mem_dqs_n [2][4]
#set_location_assignment PIN_AW1  -to mem_dbi_n [2][4]
#set_location_assignment PIN_AV10 -to mem_dqs   [2][5]
#set_location_assignment PIN_AU10 -to mem_dqs_n [2][5]
#set_location_assignment PIN_AU13 -to mem_dbi_n [2][5]
#set_location_assignment PIN_AT11 -to mem_dqs   [2][6]
#set_location_assignment PIN_AR11 -to mem_dqs_n [2][6]
#set_location_assignment PIN_AR13 -to mem_dbi_n [2][6]
#set_location_assignment PIN_BA4  -to mem_dqs   [2][7]
#set_location_assignment PIN_BB4  -to mem_dqs_n [2][7]
#set_location_assignment PIN_AW5  -to mem_dbi_n [2][7]
#set_location_assignment PIN_AN10 -to mem_dqs   [2][8]
#set_location_assignment PIN_AN11 -to mem_dqs_n [2][8]
#set_location_assignment PIN_AM12 -to mem_dbi_n [2][8]
#set_location_assignment PIN_AF1  -to mem_dq    [2][0]
#set_location_assignment PIN_AH6  -to mem_dq    [2][1]
#set_location_assignment PIN_AH3  -to mem_dq    [2][2]
#set_location_assignment PIN_AG2  -to mem_dq    [2][3]
#set_location_assignment PIN_AF2  -to mem_dq    [2][4]
#set_location_assignment PIN_AH7  -to mem_dq    [2][5]
#set_location_assignment PIN_AH2  -to mem_dq    [2][6]
#set_location_assignment PIN_AG3  -to mem_dq    [2][7]
#set_location_assignment PIN_AK2  -to mem_dq    [2][8]
#set_location_assignment PIN_AJ3  -to mem_dq    [2][9]
#set_location_assignment PIN_AK4  -to mem_dq    [2][10]
#set_location_assignment PIN_AJ4  -to mem_dq    [2][11]
#set_location_assignment PIN_AK1  -to mem_dq    [2][12]
#set_location_assignment PIN_AH1  -to mem_dq    [2][13]
#set_location_assignment PIN_AK3  -to mem_dq    [2][14]
#set_location_assignment PIN_AJ1  -to mem_dq    [2][15]
#set_location_assignment PIN_AL12 -to mem_dq    [2][16]
#set_location_assignment PIN_AK11 -to mem_dq    [2][17]
#set_location_assignment PIN_AL9  -to mem_dq    [2][18]
#set_location_assignment PIN_AK8  -to mem_dq    [2][19]
#set_location_assignment PIN_AL14 -to mem_dq    [2][20]
#set_location_assignment PIN_AK14 -to mem_dq    [2][21]
#set_location_assignment PIN_AL7  -to mem_dq    [2][22]
#set_location_assignment PIN_AK9  -to mem_dq    [2][23]
#set_location_assignment PIN_AH13 -to mem_dq    [2][24]
#set_location_assignment PIN_AG7  -to mem_dq    [2][25]
#set_location_assignment PIN_AJ10 -to mem_dq    [2][26]
#set_location_assignment PIN_AJ8  -to mem_dq    [2][27]
#set_location_assignment PIN_AJ13 -to mem_dq    [2][28]
#set_location_assignment PIN_AG8  -to mem_dq    [2][29]
#set_location_assignment PIN_AJ9  -to mem_dq    [2][30]
#set_location_assignment PIN_AH8  -to mem_dq    [2][31]
#set_location_assignment PIN_AU4  -to mem_dq    [2][32]
#set_location_assignment PIN_AU5  -to mem_dq    [2][33]
#set_location_assignment PIN_AU3  -to mem_dq    [2][34]
#set_location_assignment PIN_AV2  -to mem_dq    [2][35]
#set_location_assignment PIN_AV7  -to mem_dq    [2][36]
#set_location_assignment PIN_AV8  -to mem_dq    [2][37]
#set_location_assignment PIN_AU2  -to mem_dq    [2][38]
#set_location_assignment PIN_AV3  -to mem_dq    [2][39]
#set_location_assignment PIN_AY7  -to mem_dq    [2][40]
#set_location_assignment PIN_AW10 -to mem_dq    [2][41]
#set_location_assignment PIN_AV11 -to mem_dq    [2][42]
#set_location_assignment PIN_AW8  -to mem_dq    [2][43]
#set_location_assignment PIN_AY6  -to mem_dq    [2][44]
#set_location_assignment PIN_AW11 -to mem_dq    [2][45]
#set_location_assignment PIN_AV12 -to mem_dq    [2][46]
#set_location_assignment PIN_AW9  -to mem_dq    [2][47]
#set_location_assignment PIN_AU8  -to mem_dq    [2][48]
#set_location_assignment PIN_AT12 -to mem_dq    [2][49]
#set_location_assignment PIN_AT9  -to mem_dq    [2][50]
#set_location_assignment PIN_AT7  -to mem_dq    [2][51]
#set_location_assignment PIN_AU7  -to mem_dq    [2][52]
#set_location_assignment PIN_AT10 -to mem_dq    [2][53]
#set_location_assignment PIN_AU9  -to mem_dq    [2][54]
#set_location_assignment PIN_AR12 -to mem_dq    [2][55]
#set_location_assignment PIN_BA2  -to mem_dq    [2][56]
#set_location_assignment PIN_AY4  -to mem_dq    [2][57]
#set_location_assignment PIN_AW3  -to mem_dq    [2][58]
#set_location_assignment PIN_BA5  -to mem_dq    [2][59]
#set_location_assignment PIN_AY2  -to mem_dq    [2][60]
#set_location_assignment PIN_AW4  -to mem_dq    [2][61]
#set_location_assignment PIN_AY3  -to mem_dq    [2][62]
#set_location_assignment PIN_BB5  -to mem_dq    [2][63]
#set_location_assignment PIN_AM7  -to mem_dq    [2][64]
#set_location_assignment PIN_AM8  -to mem_dq    [2][65]
#set_location_assignment PIN_AN13 -to mem_dq    [2][66]
#set_location_assignment PIN_AN12 -to mem_dq    [2][67]
#set_location_assignment PIN_AN6  -to mem_dq    [2][68]
#set_location_assignment PIN_AN7  -to mem_dq    [2][69]
#set_location_assignment PIN_AM9  -to mem_dq    [2][70]
#set_location_assignment PIN_AM10 -to mem_dq    [2][71]
#=========================================================
#            DDR4 CH3 (Upper 3)  - A/C 
#=========================================================
#set_location_assignment PIN_L6   -to mem_ck       [3]
#set_location_assignment PIN_L7   -to mem_ck_n     [3]
#set_location_assignment PIN_L5   -to mem_act_n    [3]
#set_location_assignment PIN_M4   -to mem_cke      [3]
#set_location_assignment PIN_M5   -to mem_cs_n     [3]
#set_location_assignment PIN_M8   -to mem_odt      [3]
#set_location_assignment PIN_M9   -to mem_reset_n  [3]
#set_location_assignment PIN_K4   -to mem_par      [3]
#set_location_assignment PIN_L4   -to mem_alert_n  [3]
#set_location_assignment PIN_J5   -to mem_oct_rzqin[3]
#set_location_assignment PIN_K8   -to mem_ref_clk  [3]
#set_location_assignment PIN_H1   -to mem_a     [3][0]
#set_location_assignment PIN_J1   -to mem_a     [3][1]
#set_location_assignment PIN_L2   -to mem_a     [3][2]
#set_location_assignment PIN_K2   -to mem_a     [3][3]
#set_location_assignment PIN_F2   -to mem_a     [3][4]
#set_location_assignment PIN_F1   -to mem_a     [3][5]
#set_location_assignment PIN_L1   -to mem_a     [3][6]
#set_location_assignment PIN_K1   -to mem_a     [3][7]
#set_location_assignment PIN_G2   -to mem_a     [3][8]
#set_location_assignment PIN_H2   -to mem_a     [3][9]
#set_location_assignment PIN_K3   -to mem_a     [3][10]
#set_location_assignment PIN_J3   -to mem_a     [3][11]
#set_location_assignment PIN_J4   -to mem_a     [3][12]
#set_location_assignment PIN_K6   -to mem_a     [3][13]
#set_location_assignment PIN_J6   -to mem_a     [3][14]
#set_location_assignment PIN_H3   -to mem_a     [3][15]
#set_location_assignment PIN_G3   -to mem_a     [3][16]
#set_location_assignment PIN_H5   -to mem_a     [3][17]
#set_location_assignment PIN_G4   -to mem_ba    [3][1]
#set_location_assignment PIN_H6   -to mem_ba    [3][0]
#set_location_assignment PIN_M10  -to mem_bg    [3][1]
#set_location_assignment PIN_G5   -to mem_bg    [3][0]
#set_location_assignment PIN_G8   -to mem_dqs   [3][0]
#set_location_assignment PIN_G9   -to mem_dqs_n [3][0]
#set_location_assignment PIN_J13  -to mem_dbi_n [3][0]
#set_location_assignment PIN_C7   -to mem_dqs   [3][1]
#set_location_assignment PIN_B7   -to mem_dqs_n [3][1]
#set_location_assignment PIN_E9   -to mem_dbi_n [3][1]
#set_location_assignment PIN_F4   -to mem_dqs   [3][2]
#set_location_assignment PIN_E4   -to mem_dqs_n [3][2]
#set_location_assignment PIN_E3   -to mem_dbi_n [3][2]
#set_location_assignment PIN_C5   -to mem_dqs   [3][3]
#set_location_assignment PIN_D5   -to mem_dqs_n [3][3]
#set_location_assignment PIN_A4   -to mem_dbi_n [3][3]
#set_location_assignment PIN_P1   -to mem_dqs   [3][4]
#set_location_assignment PIN_N1   -to mem_dqs_n [3][4]
#set_location_assignment PIN_N2   -to mem_dbi_n [3][4]
#set_location_assignment PIN_P9   -to mem_dqs   [3][5]
#set_location_assignment PIN_P8   -to mem_dqs_n [3][5]
#set_location_assignment PIN_R6   -to mem_dbi_n [3][5]
#set_location_assignment PIN_T6   -to mem_dqs   [3][6]
#set_location_assignment PIN_T7   -to mem_dqs_n [3][6]
#set_location_assignment PIN_R7   -to mem_dbi_n [3][6]
#set_location_assignment PIN_P13  -to mem_dqs   [3][7]
#set_location_assignment PIN_N13  -to mem_dqs_n [3][7]
#set_location_assignment PIN_R11  -to mem_dbi_n [3][7]
#set_location_assignment PIN_M12  -to mem_dqs   [3][8]
#set_location_assignment PIN_L12  -to mem_dqs_n [3][8]
#set_location_assignment PIN_K11  -to mem_dbi_n [3][8]
#set_location_assignment PIN_H10  -to mem_dq    [3][0]
#set_location_assignment PIN_H11  -to mem_dq    [3][1]
#set_location_assignment PIN_G10  -to mem_dq    [3][2]
#set_location_assignment PIN_F9   -to mem_dq    [3][3]
#set_location_assignment PIN_J10  -to mem_dq    [3][4]
#set_location_assignment PIN_J11  -to mem_dq    [3][5]
#set_location_assignment PIN_H12  -to mem_dq    [3][6]
#set_location_assignment PIN_F10  -to mem_dq    [3][7]
#set_location_assignment PIN_B5   -to mem_dq    [3][8]
#set_location_assignment PIN_A5   -to mem_dq    [3][9]
#set_location_assignment PIN_A6   -to mem_dq    [3][10]
#set_location_assignment PIN_E7   -to mem_dq    [3][11]
#set_location_assignment PIN_E6   -to mem_dq    [3][12]
#set_location_assignment PIN_D6   -to mem_dq    [3][13]
#set_location_assignment PIN_C6   -to mem_dq    [3][14]
#set_location_assignment PIN_A7   -to mem_dq    [3][15]
#set_location_assignment PIN_J8   -to mem_dq    [3][16]
#set_location_assignment PIN_G7   -to mem_dq    [3][17]
#set_location_assignment PIN_J9   -to mem_dq    [3][18]
#set_location_assignment PIN_F6   -to mem_dq    [3][19]
#set_location_assignment PIN_F5   -to mem_dq    [3][20]
#set_location_assignment PIN_H7   -to mem_dq    [3][21]
#set_location_assignment PIN_H8   -to mem_dq    [3][22]
#set_location_assignment PIN_F7   -to mem_dq    [3][23]
#set_location_assignment PIN_C2   -to mem_dq    [3][24]
#set_location_assignment PIN_D3   -to mem_dq    [3][25]
#set_location_assignment PIN_B2   -to mem_dq    [3][26]
#set_location_assignment PIN_B3   -to mem_dq    [3][27]
#set_location_assignment PIN_E1   -to mem_dq    [3][28]
#set_location_assignment PIN_D1   -to mem_dq    [3][29]
#set_location_assignment PIN_C3   -to mem_dq    [3][30]
#set_location_assignment PIN_D4   -to mem_dq    [3][31]
#set_location_assignment PIN_R4   -to mem_dq    [3][32]
#set_location_assignment PIN_R1   -to mem_dq    [3][33]
#set_location_assignment PIN_T2   -to mem_dq    [3][34]
#set_location_assignment PIN_R3   -to mem_dq    [3][35]
#set_location_assignment PIN_N3   -to mem_dq    [3][36]
#set_location_assignment PIN_P3   -to mem_dq    [3][37]
#set_location_assignment PIN_T1   -to mem_dq    [3][38]
#set_location_assignment PIN_R2   -to mem_dq    [3][39]
#set_location_assignment PIN_N5   -to mem_dq    [3][40]
#set_location_assignment PIN_P4   -to mem_dq    [3][41]
#set_location_assignment PIN_N8   -to mem_dq    [3][42]
#set_location_assignment PIN_P10  -to mem_dq    [3][43]
#set_location_assignment PIN_N6   -to mem_dq    [3][44]
#set_location_assignment PIN_P5   -to mem_dq    [3][45]
#set_location_assignment PIN_N7   -to mem_dq    [3][46]
#set_location_assignment PIN_N10  -to mem_dq    [3][47]
#set_location_assignment PIN_U4   -to mem_dq    [3][48]
#set_location_assignment PIN_T4   -to mem_dq    [3][49]
#set_location_assignment PIN_U5   -to mem_dq    [3][50]
#set_location_assignment PIN_T9   -to mem_dq    [3][51]
#set_location_assignment PIN_U2   -to mem_dq    [3][52]
#set_location_assignment PIN_R9   -to mem_dq    [3][53]
#set_location_assignment PIN_T5   -to mem_dq    [3][54]
#set_location_assignment PIN_U3   -to mem_dq    [3][55]
#set_location_assignment PIN_R13  -to mem_dq    [3][56]
#set_location_assignment PIN_N11  -to mem_dq    [3][57]
#set_location_assignment PIN_R14  -to mem_dq    [3][58]
#set_location_assignment PIN_T11  -to mem_dq    [3][59]
#set_location_assignment PIN_T12  -to mem_dq    [3][60]
#set_location_assignment PIN_N12  -to mem_dq    [3][61]
#set_location_assignment PIN_T10  -to mem_dq    [3][62]
#set_location_assignment PIN_R12  -to mem_dq    [3][63]
#set_location_assignment PIN_K14  -to mem_dq    [3][64]
#set_location_assignment PIN_K13  -to mem_dq    [3][65]
#set_location_assignment PIN_L9   -to mem_dq    [3][66]
#set_location_assignment PIN_L11  -to mem_dq    [3][67]
#set_location_assignment PIN_M13  -to mem_dq    [3][68]
#set_location_assignment PIN_M14  -to mem_dq    [3][69]
#set_location_assignment PIN_L10  -to mem_dq    [3][70]
#set_location_assignment PIN_K9   -to mem_dq    [3][71]

