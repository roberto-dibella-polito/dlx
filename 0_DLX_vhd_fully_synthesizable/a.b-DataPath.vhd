-- DLX
-- Datapath / PIPELINED
-- The usage of the pipeline drastically changes the control signals,
-- removing the LATCH_EN signals.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_DP is
	generic(
		ADDR_SIZE	: integer := 32;
		DATA_SIZE	: integer := 32
	);
	port(
		CLK		: in std_logic;
		RST		: in std_logic;	-- Active HIGH
		
		-- Pipeline registers enable and clear signal
		PIPE_IF_ID_EN	: in std_logic;
		PIPE_ID_EX_EN	: in std_logic;
		PIPE_EX_MEM_EN	: in std_logic;
		PIPE_MEM_WB_EN	: in std_logic;
		
		PIPE_CLEAR_n	: in std_logic;
		
		-- Instruction Memory interface
		IRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
		IRAM_DATA	: in std_logic_vector(DATA_SIZE-1 downto 0);
		
		-- Instruction port, forwarded to CU
		INSTR		: out std_logic_vector(DATA_SIZE-1 downto 0);	

		RegRD_SEL	: in std_logic;
		
		-- ID control signals
		-- Windowed register file
		CALL		: in std_logic;
		RET		: in std_logic;
		SPILL		: out std_logic;
		FILL		: out std_logic;
		RF_EN		: in std_logic;
		RS1_EN		: in std_logic;
		RS2_EN		: in std_logic;
		
		IMM_ISOFF	: in std_logic;	
		
		-- EX control signals
		MUXA_SEL	: in std_logic;
		MUXB_SEL	: in std_logic;
		BRANCH_T	: out std_logic;
		ALU_OP		: in aluOp;
		MEM_IN_EN	: in std_logic;
		
		-- DRAM Data Interface
		DRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
		DRAM_DATA	: inout std_logic_vector(DATA_SIZE-1 downto 0);
		
		-- MEM control signals
		--LMD_LATCH_EN	: in std_logic;	-- LMD Register Latch Enable
		JUMP_EN		: in std_logic;	-- JUMP Enable Signal for PC input MUX
		PC_LATCH_EN	: in std_logic;	-- Pipelined version -> with no stalls, always active
		
		-- WB Control signals
		WB_MUX_SEL	: in std_logic;  -- Write Back MUX Sel
		RF_WE		: in std_logic  -- Register File Write Enable

	);
end DLX_DP;

