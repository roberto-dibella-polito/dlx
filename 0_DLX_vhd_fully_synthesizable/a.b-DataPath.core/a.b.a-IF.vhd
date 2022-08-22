--	DLX
--	Instruction Fetch phase

--	Sub-blocks:
--	.Program counter	-> 	ALREADY DEFINED into a-DLX.vhd
--							Moved here for simplicity
--	.Incrementer		->	increments the PC by 4
--	.Multiplexer		->	Chooses between the next PC and a jump
--	.Instruction Mem	->	INTERFACE ONLY

library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use work.ROCACHE_PKG.all;

entity DLX_IF is
	generic (
    	IR_SIZE      : integer := 32;       -- Instruction Register Size
    	PC_SIZE      : integer := 32       -- Program Counter Size
    );
	port(
		CLK			: in std_logic;
		RST			: in std_logic;			-- Active LOW
		
		-- Instruction Memory interface
		IRAM_ADDRESS			: out std_logic_vector(Instr_size - 1 downto 0);
		--IRAM_ISSUE				: out std_logic;
		--IRAM_READY				: in std_logic;
		IRAM_DATA				: in std_logic_vector(2*Data_size-1 downto 0);
		
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
end DLX_IF;

architecture structure of DLX_IF is

	component mux2to1 is 
		generic (N : integer);
		port (IN0,IN1 : in std_logic_vector (N-1 downto 0); --input signals
			SEL: in std_logic; --select signal
			MUX_OUT : out std_logic_vector (N-1 downto 0));--N bits output
	end component;
	
	signal PC_i, NPC_4_i, NPC_OUT_i	: std_logic_vector(PC_SIZE-1 downto 0);
	
begin

	--------------------------------------
	--	PROGRAM COUNTER register		--
	--------------------------------------
	-- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC_BUS
    -- outputs: IRam_Addr
	--------------------------------------
    PC: process (Clk, Rst)
    begin  -- process PC_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        PC_i <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (PC_LATCH_EN = '1') then
          PC_i <= NPC_OUT_i;
        end if;
      end if;
    end process PC;
	
	-------------------------------------
	-- INCREMENTER
	-------------------------------------
	NPC_4_i <= PC_i + 4;
	
	-------------------------------------
	-- MULTIPLEXER
	-------------------------------------
	mux: generic map( N => PC_SIZE ) port map(
		IN0 => NPC_4_i,
		IN1	=> NPC_ALU,
		SEL	=> NPC_SEL,
		MUX_OUT	=> NPC_OUT_i );
		
	NPC_OUT <= NPC_OUT_i;
	
	-------------------------------------
	-- Instruction Memory Interface
	-------------------------------------
	IRAM_ADDRESS <= PC_i;
	INSTR <= IRAM_DATA;

end structure;