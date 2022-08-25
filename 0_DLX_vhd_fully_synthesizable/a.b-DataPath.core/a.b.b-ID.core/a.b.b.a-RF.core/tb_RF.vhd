------------------------------------------------------------------------------
--	WINDOWED REGISTER FILE TESTBENCH										--
------------------------------------------------------------------------------
--	Author:			Roberto Di Bella, Francesco Rota
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use IEEE.numeric_std.all;
use WORK.all;

entity RF_TB is
end RF_TB;

architecture bhv of RF_TB is

  component RF
    generic (Nbit : integer := 64;      -- Parallelism
             M    : integer := 8;       -- Global registers
             N    : integer := 8;       -- IN/OUT and LOC registers per window
             F    : integer := 8);      -- Number of windows
    port (CLK     : in  std_logic;
          RESET   : in  std_logic;
          CALL    : in  std_logic;
          RET     : in  std_logic;
          SPILL   : out std_logic;
          FILL    : out std_logic;
          ENABLE  : in  std_logic;
          RD1     : in  std_logic;
          RD2     : in  std_logic;
          WR      : in  std_logic;
          ADD_WR  : in  std_logic_vector(NbitAdd-1 downto 0);
          ADD_RD1 : in  std_logic_vector(NbitAdd-1 downto 0);
          ADD_RD2 : in  std_logic_vector(NbitAdd-1 downto 0);
          DATAIN  : in  std_logic_vector(Nbit-1 downto 0);
          OUT1    : out std_logic_vector(Nbit-1 downto 0);
          OUT2    : out std_logic_vector(Nbit-1 downto 0));
  end component;

  signal CLK, RESET, CALL, RET, SPILL, FILL, ENABLE, RD1, RD2, WR : std_logic;
  signal ADD_WR, ADD_RD1, ADD_RD2                                 : std_logic_vector(NbitAdd-1 downto 0);
  signal DATAIN, OUT1, OUT2                                       : std_logic_vector(Nbit-1 downto 0);

  -- MEMORY SIMULATION
  subtype MEM_ADDR is integer range 0 to 3; -- using natural type
  type MEM_TYPE is array(MEM_ADDR) of std_logic_vector(Nbit-1 downto 0);

  signal MEM : MEM_TYPE;
  
begin

  dut : RF generic map(Nbit => Nbit, M => M, F => F, N => N) port map
    (CLK     => CLK,
     RESET   => RESET,
     CALL    => CALL,
     RET     => RET,
     SPILL   => SPILL,
     FILL    => FILL,
     ENABLE  => ENABLE,
     RD1     => RD1,
     RD2     => RD2,
     WR      => WR,
     ADD_WR  => ADD_WR,
     ADD_RD1 => ADD_RD1,
     ADD_RD2 => ADD_RD2,
     DATAIN  => DATAIN,
     OUT1    => OUT1,
     OUT2    => OUT2);

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


  
  clkgen : process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  --Reset
  process
  begin

    CALL    <= '0';
    RET     <= '0';
    ENABLE  <= '0';
    RD1     <= '0';
    RD2     <= '0';
    WR      <= '0';
    ADD_WR  <= (others => '0');
    ADD_RD1 <= (others => '0');
    ADD_RD2 <= (others => '0');
    DATAIN  <= (others => '0');
    RESET   <= '1';
    wait for 10 ns;
    RESET <= '0';
    wait for 10 ns;

    -- Two write operations in W0
    wait for 10 ns;			-- 	25 ns 
    WR <='1';
    ADD_WR <= "1000";    	--GLOBAL 8 ,physical address=18  
    DATAIN <= "00000001";  
    ENABLE <= '1';
    
							-- 	30 ns: R(18)<= "1"		
	wait for 10 ns;			-- 	35 ns: 
    ADD_WR <= "0011";    	-- W0, LOCAL 3 - physical address=3      
    DATAIN <= "00000010";
							--	40 ns: R(3) <= "2"    
	
	wait for 10 ns;			-- 	35 ns: 
    ADD_WR <= "1001";    	-- W0, LOCAL 3 - physical address=3      
    DATAIN <= "00000011";
	
    -- Read operation on the two written registers
					
	wait for 10 ns;			-- 45 ns => READ
    WR <= '0';
    RD1 <= '1';
    RD2 <= '1';
    ADD_RD1 <= "0011"; -- W0, LOCAL 3 - physical address = 3
    ADD_RD2 <= "1000"; -- GLOBAL 8 - physical address = 18
    wait for 10 ns;			-- 55 ns

    -- CALL
    RD1 <= '0';
    RD2 <= '0';
    CALL <= '1';
    wait for 10 ns;
    CALL <= '0';
    wait for 10 ns;
    CALL <= '1';
    wait for 10 ns;
    CALL <= '0';

    -- Write on current window W2

    WR <='1';
    ADD_WR <= "0110"; -- GLOBAL 6 - physical address = 16
    DATAIN <= "00000100"; 
    wait for 10 ns;
    ADD_WR <= "0100"; -- W2, OUT 4 - physical address = 12
    DATAIN <= "00001000";
    wait for 10 ns;

    -- Read
    WR <= '0';
    RD1 <= '1';
    RD2 <= '1';
    ADD_RD1 <= "0110"; --GLOBAL 6 - physical address=16
    ADD_RD2 <= "1000"; --GLOBAL 8 - physical address=18
    wait for 10 ns;
    RD1 <= '0';
    RD2 <= '0';
   

    -- Another call - current window W2 to W3 -> CANSAVE = 0 => SPILL
    CALL <= '1';
    wait for 10 ns;
    CALL <= '0';    
    wait for 30 ns;
    MEM(0) <= OUT1;
    wait for 10 ns;
    MEM(1) <= OUT1;
    wait for 10 ns;
    MEM(2) <= OUT1;
    wait for 10 ns;
    MEM(3) <= OUT1;
    wait for 10 ns;

    -- Current window W3
    WR <='1';
    ADD_WR <= "0101"; -- W3, OUT 5 - physical address = 1
    DATAIN <= "00010000";
    wait for 10 ns;
    WR <= '1';
    ADD_WR <= "0011"; -- W3, LOC 3 - physical address = 15
    DATAIN <= "00100000";
    wait for 10 ns;
    

    -- Read
    WR <= '0';
    RD1 <= '1';
    RD2 <= '1';
    ADD_RD1 <= "0011"; -- W3, LOC 3 - physical address = 15
    ADD_RD2 <= "0101"; -- W3, OUT 5 - physical address = 1
    wait for 10 ns;
    RD1 <= '0';
    RD2 <= '0';
    

    -- RETURN TO W0
    RET <= '1';
    wait for 10 ns;
    RET <= '0';
    wait for 10 ns; ---> W2
    RET <= '1';
    wait for 10 ns;
    RET <= '0';
    wait for 10 ns; ---> W1
    RET <= '1';
    wait for 10 ns;
    RET <= '0';
    wait for 10 ns; ---> W0 -> CANRESTORE = 0 => FILL
    DATAIN <= MEM(0);
    wait for 10 ns;
    DATAIN <= MEM(1);
    wait for 10 ns;
    DATAIN <= MEM(2);
    wait for 10 ns;
    DATAIN <= MEM(3);
    wait for 30 ns;
    RD2 <= '1';
    ADD_RD2 <= "0011"; -- W0, LOCAL 3 - physical address = 3
    
    
 
    
    
    
    

    wait for 100000 ns;
  end process;

end bhv;





