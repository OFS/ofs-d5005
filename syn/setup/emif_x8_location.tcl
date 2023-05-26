# Copyright 2020 Intel Corporation
# SPDX-License-Identifier: MIT

# Description
#-----------------------------------------------------------------------------
#
# DDR4 pin and location assignments
#
#-----------------------------------------------------------------------------

#=======================================================
# DDR4 CH0 (Lower 3) -  A/C 
#=======================================================
set_location_assignment PIN_AP10 -to ddr4_mem[2].ck
set_location_assignment PIN_AP11 -to ddr4_mem[2].ck_n
set_location_assignment PIN_AT4 -to ddr4_mem[2].a[0]
set_location_assignment PIN_AT5 -to ddr4_mem[2].a[1]
set_location_assignment PIN_AR2 -to ddr4_mem[2].a[2]
set_location_assignment PIN_AR1 -to ddr4_mem[2].a[3]
set_location_assignment PIN_AR3 -to ddr4_mem[2].a[4]
set_location_assignment PIN_AR4 -to ddr4_mem[2].a[5]
set_location_assignment PIN_AP1 -to ddr4_mem[2].a[6]
set_location_assignment PIN_AN1 -to ddr4_mem[2].a[7]
set_location_assignment PIN_AP4 -to ddr4_mem[2].a[8]
set_location_assignment PIN_AP3 -to ddr4_mem[2].a[9]
set_location_assignment PIN_AT2 -to ddr4_mem[2].a[10]
set_location_assignment PIN_AT1 -to ddr4_mem[2].a[11]
set_location_assignment PIN_AN2 -to ddr4_mem[2].a[12]
set_location_assignment PIN_AN5 -to ddr4_mem[2].a[13]
set_location_assignment PIN_AM5 -to ddr4_mem[2].a[14]
set_location_assignment PIN_AM2 -to ddr4_mem[2].a[15]
set_location_assignment PIN_AM3 -to ddr4_mem[2].a[16]
set_location_assignment PIN_AM4 -to ddr4_mem[2].a[17]
set_location_assignment PIN_AR7 -to ddr4_mem[2].act_n
set_location_assignment PIN_AL1 -to ddr4_mem[2].ba[1]
set_location_assignment PIN_AL4 -to ddr4_mem[2].ba[0]
set_location_assignment PIN_AR9 -to ddr4_mem[2].bg[1]
set_location_assignment PIN_AL2 -to ddr4_mem[2].bg[0]
set_location_assignment PIN_AT6 -to ddr4_mem[2].cke
set_location_assignment PIN_AR8 -to ddr4_mem[2].cs_n
set_location_assignment PIN_AP8 -to ddr4_mem[2].odt
set_location_assignment PIN_AP9 -to ddr4_mem[2].reset_n
set_location_assignment PIN_AP5 -to ddr4_mem[2].par
set_location_assignment PIN_AP6 -to ddr4_mem[2].alert_n
set_location_assignment PIN_AN3 -to ddr4_mem[2].oct_rzqin
set_location_assignment PIN_AL5 -to ddr4_mem[2].ref_clk

# DDR4 CH0 - DQS0
set_location_assignment PIN_AH5 -to ddr4_mem[2].dqs[0]
set_location_assignment PIN_AG5 -to ddr4_mem[2].dqs_n[0]
set_location_assignment PIN_AG4 -to ddr4_mem[2].dbi_n[0]
set_location_assignment PIN_AF1 -to ddr4_mem[2].dq[0]
set_location_assignment PIN_AH6 -to ddr4_mem[2].dq[1]
set_location_assignment PIN_AH3 -to ddr4_mem[2].dq[2]
set_location_assignment PIN_AG2 -to ddr4_mem[2].dq[3]
set_location_assignment PIN_AF2 -to ddr4_mem[2].dq[4]
set_location_assignment PIN_AH7 -to ddr4_mem[2].dq[5]
set_location_assignment PIN_AH2 -to ddr4_mem[2].dq[6]
set_location_assignment PIN_AG3 -to ddr4_mem[2].dq[7]

# DDR4 CH0 - DQS1
set_location_assignment PIN_AK6 -to ddr4_mem[2].dqs[1]
set_location_assignment PIN_AK7 -to ddr4_mem[2].dqs_n[1]
set_location_assignment PIN_AJ6 -to ddr4_mem[2].dbi_n[1]
set_location_assignment PIN_AK2 -to ddr4_mem[2].dq[8]
set_location_assignment PIN_AJ3 -to ddr4_mem[2].dq[9]
set_location_assignment PIN_AK4 -to ddr4_mem[2].dq[10]
set_location_assignment PIN_AJ4 -to ddr4_mem[2].dq[11]
set_location_assignment PIN_AK1 -to ddr4_mem[2].dq[12]
set_location_assignment PIN_AH1 -to ddr4_mem[2].dq[13]
set_location_assignment PIN_AK3 -to ddr4_mem[2].dq[14]
set_location_assignment PIN_AJ1 -to ddr4_mem[2].dq[15]

# DDR4 CH0 - DQS2
set_location_assignment PIN_AL11 -to ddr4_mem[2].dqs[2]
set_location_assignment PIN_AL10 -to ddr4_mem[2].dqs_n[2]
set_location_assignment PIN_AK12 -to ddr4_mem[2].dbi_n[2]
set_location_assignment PIN_AL12 -to ddr4_mem[2].dq[16]
set_location_assignment PIN_AK11 -to ddr4_mem[2].dq[17]
set_location_assignment PIN_AL9 -to ddr4_mem[2].dq[18]
set_location_assignment PIN_AK8 -to ddr4_mem[2].dq[19]
set_location_assignment PIN_AL14 -to ddr4_mem[2].dq[20]
set_location_assignment PIN_AK14 -to ddr4_mem[2].dq[21]
set_location_assignment PIN_AL7 -to ddr4_mem[2].dq[22]
set_location_assignment PIN_AK9 -to ddr4_mem[2].dq[23]

