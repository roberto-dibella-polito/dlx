library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use IEEE.numeric_std.all;
use WORK.all;

-- N,F are power of 2

-- CURRENT USAGE:
-- Asynchronous physical register file

entity  RF_datapath is
  generic ( 
	Nbit : integer := 64; -- Parallelism
	M: integer := 8;      -- Global registers
	N: integer := 8;      -- IN/OUT and LOC registers per window
	F: integer := 8);     -- Number of windows
  port (
	CLK: 		IN std_logic;
	RD_CU: 		IN std_logic;
	WR_CU:		IN std_logic;
    RD1_CPU:	IN std_logic;
	RD2_CPU:	IN std_logic;
	WR_CPU:		IN std_logic;
	EN_CU:		IN std_logic;
    EN_CPU:		IN std_logic;
	ADD_WR:		IN std_logic_vector(NbitAdd-1 downto 0);
	ADD_RD1:	IN std_logic_vector(NbitAdd-1 downto 0);
	ADD_RD2:	IN std_logic_vector(NbitAdd-1 downto 0);

    -- Physical RF 
    RST_RF:	in std_logic;
	DATAIN: 	IN std_logic_vector(Nbit-1 downto 0);
    OUT1: 		OUT std_logic_vector(Nbit-1 downto 0);
	OUT2: 		OUT std_logic_vector(Nbit-1 downto 0);
         
    --Counters signals: inputs
	CNT_SWP, CNT_CWP, CNT_SAVE, CNT_REST, CNT_SPILL_FILL : in std_logic; --Enables
	RST_SWP, RST_CWP, RST_REST, RST_SPILL_FILL : in std_logic; --Resets
	UP_DWN_SWP, UP_DWN_CWP, UP_DWN_SAVE, UP_DWN_REST : in std_logic;--up/down
	LD_SAVE: in std_logic; -- Load
	
	--Counters signals: outputs
	CANSAVE, CANRESTORE,END_SF: out std_logic;

	--Mux
	SEL_WP,CPU_WORK: in std_logic);

end RF_datapath;

architecture BEHAVIOR of RF_datapath is

  --Physical Register file
  component RF_phys 
    generic ( Nbit: integer := 64;
              Nreg: integer := 32;
              NbitAdd: integer := 5);
    port ( CLK: 		IN std_logic;
           RESET:	IN std_logic;
           ENABLE: 	IN std_logic;
           RD1: 	IN std_logic;
           RD2: 	IN std_logic;
           WR: 	    IN std_logic;
           ADD_WR:  IN std_logic_vector(NbitAdd-1 downto 0);
           ADD_RD1: IN std_logic_vector(NbitAdd-1 downto 0);
           ADD_RD2: IN std_logic_vector(NbitAdd-1 downto 0);
           DATAIN: 	IN std_logic_vector(Nbit-1 downto 0);
           OUT1:    OUT std_logic_vector(Nbit-1 downto 0);
           OUT2: 	OUT std_logic_vector(Nbit-1 downto 0));
    
  end component;


  -- Counter
  component counter
    generic ( Nbit: integer := 8 );
    port ( enable, clear_n, load, up_dwn_n, clk: in std_logic;
           D_in: in std_logic_vector(Nbit-1 downto 0);
           Q : inout std_logic_vector(Nbit-1 downto 0));
  end component;

  -- Multiplexer
  component mux2to1 
    generic (N : integer);
    port (IN0,IN1 : in std_logic_vector (N-1 downto 0); --input signals
          SEL: in std_logic; --select signal
          MUX_OUT : out std_logic_vector (N-1 downto 0));--N bits output
  end component;

  component mux2to1_1b 
    port (IN0,IN1 : in std_logic; --input signals
          SEL: in std_logic; --select signal
          MUX_OUT : out std_logic);--1 bit output
  end component;

  -- Address Converter
  component address_converter
    port ( ADDR: in std_logic_vector(NbitAdd-1 downto 0);         --Address seen by CPU
           CWP:  in std_logic_vector(integer(log2(real(F)))-1 downto 0);
           PH_ADDR: out std_logic_vector(NbitAdd_phy-1 downto 0)); --Physical address
  end component;
  
  -- Physical Addresses
  signal addr_rd1_p, addr_rd2_p, addr_w_p : std_logic_vector(NbitAdd_phy-1 downto 0);

  -- Counter signals
  signal CWP, SWP, CANSAVE_out, CANRESTORE_out: std_logic_vector(integer(log2(real(F)))-1 downto 0);
  signal cansave_max : std_logic_vector(integer(log2(real(F)))-1 downto 0); --starting value of cansave counter
  signal cnt_sf_out : std_logic_vector(integer(log2(real(2*N)))-1 downto 0);
  signal cnt_sf_out_zeros: std_logic_vector(NbitAdd - integer(log2(real(2*N)))-1 downto 0);
  signal addr_sf_in : std_logic_vector(NbitAdd-1 downto 0);
  signal spill_fill_addr: std_logic_vector(NbitAdd_phy-1 downto 0);
  signal d_in_cwp : std_logic_vector(integer(log2(real(F)))-1 downto 0);
  signal d_in_sf: std_logic_vector(integer(log2(real(2*N)))-1 downto 0);
 
   --CWP incremented by 1
  signal cwp_1: std_logic_vector(integer(log2(real(F)))-1 downto 0);
  
 -- Window pointer used to make spill and fill operations
  signal sf_wp: std_logic_vector(integer(log2(real(F)))-1 downto 0);

  -- Multiplexer signals
  signal mux_rd_out : std_logic_vector(NbitAdd_phy-1 downto 0);
  signal mux_wr_out : std_logic_vector(NbitAdd_phy-1 downto 0);
  signal mux_rd1_control_out: std_logic;
  signal mux_rd2_control_out: std_logic;
  signal mux_wr_control_out: std_logic;
  signal mux_en_control_out: std_logic;
  
