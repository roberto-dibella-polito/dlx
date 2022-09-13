-- prova
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prova is
end entity;

architecture bhv of prova is

	signal a,b			: std_logic_vector(3 downto 0);
	signal clk,rst,en	: std_logic;

begin
	
	rst <= '1', '0' after 2 ns;
	
	clk <= not clk after 5 ns;
	en <= '0';
	a <= x"A";

	reg: process(clk, rst)
	begin
		
		if(rst = '1') then
			b <= x"0";
		elsif( clk'event and clk = '1' ) then
			if(en = '1') then
				b <= a;
			end if;
		end if;
	end process;

end bhv;