# DDR4 CH0 - DQS3
set_location_assignment PIN_AH10 -to ddr4_mem[2].dqs[3]
set_location_assignment PIN_AJ11 -to ddr4_mem[2].dqs_n[3]
set_location_assignment PIN_AH11 -to ddr4_mem[2].dbi_n[3]
set_location_assignment PIN_AH13 -to ddr4_mem[2].dq[24]
set_location_assignment PIN_AG7 -to ddr4_mem[2].dq[25]
set_location_assignment PIN_AJ10 -to ddr4_mem[2].dq[26]
set_location_assignment PIN_AJ8 -to ddr4_mem[2].dq[27]
set_location_assignment PIN_AJ13 -to ddr4_mem[2].dq[28]
set_location_assignment PIN_AG8 -to ddr4_mem[2].dq[29]
set_location_assignment PIN_AJ9 -to ddr4_mem[2].dq[30]
set_location_assignment PIN_AH8 -to ddr4_mem[2].dq[31]

# DDR4 CH0 - DQS4
set_location_assignment PIN_AV6 -to ddr4_mem[2].dqs[4]
set_location_assignment PIN_AV5 -to ddr4_mem[2].dqs_n[4]
set_location_assignment PIN_AW1 -to ddr4_mem[2].dbi_n[4]
set_location_assignment PIN_AU4 -to ddr4_mem[2].dq[32]
set_location_assignment PIN_AU5 -to ddr4_mem[2].dq[33]
set_location_assignment PIN_AU3 -to ddr4_mem[2].dq[34]
set_location_assignment PIN_AV2 -to ddr4_mem[2].dq[35]
set_location_assignment PIN_AV7 -to ddr4_mem[2].dq[36]
set_location_assignment PIN_AV8 -to ddr4_mem[2].dq[37]
set_location_assignment PIN_AU2 -to ddr4_mem[2].dq[38]
set_location_assignment PIN_AV3 -to ddr4_mem[2].dq[39]

# DDR4 CH0 - DQS5
set_location_assignment PIN_AV10 -to ddr4_mem[2].dqs[5]
set_location_assignment PIN_AU10 -to ddr4_mem[2].dqs_n[5]
set_location_assignment PIN_AU13 -to ddr4_mem[2].dbi_n[5]
set_location_assignment PIN_AY7 -to ddr4_mem[2].dq[40]
set_location_assignment PIN_AW10 -to ddr4_mem[2].dq[41]
set_location_assignment PIN_AV11 -to ddr4_mem[2].dq[42]
set_location_assignment PIN_AW8 -to ddr4_mem[2].dq[43]
set_location_assignment PIN_AY6 -to ddr4_mem[2].dq[44]
set_location_assignment PIN_AW11 -to ddr4_mem[2].dq[45]
set_location_assignment PIN_AV12 -to ddr4_mem[2].dq[46]
set_location_assignment PIN_AW9 -to ddr4_mem[2].dq[47]

# DDR4 CH0 - DQS6
set_location_assignment PIN_AT11 -to ddr4_mem[2].dqs[6]
set_location_assignment PIN_AR11 -to ddr4_mem[2].dqs_n[6]
set_location_assignment PIN_AR13 -to ddr4_mem[2].dbi_n[6]
set_location_assignment PIN_AU8 -to ddr4_mem[2].dq[48]
set_location_assignment PIN_AT12 -to ddr4_mem[2].dq[49]
set_location_assignment PIN_AT9 -to ddr4_mem[2].dq[50]
set_location_assignment PIN_AT7 -to ddr4_mem[2].dq[51]
set_location_assignment PIN_AU7 -to ddr4_mem[2].dq[52]
set_location_assignment PIN_AT10 -to ddr4_mem[2].dq[53]
set_location_assignment PIN_AU9 -to ddr4_mem[2].dq[54]
set_location_assignment PIN_AR12 -to ddr4_mem[2].dq[55]

# DDR4 CH0 - DQS7
set_location_assignment PIN_BA4 -to ddr4_mem[2].dqs[7]
set_location_assignment PIN_BB4 -to ddr4_mem[2].dqs_n[7]
set_location_assignment PIN_AW5 -to ddr4_mem[2].dbi_n[7]
set_location_assignment PIN_BA2 -to ddr4_mem[2].dq[56]
set_location_assignment PIN_AY4 -to ddr4_mem[2].dq[57]
set_location_assignment PIN_AW3 -to ddr4_mem[2].dq[58]
set_location_assignment PIN_BA5 -to ddr4_mem[2].dq[59]
set_location_assignment PIN_AY2 -to ddr4_mem[2].dq[60]
set_location_assignment PIN_AW4 -to ddr4_mem[2].dq[61]
set_location_assignment PIN_AY3 -to ddr4_mem[2].dq[62]
set_location_assignment PIN_BB5 -to ddr4_mem[2].dq[63]

