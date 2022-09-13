library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use WORK.all;

-- ATTENTION: 
-- works only with N,F as power of 2!

entity address_converter is
  --generic( M,N,F : integer := 2 );
  port ( ADDR: in std_logic_vector(NbitAdd-1 downto 0);         --Address seen by CPU
         CWP:  in std_logic_vector(integer(log2(real(F)))-1 downto 0);
         PH_ADDR: out std_logic_vector(NbitAdd_phy-1 downto 0));
end address_converter;

architecture behavior of address_converter is

  signal CWP_i: unsigned(NbitAdd_phy-1 downto 0);
  signal pre_ph_addr: std_logic_vector(NbitAdd_phy-1 downto 0);
  signal zeros : std_logic_vector(NbitAdd_phy-NbAddPart-1 downto 0);
  
begin

  -- Moltiplicazione tra INTEGER
  -- to_unsigned(to_integer(unsigned(CWPi))*2*N,log2(2*N*F))

  CWP_i <= to_unsigned(to_integer(unsigned(CWP))*2*N,NbitAdd_phy);
  zeros <= (others=>'0');
  pre_ph_addr <= std_logic_vector(unsigned(ADDR) + CWP_i);
  
  Ph_generator: process(CWP_i,ADDR,zeros,pre_ph_addr)
  begin

    if( ADDR < 3*N ) then
   
      PH_ADDR <= zeros & pre_ph_addr(NbAddPart-1 downto 0);
      
    else --Accessing global variable

      PH_ADDR <= std_logic_vector(to_unsigned(to_integer(unsigned(ADDR)) + 2*N*F - 3*N,NbitAdd_phy));

    end if;

    end process;


  end behavior;


  
  
         
