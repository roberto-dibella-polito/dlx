library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 0	RF_EN
	-- 1	RF_RS1_EN
	-- 2	RF_RS2_EN
	-- 3	IMM_ISOFF
	-- 4	MUXA_SEL
	-- 5	MUXB_SEL
	-- 6	DRAM_ISSUE
	-- 7	DRAM_READNOTWRITE
	-- 8	JUMP_EN
	-- 9	WB_MUX_SEL
	-- 10	RF_WE

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 11;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "111000010111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "110001010111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "000000010001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "110001110011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "111001100001";	
	--constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
	-- OPTIONAL INSTRUCTIONS
	
end DLX_ControlWords;