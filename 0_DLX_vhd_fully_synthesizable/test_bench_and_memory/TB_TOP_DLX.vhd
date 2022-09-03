library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.ROCACHE_PKG.all;
use work.RWCACHE_PKG.all;

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
			FILE_PATH: string;				-- RAM output data file
			FILE_PATH_INIT: string;			-- RAM initialization data file
			WORD_SIZE: natural := 32;		-- Number of bits per word
			ENTRIES: 	natural := 128;		-- Number of lines in the ROM
			DATA_DELAY: natural := 2		-- Delay ( in # of clock cycles )
		);
	port (
			CLK   				: in std_logic;
			RST					: in std_logic;
			ADDRESS				: in std_logic_vector(WORD_SIZE - 1 downto 0);
			ENABLE				: in std_logic;
			READNOTWRITE		: in std_logic;
			DATA_READY			: out std_logic;
			INOUT_DATA			: inout std_logic_vector(2*WORD_SIZE-1 downto 0)
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
			IRAM_DATA				: in std_logic_vector(2*Data_size-1 downto 0);

			DRAM_ADDRESS			: out std_logic_vector(Instr_size-1 downto 0);
			DRAM_ISSUE				: out std_logic;
			DRAM_READNOTWRITE		: out std_logic;
			DRAM_READY				: in std_logic;
			DRAM_DATA				: inout std_logic_vector(2*Data_size-1 downto 0)
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

begin
	-- IRAM
	IRAM : ROMEM
		generic map ("/home/ms22.32/Desktop/DLX/asm_example/test.asm.mem")
		port map (CLK, RST, IRAM_ADDRESS, IRAM_ENABLE, IRAM_READY, IRAM_DATA);

	-- DRAM
	DRAM : RWMEM
		generic map (
			FILE_PATH_INIT => "/home/ms22.32/Desktop/DLX/0_DLX_vhd_fully_synthesizable/test_bench_and_memory/TB_rwmem/hex.txt",
			FILE_PATH => "/home/ms22.32/Desktop/DLX/0_DLX_vhd_fully_synthesizable/test_bench_and_memory/TB_rwmem/hex_out.txt"
		)
		port map ( CLK, RST, DRAM_ADDRESS, DRAM_ENABLE, DRAM_READNOTWRITE, DRAM_READY, DRAM_DATA );

	iram_first_word	<= IRAM_DATA(31 downto 0);
	dram_first_word	<= DRAM_DATA(31 downto 0);

	-- The memory is BYTE-ADDRESSABLE: each row corresponds to 4 bytes
	-- => Incoming address is shifted by two
	iram_addr_shifted <= "00" & IRAM_ADDRESS(31 downto 2);

	-- DLX
	UUT : DLX 
		generic map( IR_SIZE => 32, PC_SIZE => 32, DATA_SIZE => 32) 
		port map ( CLK, RST, iram_addr_shifted, IRAM_ENABLE, IRAM_READY, iram_data_first, DRAM_ADDRESS, DRAM_ENABLE, DRAM_READNOTWRITE, DRAM_READY, dram_data_first );

	Clk <= not Clk after 10 ns;
	Rst <= '1', '0' after 5 ns;
	
end tb;

