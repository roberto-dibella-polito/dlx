----------------------------------------------------------------
-- CLOCK GENERATOR
-- Modified version of the "clk_gen.vhd" example code.
-- Generates a clock signal of period Ts.
--
-- Project: Lab 2
-- Authors: Group 32 (Chatrasi, Di Bella, Zangeneh)
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clk_gen is
  port (
    END_SIM : in  std_logic;
    CLK     : out std_logic);
end clk_gen;

architecture bhv of clk_gen is

  constant Ts : time := 10 ns;	-- Period
  
  signal CLK_i : std_logic;
  
begin  -- beh

  clock: process
  begin  -- process
    if (CLK_i = 'U') then
      CLK_i <= '0';
    else
      CLK_i <= not(CLK_i);
    end if;
    wait for Ts/2;
  end process clock;

  CLK <= CLK_i and not(END_SIM);

end bhv;
