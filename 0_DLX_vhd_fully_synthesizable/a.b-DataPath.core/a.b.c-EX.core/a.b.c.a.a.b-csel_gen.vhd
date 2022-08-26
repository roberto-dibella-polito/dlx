library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

-- CARRY-SELECT SUM GENERATOR

entity CS_SUM is

  generic( Nbit : integer := 8; N : integer := 4 );

  -- Nbit: Number of bits of operands
  -- N:Number of bits of each Carry Select Block
  -- C : CARRIES
  -- We have a number of carries equal to Nbit/N
  
  port (
    CN : in std_logic_vector((Nbit/N-1) downto 0);  --Carry N per time
    A : in std_logic_vector(Nbit-1 downto 0);      --Operand 1
    B : in std_logic_vector(Nbit-1 downto 0);      --Operand 2
    S : out std_logic_vector(Nbit-1 downto 0) );   --Sum

end CS_SUM;

architecture STRUCTURE of CS_SUM is

  component CS_BLOCK is
	generic ( N : integer := 4 );
	port (
		A   : in std_logic_vector(N-1 downto 0);
		B   : in std_logic_vector(N-1 downto 0);
		Cin : in std_logic;
		S   : out std_logic_vector(N-1 downto 0));
  end component;

begin

  CS_Blocks: for i in 0 to Nbit/N-1 generate

    --Nbit/N block of N bits each
    CS_Bn : CS_BLOCK generic map (N => N)
      port map (
        A => A(i*N+N-1 downto i*N),
        B => B(i*N+N-1 downto i*N),
        Cin => CN(i),
        S => S(i*N+N-1 downto i*N));
    end generate;

end STRUCTURE;
