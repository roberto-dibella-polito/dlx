library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 13	RF_EN
	-- 12	RF_RS1_EN
	-- 11	RF_RS2_EN
	-- 10	IMM_ISOFF
	-- 9	RegRD_SEL
	-- 8	MUXA_SEL
	-- 7	MUXB_SEL
	-- 6	MEM_IN_EN
	-- 5	DRAM_ISSUE
	-- 4	DRAM_READNOTWRITE
	-- 3	JUMP_EN
	-- 2	WB_MUX_SEL
	-- 1	RF_WE
	-- 0	pipe_flush_n

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 14;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11100000010111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11001010010111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "00000000010001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11001010110011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "11100011100001";	
	--constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
	-- OPTIONAL INSTRUCTIONS

	
end DLX_ControlWords;
