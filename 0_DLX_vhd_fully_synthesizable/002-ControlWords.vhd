library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 0	NPC_LATCH_EN
	-- 1	RF_EN
	-- 2	RF_RS1_EN
	-- 3	RF_RS2_EN
	-- 4	IMM_ISOFF
	-- 5	MUXA_SEL
	-- 6	MUXB_SEL
	-- 7	DRAM_ISSUE
	-- 8	DRAM_READNOTWRITE
	-- 9	JUMP_EN
	-- 10	WB_MUX_SEL
	-- 11	RF_WE

	constant CW_SIZE	: integer := 12;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0111000010111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0110001010111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0000000010001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0110001110011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0111001100001";	
	--constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
	-- OPTIONAL INSTRUCTIONS
	
end DLX_ControlWords;