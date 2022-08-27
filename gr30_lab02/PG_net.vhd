library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

-- PG Network basic block
-- Representation of sum and carry ad generate and propagate

entity PG_NET is
  port( A:  in std_logic;
        B:  in std_logic;
        p:  out std_logic;
        g: out std_logic );
end PG_NET;


architecture STRUCT_PG_1 of PG_NET is

  
begin

  p <= a xor b; -- Propagate
  g <= a and b; -- Generate

end STRUCT_PG_1;


configuration CFG_STRUCT_PG_1 of PG_NET is
  for STRUCT_PG_1
  end for;
end CFG_STRUCT_PG_1;

  