# DDR4 CH0 - DQS8
set_location_assignment PIN_AN10 -to ddr4_mem[2].dqs[8]
set_location_assignment PIN_AN11 -to ddr4_mem[2].dqs_n[8]
set_location_assignment PIN_AM12 -to ddr4_mem[2].dbi_n[8]
set_location_assignment PIN_AM7 -to ddr4_mem[2].dq[64]
set_location_assignment PIN_AM8 -to ddr4_mem[2].dq[65]
set_location_assignment PIN_AN13 -to ddr4_mem[2].dq[66]
set_location_assignment PIN_AN12 -to ddr4_mem[2].dq[67]
set_location_assignment PIN_AN6 -to ddr4_mem[2].dq[68]
set_location_assignment PIN_AN7 -to ddr4_mem[2].dq[69]
set_location_assignment PIN_AM9 -to ddr4_mem[2].dq[70]
set_location_assignment PIN_AM10 -to ddr4_mem[2].dq[71]

#=========================================================
# DDR4 CH1 (Upper 3)  - A/C 
#=========================================================
set_location_assignment PIN_L6 -to ddr4_mem[3].ck
set_location_assignment PIN_L7 -to ddr4_mem[3].ck_n
set_location_assignment PIN_H1 -to ddr4_mem[3].a[0]
set_location_assignment PIN_J1 -to ddr4_mem[3].a[1]
set_location_assignment PIN_L2 -to ddr4_mem[3].a[2]
set_location_assignment PIN_K2 -to ddr4_mem[3].a[3]
set_location_assignment PIN_F2 -to ddr4_mem[3].a[4]
set_location_assignment PIN_F1 -to ddr4_mem[3].a[5]
set_location_assignment PIN_L1 -to ddr4_mem[3].a[6]
set_location_assignment PIN_K1 -to ddr4_mem[3].a[7]
set_location_assignment PIN_G2 -to ddr4_mem[3].a[8]
set_location_assignment PIN_H2 -to ddr4_mem[3].a[9]
set_location_assignment PIN_K3 -to ddr4_mem[3].a[10]
set_location_assignment PIN_J3 -to ddr4_mem[3].a[11]
set_location_assignment PIN_J4 -to ddr4_mem[3].a[12]
set_location_assignment PIN_K6 -to ddr4_mem[3].a[13]
set_location_assignment PIN_J6 -to ddr4_mem[3].a[14]
set_location_assignment PIN_H3 -to ddr4_mem[3].a[15]
set_location_assignment PIN_G3 -to ddr4_mem[3].a[16]
set_location_assignment PIN_H5 -to ddr4_mem[3].a[17]
set_location_assignment PIN_L5 -to ddr4_mem[3].act_n
set_location_assignment PIN_G4 -to ddr4_mem[3].ba[1]
set_location_assignment PIN_H6 -to ddr4_mem[3].ba[0]
set_location_assignment PIN_M10 -to ddr4_mem[3].bg[1]
set_location_assignment PIN_G5 -to ddr4_mem[3].bg[0]
set_location_assignment PIN_M4 -to ddr4_mem[3].cke
set_location_assignment PIN_M5 -to ddr4_mem[3].cs_n
set_location_assignment PIN_M8 -to ddr4_mem[3].odt
set_location_assignment PIN_M9 -to ddr4_mem[3].reset_n
set_location_assignment PIN_K4 -to ddr4_mem[3].par
set_location_assignment PIN_L4 -to ddr4_mem[3].alert_n
set_location_assignment PIN_J5 -to ddr4_mem[3].oct_rzqin
set_location_assignment PIN_K8 -to ddr4_mem[3].ref_clk

# DDR4 CH1 - DQS0
set_location_assignment PIN_G8 -to ddr4_mem[3].dqs[0]
set_location_assignment PIN_G9 -to ddr4_mem[3].dqs_n[0]
set_location_assignment PIN_J13 -to ddr4_mem[3].dbi_n[0]
set_location_assignment PIN_H10 -to ddr4_mem[3].dq[0]
set_location_assignment PIN_H11 -to ddr4_mem[3].dq[1]
set_location_assignment PIN_G10 -to ddr4_mem[3].dq[2]
set_location_assignment PIN_F9 -to ddr4_mem[3].dq[3]
set_location_assignment PIN_J10 -to ddr4_mem[3].dq[4]
set_location_assignment PIN_J11 -to ddr4_mem[3].dq[5]
set_location_assignment PIN_H12 -to ddr4_mem[3].dq[6]
set_location_assignment PIN_F10 -to ddr4_mem[3].dq[7]

# DDR4 CH1 - DQS1
set_location_assignment PIN_C7 -to ddr4_mem[3].dqs[1]
set_location_assignment PIN_B7 -to ddr4_mem[3].dqs_n[1]
set_location_assignment PIN_E9 -to ddr4_mem[3].dbi_n[1]
set_location_assignment PIN_B5 -to ddr4_mem[3].dq[8]
set_location_assignment PIN_A5 -to ddr4_mem[3].dq[9]
set_location_assignment PIN_A6 -to ddr4_mem[3].dq[10]
set_location_assignment PIN_E7 -to ddr4_mem[3].dq[11]
set_location_assignment PIN_E6 -to ddr4_mem[3].dq[12]
set_location_assignment PIN_D6 -to ddr4_mem[3].dq[13]
set_location_assignment PIN_C6 -to ddr4_mem[3].dq[14]
set_location_assignment PIN_A7 -to ddr4_mem[3].dq[15]

