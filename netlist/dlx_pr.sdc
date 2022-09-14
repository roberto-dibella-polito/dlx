###################################################################

# Created by write_sdc on Wed Sep 14 02:34:10 2022

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 5  -waveform {0 2.5}
set_max_delay 5  -from [list [get_ports CLK] [get_ports RST] [get_ports IRAM_READY] [get_ports \
{IRAM_DATA[31]}] [get_ports {IRAM_DATA[30]}] [get_ports {IRAM_DATA[29]}]       \
[get_ports {IRAM_DATA[28]}] [get_ports {IRAM_DATA[27]}] [get_ports             \
{IRAM_DATA[26]}] [get_ports {IRAM_DATA[25]}] [get_ports {IRAM_DATA[24]}]       \
[get_ports {IRAM_DATA[23]}] [get_ports {IRAM_DATA[22]}] [get_ports             \
{IRAM_DATA[21]}] [get_ports {IRAM_DATA[20]}] [get_ports {IRAM_DATA[19]}]       \
[get_ports {IRAM_DATA[18]}] [get_ports {IRAM_DATA[17]}] [get_ports             \
{IRAM_DATA[16]}] [get_ports {IRAM_DATA[15]}] [get_ports {IRAM_DATA[14]}]       \
[get_ports {IRAM_DATA[13]}] [get_ports {IRAM_DATA[12]}] [get_ports             \
{IRAM_DATA[11]}] [get_ports {IRAM_DATA[10]}] [get_ports {IRAM_DATA[9]}]        \
[get_ports {IRAM_DATA[8]}] [get_ports {IRAM_DATA[7]}] [get_ports               \
{IRAM_DATA[6]}] [get_ports {IRAM_DATA[5]}] [get_ports {IRAM_DATA[4]}]          \
[get_ports {IRAM_DATA[3]}] [get_ports {IRAM_DATA[2]}] [get_ports               \
{IRAM_DATA[1]}] [get_ports {IRAM_DATA[0]}] [get_ports DRAM_READY] [get_ports   \
{DRAM_DATA[31]}] [get_ports {DRAM_DATA[30]}] [get_ports {DRAM_DATA[29]}]       \
[get_ports {DRAM_DATA[28]}] [get_ports {DRAM_DATA[27]}] [get_ports             \
{DRAM_DATA[26]}] [get_ports {DRAM_DATA[25]}] [get_ports {DRAM_DATA[24]}]       \
[get_ports {DRAM_DATA[23]}] [get_ports {DRAM_DATA[22]}] [get_ports             \
{DRAM_DATA[21]}] [get_ports {DRAM_DATA[20]}] [get_ports {DRAM_DATA[19]}]       \
[get_ports {DRAM_DATA[18]}] [get_ports {DRAM_DATA[17]}] [get_ports             \
{DRAM_DATA[16]}] [get_ports {DRAM_DATA[15]}] [get_ports {DRAM_DATA[14]}]       \
[get_ports {DRAM_DATA[13]}] [get_ports {DRAM_DATA[12]}] [get_ports             \
{DRAM_DATA[11]}] [get_ports {DRAM_DATA[10]}] [get_ports {DRAM_DATA[9]}]        \
[get_ports {DRAM_DATA[8]}] [get_ports {DRAM_DATA[7]}] [get_ports               \
{DRAM_DATA[6]}] [get_ports {DRAM_DATA[5]}] [get_ports {DRAM_DATA[4]}]          \
[get_ports {DRAM_DATA[3]}] [get_ports {DRAM_DATA[2]}] [get_ports               \
{DRAM_DATA[1]}] [get_ports {DRAM_DATA[0]}]]  -to [list [get_ports {IRAM_ADDRESS[31]}] [get_ports {IRAM_ADDRESS[30]}]       \
[get_ports {IRAM_ADDRESS[29]}] [get_ports {IRAM_ADDRESS[28]}] [get_ports       \
{IRAM_ADDRESS[27]}] [get_ports {IRAM_ADDRESS[26]}] [get_ports                  \
{IRAM_ADDRESS[25]}] [get_ports {IRAM_ADDRESS[24]}] [get_ports                  \
{IRAM_ADDRESS[23]}] [get_ports {IRAM_ADDRESS[22]}] [get_ports                  \
{IRAM_ADDRESS[21]}] [get_ports {IRAM_ADDRESS[20]}] [get_ports                  \
{IRAM_ADDRESS[19]}] [get_ports {IRAM_ADDRESS[18]}] [get_ports                  \
{IRAM_ADDRESS[17]}] [get_ports {IRAM_ADDRESS[16]}] [get_ports                  \
{IRAM_ADDRESS[15]}] [get_ports {IRAM_ADDRESS[14]}] [get_ports                  \
{IRAM_ADDRESS[13]}] [get_ports {IRAM_ADDRESS[12]}] [get_ports                  \
{IRAM_ADDRESS[11]}] [get_ports {IRAM_ADDRESS[10]}] [get_ports                  \
{IRAM_ADDRESS[9]}] [get_ports {IRAM_ADDRESS[8]}] [get_ports {IRAM_ADDRESS[7]}] \
[get_ports {IRAM_ADDRESS[6]}] [get_ports {IRAM_ADDRESS[5]}] [get_ports         \
{IRAM_ADDRESS[4]}] [get_ports {IRAM_ADDRESS[3]}] [get_ports {IRAM_ADDRESS[2]}] \
[get_ports {IRAM_ADDRESS[1]}] [get_ports {IRAM_ADDRESS[0]}] [get_ports         \
IRAM_ISSUE] [get_ports {DRAM_ADDRESS[31]}] [get_ports {DRAM_ADDRESS[30]}]      \
[get_ports {DRAM_ADDRESS[29]}] [get_ports {DRAM_ADDRESS[28]}] [get_ports       \
{DRAM_ADDRESS[27]}] [get_ports {DRAM_ADDRESS[26]}] [get_ports                  \
{DRAM_ADDRESS[25]}] [get_ports {DRAM_ADDRESS[24]}] [get_ports                  \
{DRAM_ADDRESS[23]}] [get_ports {DRAM_ADDRESS[22]}] [get_ports                  \
{DRAM_ADDRESS[21]}] [get_ports {DRAM_ADDRESS[20]}] [get_ports                  \
{DRAM_ADDRESS[19]}] [get_ports {DRAM_ADDRESS[18]}] [get_ports                  \
{DRAM_ADDRESS[17]}] [get_ports {DRAM_ADDRESS[16]}] [get_ports                  \
{DRAM_ADDRESS[15]}] [get_ports {DRAM_ADDRESS[14]}] [get_ports                  \
{DRAM_ADDRESS[13]}] [get_ports {DRAM_ADDRESS[12]}] [get_ports                  \
{DRAM_ADDRESS[11]}] [get_ports {DRAM_ADDRESS[10]}] [get_ports                  \
{DRAM_ADDRESS[9]}] [get_ports {DRAM_ADDRESS[8]}] [get_ports {DRAM_ADDRESS[7]}] \
[get_ports {DRAM_ADDRESS[6]}] [get_ports {DRAM_ADDRESS[5]}] [get_ports         \
{DRAM_ADDRESS[4]}] [get_ports {DRAM_ADDRESS[3]}] [get_ports {DRAM_ADDRESS[2]}] \
[get_ports {DRAM_ADDRESS[1]}] [get_ports {DRAM_ADDRESS[0]}] [get_ports         \
DRAM_ISSUE] [get_ports DRAM_READNOTWRITE] [get_ports {DRAM_DATA[31]}]          \
[get_ports {DRAM_DATA[30]}] [get_ports {DRAM_DATA[29]}] [get_ports             \
{DRAM_DATA[28]}] [get_ports {DRAM_DATA[27]}] [get_ports {DRAM_DATA[26]}]       \
[get_ports {DRAM_DATA[25]}] [get_ports {DRAM_DATA[24]}] [get_ports             \
{DRAM_DATA[23]}] [get_ports {DRAM_DATA[22]}] [get_ports {DRAM_DATA[21]}]       \
[get_ports {DRAM_DATA[20]}] [get_ports {DRAM_DATA[19]}] [get_ports             \
{DRAM_DATA[18]}] [get_ports {DRAM_DATA[17]}] [get_ports {DRAM_DATA[16]}]       \
[get_ports {DRAM_DATA[15]}] [get_ports {DRAM_DATA[14]}] [get_ports             \
{DRAM_DATA[13]}] [get_ports {DRAM_DATA[12]}] [get_ports {DRAM_DATA[11]}]       \
[get_ports {DRAM_DATA[10]}] [get_ports {DRAM_DATA[9]}] [get_ports              \
{DRAM_DATA[8]}] [get_ports {DRAM_DATA[7]}] [get_ports {DRAM_DATA[6]}]          \
[get_ports {DRAM_DATA[5]}] [get_ports {DRAM_DATA[4]}] [get_ports               \
{DRAM_DATA[3]}] [get_ports {DRAM_DATA[2]}] [get_ports {DRAM_DATA[1]}]          \
[get_ports {DRAM_DATA[0]}]]
