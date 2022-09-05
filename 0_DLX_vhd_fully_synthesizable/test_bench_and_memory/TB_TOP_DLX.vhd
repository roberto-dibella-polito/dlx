library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
--use work.ROCACHE_PKG.all;
--use work.RWCACHE_PKG.all;
use work.myTypes.all;

entity DLX_TestBench is
end DLX_TestBench;

architecture tb of DLX_TestBench is
	component ROMEM is
	generic (
		FILE_PATH	: string;				-- ROM data file
		ENTRIES		: integer := 128;		-- Number of lines in the ROM
		WORD_SIZE	: integer := 32;		-- Number of bits per word
		DATA_DELAY	: natural := 2			-- Delay ( in # of clock cycles )
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

	component RWMEM is
	generic(
			file_path: string;
			file_path_init: string;
			Data_size : natural := 64;
			Instr_size: natural := 32;
			RAM_DEPTH: 	natural := 128;
			data_delay: natural := 2
		);
	port (
			CLK   				: in std_logic;
			RST					: in std_logic;
			ADDR				: in std_logic_vector(Instr_size - 1 downto 0);
			ENABLE				: in std_logic;
			READNOTWRITE		: in std_logic;
			DATA_READY			: out std_logic;
			INOUT_DATA			: inout std_logic_vector(Data_size-1 downto 0)
		);
	end component;

	component DLX is
		port (
			-- Inputs
			CLK						: in std_logic;		-- Clock
			RST						: in std_logic;		-- Reset:Active-High

			IRAM_ADDRESS			: out std_logic_vector(Instr_size - 1 downto 0);
			IRAM_ISSUE				: out std_logic;
			IRAM_READY				: in std_logic;
			IRAM_DATA				: in std_logic_vector(Data_size-1 downto 0);

			DRAM_ADDRESS			: out std_logic_vector(Instr_size-1 downto 0);
			DRAM_ISSUE				: out std_logic;
			DRAM_READNOTWRITE		: out std_logic;
			DRAM_READY				: in std_logic;
			DRAM_DATA				: inout std_logic_vector(Data_size-1 downto 0)
		);
	end component;

	signal CLK :				std_logic := '0';		-- Clock
	signal RST :				std_logic;		-- Reset:Active-Low
	signal IRAM_ADDRESS :		std_logic_vector(Instr_size - 1 downto 0);
	signal IRAM_ENABLE :		std_logic;
	signal IRAM_READY :			std_logic;
	signal IRAM_DATA :			std_logic_vector(2*Data_size-1 downto 0);

	signal DRAM_ADDRESS :		std_logic_vector(Instr_size-1 downto 0);
	signal DRAM_ENABLE :		std_logic;
	signal DRAM_READNOTWRITE :	std_logic;
	signal DRAM_READY :			std_logic;
	signal DRAM_DATA :			std_logic_vector(2*Data_size-1 downto 0);

	signal iram_first_word		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal dram_first_word		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal iram_addr_shifted	: std_logic_vector(PC_SIZE-1 downto 0);

	signal opcode_i				: std_logic_vector(INSTR_SIZE-1 downto 0);
	signal func_i				: std_logic_vector(FUNC_SIZE-1 downto 0);
	signal instruction_i		: dlxInstr;
	
begin
	-- IRAM
	IRAM : ROMEM
		generic map (
			file_path	=> "/home/ms22.32/Desktop/DLX/asm_example/test.asm.mem",
			DATA_DELAY	=> 0
		)
		port map (
			CLK					=> Clk,
			RST					=> Rst,
			ADDRESS				=> iram_addr_shifted,
			ENABLE				=> IRAM_ENABLE,
			DATA_READY			=> IRAM_READY,
			DATA				=> IRAM_DATA
		);

	-- DRAM
	DRAM : RWMEM
		generic map (
			file_path_init 	=> "/home/ms22.32/Desktop/DLX/0_DLX_vhd_fully_synthesizable/test_bench_and_memory/TB_rwmem/hex.txt",
			file_path 		=> "/home/ms22.32/Desktop/DLX/0_DLX_vhd_fully_synthesizable/test_bench_and_memory/TB_rwmem/hex_out.txt",
			DATA_DELAY		=> 0
		)
		port map ( CLK, RST, DRAM_ADDRESS, DRAM_ENABLE, DRAM_READNOTWRITE, DRAM_READY, DRAM_DATA );

	iram_first_word	<= IRAM_DATA(31 downto 0);
	dram_first_word	<= DRAM_DATA(31 downto 0);

	opcode_i 	<= iram_first_word(31 downto 0);
	func_i		<= iram_first_word(FUNC_SIZE-1 downto 0);
	
	-- The memory is BYTE-ADDRESSABLE: each row corresponds to 4 bytes
	-- => Incoming address is shifted by two
	iram_addr_shifted <= "00" & IRAM_ADDRESS(31 downto 2);

	-- DLX
	UUT : DLX 
		generic map( IR_SIZE => 32, PC_SIZE => 32, DATA_SIZE => 32) 
		port map ( CLK, RST, IRAM_ADDRESS, IRAM_ENABLE, IRAM_READY, iram_first_word, DRAM_ADDRESS, DRAM_ENABLE, DRAM_READNOTWRITE, DRAM_READY, dram_first_word );

	-- INSTRUCTION EVALUATOR
	-- Only used to display the fetched instruction in an easy way
	-- Inputs: 	opcode_i, func_i
	-- Outputs:	instruction_i
	display_op: process(opcode_i, func_i)
	begin
	
		case conv_integer(unsigned(opcode_i)) is
			when 0 =>
				
				case conv_integer(unsigned(func_i)) is
					when 4 => instruction_i <= SLL_op;
					when 6 => instruction_i <= SRL_op;
					when 7 => instruction_i <= SRA_op;
					when 14 => instruction_i <= MULT;
					when 32 => instruction_i <= ADD;
					when 33 => instruction_i <= ADDU;
					when 34 => instruction_i <= SUB;
					when 35 => instruction_i <= SUBU;
					when 36 => instruction_i <= AND_op;
					when 37 => instruction_i <= OR_op;
					when 38 => instruction_i <= XOR_op;
					when 40 => instruction_i <= SEQ;
					when 41 => instruction_i <= SNE;
					when 42 => instruction_i <= SLT;
					when 43 => instruction_i <= SGT;
					when 44 => instruction_i <= SLE;
					when 45 => instruction_i <= SGE;
					when 58 => instruction_i <= SLTU;
					when 59 => instruction_i <= SGTU;
					when 61 => instruction_i <= SGEU;
					when others => NOP;
				end case;
			when 2 => instruction_i <= J;
			when 3 => instruction_i <= JAL;
			when 4 => instruction_i <= BEQZ;
			when 5 => instruction_i <= BNEZ;
			when 8 => instruction_i <= ADDI;
			when 9 => instruction_i <= ADDUI;
			when 10 => instruction_i <= SUBI;
			when 11 => instruction_i <= SUBUI;
			when 12 => instruction_i <= ANDI;
			when 13 => instruction_i <= ORI;
			when 14 => instruction_i <= XORI;
			when 15 => instruction_i <= LHI;
			when 18 => instruction_i <= JR;
			when 19 => instruction_i <= JALR;
			when 20 => instruction_i <= SLLI;
			when 21 => instruction_i <= NOP;
			when 22 => instruction_i <= SRLI;
			when 23 => instruction_i <= SRAI;
			when 24 => instruction_i <= SEQI;
			when 25 => instruction_i <= SNEI;
			when 26 => instruction_i <= SLTI;
			when 27 => instruction_i <= SGTI;
			when 28 => instruction_i <= SLEI;
			when 29 => instruction_i <= SGEI;
			when 32 => instruction_i <= LB;
			when 35 => instruction_i <= LW;
			when 36 => instruction_i <= LBU;
			when 37 => instruction_i <= LHU;
			when 40 => instruction_i <= SB;
			when 43 => instruction_i <= SW;
			when 58 => instruction_i <= SLTUI;
			when 59 => instruction_i <= SGTUI;
			when 61 => instruction_i <= SGEUI;
			when others => NOP;
		end case;
	end process;
	
	Clk <= not Clk after 5 ns;
	Rst <= '1', '0' after 3 ns;
	
end tb;