# DDR4 CH1 - DQS2
set_location_assignment PIN_F4 -to ddr4_mem[3].dqs[2]
set_location_assignment PIN_E4 -to ddr4_mem[3].dqs_n[2]
set_location_assignment PIN_E3 -to ddr4_mem[3].dbi_n[2]
set_location_assignment PIN_J8 -to ddr4_mem[3].dq[16]
set_location_assignment PIN_G7 -to ddr4_mem[3].dq[17]
set_location_assignment PIN_J9 -to ddr4_mem[3].dq[18]
set_location_assignment PIN_F6 -to ddr4_mem[3].dq[19]
set_location_assignment PIN_F5 -to ddr4_mem[3].dq[20]
set_location_assignment PIN_H7 -to ddr4_mem[3].dq[21]
set_location_assignment PIN_H8 -to ddr4_mem[3].dq[22]
set_location_assignment PIN_F7 -to ddr4_mem[3].dq[23]

# DDR4 CH1 - DQS3
set_location_assignment PIN_C5 -to ddr4_mem[3].dqs[3]
set_location_assignment PIN_D5 -to ddr4_mem[3].dqs_n[3]
set_location_assignment PIN_A4 -to ddr4_mem[3].dbi_n[3]
set_location_assignment PIN_C2 -to ddr4_mem[3].dq[24]
set_location_assignment PIN_D3 -to ddr4_mem[3].dq[25]
set_location_assignment PIN_B2 -to ddr4_mem[3].dq[26]
set_location_assignment PIN_B3 -to ddr4_mem[3].dq[27]
set_location_assignment PIN_E1 -to ddr4_mem[3].dq[28]
set_location_assignment PIN_D1 -to ddr4_mem[3].dq[29]
set_location_assignment PIN_C3 -to ddr4_mem[3].dq[30]
set_location_assignment PIN_D4 -to ddr4_mem[3].dq[31]

# DDR4 CH1 - DQS4
set_location_assignment PIN_P1 -to ddr4_mem[3].dqs[4]
set_location_assignment PIN_N1 -to ddr4_mem[3].dqs_n[4]
set_location_assignment PIN_N2 -to ddr4_mem[3].dbi_n[4]
set_location_assignment PIN_R4 -to ddr4_mem[3].dq[32]
set_location_assignment PIN_R1 -to ddr4_mem[3].dq[33]
set_location_assignment PIN_T2 -to ddr4_mem[3].dq[34]
set_location_assignment PIN_R3 -to ddr4_mem[3].dq[35]
set_location_assignment PIN_N3 -to ddr4_mem[3].dq[36]
set_location_assignment PIN_P3 -to ddr4_mem[3].dq[37]
set_location_assignment PIN_T1 -to ddr4_mem[3].dq[38]
set_location_assignment PIN_R2 -to ddr4_mem[3].dq[39]

# DDR4 CH1 - DQS5
set_location_assignment PIN_P9 -to ddr4_mem[3].dqs[5]
set_location_assignment PIN_P8 -to ddr4_mem[3].dqs_n[5]
set_location_assignment PIN_R6 -to ddr4_mem[3].dbi_n[5]
set_location_assignment PIN_N5 -to ddr4_mem[3].dq[40]
set_location_assignment PIN_P4 -to ddr4_mem[3].dq[41]
set_location_assignment PIN_N8 -to ddr4_mem[3].dq[42]
set_location_assignment PIN_P10 -to ddr4_mem[3].dq[43]
set_location_assignment PIN_N6 -to ddr4_mem[3].dq[44]
set_location_assignment PIN_P5 -to ddr4_mem[3].dq[45]
set_location_assignment PIN_N7 -to ddr4_mem[3].dq[46]
set_location_assignment PIN_N10 -to ddr4_mem[3].dq[47]

# DDR4 CH1 - DQS6
set_location_assignment PIN_T6 -to ddr4_mem[3].dqs[6]
set_location_assignment PIN_T7 -to ddr4_mem[3].dqs_n[6]
set_location_assignment PIN_R7 -to ddr4_mem[3].dbi_n[6]
set_location_assignment PIN_U4 -to ddr4_mem[3].dq[48]
set_location_assignment PIN_T4 -to ddr4_mem[3].dq[49]
set_location_assignment PIN_U5 -to ddr4_mem[3].dq[50]
set_location_assignment PIN_T9 -to ddr4_mem[3].dq[51]
set_location_assignment PIN_U2 -to ddr4_mem[3].dq[52]
set_location_assignment PIN_R9 -to ddr4_mem[3].dq[53]
set_location_assignment PIN_T5 -to ddr4_mem[3].dq[54]
set_location_assignment PIN_U3 -to ddr4_mem[3].dq[55]

# DDR4 CH1 - DQS7
set_location_assignment PIN_P13 -to ddr4_mem[3].dqs[7]
set_location_assignment PIN_N13 -to ddr4_mem[3].dqs_n[7]
set_location_assignment PIN_R11 -to ddr4_mem[3].dbi_n[7]
set_location_assignment PIN_R13 -to ddr4_mem[3].dq[56]
set_location_assignment PIN_N11 -to ddr4_mem[3].dq[57]
set_location_assignment PIN_R14 -to ddr4_mem[3].dq[58]
set_location_assignment PIN_T11 -to ddr4_mem[3].dq[59]
set_location_assignment PIN_T12 -to ddr4_mem[3].dq[60]
set_location_assignment PIN_N12 -to ddr4_mem[3].dq[61]
set_location_assignment PIN_T10 -to ddr4_mem[3].dq[62]
set_location_assignment PIN_R12 -to ddr4_mem[3].dq[63]

