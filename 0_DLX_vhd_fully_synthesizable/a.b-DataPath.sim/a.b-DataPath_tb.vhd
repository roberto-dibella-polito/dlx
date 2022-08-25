-- DLX
-- Datapath

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_DP_tb is
end DLX_DP_tb;

architecture structure of DLX_DP_tb is

	component DLX_DP is
		port(
			CLK				: in std_logic;
			RST				: in std_logic;	-- Active HIGH
			
			-- Instruction Memory interface
			IRAM_ADDRESS	: out std_logic_vector(PC_SIZE-1 downto 0);
			IRAM_DATA		: in std_logic_vector(IR_SIZE-1 downto 0);
			
			-- IF control signals
			NPC_SEL			: in std_logic;
			PC_LATCH_EN		: in std_logic;
			
			-- IF/ID pipeline registers control
			IR_LATCH_EN		: in std_logic;
			NPC_LATCH_EN	: in std_logic;
			
			-- ID control signals
			-- Windowed register file
			CALL			: in std_logic;
			RET				: in std_logic;
			SPILL			: out std_logic;
			FILL			: out std_logic;
			RF_EN			: in std_logic;
			RS1_EN			: in std_logic;
			RS2_EN			: in std_logic;
			RF_WR_EN		: in std_logic;
			
			IMM_ISOFF		: in std_logic	
			
			-- ID/EX control signals
			RegA_LATCH_EN	: in std_logic;  -- Register A Latch Enable
			RegB_LATCH_EN	: in std_logic;  -- Register B Latch Enable
			RegIMM_LATCH_EN	: in std_logic;  -- Immediate Register Latch Enable
			
			-- ... more stages missing
		);
	end component;
	
	component IRAM is
		generic (
			RAM_DEPTH : integer := 127;
			I_SIZE : integer := 32);
		port (
			Rst  : in  std_logic;
			Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
			Dout : out std_logic_vector(I_SIZE - 1 downto 0)
		);
	end component;
	
	signal clk_i, rst_i, npc_sel_i, pc_latch_en_i, ir_latch_en_i,
		ir_latch_en_i, npc_latch_en_i, call_i, ret_i, spill_i, fill_i,
		rf_en_i, rs1_en_i, rs2_en_i, rf_wr_en_i, imm_isoff_i : std_logic;
		
	signal ram_addr_i : std_logic_vector(PC_SIZE-1 downto 0);
	signal ram_data_i : std_logic_vector(INSTR_SIZE-1 downto 0);
	signal rega_latch_en_i, regb_latch_en_i, regimm_latch_en_i : std_logic;
	
begin

	dut: DLX_DP port map(
		CLK				=> clk_i,
		RST				=> rst_i,
		
		-- Instruction Memory interface
		IRAM_ADDRESS	=> ram_addr_i,
		IRAM_DATA		=> ram_data_i,
		
		-- IF control signals
		NPC_SEL			=> npc_sel_i,
		PC_LATCH_EN		=> pc_latch_en_i,
		
		-- IF/ID pipeline registers control
		IR_LATCH_EN		=> ir_latch_en_i,
		NPC_LATCH_EN	=> npc_latch_en_i,
		
		-- ID control signals
		-- Windowed register file
		CALL			=> call_i,
		RET				=> rst_i,
		SPILL			=> spill_i,
		FILL			=> fill_i,
		RF_EN			=> rf_en_i,
		RS1_EN			=> rs1_en_i,
		RS2_EN			=> rs2_en_i,
		RF_WR_EN		=> rf_wr_en_i,
		
		IMM_ISOFF		=> imm_isoff_i,
		
		-- ID/EX control signals
		RegA_LATCH_EN	=> rega_latch_en_i,
		RegB_LATCH_EN	=> regb_latch_en_i,
		RegIMM_LATCH_EN	=> regimm_latch_en_i
		
		-- ... more stages missing
	);
	
	mem: IRAM generic map(
		RAM_DEPTH => 127,
		I_SIZE => INSTR_SIZE )
	port map(
		Rst  => rst_i,
		Addr => ram_addr_i,
		Dout => ram_data_i
	);
	
	-- Clock process
	clkgen : process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;
	
	-- Test
	test: process
	begin
		rst_i				<= '1';
		npc_sel_i			<= '0';
		pc_latch_en_i		<= '1';
		ir_latch_en_i		<= '1';
		npc_latch_en_i		<= '1';
		call_i				<= '0';
		ret_i				<= '0';
		spill_i				<= '0';
		fill_i				<= '0';
		rf_en_i				<= '1';
		rs1_en_i			<= '1';
		rs2_en_i			<= '1';
		rf_en_i				<= '0';
		imm_isoff_i			<= '0';
		rega_latch_en_i		<= '1';
		regb_latch_en_i		<= '1';
		regimm_latch_en_i	<= '1';
		wait for 2 ns;
		rst_i <= '0';
		
		wait for 10000 ns;	
	end process test;
		
end structure;
