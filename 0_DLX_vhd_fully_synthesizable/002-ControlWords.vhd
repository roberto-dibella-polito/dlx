library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 15	RF_EN
	-- 14	RF_RS1_EN
	-- 13	RF_RS2_EN
	-- 12	IMM_ISOFF
	-- 11	RegRD_SEL
	-- 10	MUXA_SEL
	-- 9	MUXB_SEL
	-- 8	MEM_IN_EN
	-- 7	DRAM_ISSUE
	-- 6	DRAM_READNOTWRITE
	-- 5	eqz_cond				for BEQZ
	-- 4	neqz_cond 			for BNEZ
	-- 3	jump_en_i			for Unconditional Jumps
	-- 2	WB_MUX_SEL
	-- 1	RF_WE
	-- 0	pipe_flush_n

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 16;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110000001000111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100101001000111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0000000001000001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100101011000011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110001010000001";	
	--constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100011000100001";
	constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100011000010001";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
	-- OPTIONAL INSTRUCTIONS

	
end DLX_ControlWords;