# DDR4 CH1 - DQS8
set_location_assignment PIN_M12 -to ddr4_mem[3].dqs[8]
set_location_assignment PIN_L12 -to ddr4_mem[3].dqs_n[8]
set_location_assignment PIN_K11 -to ddr4_mem[3].dbi_n[8]
set_location_assignment PIN_K14 -to ddr4_mem[3].dq[64]
set_location_assignment PIN_K13 -to ddr4_mem[3].dq[65]
set_location_assignment PIN_L9 -to ddr4_mem[3].dq[66]
set_location_assignment PIN_L11 -to ddr4_mem[3].dq[67]
set_location_assignment PIN_M13 -to ddr4_mem[3].dq[68]
set_location_assignment PIN_M14 -to ddr4_mem[3].dq[69]
set_location_assignment PIN_L10 -to ddr4_mem[3].dq[70]
set_location_assignment PIN_K9 -to ddr4_mem[3].dq[71]

#=========================================================
# DDR4 CH2 (Lower 2) - A/C 
#=========================================================
set_location_assignment PIN_AU22 -to ddr4_mem[0].ck
set_location_assignment PIN_AV22 -to ddr4_mem[0].ck_n
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
set_location_assignment PIN_AR22 -to ddr4_mem[0].act_n
set_location_assignment PIN_AW20 -to ddr4_mem[0].ba[1]
set_location_assignment PIN_BA20 -to ddr4_mem[0].ba[0]
set_location_assignment PIN_BA22 -to ddr4_mem[0].bg[1]
set_location_assignment PIN_AV20 -to ddr4_mem[0].bg[0]
set_location_assignment PIN_AV23 -to ddr4_mem[0].cke
set_location_assignment PIN_AT22 -to ddr4_mem[0].cs_n
set_location_assignment PIN_BB23 -to ddr4_mem[0].odt
set_location_assignment PIN_AY22 -to ddr4_mem[0].reset_n
set_location_assignment PIN_AW23 -to ddr4_mem[0].par
set_location_assignment PIN_AY23 -to ddr4_mem[0].alert_n
set_location_assignment PIN_BA21 -to ddr4_mem[0].oct_rzqin
set_location_assignment PIN_AY19 -to ddr4_mem[0].ref_clk

# DDR4 CH2  - DQS0
set_location_assignment PIN_AH18 -to ddr4_mem[0].dqs[0]
set_location_assignment PIN_AJ18 -to ddr4_mem[0].dqs_n[0]
set_location_assignment PIN_AJ19 -to ddr4_mem[0].dbi_n[0]
set_location_assignment PIN_AL17 -to ddr4_mem[0].dq[0]
set_location_assignment PIN_AL19 -to ddr4_mem[0].dq[1]
set_location_assignment PIN_AM17 -to ddr4_mem[0].dq[2]
set_location_assignment PIN_AK17 -to ddr4_mem[0].dq[3]
set_location_assignment PIN_AK19 -to ddr4_mem[0].dq[4]
set_location_assignment PIN_AM20 -to ddr4_mem[0].dq[5]
set_location_assignment PIN_AN17 -to ddr4_mem[0].dq[6]
set_location_assignment PIN_AM19 -to ddr4_mem[0].dq[7]

# DDR4 CH2  - DQS1
set_location_assignment PIN_AK22 -to ddr4_mem[0].dqs[1]
set_location_assignment PIN_AK21 -to ddr4_mem[0].dqs_n[1]
set_location_assignment PIN_AJ24 -to ddr4_mem[0].dbi_n[1]
set_location_assignment PIN_AL22 -to ddr4_mem[0].dq[8]
set_location_assignment PIN_AJ23 -to ddr4_mem[0].dq[9]
set_location_assignment PIN_AJ26 -to ddr4_mem[0].dq[10]
set_location_assignment PIN_AK23 -to ddr4_mem[0].dq[11]
set_location_assignment PIN_AL20 -to ddr4_mem[0].dq[12]
set_location_assignment PIN_AH24 -to ddr4_mem[0].dq[13]
set_location_assignment PIN_AJ25 -to ddr4_mem[0].dq[14]
set_location_assignment PIN_AL21 -to ddr4_mem[0].dq[15]

# DDR4 CH2  - DQS2
set_location_assignment PIN_AM18 -to ddr4_mem[0].dqs[2]
set_location_assignment PIN_AN18 -to ddr4_mem[0].dqs_n[2]
set_location_assignment PIN_AR18 -to ddr4_mem[0].dbi_n[2]
set_location_assignment PIN_AT17 -to ddr4_mem[0].dq[16]
set_location_assignment PIN_AR16 -to ddr4_mem[0].dq[17]
set_location_assignment PIN_AT16 -to ddr4_mem[0].dq[18]
set_location_assignment PIN_AP18 -to ddr4_mem[0].dq[19]
set_location_assignment PIN_AU17 -to ddr4_mem[0].dq[20]
set_location_assignment PIN_AP19 -to ddr4_mem[0].dq[21]
set_location_assignment PIN_AT19 -to ddr4_mem[0].dq[22]
set_location_assignment PIN_AR19 -to ddr4_mem[0].dq[23]

