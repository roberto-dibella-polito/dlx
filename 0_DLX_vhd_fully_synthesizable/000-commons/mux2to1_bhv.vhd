LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


-- a N bits multiplexer 2to1


entity mux2to1 is 
	generic (N : integer);
	port (
		IN0,IN1	: in std_logic_vector (N-1 downto 0); --input signals
		SEL		: in std_logic; --select signal
		MUX_OUT	: out std_logic_vector (N-1 downto 0));--N bits output
end mux2to1;

architecture behavior of mux2to1 is
  
BEGIN
  with SEL select
    MUX_OUT <=
    IN0 when '0',
    IN1 when others;

END behavior;
