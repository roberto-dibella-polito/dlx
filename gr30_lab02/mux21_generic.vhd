library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all; 

entity  MUX21_GENERIC is
Generic ( N: integer:= numBit;
	  DELAY_MUX: Time:= tp_mux);
Port (	A:	In	std_logic_vector(N-1 downto 0) ;
	B:	In	std_logic_vector(N-1 downto 0);
	SEL:	In	std_logic;
	Y:	Out	std_logic_vector(N-1 downto 0));
end MUX21_GENERIC;


--Behavioral 
architecture BEHAVIOR of MUX21_GENERIC is
begin

  Y <= A when SEL='1' else B;
  
end BEHAVIOR;


--Structural
architecture STRUCTURE of MUX21_GENERIC is

   --Y <= (A and SEL) or (B and (not SEL));
   component MUX21
     Port (	A:	In	std_logic;
                B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
   end component;

   begin
     G1: for i in 0 to N-1 generate
       Mux: MUX21 port map
         (      A => A(i),
                B => B(i),
                S => SEL,
                Y => Y(i));
       end generate;

end STRUCTURE;



configuration CFG_MUX21_GEN_BEHAVIORAL of MUX21_GENERIC is
  for BEHAVIOR
  end for;
end CFG_MUX21_GEN_BEHAVIORAL;

configuration CFG_MUX21_GEN_STRUCTURAL of MUX21_GENERIC is
  for STRUCTURE
    end for;
end CFG_MUX21_GEN_STRUCTURAL;
