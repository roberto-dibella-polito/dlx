library IEEE;
use IEEE.math_real.all;

package CONSTANTS is
 
  constant Nbit: integer := 8;
  constant M : integer :=4;
  constant N : integer :=2;
  constant F : integer :=4;

  -- CPU ADDRESS
  -- CPU "sees", for each call:
  -- M global   registers
  -- N input    registers
  -- N output
  -- N locals
  -- = 3*N+M number of addressable cells
  
  constant NbitAdd: integer := integer(ceil(log2(real(3*N+M))));

  -- PHYSICAL ADDRESS
  -- Address of physical registers inside the RF.
  -- Considering:
  --  each window composed by an IN/OUT and a LOC block,
  --  M global registers,
  --  F windows
  --  = 2*N*F + M

  constant NbitAdd_phy : integer := integer(ceil(log2(real(2*N*F+M))));

  -- PARTIAL ADDRESS
  -- Computed without considering global registers

  constant NbAddPart: integer := integer(ceil(log2(real(2*N*F))));

end CONSTANTS;
