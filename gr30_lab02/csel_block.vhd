library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

-- CARRY-SELECT BLOCK

entity CS_BLOCK is
  
  generic ( N : integer := 8 );

  port (
    A   : in std_logic_vector(N-1 downto 0);
    B   : in std_logic_vector(N-1 downto 0);
    Cin : in std_logic;
    S   : out std_logic_vector(N-1 downto 0));

end CS_BLOCK;


architecture STRUCTURE  of CS_BLOCK is

  signal rca_out0 : std_logic_vector(N-1 downto 0);
  signal rca_out1 : std_logic_vector(N-1 downto 0);

  -- Ripple-Carry Adder
  component RCA  
      generic (DRCAS  : 	Time := 0 ns;   --Delay for sum
	       DRCAC  : 	Time := 0 ns;
               Nbit   :       Integer := 6);  --Delay for carry
	Port (	A:	In	std_logic_vector(Nbit-1 downto 0);
                B:	In	std_logic_vector(Nbit-1 downto 0);
                Ci:	In	std_logic;
                S:	Out	std_logic_vector(Nbit-1 downto 0);
                Co:	Out	std_logic);
     
  end component RCA;

  -- MUX 2 to 1
  component MUX21_GENERIC 
    Generic ( N: integer:= numBit;
              DELAY_MUX: Time:= tp_mux);
    Port (	A:	In	std_logic_vector(N-1 downto 0) ;
                B:	In	std_logic_vector(N-1 downto 0);
                SEL:	In	std_logic;
                Y:	Out	std_logic_vector(N-1 downto 0));
  end component MUX21_GENERIC;

  
  
begin  -- architecture STRUCTURE 

  RCA0: RCA generic map(Nbit => N)
    port map
    ( A => A,
      B => B,
      Ci => '0',
      S => rca_out0 );

  RCA1: RCA generic map(Nbit => N)
    port map
    ( A => A,
      B => B,
      Ci => '1',
      S => rca_out1 );

  Mux: MUX21_GENERIC generic map(N => N)
    port map
    ( A => rca_out1,
      B => rca_out0,
      SEL => Cin,
      Y => S );

end architecture STRUCTURE ;
    
