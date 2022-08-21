-- Counter
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.constants.all;
use WORK.all;

entity counter is
  generic ( Nbit: integer := 8 );
  port ( enable, clear_n, load, up_dwn_n, clk: in std_logic;
         D_in: in std_logic_vector(Nbit-1 downto 0);
         Q : inout std_logic_vector(Nbit-1 downto 0));
         
end counter;

architecture BEHAVIOR of counter is

begin

  Count: process(clk)
  begin

    if(clk'event and clk = '1') then

      --Synch Reset control
      if(clear_n = '0') then
        Q <= (others=>'0');

      elsif(load = '1') then
            Q <= D_in;
            
      elsif(enable = '1') then          
          
       	  if(up_dwn_n = '1') then --Up counter
            Q <= std_logic_vector((unsigned(Q))+"1");
          else --Down Counter
            Q <= std_logic_vector(unsigned(Q)-"1");
          end if;
	  end if;

    end if;   



  end process;

end BEHAVIOR;
        


                    
         
