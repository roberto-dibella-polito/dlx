library IEEE;
use IEEE.std_logic_1164.all;
--use work.constants.all;

-- General Generate generation block

entity G_BLOCK is
  port( p,g,c_in: in  std_logic;
        c_out:    out std_logic );
end G_BLOCK;

architecture STRUCTURE of G_BLOCK is
begin

  c_out <= g or (p and c_in);

end STRUCTURE;


