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
		RD_SIZE		: integer := 32
	);
	port(
		PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
		PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
		NPC_IN		: in std_logic_vector(NPC_SIZE-1 downto 0);
		IMM_IN		: in std_logic_vector(DATA_SIZE-1 downto 0);
		RD_FWD_IN	: in std_logic_vector(RD_SIZE-1 downto 0);
		ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
		DATA_MEM	: out std_logic_vector(DATA_SIZE-1 downto 0);
		RD_FWD_OUT	: out std_logic_vector(RD_SIZE-1 downto 0);
		BRANCH_T	: out std_logic;
		
		-- Control signals
		MUXA_SEL	: in std_logic;  -- MUX-A Sel
		MUXB_SEL	: in std_logic;  -- MUX-B Sel
		ALU_OP		: in aluOp		
	);
end DLX_EX;

architecture structure of DLX_EX is
	
	component DLX_ALU
		generic(
			DATA_SIZE	: integer := 32
		);
		port(
			PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
			PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
			ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
			ALU_OP		: in aluOp
		);
	end component;
	
	component mux2to1 
		generic (N : integer);
		port (
			IN0,IN1	: in std_logic_vector (N-1 downto 0); --input signals
			SEL		: in std_logic; --select signal
			MUX_OUT	: out std_logic_vector (N-1 downto 0));--N bits output
	end component;
	
	signal muxA_out, muxB_out : std_logic_vector(DATA_SIZE-1 downto 0);
	
begin

	-- Zero detector
	BRANCH_T <= '0' when ( unsigned(PORT_A) = to_unsigned(0,DATA_SIZE) ) else '1';
	
	muxA: mux2to1 generic map (N => DATA_SIZE)
	port map (
		IN0		=> PORT_A,
		IN1		=> NPC_IN,
		SEL		=> MUXA_SEL,
		MUX_OUT	=> muxA_out
	);
	
	muxB: mux2to1 generic map (N => DATA_SIZE)
	port map (
		IN0		=> PORT_B,
		IN1		=> IMM_IN,
		SEL		=> MUXB_SEL,
		MUX_OUT	=> muxB_out
	);
	
	alu: DLX_ALU generic map( DATA_SIZE	=> DATA_SIZE )
	port map(
		PORT_A		=> muxA_out,
		PORT_B		=> muxB_out,
		ALU_OUT		=> ALU_OUT,
		ALU_OP		=> ALU_OP
	);
	
	RD_FWD_OUT  <= RD_FWD_IN;
	DATA_MEM	<= PORT_B;
	
end structure;
	
