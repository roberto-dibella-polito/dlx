-- DLX
-- Datapath

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_DP_tb is
end DLX_DP_tb;

architecture structure of DLX_DP_tb is

	constant ADDR_SIZE : integer := 32;
	constant DATA_SIZE	: integer := 32;

	component DLX_DP is
		generic(
			ADDR_SIZE	: integer := 32;
			DATA_SIZE	: integer := 32
		);
		port(
			CLK				: in std_logic;
			RST				: in std_logic;	-- Active HIGH
		
			-- Pipeline registers enable and clear signal
			PIPE_IF_ID_EN	: in std_logic;
			PIPE_ID_EX_EN	: in std_logic;
			PIPE_EX_MEM_EN	: in std_logic;
			PIPE_MEM_WB_EN	: in std_logic;
		
			PIPE_CLEAR_n	: in std_logic;
		
			-- Instruction Memory interface
			IRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
			IRAM_DATA		: in std_logic_vector(DATA_SIZE-1 downto 0);
		
			-- Instruction port, forwarded to CU
			INSTR			: out std_logic_vector(DATA_SIZE-1 downto 0);	
		
			-- ID control signals
			-- Windowed register file
			CALL			: in std_logic;
			RET				: in std_logic;
			SPILL			: out std_logic;
			FILL			: out std_logic;
			RF_EN			: in std_logic;
			RS1_EN			: in std_logic;
			RS2_EN			: in std_logic;
		
			IMM_ISOFF		: in std_logic;	
		
			-- EX control signals
			MUXA_SEL		: in std_logic;
			MUXB_SEL		: in std_logic;
			BRANCH_T		: out std_logic;
			ALU_OP			: in aluOp;
			MEM_IN_EN		: in std_logic;
		
			-- DRAM Data Interface
			DRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
			DRAM_DATA		: inout std_logic_vector(DATA_SIZE-1 downto 0);
		
			-- MEM control signals
			--LMD_LATCH_EN	: in std_logic;	-- LMD Register Latch Enable
			JUMP_EN			: in std_logic;	-- JUMP Enable Signal for PC input MUX
			PC_LATCH_EN		: in std_logic;	-- Pipelined version -> with no stalls, always active
		
			-- WB Control signals
			WB_MUX_SEL		: in std_logic;  -- Write Back MUX Sel
			RF_WE			: in std_logic  -- Register File Write Enable
		);
	end component;
	
	component IRAM is
		generic (
			file_path : string := "hex.txt";
			RAM_DEPTH : integer := 127;
			I_SIZE : integer := 32);
		port (
			Rst  : in  std_logic;
			Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
			Dout : out std_logic_vector(I_SIZE - 1 downto 0)
		);
	end component;
	
	--signal clk_i, rst_i, npc_sel_i, pc_latch_en_i, ir_latch_en_i,
	--	npc_latch_en_i, call_i, ret_i, spill_i, fill_i,
	--	rf_en_i, rs1_en_i, rs2_en_i, rf_wr_en_i, imm_isoff_i : std_logic;
	
	signal clk_i, rst_i	: std_logic;
	signal ram_addr_i : std_logic_vector(PC_SIZE-1 downto 0);
	signal ram_data_i : std_logic_vector(INSTR_SIZE-1 downto 0);
	signal rega_latch_en_i, regb_latch_en_i, regimm_latch_en_i : std_logic;

	-- Control Unit Bus signals
	signal instr_i			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal pipe_if_id_en_i	: std_logic;
	signal pipe_id_ex_en_i	: std_logic;
	signal pipe_ex_mem_en_i	: std_logic;
	signal pipe_mem_wb_en_i	: std_logic;
	signal pipe_clear_n_i	: std_logic;
	signal rf_call_i		: std_logic;
	signal rf_ret_i			: std_logic;
	signal rf_spill_i		: std_logic;
	signal rf_fill_i		: std_logic;
	signal rf_en_i			: std_logic;
	signal rf_rs1_en_i		: std_logic;
	signal rf_rs2_en_i		: std_logic;
	signal imm_isoff_i		: std_logic;
	signal muxA_sel_i		: std_logic;
	signal muxB_sel_i		: std_logic;
	signal mem_in_en_i		: std_logic;
	signal is_zero_i		: std_logic;
	signal alu_op_i			: aluOp;
	signal dram_issue_i		: std_logic;
	signal dram_rd_wr_i		: std_logic;
	signal dram_ready_i		: std_logic;
	signal jump_en_i		: std_logic;
	signal pc_latch_en_i	: std_logic;
	signal wb_mux_sel_i		: std_logic;
	signal rf_we_i			: std_logic;
	
	signal dram_addr_i		: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal dram_data_i		: std_logic_vector(ADDR_SIZE-1 downto 0);

begin

	dp: DLX_DP generic map(
		ADDR_SIZE	=> INSTR_SIZE,
		DATA_SIZE	=> DATA_SIZE
	)
	port map(
		CLK				=> clk_i,
		RST				=> rst_i,
		PIPE_IF_ID_EN	=> '1',
		PIPE_ID_EX_EN	=> '1',
		PIPE_EX_MEM_EN	=> '1',
		PIPE_MEM_WB_EN	=> '1',
		PIPE_CLEAR_n	=> '1',
		IRAM_ADDRESS	=> ram_addr_i,
		IRAM_DATA		=> ram_data_i,
		INSTR			=> instr_i,
		CALL			=> rf_call_i,
		RET				=> rf_ret_i,
		SPILL			=> rf_spill_i,
		FILL			=> rf_fill_i,
		RF_EN			=> rf_en_i,
		RS1_EN			=> rf_rs1_en_i,
		RS2_EN			=> rf_rs2_en_i,
		IMM_ISOFF		=> imm_isoff_i,	
		MUXA_SEL		=> muxA_sel_i,
		MUXB_SEL		=> muxB_sel_i,
		MEM_IN_EN		=> mem_in_en_i,
 		BRANCH_T		=> is_zero_i,
		ALU_OP			=> alu_op_i,
		DRAM_ADDRESS	=> dram_addr_i,
		DRAM_DATA		=> dram_data_i,
		JUMP_EN			=> '0',
		PC_LATCH_EN		=> '1',
		WB_MUX_SEL		=> wb_mux_sel_i,
		RF_WE			=> rf_we_i
	);
	
	mem: IRAM generic map(
		file_path => "/home/ms22.32/Desktop/DLX/asm_example/test.asm.mem",
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
		clk_i <= '0';
		wait for 5 ns;
		clk_i <= '1';
		wait for 5 ns;
	end process;
	
	-- Test
	--test: process
	--begin
	--	rst_i				<= '1';
	--	npc_sel_i			<= '0';
	--	pc_latch_en_i		<= '1';
	--	ir_latch_en_i		<= '1';
	--	npc_latch_en_i		<= '1';
	--	call_i				<= '0';
	--	ret_i				<= '0';
	--	spill_i				<= '0';
	--	fill_i				<= '0';
	--	rf_en_i				<= '1';
	--	rs1_en_i			<= '1';
	--	rs2_en_i			<= '1';
	--	rf_wr_en_i			<= '0';
	--	imm_isoff_i			<= '0';
	--	rega_latch_en_i		<= '1';
	--	regb_latch_en_i		<= '1';
	--	regimm_latch_en_i	<= '1';
	--	wait for 2 ns;
	--	rst_i <= '0';
	--	
	--	wait for 10000 ns;	
	--end process test;
		
end structure;
