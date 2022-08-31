library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use IEEE.numeric_std.all;
use WORK.all;

-- Windowed Register File example
	
-- Constants:
-- M = 4 Globals
-- N = 2 Number of IN/LOC/OUT registers
-- F = 4 Windows
  
-- PHYSICAL RF                       ACTIVE WINDOW
--  _________                          _________
-- |  IN/OUT | <- 0 - W0              |   IN    | <- 0
-- |_________| <- 1                   |_________| <- 1
-- |   LOC   | <- 2                   |   LOC   | <- 2 
-- |_________| <- 3                   |_________| <- 3 
-- |  IN/OUT | <- 4 - W1              |   OUT   | <- 4             
-- |_________| <- 5                   |_________| <- 5 
-- |   LOC   | <- 6                   | GLOBALS | <- 6
-- |_________| <- 7                   |         | <- 7
-- |  IN/OUT | <- 8 - W2              |         | <- 8   
-- |_________| <- 9                   |_________| <- 9
-- |   LOC   | <- 10 
-- |_________| <- 11
-- |  IN/OUT | <- 12 - W3
-- |_________| <- 13 
-- |   LOC   | <- 14
-- |_________| <- 15
-- | GLOBALS | <- 16 
-- |         | <- 17
-- |         | <- 18
-- |_________| <- 19


entity RF is
  generic (Nbit : integer := 64;  -- Parallelism
           M    : integer := 8;  -- Global registers
           N    : integer := 8;  -- IN/OUT and LOC registers per window
           F    : integer := 8);     -- Number of windows
  port (CLK     : IN  std_logic;
        RESET   : IN  std_logic;
        CALL    : IN  std_logic;
        RET     : IN  std_logic;
        SPILL   : OUT std_logic;
        FILL    : OUT std_logic;
        ENABLE  : IN  std_logic;
        RD1     : IN  std_logic;
        RD2     : IN  std_logic;
        WR      : IN  std_logic;
        ADD_WR  : IN  std_logic_vector(NbitAdd-1 downto 0);
        ADD_RD1 : IN  std_logic_vector(NbitAdd-1 downto 0);
        ADD_RD2 : IN  std_logic_vector(NbitAdd-1 downto 0);
        DATAIN  : IN  std_logic_vector(Nbit-1 downto 0);
        OUT1    : OUT std_logic_vector(Nbit-1 downto 0);
        OUT2    : OUT std_logic_vector(Nbit-1 downto 0));
end RF;


architecture STRUCTURE of RF is

  component RF_datapath
    generic (Nbit : integer := 64;  -- Parallelism
             M    : integer := 8;  -- Global registers
             N    : integer := 8;  -- IN/OUT and LOC registers per window
             F    : integer := 8);     -- Number of windows
    port (
      
      CLK: 		IN std_logic;
      RD_CU: 	IN std_logic;
      WR_CU:	IN std_logic;
      RD1_CPU:  IN std_logic;
      RD2_CPU:  IN std_logic;
      WR_CPU:   IN std_logic;
      EN_CU:	IN std_logic;
      EN_CPU:	IN std_logic;
      ADD_WR:	IN std_logic_vector(NbitAdd-1 downto 0);
      ADD_RD1:	IN std_logic_vector(NbitAdd-1 downto 0);
      ADD_RD2:	IN std_logic_vector(NbitAdd-1 downto 0);

      -- Physical RF 
      RST_RF:	in std_logic;
      DATAIN:	IN std_logic_vector(Nbit-1 downto 0);
      OUT1:		OUT std_logic_vector(Nbit-1 downto 0);
      OUT2:		OUT std_logic_vector(Nbit-1 downto 0);
      
      --Counters signals: inputs
      CNT_SWP, CNT_CWP, CNT_SAVE, CNT_REST, CNT_SPILL_FILL : in std_logic; --Enables
      RST_SWP, RST_CWP, RST_REST, RST_SPILL_FILL : in std_logic; --Resets
      UP_DWN_SWP, UP_DWN_CWP, UP_DWN_SAVE, UP_DWN_REST : in std_logic;--up/down
      LD_SAVE: in std_logic; -- Load

      --Counters signals: outputs
      CANSAVE, CANRESTORE,END_SF: out std_logic;

      --Mux
      SEL_WP,CPU_WORK: in std_logic);

  end component;

  
  component RF_CU 
    port (CLK       : in  std_logic;
          RESET     : in  std_logic;
          CALL      : in  std_logic;
          RET       : in  std_logic;
          RD_CU     : out std_logic;
          WR_CU     : out std_logic;
          SPILL     : out std_logic;
          FILL      : out std_logic;
          RF_ENABLE : out std_logic;
          RST_RF    : out std_logic;

          --Counters signals: inputs
          CNT_SWP, CNT_CWP, CNT_SAVE, CNT_REST, CNT_SPILL_FILL : out std_logic;  --Enables
          RST_SWP, RST_CWP, RST_REST, RST_SPILL_FILL           : out std_logic;  --Resets
          UP_DWN_SWP, UP_DWN_CWP, UP_DWN_SAVE, UP_DWN_REST     : out std_logic;  --up/down
          LD_SAVE                                              : out std_logic;  -- Load

          --Counters signals: outputs
          CANSAVE, CANRESTORE, END_SF : in std_logic;

          --Mux
          SEL_WP, CPU_WORK : out std_logic);
  end component;


  signal rd_cu, wr_cu, rf_enable, rst_rf, cnt_swp, cnt_cwp, cnt_save, cnt_rest, cnt_spill_fill, rst_swp, rst_cwp, rst_rest, rst_spill_fill: std_logic;
  signal up_dwn_swp, up_dwn_cwp, up_dwn_save, up_dwn_rest, ld_save, cansave,canrestore, end_sf, sel_wp, cpu_work: std_logic; 



