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
		IRAM_DATA		: in std_logic_vector(INSTR_SIZE-1 downto 0);
		
		-- IF control signals
		NPC_SEL			: in std_logic;
		PC_LATCH_EN		: in std_logic;
		
		-- IF/ID pipeline registers control
		IR_LATCH_EN		: in std_logic;
		NPC_LATCH_EN	: in std_logic;
		
		-- ID control signals
		-- Windowed register file
		CALL			: in std_logic;
		RET				: in std_logic;
		SPILL			: out std_logic;
		FILL			: out std_logic;
		RF_EN			: in std_logic;
		RS1_EN			: in std_logic;
		RS2_EN			: in std_logic;
		RF_WR_EN		: in std_logic;
		
		IMM_ISOFF		: in std_logic;	
		
		-- ID/EX control signals
		RegA_LATCH_EN	: in std_logic;  -- Register A Latch Enable
		RegB_LATCH_EN	: in std_logic;  -- Register B Latch Enable
		RegIMM_LATCH_EN	: in std_logic  -- Immediate Register Latch Enable
		
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
	
	component DLX_ID is
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
	
	signal npc_alu_fb			: std_logic_vector(PC_SIZE-1 downto 0);		-- Feedback signal for the ALU-computed NPC
	
	-- IF/ID signals
	signal npc_if_o, npc_id_i			: std_logic_vector(PC_SIZE-1 downto 0);		-- NPC signal (npc_ex_i = npc_latch)
	signal instr_if_o, ir				: std_logic_vector(INSTR_SIZE-1 downto 0);	-- Instruction register (ir)
	
	signal rs1_id_i, rs2_id_i, rd_id_i	: std_logic_vector(RX_SIZE-1 downto 0);		-- RX addresses from IR
	signal imm_id_i						: std_logic_vector(OFFSET_SIZE-1 downto 0); -- Immediate from IR
	signal wr_data_id_i					: std_logic_vector(DATA_SIZE-1 downto 0);	-- Write back data from WB
	
	-- ID/EX signals
	signal rf_out1_id_o, rf_out2_id_o, rf_out1_ex_i, rf_out2_ex_i	: std_logic_vector(DATA_SIZE-1 downto 0);			-- 
	signal imm_id_o, imm_ex_i			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal rd_id_o, rd_ex_i				: std_logic_vector(RX_SIZE-1 downto 0);
	signal npc_id_o, npc_ex_i			: std_logic_vector(PC_SIZE-1 downto 0);	

	signal ir_reset						: std_logic_vector(INSTR_SIZE-OP_SIZE-1 downto 0);
	
begin
	
	if_stage: DLX_IF generic map( IR_SIZE => INSTR_SIZE, PC_SIZE => PC_SIZE ) 
	port map(
		CLK				=> CLK,
		RST				=> RST,
		IRAM_ADDRESS	=> IRAM_ADDRESS,
		IRAM_DATA		=> IRAM_DATA,
		NPC_ALU			=> npc_alu_fb,
		NPC_OUT			=> npc_if_o,
		INSTR			=> instr_if_o,
		NPC_SEL			=> NPC_SEL,
		PC_LATCH_EN		=> PC_LATCH_EN
	);
	
	-- IF/ID REGISTERS
	
	ir_reset <= (others=>'0');

	if_id_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
			
			ir <= NOP_OP & ir_reset;
			npc_id_i <= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			-- Instruction Register
			if(IR_LATCH_EN = '1') then
				ir <= instr_if_o;
			end if;
			
			-- NPC register
			if(NPC_LATCH_EN = '1') then
				npc_id_i <= npc_if_o;
			end if;
		
		end if;
	end process;
	
	--ir <= instr_i;
	
	rs1_id_i <= ir(25 downto 21);
	rs2_id_i <= ir(20 downto 16);
	rd_id_i	 <= ir(15 downto 11);
	
	imm_id_i <= ir(25 downto 0);
			
	id_stage: DLX_ID
		generic map(
			ADDR_SIZE	=> RX_SIZE,
			DATA_SIZE	=> DATA_SIZE,
			IMM_I_SIZE	=> OFFSET_SIZE,
			IMM_O_SIZE	=> DATA_SIZE,
			NPC_SIZE	=> PC_SIZE )
		port map(
			CLK			=> CLK,
			RST			=> RST,
			
			-- Windowed register file control interface
			CALL		=> CALL,
			RET			=> RET,
			SPILL		=> SPILL,
			FILL		=> FILL,
			RF_EN		=> RF_EN,
			RS1_EN		=> RS1_EN,
			RS2_EN		=> RS2_EN,
			RF_WR_EN	=> RF_WR_EN,
			
			IMM_ISOFF	=> IMM_ISOFF,
			
			ADDR_WR  	=> rd_id_i,
			ADDR_RS1 	=> rs1_id_i,
			ADDR_RS2 	=> rs2_id_i,
			DATAIN  	=> wr_data_id_i,
			OUT1    	=> rf_out1_id_o,
			OUT2    	=> rf_out2_id_o,
			
			IMM_I		=> imm_id_i,
			IMM_O		=> imm_id_o,
			NPC_FWD_I	=> npc_id_i,
			NPC_FWD_O	=> npc_id_o,
			RD_FWD_I	=> rd_id_i,
			RD_FWD_O	=> rd_id_o
		);
	
	-- ID/EX REGISTERS
	-- Blocking and flushing mechanisms not yet implemented
	id_ex_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
		
			rf_out1_ex_i	<= (others=>'0');
			rf_out2_ex_i	<= (others=>'0');
			imm_ex_i		<= (others=>'0');
			npc_ex_i		<= (others=>'0');
			rd_ex_i 		<= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			-- Operands registers Register
			if(RegA_LATCH_EN = '1') then
				rf_out1_ex_i <= rf_out1_id_o;
			end if;
			
			if(RegB_LATCH_EN = '1') then
				rf_out2_ex_i <= rf_out2_id_o;
			end if;
			
			if(RegIMM_LATCH_EN = '1') then
				imm_ex_i <= imm_id_o;
			end if;
			
			rd_ex_i <= rd_id_o;
			npc_ex_i <= npc_id_o;
		
		end if;
	end process;
	
	-- EX STAGE
	-- ...to be continued...
	
end structure;
