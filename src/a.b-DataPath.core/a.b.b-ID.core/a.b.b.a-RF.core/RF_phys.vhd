library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use WORK.all;

entity RF_phys is
  generic ( Nbit: integer := 64;
            Nreg: integer := 32;
            NbitAdd: integer := 5);
  port ( CLK: 		IN std_logic;
         RESET: 	IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(NbitAdd-1 downto 0);
	 ADD_RD1: 	IN std_logic_vector(NbitAdd-1 downto 0);
	 ADD_RD2: 	IN std_logic_vector(NbitAdd-1 downto 0);
	 DATAIN: 	IN std_logic_vector(Nbit-1 downto 0);
         OUT1: 		OUT std_logic_vector(Nbit-1 downto 0);
	 OUT2: 		OUT std_logic_vector(Nbit-1 downto 0));
end RF_phys;


architecture BEHAVIOR of RF_phys is

  -- suggested structures
  subtype REG_ADDR is integer range 0 to Nreg-1; -- using natural type
  type REG_ARRAY is array(REG_ADDR) of std_logic_vector(Nbit-1 downto 0); 
  signal REGISTERS : REG_ARRAY; 

  
begin 
-- write your RF code 



  p0: process (CLK) is
  begin
    if CLK = '1' and CLK'event then
      if RESET='1' then
        REGISTERS <= (others => (others =>'0'));
        OUT1 <= (others =>'0');
        OUT2 <= (others =>'0');
      elsif ENABLE = '1'then
        if WR = '1' then REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; 
        end if;
        if RD1 = '1' then  OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))); 
        end if;
        if RD2 = '1' then  OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))); 
        end if;
      end if;
    end if;
  end process p0;

end BEHAVIOR;
