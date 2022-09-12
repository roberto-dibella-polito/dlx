library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 19	RF_EN
	-- 18	RF_RS1_EN
	-- 17	RF_RS2_EN
	-- 16	IMM_ISOFF
	-- 15	IMM_UNS
	-- 14	regRd_jal_sel		for JAL
	-- 13	RegRD_SEL
	-- 12	MUXA_SEL
	-- 11	MUXB_SEL
	-- 10	MEM_IN_EN
	-- 9	DRAM_ISSUE
	-- 8	DRAM_READNOTWRITE
	-- 7	eqz_cond			for BEQZ
	-- 6	neqz_cond 			for BNEZ
	-- 5	jump_pc_sel			for J
	-- 4	jump_en_i			for Unconditional Jumps
	-- 3	wb_pc_sel			for JAL
	-- 2	WB_MUX_SEL
	-- 1	RF_WE
	-- 0	pipe_flush_n

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 20;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11100000000100000111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11000010100100000111";
	constant RUI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11001010100100000111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "00000000000100000001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11000010111100000011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11100000101000000001";	
	constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "00010001100100110000";
	constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "10010101100100111010";
	constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11000001100010000001";
	constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11000001100001000001";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
end DLX_ControlWords;
