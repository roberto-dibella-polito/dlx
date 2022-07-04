library IEEE;
use IEEE.std_logic_1164.all;

-- Flip Flop D with:
-- Synchronous reset active low
-- Synchronous preset active low

entity FD is
	Port (	D:	        In	std_logic;
		CK:	        In	std_logic;
		RESET_n:        In	std_logic;
                PRESET_n:       in      std_logic;
		Q:	        Out	std_logic);
end FD;


architecture BHV of FD is -- flip flop D with syncronous reset

begin
  PSYNCH: process(CK,RESET_n,PRESET_n)
  begin
    if CK'event and CK='1' then -- positive edge triggered:
      if RESET_n='0' then -- active low reset 
        Q <= '0'; 
      elsif  PRESET_n = '0' then
        Q <= '1';
      else
        Q <= D; -- input is written on output
      end if;
    end if;   
  end process;

end BHV;



