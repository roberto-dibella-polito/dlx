library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 18	RF_EN
	-- 17	RF_RS1_EN
	-- 16	RF_RS2_EN
	-- 15	IMM_ISOFF
	-- 14	IMM_UNS
	-- 13	Reg31_SEL
	-- 12	RegRD_SEL
	-- 11	MUXA_SEL
	-- 10	MUXB_SEL
	-- 9	MEM_IN_EN
	-- 8	NPC_WB_EN
	-- 7	DRAM_ISSUE
	-- 6	DRAM_READNOTWRITE
	-- 5	eqz_cond			for BEQZ
	-- 4	neqz_cond 			for BNEZ
	-- 3	jump_en_i			for Unconditional Jumps
	-- 2	WB_MUX_SEL
	-- 1	RF_WE
	-- 0	pipe_flush_n

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 19;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110000000001000111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100001010001000111";
	constant RUI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100101010001000111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0000000000001000001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100001011011000011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110000010010000001";	
	constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0001000110001001000";
	constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1001010110101001010";
	constant JR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1111100010001001000";
	constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100000110000100001";
	constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100000110000010001";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
end DLX_ControlWords;
