library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

-- General Propagate and General Generate generation block

entity PG_BLOCK is
  port( p_in, p_prev, g_in, g_prev: in  std_logic;
        p_out, g_out:               out std_logic );
end PG_BLOCK;

architecture STRUCTURE of PG_BLOCK is
begin
  p_out <= p_in and p_prev;

  g_out <= g_in or (p_in and g_prev);

end STRUCTURE;
