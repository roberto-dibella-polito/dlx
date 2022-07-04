library IEEE;
use IEEE.std_logic_1164.all;

entity reg_n is
  GENERIC 	( N : INTEGER := 6 );
  PORT		( A : in std_logic_vector (N-1 downto 0);
                  Q : out std_logic_vector (N-1 downto 0);
                  CLK	: in Std_logic;
                  RST_n	: In std_logic );
end reg_n;

-- Synchronous reset
architecture BHV of reg_n is
  
begin
  FF: process(CLK)
  begin
    if CLK'event and CLK = '1' then
      if (RST_n = '0') then
        Q <= (others=>'0');
      else
        Q <= A;
      end if;
    end if;
  end process;
                            
end BHV;

		
  
