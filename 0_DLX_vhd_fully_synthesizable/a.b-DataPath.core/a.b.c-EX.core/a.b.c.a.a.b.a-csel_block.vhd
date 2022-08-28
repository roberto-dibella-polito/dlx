library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
--use work.constants.all;

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
	component mux2to1 
		generic (N : integer);
		port (
			IN0,IN1	: in std_logic_vector (N-1 downto 0); --input signals
			SEL		: in std_logic; --select signal
			MUX_OUT	: out std_logic_vector (N-1 downto 0));--N bits output
	end component;
  
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

  Mux: mux2to1 generic map(N => N)
    port map
    ( IN1		=> rca_out1,
      IN0		=> rca_out0,
      SEL		=> Cin,
      MUX_OUT	=> S );

end architecture STRUCTURE ;
    
