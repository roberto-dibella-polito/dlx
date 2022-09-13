--	DLX
--	Instruction Fetch stage testbench

library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use work.ROCACHE_PKG.all;

entity DLX_IF_tb is
end DLX_IF_tb;

architecture structure of DLX_IF_tb is
	
	component DLX_IF
		generic (
			IR_SIZE      : integer := 32;       -- Instruction Register Size
			PC_SIZE      : integer := 32       -- Program Counter Size
		);
		port(
			CLK			: in std_logic;
			RST			: in std_logic;			-- Active LOW
			
			-- Instruction Memory interface
			IRAM_ADDRESS			: out std_logic_vector(INSTR_SIZE-1 downto 0);
			--IRAM_ISSUE				: out std_logic;
			--IRAM_READY				: in std_logic;
			IRAM_DATA				: in std_logic_vector(INSTR_SIZE-1 downto 0);
			
			-- Stage interface
			NPC_SEL					: in std_logic;
			NPC_ALU					: in std_logic_vector(PC_SIZE-1 downto 0);
			NPC_OUT					: out std_logic_vector(PC_SIZE-1 downto 0);
			INSTR					: out std_logic_vector(IR_SIZE-1 downto 0);
			
			-- IF control signals
			--IR_LATCH_EN				: in std_logic;
			--NPC_LATCH_EN			: in std_logic;
			PC_LATCH_EN				: in std_logic
		);
	end component;
	
	-- INSTRUCTION RAM -> To be substituted by an asynchronous ROMEM with CACHE
	--component IRAM is
	--	generic (
	--		RAM_DEPTH : integer := 48;
	--		I_SIZE : integer := 32);
	--	port (
	--		Rst  : in  std_logic;
	--		Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
	--		Dout : out std_logic_vector(I_SIZE - 1 downto 0)
	--	);
	--end component;
	
	component ROMEM
		generic (
			file_path	: -- string(1 to 37) := "C://DLX//dlx-master//rocache//hex.txt";
						string(1 to 94) := "/home/ms22.32/Desktop/DLX/0_DLX_vhd_fully_synthesizable/test_bench_and_memory/TB_romem/hex.txt";
			ENTRIES		: integer := 128;
			WORD_SIZE	: integer := 32;
			data_delay	: natural := 2
		);
		port (
			CLK					: in std_logic;
			RST					: in std_logic;
			ADDRESS				: in std_logic_vector(WORD_SIZE - 1 downto 0);
			ENABLE				: in std_logic;
			DATA_READY			: out std_logic;
			DATA				: out std_logic_vector(2*WORD_SIZE - 1 downto 0)
		);
	end component;
	
	component ROCACHE
		port (
			CLK						: in std_logic;
			RST						: in std_logic;  -- active high
			ENABLE					: in std_logic;
			ADDRESS					: in std_logic_vector(INSTR_SIZE - 1 downto 0);
			OUT_DATA				: out std_logic_vector(INSTR_SIZE - 1 downto 0);
			STALL					: out std_logic;
			RAM_ISSUE				: out std_logic;
			RAM_ADDRESS				: out std_logic_vector(INSTR_SIZE - 1 downto 0);
			RAM_DATA				: in std_logic_vector(2*INSTR_SIZE - 1 downto 0);
			RAM_READY				: in std_logic
		);
	end component;
	
	component clk_gen
		port (
			END_SIM : in  std_logic;
			CLK     : out std_logic);
	end component;
	
	signal stall_i, ram_issue_i, ram_ready_i, clk_i, rst_i, npc_sel_i, pc_latch_en_i: std_logic;
	signal npc_alu_i, npc_out_o, instr_o : std_logic_vector(31 downto 0);
	signal address_i, ram_address_i, data_i: std_logic_vector(31 downto 0);
	signal ram_data_i	: std_logic_vector(2*32-1 downto 0);
	
begin
	
	dut: DLX_IF port map(
		CLK				=> clk_i,
		RST				=> rst_i,
		IRAM_ADDRESS	=> address_i,
		IRAM_DATA		=> data_i,
		NPC_SEL			=> npc_sel_i, 
		NPC_ALU			=> npc_alu_i,
		NPC_OUT			=> npc_out_o,
		INSTR			=> instr_o,
		PC_LATCH_EN		=> pc_latch_en_i );
		
	pc_latch_en_i <= not stall_i;
	
	cache: ROCACHE port map(
		CLK				=> clk_i,
		RST				=> rst_i,
		ENABLE			=> '1',
		ADDRESS			=> address_i,
		OUT_DATA		=> data_i,
		STALL			=> stall_i,
		RAM_ISSUE		=> ram_issue_i,
		RAM_ADDRESS		=> ram_address_i,
		RAM_DATA		=> ram_data_i,
		RAM_READY		=> ram_ready_i
	);
	
	mem: ROMEM port map(
		CLK				=> clk_i,
		RST				=> rst_i,
		ADDRESS			=> ram_address_i,
		ENABLE			=> ram_issue_i,
		DATA_READY		=> ram_ready_i,
		DATA			=> ram_data_i
	);
	
	clock: clk_gen port map (
		END_SIM		=> '0',
		CLK     	=> clk_i 
	);

end structure;
