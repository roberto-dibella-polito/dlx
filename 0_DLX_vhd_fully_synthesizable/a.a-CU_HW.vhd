library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use work.DLX_ControlWords.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
	generic (
		MICROCODE_MEM_SIZE	: integer := 10;	-- Microcode Memory Size
		FUNC_SIZE			: integer := 11;	-- Func Field Size for R-Type Ops
		OP_CODE_SIZE		: integer := 6;		-- Op Code Size
		IR_SIZE				: integer := 32;	-- Instruction Register Size    
		CW_SIZE				: integer := 16
	);	-- Control Word Size


	port (
		Clk					: in  std_logic;	-- Clock
		Rst					: in  std_logic;	-- Reset:Active-High

		-- Instruction Register
		IR_IN				: in  std_logic_vector(IR_SIZE - 1 downto 0);
	
		-- IRAM control signals
		IRAM_ISSUE			: out std_logic;
		IRAM_READY			: in std_logic;
		
		-- Pipeline control signals (ID, EX, MEM)
		PIPE_IF_ID_EN		: out std_logic;
		PIPE_ID_EX_EN		: out std_logic;
		PIPE_EX_MEM_EN		: out std_logic;
		PIPE_MEM_WB_EN		: out std_logic;

		PIPE_CLEAR_n		: out std_logic;

		-- IF Control Signal
		-- Controlled by PIPE_IF_ID_EN
		--IR_LATCH_EN			: out std_logic;  -- Instruction Register Latch Enable
		--NPC_LATCH_EN		: out std_logic;	 -- NextProgramCounter Register Latch Enable

		-- ID Control Signals
		-- Not used -> Controlled by PIPE_ID_EX_EN
		--RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
		--RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
		--RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable
		RegRD_SEL			: out std_logic;
		RF_CALL				: out std_logic;
		RF_RET				: out std_logic;
		RF_SPILL			: in std_logic;
		RF_FILL				: in std_logic;
		RF_EN				: out std_logic;
		RF_RS1_EN			: out std_logic;
		RF_RS2_EN			: out std_logic;
		IMM_ISOFF			: out std_logic;
		IMM_UNS				: out std_logic;	

		-- EX Control Signals
		MUXA_SEL           	: out std_logic;  	-- MUX-A Sel
		MUXB_SEL           	: out std_logic;  	-- MUX-B Sel
		IS_ZERO				: in std_logic;
		ALU_OP				: out aluOp;		-- FUNC field

		-- Controlled by PIPE_EX_MEM_EN
		--ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
		--EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
		MEM_IN_EN			: out std_logic;		
		
		-- MEM Control Signals
		-- . DRAM control interface
		DRAM_ISSUE			: out std_logic;
		DRAM_READNOTWRITE	: out std_logic;
		DRAM_READY			: in std_logic;
		
		--LMD_LATCH_EN       : out std_logic;	-- LMD Register Latch Enable
		JUMP_EN            : out std_logic;		-- JUMP Enable Signal for PC input MUX
		PC_LATCH_EN        : out std_logic;		-- Program Counte Latch Enable

		-- WB Control signals
		WB_MUX_SEL         : out std_logic_vector(2 downto 0);		-- Write Back MUX Sel
		RF_WE              : out std_logic		-- Register File Write Enable

	);  
