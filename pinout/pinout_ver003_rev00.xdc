## Version 1; compatible with Ver 3 REV 00; FPGA_PN XC7S15-2FTGB196I

## Clock
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {clk}]; #D1 100MHz System Clock
create_clock -period 10.000 -waveform {0.000 5.000} [get_ports {clk}];


### Costum PMOD Header 'E'
#set_property -dict { PACKAGE_PIN B14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[0] }]; #E1
#set_property -dict { PACKAGE_PIN B13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[1] }]; #E2
#set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[2] }]; #E3
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[3] }]; #E4
#set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[4] }]; #E5
#set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[5] }]; #E6
#set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[6] }]; #E7
#set_property -dict { PACKAGE_PIN C10 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[7] }]; #E8
#set_property -dict { PACKAGE_PIN A12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[8] }]; #E9
#set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[9] }]; #E10
#
### Costum PMOD Header 'G' 
#set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[10] }]; #G1
#set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[11] }]; #G2
#set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[12] }]; #G3
#set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[13] }]; #G4
#set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[14] }]; #G5
#set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[15] }]; #G6
#set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[16] }]; #G7
#set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[17] }]; #G8
#set_property -dict { PACKAGE_PIN F11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[18] }]; #G9
#set_property -dict { PACKAGE_PIN F12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[19] }]; #G10
#
### Costum PMOD Header 'H' 
#set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[20] }]; #H1
#set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[21] }]; #H2
#set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[22] }]; #H3
#set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[23] }]; #H4
#set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[24] }]; #H5
#set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[25] }]; #H6
#set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[26] }]; #H7
#set_property -dict { PACKAGE_PIN K11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[27] }]; #H8
#set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[28] }]; #H9
#set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[29] }]; #H10
#
### Costum PMOD Header 'N' 
#set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[30] }]; #N1
#set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[31] }]; #N2
#set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[32] }]; #N3
#set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[33] }]; #N4
#set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[34] }]; #N5
#set_property -dict { PACKAGE_PIN N10 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[35] }]; #N6
#set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { SW1 }]; #N7 Sch=SW1 shared with SW1 Button
#set_property -dict { PACKAGE_PIN M11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[36] }]; #N8 
#set_property -dict { PACKAGE_PIN M10 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { L2 }]; #N9 Sch=L2 shared with L2 LED
#set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { L1 }]; #N10 Sch=L1 shared with L1 LED
#
#
### Pmod Header 'A' 
#set_property -dict { PACKAGE_PIN H1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[37] }]; #A1_N
#set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[38] }]; #A1_P
#set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[39] }]; #A2_N
#set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[40] }]; #A2_P
#set_property -dict { PACKAGE_PIN F4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[41] }]; #A3_N
#set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[42] }]; #A3_P
#set_property -dict { PACKAGE_PIN D2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[43] }]; #A4
#set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[44] }]; #A5
#
### Pmod Header 'B' 
#set_property -dict { PACKAGE_PIN M3 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[45] }]; #B1_P
#set_property -dict { PACKAGE_PIN M2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[46] }]; #B1_N
#set_property -dict { PACKAGE_PIN P2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[47] }]; #B2_P
#set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[48] }]; #B2_N
#set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[49] }]; #B3_N
#set_property -dict { PACKAGE_PIN M1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[50] }]; #B3_P
#set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[51] }]; #B4_P
#set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[52] }]; #B4_N
#
### J Header 
#set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[53] }]; #JA
#set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[54] }]; #JB
#
### Arduino Spare Header or 5V signals level translator
#set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[55] }]; #SPARE1/SPARE1_5V, Arduino PIN=D6
#set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[56] }]; #SPARE2/SPARE2_5V, Arduino PIN=D5
#set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[57] }]; #SPARE3/SPARE3_5V, Arduino PIN=D4
#set_property -dict { PACKAGE_PIN B3 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[58] }]; #SPARE4/SPARE4_5V, Arduino PIN=D3
#set_property -dict { PACKAGE_PIN A2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[59] }]; #SPARE5/SPARE5_5V, Arduino PIN=D2
#set_property -dict { PACKAGE_PIN B2 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[60] }]; #UART_RX/UART_RX_5V, Arduino PIN=D1
#set_property -dict { PACKAGE_PIN B1 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[61] }]; #UART_RX/UART_TX_5V, Arduino PIN=D0
#
### Test-Point Bottom
#set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[62] }]; #TPS1
#set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[63] }]; #TPS2
#set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[64] }]; #TPS3
#set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVCMOS33 PULLUP true DRIVE 4 } [get_ports { pins[65] }]; #TPS4