architecture structure of DLX_DP is

	component DLX_IF
		generic (
			IR_SIZE		: integer := 32;       -- Instruction Register Size
			PC_SIZE		: integer := 32       -- Program Counter Size
		);
		port(
			CLK		: in std_logic;
			RST		: in std_logic;			-- Active LOW
			
			-- Instruction Memory interface
			IRAM_ADDRESS	: out std_logic_vector(PC_SIZE-1 downto 0);
			IRAM_DATA	: in std_logic_vector(IR_SIZE-1 downto 0);
			
			-- Stage interface
			NPC_ALU		: in std_logic_vector(PC_SIZE-1 downto 0);
			NPC_OUT		: out std_logic_vector(PC_SIZE-1 downto 0);
			INSTR		: out std_logic_vector(IR_SIZE-1 downto 0);
			
			-- IF control signals
			NPC_SEL		: in std_logic;
			PC_LATCH_EN	: in std_logic
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
			CLK		: in std_logic;
			RST		: in std_logic;	-- Active HIGH
		
			-- Windowed register file control interface
			CALL		: in std_logic;
			RET		: in std_logic;
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
	
	component DLX_EX
		generic(
			DATA_SIZE	: integer := 32;
			NPC_SIZE	: integer := 32;
			IMM_SIZE	: integer := 32;
			RD_SIZE		: integer := 32
		);
		port(
			PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
			PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
			NPC_IN		: in std_logic_vector(NPC_SIZE-1 downto 0);
			IMM_IN		: in std_logic_vector(DATA_SIZE-1 downto 0);
			RD_FWD_IN	: in std_logic_vector(RD_SIZE-1 downto 0);
			ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
			DATA_MEM	: out std_logic_vector(DATA_SIZE-1 downto 0);
			RD_FWD_OUT	: out std_logic_vector(RD_SIZE-1 downto 0);
			BRANCH_T	: out std_logic;
			
			-- Control signals
			MUXA_SEL	: in std_logic;  -- MUX-A Sel
			MUXB_SEL	: in std_logic;  -- MUX-B Sel
			ALU_OP		: in aluOp		
		);
	end component;
	
	signal npc_alu_fb			: std_logic_vector(PC_SIZE-1 downto 0);		-- Feedback signal for the ALU-computed NPC
	
	-- IF/ID signals
	signal npc_if_o, npc_id_i		: std_logic_vector(PC_SIZE-1 downto 0);		-- NPC signal (npc_ex_i = npc_latch)
	signal instr_if_o, ir			: std_logic_vector(INSTR_SIZE-1 downto 0);	-- Instruction register (ir)
	
	signal rs1_id_i, rs2_id_i, rd_id_i	: std_logic_vector(RX_SIZE-1 downto 0);		-- RX addresses from IR
	signal imm_id_i				: std_logic_vector(OFFSET_SIZE-1 downto 0); -- Immediate from IR
	signal wr_data_id_i			: std_logic_vector(DATA_SIZE-1 downto 0);	-- Write back data from WB
	
	-- ID/EX signals
	signal rf_out1_id_o, rf_out2_id_o, rf_out1_ex_i, rf_out2_ex_i	: std_logic_vector(DATA_SIZE-1 downto 0);			-- 
	signal imm_id_o, imm_ex_i		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal rd_fwd_id_o, rd_fwd_ex_i		: std_logic_vector(RX_SIZE-1 downto 0);
	signal npc_id_o, npc_ex_i		: std_logic_vector(PC_SIZE-1 downto 0);	

	signal ir_reset				: std_logic_vector(INSTR_SIZE-OP_SIZE-1 downto 0);
	
	-- EX/MEM signals
	signal alu_out_ex_o, alu_out_mem_i	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_mem_ex_o, data_mem_mem_i	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal rd_fwd_ex_o, rd_fwd_mem_i	: std_logic_vector(RX_SIZE-1 downto 0);
	signal branch_t_ex_o, branch_t_mem_i	: std_logic;
	
	-- MEM interface internal signals
	--DRAM_WE			: in std_logic;  -- Data RAM Write Enable
	--DMEM_READY		: out std_logic;
	--DMEM_ISSUE		: in std_logic;
	signal z_word		: std_logic_vector(DATA_SIZE-1 downto 0);
	
	-- MEM/WB signals
	signal rd_fwd_mem_o, rd_fwd_wb_i	: std_logic_vector(RX_SIZE-1 downto 0);
	signal data_mem_mem_o, data_mem_wb_i	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal alu_out_mem_o, alu_out_wb_i	: std_logic_vector(DATA_SIZE-1 downto 0);
	
begin
	
	if_stage: DLX_IF generic map( IR_SIZE => INSTR_SIZE, PC_SIZE => PC_SIZE ) 
	port map(
		CLK		=> CLK,
		RST		=> RST,
		IRAM_ADDRESS	=> IRAM_ADDRESS,
		IRAM_DATA	=> IRAM_DATA,
		NPC_ALU		=> npc_alu_fb,
		NPC_OUT		=> npc_if_o,
		INSTR		=> instr_if_o,
		NPC_SEL		=> JUMP_EN,
		PC_LATCH_EN	=> PC_LATCH_EN
	);
	
	INSTR <= instr_if_o;
	
	-- IF/ID REGISTERS
	
	ir_reset <= (others=>'0');

	if_id_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
			
			ir <= NOP_OP & ir_reset;
			npc_id_i <= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			if( PIPE_IF_ID_EN <= '1' ) then
			-- Instruction Register
			--if(IR_LATCH_EN = '1') then
				ir <= instr_if_o;
			--end if;
				
			-- NPC register
			--if(NPC_LATCH_EN = '1') then	
				npc_id_i <= npc_if_o;
			--end if;
			
			end if;
		end if;
	end process;
	
	--ir <= instr_i;
	
	rs1_id_i <= ir(25 downto 21);
	rs2_id_i <= ir(20 downto 16);
	
	rd_id_i <= ir(15 downto 11) when RegRD_SEL = '0' else ir(20 downto 16);


	--rd_id_i	 <= ir(15 downto 11);
	
	imm_id_i <= ir(25 downto 0);
			
	id_stage: DLX_ID generic map(
		ADDR_SIZE	=> RX_SIZE,
		DATA_SIZE	=> DATA_SIZE,
		IMM_I_SIZE	=> OFFSET_SIZE,
		IMM_O_SIZE	=> DATA_SIZE,
		NPC_SIZE	=> PC_SIZE )
	port map(
		CLK		=> CLK,
		RST		=> RST,
		
		-- Windowed register file control interface
		CALL		=> CALL,
		RET		=> RET,
		SPILL		=> SPILL,
		FILL		=> FILL,
		RF_EN		=> RF_EN,
		RS1_EN		=> RS1_EN,
		RS2_EN		=> RS2_EN,
		RF_WR_EN	=> RF_WE,
		
		IMM_ISOFF	=> IMM_ISOFF,
		
		ADDR_WR  	=> rd_fwd_wb_i,
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
		RD_FWD_O	=> rd_fwd_id_o
	);
	
	-- ID/EX REGISTERS
	-- Blocking mechanisms not yet implemented
	-- Flushing mechanis: synchronous reset PIPE_CLEAR_n
	
	id_ex_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
		
			rf_out1_ex_i	<= (others=>'0');
			rf_out2_ex_i	<= (others=>'0');
			imm_ex_i	<= (others=>'0');
			npc_ex_i	<= (others=>'0');
			rd_fwd_ex_i 	<= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			if( PIPE_CLEAR_n = '0' ) then
				rf_out1_ex_i	<= (others=>'0');
				rf_out2_ex_i	<= (others=>'0');
				imm_ex_i	<= (others=>'0');
				npc_ex_i	<= (others=>'0');
				rd_fwd_ex_i	<= (others=>'0');
			elsif( PIPE_ID_EX_EN <= '1' ) then
						
				-- Operands registers Register
				--if(RegA_LATCH_EN = '1') then
					rf_out1_ex_i <= rf_out1_id_o;
				--end if;
			
				--if(RegB_LATCH_EN = '1') then
					rf_out2_ex_i <= rf_out2_id_o;
				--end if;
			
				--if(RegIMM_LATCH_EN = '1') then
					imm_ex_i <= imm_id_o;
				--end if;
			
				rd_fwd_ex_i <= rd_fwd_id_o;
				npc_ex_i <= npc_id_o;
			end if;
		
		end if;
	end process;
	
	-- EX STAGE
	ex_stage: DLX_EX generic map(
		DATA_SIZE	=> DATA_SIZE,
		NPC_SIZE	=> PC_SIZE,
		IMM_SIZE	=> DATA_SIZE,
		RD_SIZE		=> RX_SIZE
	)
	port map(
		PORT_A		=> rf_out1_ex_i,
		PORT_B		=> rf_out2_ex_i,
		NPC_IN		=> npc_ex_i,
		IMM_IN		=> imm_ex_i,
		RD_FWD_IN	=> rd_fwd_ex_i,
		ALU_OUT		=> alu_out_ex_o,
		DATA_MEM	=> data_mem_ex_o,
		RD_FWD_OUT	=> rd_fwd_ex_o,
		BRANCH_T	=> BRANCH_T,
		MUXA_SEL	=> MUXA_SEL,
		MUXB_SEL	=> MUXB_SEL,
		ALU_OP		=> ALU_OP	
	);
	
	-- EX/MEM REGISTERS
	-- Blocking and flushing mechanisms not yet implemented
	-- Input:	ALU_OUTREG_EN
	
	z_word <= (others=>'Z');
	
	ex_mem_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
		
			alu_out_mem_i	<= (others=>'0');
			data_mem_mem_i	<= (others=>'0');
			rd_fwd_mem_i	<= (others=>'0');
			branch_t_mem_i	<= '0';
			
		elsif(CLK'event and CLK = '1') then
		
			if( PIPE_CLEAR_n = '0' ) then
			
				alu_out_mem_i	<= (others=>'0');
				data_mem_mem_i	<= (others=>'0');
				rd_fwd_mem_i	<= (others=>'0');
				branch_t_mem_i	<= '0';
			
			elsif( PIPE_EX_MEM_EN = '1') then
				-- Operands registers Register
				--if(ALU_OUTREG_EN = '1') then
					alu_out_mem_i <= alu_out_ex_o;
				--end if;
				if( MEM_IN_EN = '1' ) then
					data_mem_mem_i	<= z_word;
				else
					data_mem_mem_i	<= data_mem_ex_o;
				end if;
				rd_fwd_mem_i	<= rd_fwd_ex_o;
				branch_t_mem_i	<= branch_t_ex_o;
			
			end if;
		end if;
	end process;
	
	-- MEM Stage
	-- Currently only composed of branch taken output
	-- and memory interface
	
	-- Branch taken flag
	BRANCH_T <= branch_t_mem_i;
	
	
	DRAM_ADDRESS	<= alu_out_mem_i;
	DRAM_DATA	<= data_mem_mem_i;
	alu_out_mem_o	<= alu_out_mem_i;
	data_mem_mem_o	<= data_mem_mem_i;
	rd_fwd_mem_o	<= rd_fwd_mem_i;
	
	

	-- MEM/WB registers
	mem_wb_pipe: process(CLK, RST)
	begin
		if( RST = '1' ) then
			
			alu_out_wb_i	<= (others=>'0');
			data_mem_wb_i	<= (others=>'0');
			rd_fwd_wb_i		<= (others=>'0');
			
		elsif(CLK'event and CLK = '1') then
			
			if( PIPE_CLEAR_n = '0' ) then
				
				alu_out_wb_i	<= (others=>'0');
				data_mem_wb_i	<= (others=>'0');
				rd_fwd_wb_i	<= (others=>'0');
			
			elsif( PIPE_MEM_WB_EN = '1' ) then
			
				-- LMD register
				--if(LMD_LATCH_EN = '1') then
					data_mem_wb_i <= data_mem_mem_o;
				--end if;
				
				alu_out_wb_i	<= alu_out_mem_o;
				rd_fwd_wb_i		<= rd_fwd_mem_o;
			
			end if;
		end if;
	end process;
	
	-- WRITE BACK stage
	-- Multiplexer
	--wb_mux: process(WB_MUX_SEL,alu_out_wb_i, data_mem_wb_i)
	--begin
	--	case WB_MUX_SEL is
	--		when '0'	=> wr_data_id_i <= data_mem_wb_i;
	--		when '1'	=> wr_data_id_i <= alu_out_wb_i;
	--	end case;
	--end process;
	
	wr_data_id_i <= data_mem_wb_i when WB_MUX_SEL = '0' else alu_out_wb_i;

end structure;