# DDR4 CH2  - DQS3
set_location_assignment PIN_BB18 -to ddr4_mem[0].dqs[3]
set_location_assignment PIN_BB17 -to ddr4_mem[0].dqs_n[3]
set_location_assignment PIN_AV16 -to ddr4_mem[0].dbi_n[3]
set_location_assignment PIN_AY17 -to ddr4_mem[0].dq[24]
set_location_assignment PIN_AY16 -to ddr4_mem[0].dq[25]
set_location_assignment PIN_AU18 -to ddr4_mem[0].dq[26]
set_location_assignment PIN_AY18 -to ddr4_mem[0].dq[27]
set_location_assignment PIN_AV18 -to ddr4_mem[0].dq[28]
set_location_assignment PIN_AW16 -to ddr4_mem[0].dq[29]
set_location_assignment PIN_AW18 -to ddr4_mem[0].dq[30]
set_location_assignment PIN_BA17 -to ddr4_mem[0].dq[31]

# DDR4 CH2  - DQS4
set_location_assignment PIN_BB25 -to ddr4_mem[0].dqs[4]
set_location_assignment PIN_BA25 -to ddr4_mem[0].dqs_n[4]
set_location_assignment PIN_BA27 -to ddr4_mem[0].dbi_n[4]
set_location_assignment PIN_BB24 -to ddr4_mem[0].dq[32]
set_location_assignment PIN_BA26 -to ddr4_mem[0].dq[33]
set_location_assignment PIN_AV27 -to ddr4_mem[0].dq[34]
set_location_assignment PIN_AY27 -to ddr4_mem[0].dq[35]
set_location_assignment PIN_BA24 -to ddr4_mem[0].dq[36]
set_location_assignment PIN_AY26 -to ddr4_mem[0].dq[37]
set_location_assignment PIN_AV26 -to ddr4_mem[0].dq[38]
set_location_assignment PIN_AW26 -to ddr4_mem[0].dq[39]

# DDR4 CH2  - DQS5
set_location_assignment PIN_AT27 -to ddr4_mem[0].dqs[5]
set_location_assignment PIN_AU27 -to ddr4_mem[0].dqs_n[5]
set_location_assignment PIN_AV25 -to ddr4_mem[0].dbi_n[5]
set_location_assignment PIN_AW24 -to ddr4_mem[0].dq[40]
set_location_assignment PIN_AT26 -to ddr4_mem[0].dq[41]
set_location_assignment PIN_AT24 -to ddr4_mem[0].dq[42]
set_location_assignment PIN_AU24 -to ddr4_mem[0].dq[43]
set_location_assignment PIN_AY24 -to ddr4_mem[0].dq[44]
set_location_assignment PIN_AU25 -to ddr4_mem[0].dq[45]
set_location_assignment PIN_AT25 -to ddr4_mem[0].dq[46]
set_location_assignment PIN_AR27 -to ddr4_mem[0].dq[47]

# DDR4 CH2  - DQS6
set_location_assignment PIN_AP29 -to ddr4_mem[0].dqs[6]
set_location_assignment PIN_AR30 -to ddr4_mem[0].dqs_n[6]
set_location_assignment PIN_AL30 -to ddr4_mem[0].dbi_n[6]
set_location_assignment PIN_AT29 -to ddr4_mem[0].dq[48]
set_location_assignment PIN_AR29 -to ddr4_mem[0].dq[49]
set_location_assignment PIN_AP30 -to ddr4_mem[0].dq[50]
set_location_assignment PIN_AN30 -to ddr4_mem[0].dq[51]
set_location_assignment PIN_AP28 -to ddr4_mem[0].dq[52]
set_location_assignment PIN_AR28 -to ddr4_mem[0].dq[53]
set_location_assignment PIN_AT30 -to ddr4_mem[0].dq[54]
set_location_assignment PIN_AT31 -to ddr4_mem[0].dq[55]

# DDR4 CH2  - DQS7
set_location_assignment PIN_AK28 -to ddr4_mem[0].dqs[7]
set_location_assignment PIN_AK27 -to ddr4_mem[0].dqs_n[7]
set_location_assignment PIN_AK29 -to ddr4_mem[0].dbi_n[7]
set_location_assignment PIN_AM28 -to ddr4_mem[0].dq[56]
set_location_assignment PIN_AL29 -to ddr4_mem[0].dq[57]
set_location_assignment PIN_AN28 -to ddr4_mem[0].dq[58]
set_location_assignment PIN_AP26 -to ddr4_mem[0].dq[59]
set_location_assignment PIN_AL27 -to ddr4_mem[0].dq[60]
set_location_assignment PIN_AM29 -to ddr4_mem[0].dq[61]
set_location_assignment PIN_AN27 -to ddr4_mem[0].dq[62]
set_location_assignment PIN_AM27 -to ddr4_mem[0].dq[63]

# DDR4 CH2  - DQS8
set_location_assignment PIN_AU19 -to ddr4_mem[0].dqs[8]
set_location_assignment PIN_AU20 -to ddr4_mem[0].dqs_n[8]
set_location_assignment PIN_AT21 -to ddr4_mem[0].dbi_n[8]
set_location_assignment PIN_AN22 -to ddr4_mem[0].dq[64]
set_location_assignment PIN_AN20 -to ddr4_mem[0].dq[65]
set_location_assignment PIN_AM22 -to ddr4_mem[0].dq[66]
set_location_assignment PIN_AR21 -to ddr4_mem[0].dq[67]
set_location_assignment PIN_AM23 -to ddr4_mem[0].dq[68]
set_location_assignment PIN_AP20 -to ddr4_mem[0].dq[69]
set_location_assignment PIN_AN21 -to ddr4_mem[0].dq[70]
set_location_assignment PIN_AP21 -to ddr4_mem[0].dq[71]

