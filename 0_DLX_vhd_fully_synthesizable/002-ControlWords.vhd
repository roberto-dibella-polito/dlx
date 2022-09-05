library ieee;
use ieee.std_logic_1164.all;

package DLX_ControlWords is

	-- Control word:
	-- 0	RF_EN
	-- 1	RF_RS1_EN
	-- 2	RF_RS2_EN
	-- 3	IMM_ISOFF
	-- 4	RegRD_SEL
	-- 5	MUXA_SEL
	-- 6	MUXB_SEL
	-- 7	MEM_IN_EN
	-- 8	DRAM_ISSUE
	-- 9	DRAM_READNOTWRITE
	-- 10	JUMP_EN
	-- 11	WB_MUX_SEL
	-- 12	RF_WE
	-- 13	pipe_flush_n

	constant uC_MEM_SIZE	: integer := 64;
	constant CW_SIZE		: integer := 14;
	
	constant RR_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110000010111";	-- Register-Register control word
	constant RI_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100010010111";
	constant NOP_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "0000000010001";
	constant LW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1100010110011";
	constant SW_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "1110011100001";	
	--constant J_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant JAL_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BQZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	--constant BNZ_CW	: std_logic_vector(CW_SIZE-1 downto 0) := "";
	
	constant not_implemented	: std_logic_vector(CW_SIZE-1 downto 0) := (others=>'0');
	
	-- OPTIONAL INSTRUCTIONS

	
end DLX_ControlWords;