begin

------------------CONVERTERS---------------------

  --RD1 address converter
  Conv_RD1: address_converter port map
    ( ADDR => ADD_RD1,
      CWP => CWP,
      PH_ADDR => addr_rd1_p );

  --RD2  address converter
  Conv_RD2: address_converter port map
    ( ADDR=> ADD_RD2,
      CWP => CWP,
      PH_ADDR => addr_rd2_p );

  --WR address converter
  Conv_W: address_converter port map
    ( ADDR=> ADD_WR,
      CWP => CWP,
      PH_ADDR => addr_w_p );

  cnt_sf_out_zeros <= (others=>'0');  
  addr_sf_in <= cnt_sf_out_zeros & cnt_sf_out;

  -- SPILL/FILL address converter
  SF_converter: address_converter port map
    ( ADDR=> addr_sf_in,
      CWP => sf_wp,
      PH_ADDR => spill_fill_addr ); 

---------------CWP COUNTER---------------

  d_in_cwp <= (others =>'0');

  Cwp_counter: counter generic map(integer(log2(real(F)))) port map
    (enable     => CNT_CWP,
     clear_n    => RST_CWP,
     up_dwn_n   => UP_DWN_CWP,
     load       => '0',
	 D_in 		=> d_in_cwp,
     clk        => CLK,
     Q          => CWP);

