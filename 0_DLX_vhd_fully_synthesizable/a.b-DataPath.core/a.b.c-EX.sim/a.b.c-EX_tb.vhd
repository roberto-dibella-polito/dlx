-- DLX
-- Execution stage
-- .MUXA,MUXB
-- .Zero Detector
-- .ALU

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_EX_tb is
end DLX_EX_tb;

architecture bhv of DLX_EX is
	
	component DLX_EX
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
			IMM_IN		: in std_logic_vector(DATA_SIZE-1 downto 0);
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
	end component;
	
	signal clk_i, rst_i			: std_logic;
	signal a_i, b_i, alu_out_o	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal npc_in_i				: std_logic_vector(NPC_SIZE-1 downto 0);
	signal imm_i				: std_logic_vector(DATA_SIZE-1 downto 0);
	signal rd_fwd_i, rd_fwd_o	: std_logic_vector(RX_SIZE-1 downto 0);
	signal data_mem_o			: std_logic_vector(DATA_SIZE-1 downto 0);
	
	signal branch_t_o, muxa_sel_i, muxb_sel_i	: std_logic;
	signal alu_op_i				: aluOp;

begin		

	uut: DLX_EX generic map(
		DATA_SIZE	=> DATA_SIZE,
		NPC_SIZE	=> PC_SIZE,
		IMM_SIZE	=> DATA_SIZE,
		RD_SIZE		=> RX_SIZE
	)
	port map(
		PORT_A		=> a_i,
		PORT_B		=> b_i,
		NPC_IN		=> npc_in_i,
		IMM_IN		=> imm_i,
		RD_FWD_IN	=> rd_fwd_i,
		ALU_OUT		=> alu_out_o,
		DATA_MEM	=> data_mem_o,
		RD_FWD_OUT	=> rd_fwd_o,
		BRANCH_T	=> branch_t_o,
		
		-- Control signals
		MUXA_SEL	=> muxa_sel_i,
		MUXB_SEL	=> muxb_sel_i
		ALU_OP		=> alu_op_i		
	);
	
	-- test
	test: process
	begin
		a_i <= std_logic_vector(to_unsigned(0,DATA_SIZE));
		b_i <= std_logic_vector(to_unsigned(47,DATA_SIZE));
		
		npc_in_i	<= "0101010" & (others=>'0');
		imm_i		<= "0111110" & (others=>'0');
		rd_fwd_i	<=(others=>'0');
		
		muxa_sel_i	<= '0';
		muxb_sel_i	<= '0';
		
		alu_op_i	<= ADD;
		
		wait 5 ns;
		alu_op_i	<= SUB;
		wait 5 ns;
		alu_op_i	<= OR_O;
		wait 5 ns;
		alu_op_i	<= SRL_O;
		wait 5 ns;
	end process test;
	
end bhv;
	