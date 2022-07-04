library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

  -- 3-bit RING COUNTER
  -- Only one bit is set to 1 and always shifts.
  -- At each clock cycle:
  -- RESET:     Q = "100"
  --            Q = "001"
  --            Q = "010"
  --            Q = "100"
  --            ...and so on.

entity ring_counter is
  port( CLK,RESET : in std_logic;
        Q         : inout std_logic_vector(2 downto 0));
end ring_counter;

architecture STRUCTURE of ring_counter is

  component FD
    Port (	D:	        In	std_logic;
		CK:	        In	std_logic;
		RESET_n:        In	std_logic;
        PRESET_n:       in      std_logic;
		Q:	        Out	std_logic);
  end component;

begin

  F0: FD port map
    ( D => Q(2),
      CK => CLK,
      RESET_n => RESET,
      PRESET_n => '1',
      Q => Q(0) );

  F1: FD port map
    ( D => Q(0),
      CK => CLK,
      RESET_n => RESET,
      PRESET_n => '1',
      Q => Q(1) );
  
  F2: FD port map
    ( D => Q(1),
      CK => CLK,
      RESET_n => '1',
      PRESET_n => RESET,
      Q => Q(2) );
  
end STRUCTURE;
