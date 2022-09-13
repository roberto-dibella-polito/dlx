-- DLX
-- Instruction Decode (ID) stage

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.rf_constants.all;
use ieee.std_logic_arith.all;
use WORK.all;
use work.myTypes.all;

entity DLX_ID is
	generic(
		ADDR_SIZE	: integer := 5;
		DATA_SIZE	: integer := 32;
		IMM_I_SIZE	: integer := 26;
		IMM_O_SIZE	: integer := 32;
		NPC_SIZE	: integer := 32 );
	port(
		CLK			: in std_logic;
		RST			: in std_logic;	-- Active HIGH
		
		-- Windowed register file control interface
		CALL		: in std_logic;
		RET			: in std_logic;
		SPILL		: out std_logic;
		FILL		: out std_logic;
		RF_EN		: in std_logic;
		RS1_EN		: in std_logic;
		RS2_EN		: in std_logic;
		RF_WR_EN	: in std_logic;
		
		IMM_ISOFF	: in std_logic;
		IMM_UNS		: in std_logic;
		
		ADDR_WR  	: IN  std_logic_vector(ADDR_SIZE-1 downto 0);
        ADDR_RS1 	: IN  std_logic_vector(ADDR_SIZE-1 downto 0);
        ADDR_RS2 	: IN  std_logic_vector(ADDR_SIZE-1 downto 0);
        DATAIN  	: IN  std_logic_vector(DATA_SIZE-1 downto 0);
        OUT1    	: OUT std_logic_vector(DATA_SIZE-1 downto 0);
        OUT2    	: OUT std_logic_vector(DATA_SIZE-1 downto 0);
		
		IMM_I		: in std_logic_vector(IMM_I_SIZE-1 downto 0);
		IMM_O		: out std_logic_vector(IMM_O_SIZE-1 downto 0);
		NPC_FWD_I	: in std_logic_vector(NPC_SIZE-1 downto 0);
		NPC_FWD_O	: out std_logic_vector(NPC_SIZE-1 downto 0);
		RD_FWD_I	: in std_logic_vector(ADDR_SIZE-1 downto 0);
		RD_FWD_O	: out std_logic_vector(ADDR_SIZE-1 downto 0)
	);
end DLX_ID;

architecture structure of DLX_ID is

	component RF is
		generic (
			Nbit	: integer := 64;  -- Parallelism
			M		: integer := 8;  -- Global registers
			N		: integer := 8;  -- IN/OUT and LOC registers per window
			F		: integer := 8);     -- Number of windows
		port (
			CLK		: IN  std_logic;
			RESET	: IN  std_logic;
			CALL	: IN  std_logic;
			RET		: IN  std_logic;
			SPILL	: OUT std_logic;
			FILL	: OUT std_logic;
			ENABLE	: IN  std_logic;
			RD1		: IN  std_logic;
			RD2		: IN  std_logic;
			WR		: IN  std_logic;
			ADD_WR	: IN  std_logic_vector(NbitAdd-1 downto 0);
			ADD_RD1	: IN  std_logic_vector(NbitAdd-1 downto 0);
			ADD_RD2	: IN  std_logic_vector(NbitAdd-1 downto 0);
			DATAIN	: IN  std_logic_vector(Nbit-1 downto 0);
			OUT1	: OUT std_logic_vector(Nbit-1 downto 0);
			OUT2	: OUT std_logic_vector(Nbit-1 downto 0));
	end component;
	
	signal x0, out1_i, out2_i				: std_logic_vector(Nbit-1 downto 0);
	signal addr_wRS1, addr_wRS2, addr_wRD	: std_logic_vector(NbitAdd-1 downto 0);
	signal p_addr_wRS1, p_addr_wRS2, p_addr_wRD	: unsigned(NbitAdd-1 downto 0);
	signal aRS1_iszero_n, aRS2_iszero_n		: std_logic;
	signal imm_sel							: std_logic_vector(1 downto 0);
	
begin
		
	-- SIGN EXTENDER
	-- It takes 26 bits: if the instruction is a J-type, the
	-- flag is rised and the right immediate is selected.
	
	imm_sel <= IMM_ISOFF & IMM_UNS:
	
	--imm_or_off: process( IMM_ISOFF, IMM_UNS, IMM_I )
	imm_or_off: process( imm_sel, IMM_I )
	begin
		--if IMM_ISOFF = '1' then
		--	IMM_O	<= SXT(IMM_I,IMM_O'length);
		--elsif IMM_UNS = '0' then
		--	IMM_O	<= SXT(IMM_I(15 downto 0),IMM_O'length);
		--else
		--	IMM_O	<= x0(15 downto 0) & IMM_I(15 downto 0);
		--end if;
		
		case imm_sel is
			when "10" => IMM_O <= SXT(IMM_I,IMM_O'length);
			when "00" => IMM_O <= SXT(IMM_I(15 downto 0),IMM_O'length);
			when "01" => IMM_O <= x0(15 downto 0) & IMM_I(15 downto 0);
			when "11" => IMM_O <= x0;
		end case;
		
	end process;
	
	NPC_FWD_O	<= NPC_FWD_I;
	RD_FWD_O	<= RD_FWD_I;
	
	x0 <= (others=>'0');
	
	-- WINDOWED REGISTER FILE FIX
	-- The current version of RF cannot use x0 as fixed register.
	-- An external register is added, fixed to 0, and selected when
	-- the ADDR_RSX = 0.
	-- If ADDR_RSX /= 0, the RF is addressed using ADDR_RSX-1.
	-- So, the registers used are RF(0) to RF(30). 
	-- RF(31) is currently not used.
	
	aRS1_iszero_n	<= '0' when( unsigned(ADDR_RS1) = 0 ) else '1';
	aRS2_iszero_n	<= '0' when( unsigned(ADDR_RS2) = 0 ) else '1';
	
	--addr_wRS1	<= std_logic_vector( unsigned(ADDR_RS1) - x"00000001");
	--addr_wRS2	<= std_logic_vector( unsigned(ADDR_RS1) - to_unsigned(1,ADDR_SIZE));
	--addr_wRD	<= ADDR_RD - x"00000001" ;
	
	p_addr_wRS1 <= unsigned(ADDR_RS1) - 1;
	p_addr_wRS2 <= unsigned(ADDR_RS2) - 1;	
	p_addr_wRD <= unsigned(ADDR_WR) - 1;
	
	addr_wRS1 <= std_logic_vector(p_addr_wRS1);	
	addr_wRS2 <= std_logic_vector(p_addr_wRS2);
	addr_wRD <= std_logic_vector(p_addr_wRD);

	OUT1	<= out1_i when( aRS1_iszero_n = '1' ) else x0;
	OUT2	<= out2_i when( aRS2_iszero_n = '1' ) else x0;
	
	regfile: RF generic map (
		Nbit	=> Nbit,
		M		=> M,
		N		=> N,
		F		=> F )     -- Number of windows
	port map (
		CLK		=> CLK,
		RESET	=> RST,
		CALL	=> CALL,
		RET		=> RET,
		SPILL	=> SPILL,
		FILL	=> FILL,
		ENABLE	=> RF_EN,
		RD1		=> RS1_EN,
		RD2		=> RS2_EN,
		WR		=> RF_WR_EN,
		ADD_WR	=> addr_wRD,
		ADD_RD1	=> addr_wRS1,
		ADD_RD2	=> addr_wRS2,
		DATAIN	=> DATAIN,
		OUT1	=> out1_i,
		OUT2	=> out2_i
	);

end structure;
