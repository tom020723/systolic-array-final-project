## ========================================
## 7-Segment Display Segments
## ========================================
# Verilog 코드(num_decoder)가 MSB(비트 7)부터 A를 켜는 방식이므로
# 핀 매핑 순서를 역순으로 변경했습니다. (seg_data[7] -> U17)

# Segment A (U17) - 코드의 seg_data[7]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {seg_data[7]}]
# Segment B (V17) - 코드의 seg_data[6]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {seg_data[6]}]
# Segment C (W17) - 코드의 seg_data[5]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {seg_data[5]}]
# Segment D (R18) - 코드의 seg_data[4]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {seg_data[4]}]
# Segment E (T18) - 코드의 seg_data[3]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {seg_data[3]}]
# Segment F (U18) - 코드의 seg_data[2]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {seg_data[2]}]
# Segment G (V18) - 코드의 seg_data[1]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {seg_data[1]}]
# Segment DP (P19) - 코드의 seg_data[0]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {seg_data[0]}]


## ========================================
## 7-Segment Digit Select
## ========================================
# Digit 1 ~ 8 (데이터시트 P14 ~ R17 순서)
# 만약 숫자가 왼쪽/오른쪽 반대로 나오면 이 핀 번호 순서를 반대로 뒤집으세요.

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {digit[0]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {digit[1]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {digit[2]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {digit[3]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {digit[4]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {digit[5]}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {digit[6]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {digit[7]}]


## ========================================
## Clock and Control Signals
## ========================================

# 100MHz system clock (SYS_CLK_100M -> R4)
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Reset button (SYS_RSTB -> U7) - Active Low
# 주의: Verilog Top 모듈의 포트 이름이 'rst'인지 'rst_n'인지 확인하고 맞추세요.
# 아래는 'rst'로 가정했습니다. 만약 Top 모듈에 'rst_n'으로 썼다면 이름을 바꾸세요.
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports rst_n]

# Start button (PB1 -> M20)
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports start]