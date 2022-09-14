library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

-- RIPPLE CARRY ADDER - N BITS

entity RCA is 
	generic (--DRCAS  : 	Time := 0 ns;   --Delay for sum
	         --DRCAC  : 	Time := 0 ns;
                 Nbit   :       Integer := 6);  --Delay for carry
	Port (	A:	In	std_logic_vector(Nbit-1 downto 0);
		B:	In	std_logic_vector(Nbit-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(Nbit-1 downto 0);
		Co:	Out	std_logic);
end RCA; 

architecture BEHAVIORAL of RCA is

  signal S_n    : std_logic_vector(Nbit downto 0);
  signal Ci_append   : std_logic_vector(Nbit-2 downto 0);
  
begin

	Ci_append <= (others => '0');
  
 	S_n   <= (('0'&A) + ('0'&B) + (Ci_append&Ci));
	Co    <= S_n(Nbit);
	S     <= S_n(Nbit-1 downto 0);
  
end BEHAVIORAL;


--configuration CFG_RCA_STRUCTURAL of RCA is
--  for STRUCTURAL 
--    for ADDER1
--      for all : FA
--        use configuration WORK.CFG_FA_BEHAVIORAL;
--      end for;
--    end for;
-- end for;
--end CFG_RCA_STRUCTURAL;

configuration CFG_RCA_BEHAVIORAL of RCA is
  for BEHAVIORAL 
  end for;
end CFG_RCA_BEHAVIORAL;
