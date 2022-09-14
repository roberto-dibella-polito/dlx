# Import files into Design Compiler: ANALYZE
# analyze -f vhdl -lib WORK ../src/<file name>.vhd

#####################################################
#	ANALYSIS SCRIPT									#
#	Design: 		DLX								#
#####################################################

#Delete the working directory -> to clean everything
file delete -force "work"
echo *************** Previous work directory deleted ****************

# Create again the work directory
file mkdir "work"
echo *************** New work directory created *********************

# Globals and shared resources
analyze -f vhdl -lib WORK ../src/000-globals.vhd
analyze -f vhdl -lib WORK ../src/000-commons/counter_v2.vhd
analyze -f vhdl -lib WORK ../src/000-commons/counter.vhd
analyze -f vhdl -lib WORK ../src/000-commons/mux2to1_1bit_bhv.vhd
analyze -f vhdl -lib WORK ../src/000-commons/mux2to1_bhv.vhd
analyze -f vhdl -lib WORK ../src/01-generic_shifter.vhd
analyze -f vhdl -lib WORK ../src/002-ControlWords.vhd

## DATAPTH

# Instruction Fetch
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.a-IF.vhd

# Instruction Decode
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.core/rf_constants.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.core/address_converter.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.core/RF_phys_async.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.core/RF_datapath.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.core/RF_cu.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.core/a.b.b.a-RF.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.b-ID.vhd

# Execute
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.a.a-PG_net.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.a.b-G_block.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.a.c-PG_block.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.a-SparseTree.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.b.a.a.a-fa.vhd
#analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.b.a.a-rca.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.b.a.a-rca_notime.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.b.a-csel_block.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a.b-csel_gen.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a.a-P4Adder.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.core/a.b.c.a-ALU_P4.vhd
analyze -f vhdl -lib WORK ../src/a.b-DataPath.core/a.b.c-EX.vhd

analyze -f vhdl -lib WORK ../src/a.b-DataPath.vhd

# Control unit
analyze -f vhdl -lib WORK ../src/a.a-CU_HW.vhd

# Top level entity
analyze -f vhdl -lib WORK ../src/a-DLX.vhd

set power_preserve_rtl_hier_names true

elaborate DLX -arch dlx_rtl -lib WORK > results/elaborate.txt
#uniquify
link