end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

	type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_mem : mem_array := (
		RR_CW, 				-- 0x00	R type: IS IT CORRECT?
		NOP_CW,				-- 0x01
		J_CW,				-- 0x02	J
		JAL_CW, 			-- 0x03	JAL 
		BQZ_CW,			 	-- 0x04	BEQZ
		BNZ_CW,			 	-- 0x05	BNEZ
		not_implemented, 	-- 0x06
		not_implemented,	-- 0x07
		RI_CW, 				-- 0x08	ADDI
		RUI_CW,				-- 0x09	ADDUI
		RI_CW,				-- 0x0A	SUBI
		RUI_CW,				-- 0x0B	SUBUI
		RUI_CW,				-- 0x0C	ANDI
		RUI_CW,				-- 0x0D	ORI
		RUI_CW,				-- 0x0E	XORI
		not_implemented,	-- 0x0F	LHI
		not_implemented,	-- 0x10	
		not_implemented,	-- 0x11	
		not_implemented,	-- 0x12	JR
		not_implemented,	-- 0x13	JALR
		RI_CW,				-- 0x14	SLLI
		NOP_CW,				-- 0x15	NOP
		RI_CW,				-- 0x16	SRLI
		not_implemented,	-- 0x17	SRAI
		not_implemented,	-- 0x18	SEQI
		RI_CW,				-- 0x19	SNEI
		not_implemented,	-- 0x1A	SLTI
		not_implemented,	-- 0x1B	SGTI
		RI_CW,				-- 0x1C	SLEI
		RI_CW,				-- 0x1D	SGEI
		not_implemented,	-- 0x1E
		not_implemented,	-- 0x1F
		not_implemented,	-- 0x20	LB
		not_implemented,	-- 0x21	
		not_implemented,	-- 0x22
		LW_CW,				-- 0x23	LW
		not_implemented,	-- 0x24	LBU
		not_implemented,	-- 0x25	LHU
		not_implemented,	-- 0x26	
		not_implemented,	-- 0x27
		not_implemented,	-- 0x28	SB
		not_implemented,	-- 0x29	
		not_implemented,	-- 0x2A
		SW_CW,				-- 0x2B	SW
		not_implemented,	-- 0x2C
		not_implemented,	-- 0x2D
		not_implemented,	-- 0x2E
		not_implemented,	-- 0x2F
		not_implemented,	-- 0x30
		not_implemented,	-- 0x31
		not_implemented,	-- 0x32
		not_implemented,	-- 0x33
		not_implemented,	-- 0x34
		not_implemented,	-- 0x35
		not_implemented,	-- 0x36
		not_implemented,	-- 0x37
		not_implemented,	-- 0x38
		not_implemented,	-- 0x39
		RUI_CW,				-- 0x3A	SLTUI
		RUI_CW,				-- 0x3B	SGTUI
		not_implemented,	-- 0x3C	
		RUI_CW,				-- 0x3D	SGEUI
		not_implemented,	-- 0x3E
		not_implemented		-- 0x3F
	);	
	
	signal IR_opcode	: std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
	signal IR_func 		: std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype
	signal cw   		: std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem

	-- control word is shifted to the correct stage
	signal cw0	: std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw1	: std_logic_vector(CW_SIZE - 1 downto 0); -- first stage
	signal cw2	: std_logic_vector(CW_SIZE - 1 - 6 downto 0); -- second stage
	signal cw3	: std_logic_vector(CW_SIZE - 1 - 9 downto 0); -- third stage
	signal cw4	: std_logic_vector(CW_SIZE - 1 - 14 downto 0); -- fourth stage

	signal aluOpcode_i      : aluOp := NOP; -- ALUOP defined in package
	signal aluOpcode1       : aluOp := NOP;
	signal aluOpcode2       : aluOp := NOP;

	signal pipe_enable_i, pipe_clear_i, stall 				: std_logic;
	signal eqz_cond_i, neqz_cond_i, jump_en_i, branch_taken                 : std_logic;
	signal stall_forDram, dram_issue_i, dram_issue_o		        : std_logic;
	signal stall_doubleSW, stall_doubleSW_id_ex, stall_doubleSW_ex_mem	: std_logic;
	signal iram_issue_i							: std_logic;
	signal stall_forIram, stall_forIram_1					: std_logic;
	
	signal opcode1	: std_logic_vector(OP_CODE_SIZE-1 downto 0);
	