#=========================================================
# DDR4 CH3 (Upper 2) - A/C 
#=========================================================
set_location_assignment PIN_K31 -to ddr4_mem[1].ck
set_location_assignment PIN_L30 -to ddr4_mem[1].ck_n
set_location_assignment PIN_M28 -to ddr4_mem[1].a[0]
set_location_assignment PIN_N28 -to ddr4_mem[1].a[1]
set_location_assignment PIN_R26 -to ddr4_mem[1].a[2]
set_location_assignment PIN_P26 -to ddr4_mem[1].a[3]
set_location_assignment PIN_P28 -to ddr4_mem[1].a[4]
set_location_assignment PIN_R27 -to ddr4_mem[1].a[5]
set_location_assignment PIN_K26 -to ddr4_mem[1].a[6]
set_location_assignment PIN_K27 -to ddr4_mem[1].a[7]
set_location_assignment PIN_N26 -to ddr4_mem[1].a[8]
set_location_assignment PIN_N27 -to ddr4_mem[1].a[9]
set_location_assignment PIN_L27 -to ddr4_mem[1].a[10]
set_location_assignment PIN_M27 -to ddr4_mem[1].a[11]
set_location_assignment PIN_J29 -to ddr4_mem[1].a[12]
set_location_assignment PIN_J28 -to ddr4_mem[1].a[13]
set_location_assignment PIN_K28 -to ddr4_mem[1].a[14]
set_location_assignment PIN_H31 -to ddr4_mem[1].a[15]
set_location_assignment PIN_H30 -to ddr4_mem[1].a[16]
set_location_assignment PIN_H28 -to ddr4_mem[1].a[17]
set_location_assignment PIN_L29 -to ddr4_mem[1].act_n
set_location_assignment PIN_G27 -to ddr4_mem[1].ba[1]
set_location_assignment PIN_H27 -to ddr4_mem[1].ba[0]
set_location_assignment PIN_N30 -to ddr4_mem[1].bg[1]
set_location_assignment PIN_F27 -to ddr4_mem[1].bg[0]
set_location_assignment PIN_M30 -to ddr4_mem[1].cke
set_location_assignment PIN_M29 -to ddr4_mem[1].cs_n
set_location_assignment PIN_K30 -to ddr4_mem[1].odt
set_location_assignment PIN_P31 -to ddr4_mem[1].reset_n
set_location_assignment PIN_P29 -to ddr4_mem[1].par
set_location_assignment PIN_P30 -to ddr4_mem[1].alert_n
set_location_assignment PIN_J30 -to ddr4_mem[1].oct_rzqin
set_location_assignment PIN_D27 -to ddr4_mem[1].ref_clk

# DDR4 CH3 - DQS0
set_location_assignment PIN_T23 -to ddr4_mem[1].dqs[0]
set_location_assignment PIN_R24 -to ddr4_mem[1].dqs_n[0]
set_location_assignment PIN_K23 -to ddr4_mem[1].dbi_n[0]
set_location_assignment PIN_N23 -to ddr4_mem[1].dq[0]
set_location_assignment PIN_P23 -to ddr4_mem[1].dq[1]
set_location_assignment PIN_M22 -to ddr4_mem[1].dq[2]
set_location_assignment PIN_M23 -to ddr4_mem[1].dq[3]
set_location_assignment PIN_P24 -to ddr4_mem[1].dq[4]
set_location_assignment PIN_N22 -to ddr4_mem[1].dq[5]
set_location_assignment PIN_L22 -to ddr4_mem[1].dq[6]
set_location_assignment PIN_M24 -to ddr4_mem[1].dq[7]

# DDR4 CH3 - DQS1
set_location_assignment PIN_N25 -to ddr4_mem[1].dqs[1]
set_location_assignment PIN_P25 -to ddr4_mem[1].dqs_n[1]
set_location_assignment PIN_L25 -to ddr4_mem[1].dbi_n[1]
set_location_assignment PIN_G25 -to ddr4_mem[1].dq[8]
set_location_assignment PIN_H26 -to ddr4_mem[1].dq[9]
set_location_assignment PIN_J24 -to ddr4_mem[1].dq[10]
set_location_assignment PIN_J25 -to ddr4_mem[1].dq[11]
set_location_assignment PIN_G24 -to ddr4_mem[1].dq[12]
set_location_assignment PIN_H25 -to ddr4_mem[1].dq[13]
set_location_assignment PIN_L24 -to ddr4_mem[1].dq[14]
set_location_assignment PIN_K24 -to ddr4_mem[1].dq[15]

# DDR4 CH3 - DQS2
set_location_assignment PIN_B24 -to ddr4_mem[1].dqs[2]
set_location_assignment PIN_B25 -to ddr4_mem[1].dqs_n[2]
set_location_assignment PIN_C27 -to ddr4_mem[1].dbi_n[2]
set_location_assignment PIN_E26 -to ddr4_mem[1].dq[16]
set_location_assignment PIN_D26 -to ddr4_mem[1].dq[17]
set_location_assignment PIN_D25 -to ddr4_mem[1].dq[18]
set_location_assignment PIN_C25 -to ddr4_mem[1].dq[19]
set_location_assignment PIN_F26 -to ddr4_mem[1].dq[20]
set_location_assignment PIN_F25 -to ddr4_mem[1].dq[21]
set_location_assignment PIN_A24 -to ddr4_mem[1].dq[22]
set_location_assignment PIN_A25 -to ddr4_mem[1].dq[23]

