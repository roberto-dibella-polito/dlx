library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity bubble_generator is
	generic(
		OPCODE_SIZE		: integer := 6;
		REG_ADDR_SIZE	: integer := 5	);
	port(
		CLK				: in std_logic;
		RST				: in std_logic;	-- Active:High
		ENABLE			: in std_logic;
		OPCODE			: in std_logic_vector(OPCODE_SIZE-1 downto 0);	
		OPCODE_1		: in std_logic_vector(OPCODE_SIZE-1 downto 0);		
		BUBBLE_EN		: out std_logic
	);
end entity;

architecture structure of bubble_generator is
	
	component counter_ar is
		generic ( Nbit: integer := 8 );
		port ( 
			enable		: in std_logic;
			rst			: in std_logic;		-- Asynchronous reset, Active:High
			clear_n		: in std_logic;		-- synchronous reset, active:Low
			load		: in std_logic;
			up_dwn_n	: in std_logic;
			clk			: in std_logic;
			D_in		: in std_logic_vector(Nbit-1 downto 0);
			Q 			: inout std_logic_vector(Nbit-1 downto 0));
	end component;
	
	signal enable_i, clear_i, cap_i	: std_logic;
	signal nBubbles					: std_logic_vector(1 downto 0);
	signal count					: std_logic_vector(1 downto 0);

begin
	
	enable_i <= '1' when( OPCODE = SW_OP and OPCODE_1 = SW_OP ) else '0';

	nBubbles <= "01" when( OPCODE = SW_OP and OPCODE_1 = SW_OP ) else "00";

	cnt: counter_ar generic map ( Nbit => 2 )
	port map ( 
		enable		=> enable_i,
		rst			=> RST,			-- Asynchronous reset, Active:High
		clear_n		=> clear_i,		-- synchronous reset, active:Low
		load		=> '0',
		up_dwn_n	=> '1',
		clk			=> CLK,
		D_in		=> "00",
		Q 			=> count
	);

	cap_i		<= '1' when COUNT = nBubbles else '0';
	clear_i		<= not cap_i;
	
	BUBBLE_EN	<= (not cap_i) and enable_i;

end structure;