begin  -- dlx_cu_rtl

	IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
	IR_func(FUNC_SIZE-1 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

	cw <= cw_mem(conv_integer(IR_opcode));
	
	-- PIPELINE ENABLE SIGNAL
	-- For now, all the pipeline register will remain ACTIVE
	-- and a new instruction will be fetched every clk
	--stall <= '0';

	cw0 <= cw;	
	
	-- STALL UNIT
	-- Handles:
	-- . DRAM Ready signal
	
	dram_issue_o	<= dram_issue_i and (not DRAM_READY);	-- Wait for the DRAM to be ready
	
	stall_forIram	<= iram_issue_i and (not IRAM_READY);	-- Wait for the IRAM to be ready
	stall_forDram	<= dram_issue_o;

	stall			<= stall_forDram or stall_forIram;		-- The pipeline has to be stopped AFTER the stall of the IRAM
										-- Not doing it will make the CPU loose an instruction
	pipe_enable_i 	        <= not stall;
	PC_LATCH_EN		<= not stall;

	-- Request data to the IRAM
	iram_issue_i	<= not stall_forDram;
	IRAM_ISSUE	<= iram_issue_i;
		

	PIPE_IF_ID_EN	<= pipe_enable_i;
	
	--RF_EN				<= cw1(CW_SIZE-1);	-- For now, RF always active. Enable used for single ports
	RF_EN		<= '1';	
	RF_RS1_EN	<= cw1(CW_SIZE-2);
	RF_RS2_EN	<= cw1(CW_SIZE-3);
	RF_CALL		<= '0';
	RF_RET		<= '0';
	IMM_ISOFF	<= cw1(CW_SIZE-4);
	IMM_UNS		<= cw1(CW_SIZE-5);
	RegRD_SEL	<= cw1(CW_SIZE-6);
	
	PIPE_ID_EX_EN	<= pipe_enable_i;
	
	MUXA_SEL	<= cw2(CW_SIZE-7);
	MUXB_SEL	<= cw2(CW_SIZE-8);
	MEM_IN_EN	<= cw2(CW_SIZE-9);
	
	PIPE_EX_MEM_EN	<= pipe_enable_i;
	
	dram_issue_i		<= cw3(CW_SIZE-10);
	DRAM_ISSUE			<= dram_issue_o;
	DRAM_READNOTWRITE	<= cw3(CW_SIZE-11);
	eqz_cond_i			<= cw3(CW_SIZE-12);
	neqz_cond_i			<= cw3(CW_SIZE-13);
	jump_en_i			<= cw3(CW_SIZE-14);
	
	PIPE_MEM_WB_EN		<= pipe_enable_i;
  
	WB_MUX_SEL			<= cw4(CW_SIZE-14 downto CW_SIZE-15);
	RF_WE				<= cw4(CW_SIZE-16);

	-- COMBINATIONAL LOGIC
	-- for flow control
	branch_taken		<= (neqz_cond_i and is_zero) or (eqz_cond_i and not is_zero) or jump_en_i;
	JUMP_EN				<= branch_taken;
	PIPE_CLEAR_n		<= not branch_taken;
	
	-- process to pipeline control words
	CW_PIPE: process (Clk, Rst)
	begin  -- process Clk
		if Rst = '1' then                   -- asynchronous reset (active low)
			cw1 <= NOP_CW;
			cw2 <= NOP_CW(CW_SIZE - 1 - 6 downto 0);
			cw3 <= NOP_CW(CW_SIZE - 1 - 9 downto 0);
			cw4 <= NOP_CW(CW_SIZE - 1 - 14 downto 0);
			-----------------------------------------
			aluOpcode1 	<= NOP;
			aluOpcode2 	<= NOP;
			-----------------------------------------
			opcode1					<= NOP_OP; 
			-----------------------------------------
			-----------------------------------------
		elsif Clk'event and Clk = '1' then  -- rising clock edge
			
			-- Pipeline should stall
			if( pipe_enable_i = '1' ) then
				cw1				<= cw0;
				aluOpcode1		<= aluOpcode_i;				

				-- If a branch is taken, the pipeline has to be flushed
				if( branch_taken = '1' ) then	
					cw2 <= NOP_CW(CW_SIZE - 1 - 6 downto 0);
					cw3 <= NOP_CW(CW_SIZE - 1 - 9 downto 0);
					cw4 <= NOP_CW(CW_SIZE - 1 - 14 downto 0);
					-----------------------------------------
					aluOpcode2 <= NOP;
					-----------------------------------------
					opcode1	<= NOP_OP;
					-----------------------------------------
				else				
					cw2 <= cw1(CW_SIZE - 1 - 6 downto 0);
					cw3 <= cw2(CW_SIZE - 1 - 9 downto 0);
					cw4 <= cw3(CW_SIZE - 1 - 14 downto 0);
					---------------------------------------					
					aluOpcode2 <= aluOpcode1;
					---------------------------------------
					opcode1	<= IR_opcode;
					---------------------------------------
				end if;
				
			end if;
		
		end if;
	end process CW_PIPE;

	ALU_OP <= aluOpcode2;

	ALU_OP_CODE_P : process (IR_opcode, IR_func)
	begin  -- process ALU_OP_CODE_P
		case conv_integer(unsigned(IR_opcode)) is
			-- case of R type requires analysis of FUNC
			when 0 => -- Register-register instruction
				case conv_integer(unsigned(IR_func)) is
					when 32 => aluOpcode_i <= ADD; 		-- ADD
					when 36 => aluOpcode_i <= AND_O; 	-- AND
					when 37	=> aluOpcode_i <= OR_O; 	-- OR
					when 45	=> aluOpcode_i <= SGE;		-- SGE
					when 44	=> aluOpcode_i <= SLE;		-- SLE 
					when 4	=> aluOpcode_i <= SLL_O;	-- SLL
					when 41	=> aluOpcode_i <= SNE; 		-- SNE
					when 6	=> aluOpcode_i <= SRL_O;	-- SRL
					when 34	=> aluOpcode_i <= SUB;		-- SUB
					when 38	=> aluOpcode_i <= XOR_O;	-- XOR
					when 33	=> aluOpcode_i <= ADDU;	-- for now 
					when 14	=> aluOpcode_i <= MULT;	-- for now
					when 40	=> aluOpcode_i <= SEQ; 		-- SEQ
					when 61	=> aluOpcode_i <= SGEU;		-- SGEU
					when 43	=> aluOpcode_i <= SGT;		-- SGT 
					when 59	=> aluOpcode_i <= SGTU;		-- SGTU
					when 42	=> aluOpcode_i <= SLT;		-- SLT
					when 58	=> aluOpcode_i <= SLTU; 	-- SLTU
					when 7	=> aluOpcode_i <= SRA_O;	-- SRA
					when 35	=> aluOpcode_i <= SUBU; 	-- SUBU
					when others		=> aluOpcode_i <= NOP;
				end case;
			when 2	=> aluOpcode_i <= NOP; 		-- J
			when 3	=> aluOpcode_i <= NOP; 		-- JAL
			when 4	=> aluOpcode_i <= ADD;		-- BEQZ
			when 5	=> aluOpcode_i <= ADD;		-- BNEZ
			when 8	=> aluOpcode_i <= ADD;		-- ADDI
			when 10	=> aluOpcode_i <= SUB;		-- SUBI
			when 12	=> aluOpcode_i <= AND_O;	-- ANDI
			when 13	=> aluOpcode_i <= OR_O;		-- ORI
			when 14	=> aluOpcode_i <= XOR_O;	-- XORI
			when 20	=> aluOpcode_i <= SLL_O;	-- SLL
			when 21	=> aluOpcode_i <= NOP;		-- NOP
			when 22	=> aluOpcode_i <= SRL_O;	-- SRLI
			when 25	=> aluOpcode_i <= SNE;		-- SNEI
			when 28	=> aluOpcode_i <= SLE;		-- SLEI
			when 29	=> aluOpcode_i <= SGE;		-- SGEI
			when 35	=> aluOpcode_i <= ADD;		-- LW
			when 43	=> aluOpcode_i <= ADD;		-- SW
			when 9	=> aluOpcode_i <= NOP;		-- ADDU
			when 19	=> aluOpcode_i <= NOP; 		-- JALR
			when 18	=> aluOpcode_i <= NOP; 		-- JR
			when 36	=> aluOpcode_i <= NOP; 		-- LBU
			when 15	=> aluOpcode_i <= NOP; 		-- LHI
			when 37	=> aluOpcode_i <= NOP; 		-- LHU
			when 40	=> aluOpcode_i <= NOP; 		-- SB
			when 24	=> aluOpcode_i <= NOP;		-- SEQI
			when 61	=> aluOpcode_i <= SGEU;		-- SGEUI
			when 59	=> aluOpcode_i <= SGTU;		-- SGTUI
			when 26	=> aluOpcode_i <= SLT;		-- SLTI
			when 58	=> aluOpcode_i <= SLTU;		-- SLTUI
			when 23	=> aluOpcode_i <= SRA_O;	-- SRAI
			when 11	=> aluOpcode_i <= SUBU; 	-- SUBU		
			when others => aluOpcode_i <= NOP;
		end case;
	end process ALU_OP_CODE_P;

end dlx_cu_hw;
