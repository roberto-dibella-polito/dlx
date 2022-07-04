library IEEE;
use IEEE.std_logic_1164.all;

entity reg_n is
  generic (N : integer := 8);
  port (A   : in     std_logic_vector (N-1 downto 0);
        Q   : buffer std_logic_vector (N-1 downto 0);
        CLK : in     std_logic;
        RST : in     std_logic);
end reg_n;


architecture BEHAVIOR of reg_n is

begin

  process (CLK, RST)
  begin
    if (RST = '0') then
      Q <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      Q <= A;
    end if;

end process;

end BEHAVIOR;


