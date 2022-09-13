LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


-- a 1 bit multiplexer 2to1


entity mux2to1_1b is 
  port (IN0,IN1 : in std_logic; --input signals
        SEL: in std_logic; --select signal
        MUX_OUT : out std_logic);--1 bit output
end mux2to1_1b;

architecture behavior of mux2to1_1b is
  
BEGIN
  with SEL select
    MUX_OUT <=
    IN0 when '0',
    IN1 when others;

END behavior;