-------------------SWP COUNTER ---------------------
  Swp_counter: counter generic map(integer(log2(real(F)))) port map
    (enable     => CNT_SWP,
     clear_n    => RST_SWP,
     load       => '0',
     up_dwn_n   => UP_DWN_SWP,
     clk        => CLK,
     D_in       => d_in_cwp,
     Q          => SWP);

  -------------- SPILL FILL COUNTER --------------

  d_in_sf <= (others=>'0');

  Spill_fill_counter: counter generic map(integer(log2(real(2*N)))) port map
    (enable     => CNT_SPILL_FILL,
     clear_n    => RST_SPILL_FILL,
     load       => '0',
     up_dwn_n   => '1',
     clk        => CLK,
     D_in       => d_in_sf,
     Q          => cnt_sf_out);

  	

  --END_SF status signal generator
  END_SF_gen: process(cnt_sf_out)
  begin
    if(to_integer(unsigned(cnt_sf_out)) = 2*N-1)then
      END_SF <= '1';
    else
      END_SF <= '0';
    end if;
  end process;

  -- CWP incrementer
  cwp1_gen: process(CWP)
  begin
    cwp_1 <= std_logic_vector(unsigned(CWP)+"1");
  end process;


  ----------------------------------CANSAVE GENERATION --------------------------------
  -- Data in for CANSAVE counter
  cansave_max <= std_logic_vector(to_unsigned(F-2,integer(log2(real(F)))));
  
  -- CANSAVE counter
  CANSAVE_counter: counter generic map(integer(log2(real(F)))) port map
    (enable     => CNT_SAVE,
     clear_n    => '1',
     load       => LD_SAVE,
     D_in       => cansave_max,
     up_dwn_n   => UP_DWN_SAVE,
     clk        => CLK,
     Q          => CANSAVE_out);

  -- CANSAVE status signal generator
  Csave_gen: process(CANSAVE_out)
  begin
    if(to_integer(unsigned(CANSAVE_out)) = 0)then
      CANSAVE <= '0';
    else
      CANSAVE <= '1';
    end if;
  end process;
          
  --------------------------------- CANRESTORE GENERATION --------------------------------
  
 --CANSAVE COUNTER
  CANRESTORE_counter: counter generic map(integer(log2(real(F)))) port map
    (enable     => CNT_REST,
     clear_n    => RST_REST,
     load       => '0',
     up_dwn_n   => UP_DWN_REST,
     clk        => CLK,
     D_in       => d_in_cwp,
     Q          => CANRESTORE_out);

  --CANRESTORE flag generator
  CANRESTORE_gen: process(CANRESTORE_out)
  begin
    if(to_integer(unsigned(CANRESTORE_out)) = 0)then
      CANRESTORE <= '0';
    else
      CANRESTORE <= '1';
    end if;
  end process;

  

--------------------------------- MULTIPLEXERS -----------------------------------------
  
 -- RD1 address selector
 Mux_rd: mux2to1 generic map( N => NbitAdd_phy ) port map  
  (
    IN0 => spill_fill_addr,
    IN1 => addr_rd1_p,
    SEL => CPU_WORK,
    MUX_OUT => mux_rd_out );

 -- WR address selector
  Mux_wr: mux2to1 generic map( N => NbitAdd_phy ) port map  
  ( 
    IN0 => spill_fill_addr,
    IN1 => addr_w_p,
    SEL => CPU_WORK,
    MUX_OUT => mux_wr_out );

  -- WP selector for SPILL and FILL operations
  Mux_sf: mux2to1 generic map( N => integer(log2(real(F))) ) port map  
    ( IN0 => CWP,
      IN1 => cwp_1,
      SEL => SEL_WP,
      MUX_OUT => sf_wp );

   -- RD1 control  selector
 Mux_rd1_control: mux2to1_1b port map  
  ( IN0 => RD_CU,
    IN1 => RD1_CPU,
    SEL => CPU_WORK,
    MUX_OUT =>mux_rd1_control_out);

   -- RD2 control selector
 Mux_rd2_control: mux2to1_1b port map  
  ( IN0 => '0',
    IN1 => RD2_CPU,
    SEL => CPU_WORK,
    MUX_OUT =>mux_rd2_control_out);

 -- WR control selector
  Mux_wr_control: mux2to1_1b port map  
  ( IN0 => WR_CU,
    IN1 => WR_CPU,
    SEL => CPU_WORK,
    MUX_OUT =>mux_wr_control_out);

  -- ENABLE control selector
  Mux_en_control: mux2to1_1b port map  
  ( IN0 => EN_CU,
    IN1 => EN_CPU,
    SEL => CPU_WORK,
    MUX_OUT =>mux_en_control_out);

  ---------------------------------- PHYSICAL REGISTER FILE -------------------------------------

  Physical_RF: RF_phys generic map ( Nbit => Nbit,  Nreg => 2*N*F+M, NbitAdd => NbitAdd_phy) port map
  ( CLK         => CLK,
    RESET       => RST_RF,
    ENABLE 	=> mux_en_control_out,
    RD1 	=> mux_rd1_control_out,
    RD2         => mux_rd2_control_out,	
    WR          => mux_wr_control_out,
    ADD_WR      => mux_wr_out,
    ADD_RD1 	=> mux_rd_out,
    ADD_RD2     => addr_rd2_p,
    DATAIN      => DATAIN,
    OUT1        => OUT1,
    OUT2        => OUT2 );     
  
  
  
end BEHAVIOR;