BEGIN
  
  ------------------------------------------------------------ CONTROL UNIT--------------------------------------------------------------------

  ControlUnit: RF_CU port map
    ( CLK     => CLK ,
      RESET     => RESET,
      CALL      => CALL,
      RET       => RET,
      RD_CU     => rd_cu,
      WR_CU     => wr_cu,
      SPILL     => SPILL,
      FILL      =>FILL,
      RF_ENABLE => rf_enable,
      RST_RF    => rst_rf,

      --Counters signals: inputs
      CNT_SWP => cnt_swp, CNT_CWP => cnt_cwp, CNT_SAVE => cnt_save, CNT_REST => cnt_rest, CNT_SPILL_FILL => cnt_spill_fill,--Enables
      RST_SWP => rst_swp, RST_CWP => rst_cwp, RST_REST => rst_rest, RST_SPILL_FILL => rst_spill_fill,  --Resets
      UP_DWN_SWP => up_dwn_swp, UP_DWN_CWP => up_dwn_cwp, UP_DWN_SAVE => up_dwn_save, UP_DWN_REST => up_dwn_rest, --up/down
      LD_SAVE => ld_save, -- Load

      --Counters signals: outputs
      CANSAVE => cansave, CANRESTORE => canrestore, END_SF => end_sf,

      --Muxes signals
      SEL_WP => sel_wp ,CPU_WORK => cpu_work );


  ------------------------------------------------------------------- DATA PATH ---------------------------------------------------------------------------------

  DataPath: RF_datapath generic map (Nbit => Nbit, M => M, N => N, F => F) port map
    (  CLK => CLK,
       RD_CU =>rd_cu,
       WR_CU => wr_cu,
       RD1_CPU => RD1,
       RD2_CPU => RD2,
       WR_CPU => WR,   
       EN_CU => rf_enable, 
       EN_CPU => ENABLE,      
       ADD_WR => ADD_WR,  	
       ADD_RD1 => ADD_RD1,  	
       ADD_RD2 => ADD_RD2, 	

       -- Physical RF 
       RST_RF => rst_rf,      
       DATAIN => DATAIN, 
       OUT1 => OUT1, 
       OUT2 => OUT2, 
       
       --Counters signals: inputs
       CNT_SWP => cnt_swp, CNT_CWP => cnt_cwp, CNT_SAVE => cnt_save, CNT_REST => cnt_rest, CNT_SPILL_FILL => cnt_spill_fill,--Enables
       RST_SWP => rst_swp, RST_CWP => rst_cwp, RST_REST => rst_rest, RST_SPILL_FILL => rst_spill_fill,  --Resets
       UP_DWN_SWP => up_dwn_swp, UP_DWN_CWP => up_dwn_cwp, UP_DWN_SAVE => up_dwn_save, UP_DWN_REST => up_dwn_rest, --up/down
       LD_SAVE => ld_save, -- Load

       --Counters signals: outputs
       CANSAVE => cansave, CANRESTORE => canrestore, END_SF => end_sf,

       --Muxes signals
       SEL_WP => sel_wp ,CPU_WORK => cpu_work );


end STRUCTURE;
