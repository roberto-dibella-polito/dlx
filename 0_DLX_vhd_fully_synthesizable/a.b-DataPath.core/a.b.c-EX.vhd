-- DLX
-- Execution stage
-- .MUXA,MUXB
-- .Zero Detector
-- .ALU

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_EX is
	generic(
		DATA_SIZE	: integer := 32;
		NPC_SIZE	: integer := 32;
		IMM_SIZE	: integer := 32;
		RD_SIZE		: integer := 32;
	);
	port(
		PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
		PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
		NPC_IN		: in std_logic_vector(NPC_SIZE-1 downto 0);
		IMM_IN		: in std_logic_vector(IMM_SIZE-1 downto 0);
		RD_FWD_IN	: in std_logic_vector(RD_SIZE-1 downto 0);
		ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
		DATA_MEM	: out std_logic_vector(DATA_SIZE-1 downto 0);
		RD_FWD_OUT	: out std_logic_vector(RD_SIZE-1 downto 0);
		BRANCH_T	: out std_logic;
		
		-- Control signals
		MUXA_SEL	: out std_logic;  -- MUX-A Sel
		MUXB_SEL	: out std_logic;  -- MUX-B Sel
		ALU_OP		: in aluOp;		
	);
end DLX_EX;

