#################################################################################
#	COMPILATION SCRIPT															#
#	Design: 		DLX															#
#	Goal:			Compiling for Place & Route  								#
#	Last modified:	September 13, 2022, 22:43									#	
#################################################################################

# Timing constraints
create_clock -name "CLK" -period 5 {"CLK"}	

# Load constraints
set_wire_load_model -name 5K_hvratio_1_4

# Forces a combinational max delay of 5 ns from each of the inputs
# to each of th output in case combinational paths are present 
set_max_delay 5 -from [all_inputs] -to [all_outputs]

compile -map_effort high

# Timing & Area report

report_timing > results/timing_5_00.txt
report_area -hierarchy > results/area_hierarchy_5_00.txt

ungroup -all -flatten

report_area > results/area_flatten_5_00.txt
report_power -verbose > results/power_5_00.txt

write_sdf ../netlist/dlx_pr.sdf
write -f verilog -hierarchy -output ../netlist/dlx_pr.v
write_sdc ../netlist/dlx_pr.sdc



