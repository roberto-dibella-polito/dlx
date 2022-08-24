-- DLX
-- Datapath

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_DP is
	port(
		CLK				: in std_logic;
		RST				: in std_logic;	-- Active HIGH
		
		-- Instruction Memory interface
		IRAM_ADDRESS	: out std_logic_vector(PC_SIZE-1 downto 0);
		IRAM_DATA		: in std_logic_vector(IR_SIZE-1 downto 0);
		
		-- IF control signals
		NPC_SEL			: in std_logic;
		PC_LATCH_EN		: in std_logic;
		
		-- IF/ID pipeline registers control
		IR_LATCH_EN		: in std_logic;
		NPC_LATCH_EN	: in std_logic;
		
		-- ID control signals
		-- Windowed register file
		CALL		: in std_logic;
		RET			: in std_logic;
		SPILL		: out std_logic;
		FILL		: out std_logic;
		RF_EN		: in std_logic;
		RS1_EN		: in std_logic;
		RS2_EN		: in std_logic;
		RF_WR_EN	: in std_logic
		
		-- ID/EX control signals
		
		-- ... more stages missing
	);
end DLX_DP;

architecture structure of DLX_DP is

	component DLX_IF
		generic (
			IR_SIZE		: integer := 32;       -- Instruction Register Size
			PC_SIZE		: integer := 32       -- Program Counter Size
		);
		port(
			CLK			: in std_logic;
			RST			: in std_logic;			-- Active LOW
			
			-- Instruction Memory interface
			IRAM_ADDRESS	: out std_logic_vector(PC_SIZE-1 downto 0);
			IRAM_DATA		: in std_logic_vector(IR_SIZE-1 downto 0);
			
			-- Stage interface
			NPC_ALU			: in std_logic_vector(PC_SIZE-1 downto 0);
			NPC_OUT			: out std_logic_vector(PC_SIZE-1 downto 0);
			INSTR			: out std_logic_vector(IR_SIZE-1 downto 0);
			
			-- IF control signals
			NPC_SEL			: in std_logic;
			PC_LATCH_EN		: in std_logic
		);
	end component;
	
	component DLX_ID
		generic(
			ADDR_SIZE	: integer := 32;
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
	end component;
	
	signal npc_out_i, npc_latch	: std_logic_vector(PC_SIZE-1 downto 0);
	signal npc_alu_fb			: std_logic_vector(PC_SIZE-1 downto 0);
	signal instr_i, ir			: std_logic_vector(INSTR_SIZE-1 downto 0);
	signal rs1,rs2,rd			: std_logic_vector(RX_SIZE-1 downto 0);
	signal imm_i				: std_logic_vector(OFFSET_SIZE-1 downto 0);

begin
	
	if_stage: DLX_IF generic map( IR_SIZE => INSTR_SIZE, PC_SIZE => PC_SIZE ) 
	port map(
		CLK				=> CLK,
		RST				=> RST,
		IRAM_ADDRESS	=> IRAM_ADDRESS,
		IRAM_DATA		=> IRAM_DATA,
		NPC_ALU			=> npc_alu_fb,
		NPC_OUT			=> npc_out_i,
		INSTR			=> instr_i,
		NPC_SEL			=> NPC_SEL,
		PC_LATCH_EN		=> PC_LATCH_EN
	);
	
	-- IF/ID REGISTERS
	if_id_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
			
			ir <= NOP_OP & (others=>'0');
			npc_latch <= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			-- Instruction Register
			--if(IR_LATCH_EN = '1') then
			--	ir <= instr_i;
			--end if;
			
			-- SYNCHRONOUS register file 
			-- => IR not needed; the enable of
			-- the register file has to be controlled
			
			-- NPC register
			if(NPC_LATCH_EN = '1') then
				npc_latch <= npc_out_i;
			end if;
		
		end if;
	end process;
	
	ir <= instr_i;
	
	rs1 <= ir(25 downto 21);
	rs2 <= ir(20 downto 16);
	rd	<= ir(15 downto 11);
	
	imm_i <= ir(26 downto 0);
			
			