# DDR4 CH3 - DQS3
set_location_assignment PIN_C23 -to ddr4_mem[1].dqs[3]
set_location_assignment PIN_C22 -to ddr4_mem[1].dqs_n[3]
set_location_assignment PIN_D24 -to ddr4_mem[1].dbi_n[3]
set_location_assignment PIN_B23 -to ddr4_mem[1].dq[24]
set_location_assignment PIN_G23 -to ddr4_mem[1].dq[25]
set_location_assignment PIN_E23 -to ddr4_mem[1].dq[26]
set_location_assignment PIN_B22 -to ddr4_mem[1].dq[27]
set_location_assignment PIN_D23 -to ddr4_mem[1].dq[28]
set_location_assignment PIN_F24 -to ddr4_mem[1].dq[29]
set_location_assignment PIN_A21 -to ddr4_mem[1].dq[30]
set_location_assignment PIN_A22 -to ddr4_mem[1].dq[31]

# DDR4 CH3 - DQS4
set_location_assignment PIN_D8 -to ddr4_mem[1].dqs[4]
set_location_assignment PIN_C8 -to ddr4_mem[1].dqs_n[4]
set_location_assignment PIN_C10 -to ddr4_mem[1].dbi_n[4]
set_location_assignment PIN_D11 -to ddr4_mem[1].dq[32]
set_location_assignment PIN_D9 -to ddr4_mem[1].dq[33]
set_location_assignment PIN_F12 -to ddr4_mem[1].dq[34]
set_location_assignment PIN_G12 -to ddr4_mem[1].dq[35]
set_location_assignment PIN_E12 -to ddr4_mem[1].dq[36]
set_location_assignment PIN_D10 -to ddr4_mem[1].dq[37]
set_location_assignment PIN_E11 -to ddr4_mem[1].dq[38]
set_location_assignment PIN_F11 -to ddr4_mem[1].dq[39]

# DDR4 CH3 - DQS5
set_location_assignment PIN_N17 -to ddr4_mem[1].dqs[5]
set_location_assignment PIN_M17 -to ddr4_mem[1].dqs_n[5]
set_location_assignment PIN_M18 -to ddr4_mem[1].dbi_n[5]
set_location_assignment PIN_H16 -to ddr4_mem[1].dq[40]
set_location_assignment PIN_L17 -to ddr4_mem[1].dq[41]
set_location_assignment PIN_F17 -to ddr4_mem[1].dq[42]
set_location_assignment PIN_F16 -to ddr4_mem[1].dq[43]
set_location_assignment PIN_H17 -to ddr4_mem[1].dq[44]
set_location_assignment PIN_K17 -to ddr4_mem[1].dq[45]
set_location_assignment PIN_E16 -to ddr4_mem[1].dq[46]
set_location_assignment PIN_G17 -to ddr4_mem[1].dq[47]

# DDR4 CH3 - DQS6
set_location_assignment PIN_R17 -to ddr4_mem[1].dqs[6]
set_location_assignment PIN_P18 -to ddr4_mem[1].dqs_n[6]
set_location_assignment PIN_M15 -to ddr4_mem[1].dbi_n[6]
set_location_assignment PIN_K16 -to ddr4_mem[1].dq[48]
set_location_assignment PIN_L15 -to ddr4_mem[1].dq[49]
set_location_assignment PIN_P16 -to ddr4_mem[1].dq[50]
set_location_assignment PIN_N16 -to ddr4_mem[1].dq[51]
set_location_assignment PIN_J16 -to ddr4_mem[1].dq[52]
set_location_assignment PIN_L16 -to ddr4_mem[1].dq[53]
set_location_assignment PIN_P15 -to ddr4_mem[1].dq[54]
set_location_assignment PIN_R16 -to ddr4_mem[1].dq[55]

# DDR4 CH3 - DQS7
set_location_assignment PIN_E14 -to ddr4_mem[1].dqs[7]
set_location_assignment PIN_F14 -to ddr4_mem[1].dqs_n[7]
set_location_assignment PIN_D15 -to ddr4_mem[1].dbi_n[7]
set_location_assignment PIN_H15 -to ddr4_mem[1].dq[56]
set_location_assignment PIN_F15 -to ddr4_mem[1].dq[57]
set_location_assignment PIN_G13 -to ddr4_mem[1].dq[58]
set_location_assignment PIN_G14 -to ddr4_mem[1].dq[59]
set_location_assignment PIN_J15 -to ddr4_mem[1].dq[60]
set_location_assignment PIN_G15 -to ddr4_mem[1].dq[61]
set_location_assignment PIN_E13 -to ddr4_mem[1].dq[62]
set_location_assignment PIN_D13 -to ddr4_mem[1].dq[63]

# DDR4 CH3 - DQS8
set_location_assignment PIN_J23 -to ddr4_mem[1].dqs[8]
set_location_assignment PIN_H23 -to ddr4_mem[1].dqs_n[8]
set_location_assignment PIN_E21 -to ddr4_mem[1].dbi_n[8]
set_location_assignment PIN_C21 -to ddr4_mem[1].dq[64]
set_location_assignment PIN_D21 -to ddr4_mem[1].dq[65]
set_location_assignment PIN_J21 -to ddr4_mem[1].dq[66]
set_location_assignment PIN_H21 -to ddr4_mem[1].dq[67]
set_location_assignment PIN_F22 -to ddr4_mem[1].dq[68]
set_location_assignment PIN_E22 -to ddr4_mem[1].dq[69]
set_location_assignment PIN_H22 -to ddr4_mem[1].dq[70]
set_location_assignment PIN_G22 -to ddr4_mem[1].dq[71]
