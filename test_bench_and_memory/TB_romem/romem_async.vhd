library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
--use work.ROCACHE_PKG.all;

-- Instruction memory for DLX -> ASYNCHRONOUS VERSION
-- DATA is available when ADDR and ENABLE are high.
-- The DATA_READY is set when data is available and cleared when DATA_ISSUE is cleared.
-- The generic data_delay simulates the output delay

entity ROMEM is
	generic (
		file_path	: -- string(1 to 37) := "C://DLX//dlx-master//rocache//hex.txt";
					string;
		ENTRIES		: integer := 128;
		WORD_SIZE	: integer := 32;
		data_delay	: time := 3 ns
	);
	port (
		CLK					: in std_logic;
		RST					: in std_logic;
		ADDRESS				: in std_logic_vector(WORD_SIZE - 1 downto 0);
		ENABLE				: in std_logic;
		DATA_READY			: out std_logic;
		DATA				: out std_logic_vector(2*WORD_SIZE - 1 downto 0)
	);
end ROMEM;

architecture Behavioral of ROMEM is
	type RAM is array (0 to ENTRIES-1) of integer;
	signal Memory : RAM;
	signal valid : std_logic;
	signal idout : std_logic_vector(2*WORD_SIZE-1 downto 0);
	--signal count: integer range 0 to (data_delay + 1);

begin

	-- purpose: This process is in charge of filling the Instruction RAM with the firmware
	FILL_MEM_P: process (RST,CLK,ENABLE,ADDRESS)
		file mem_fp: text;
		variable file_line : line;
		variable index : integer := 0;
		variable tmp_data_u : std_logic_vector(WORD_SIZE-1 downto 0);
	begin  -- process FILL_MEM_P
		if (Rst = '1') then
			file_open(
				mem_fp,
				file_path,
				READ_MODE
			);

			while (not endfile(mem_fp)) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				Memory(index) <= conv_integer(unsigned(tmp_data_u));
				index := index + 1;
			end loop;

			file_close(mem_fp);

			--count <= 0;
		
		--elsif CLK'event and clk= '1' then
		--	if (ENABLE = '1' ) then
		--		count <= count + 1;
		--		if (count = data_delay) then
		--			count <= 0;
		--			valid <= '1';
		--			idout <=
		--			conv_std_logic_vector(Memory(conv_integer(unsigned(ADDRESS))+1),WORD_SIZE) &
		--			conv_std_logic_vector(Memory(conv_integer(unsigned(ADDRESS))),WORD_SIZE
		--			);
		--		end if;
		--	else
		--		count <= 0;
		--		valid <= '0';
		--	end if;
		end if;
	end process FILL_MEM_P;

	async_read: process(ENABLE,ADDRESS)
	begin
		if(ENABLE = '1') then
			valid <= '1';
			idout <=
				conv_std_logic_vector(Memory(conv_integer(unsigned(ADDRESS))+1),WORD_SIZE) &
				conv_std_logic_vector(Memory(conv_integer(unsigned(ADDRESS))),WORD_SIZE);
		else
			valid <= '0';
		end if;
	end process;
	

	DATA_READY <= valid after data_delay;
	DATA <= idout when valid = '1' else (others => 'Z') after data_delay;

end Behavioral;
