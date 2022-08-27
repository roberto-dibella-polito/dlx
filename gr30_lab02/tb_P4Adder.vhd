library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_signed.all;
use WORK.constants.all;

entity tb_P4 is
end tb_P4;


architecture TEST of tb_P4 is


  constant NBit : integer := 32;    -- :=16  --:=32    

  --  input	 
  signal A_mp_i : std_logic_vector(NBit-1 downto 0) := (others => '0');
  signal B_mp_i : std_logic_vector(NBit-1 downto 0) := (others => '0');
  signal S_mp_i : std_logic_vector(NBit-1 downto 0) := (others => '0');
  signal Cin_mp_i: std_logic := '0';
  signal sub_add_n: std_logic := '0';

  -- output
  signal Cout_mp_i : std_logic := '0';


-- P4 component declaration

component P4
  generic(Nbit: integer := 32);
  port   (A             : in std_logic_vector(Nbit-1 downto 0);
          B             : in std_logic_vector(Nbit-1 downto 0);
          Cin           : in std_logic;
          Cout          : out std_logic;
          SUB_ADD_n     : in std_logic;              
          Sum           : out std_logic_vector(Nbit-1 downto 0));
end component;


begin

-- P4 instantiation
  
  DUT: P4 generic map (Nbit=> NBit)
    Port map
    ( A         => A_mp_i,
      B         => B_mp_i,
      Cin       => Cin_mp_i,
      SUB_ADD_n => sub_add_n,
      Sum       => S_mp_i,
      Cout      => Cout_mp_i);
      
-- PROCESS FOR TESTING DUT-
  test: process
  begin

    sub_add_n <= '0';
    A_mp_i <= "00000000000000000000000000000101";
    B_mp_i <= "00000000000000000000000000000011";

    wait for 50 ns;

    sub_add_n <= '1';

    wait for 50 ns;

    sub_add_n <= '0';

    A_mp_i <= "11111111111111111111111111111111";
    B_mp_i <= "00000000000000000000000000000001";

   -- wait for 50 ns;

   -- A_mp_i <= "10011000";
   -- B_mp_i <= "11111111";

    wait;
  end process test;


end TEST;
