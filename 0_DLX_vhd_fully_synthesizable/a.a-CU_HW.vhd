library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
--use ieee.numeric_std.all;
--use work.all;

entity dlx_cu is
	generic (
		MICROCODE_MEM_SIZE	: integer := 10;	-- Microcode Memory Size
		FUNC_SIZE			: integer := 11;	-- Func Field Size for R-Type Ops
		OP_CODE_SIZE		: integer := 6;		-- Op Code Size
		IR_SIZE				: integer := 32;	-- Instruction Register Size    
		CW_SIZE				: integer := 15
	);	-- Control Word Size

	port (
		Clk					: in  std_logic;	-- Clock
		Rst_n				: in  std_logic;	-- Reset:Active-Low

		-- Instruction Register
		IR_IN				: in  std_logic_vector(IR_SIZE - 1 downto 0);
	
		-- IRAM control signals
		IRAM_ISSUE			: in std_logic;
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
		RF_CALL				: out std_logic;
		RF_RET				: out std_logic;
		RF_SPILL			: in std_logic;
		RF_FILL				: in std_logic;
		RF_EN				: out std_logic;
		RF_RS1_EN			: out std_logic;
		RF_RS2_EN			: out std_logic;
		IMM_ISOFF			: out std_logic;	

		-- EX Control Signals
		MUXA_SEL           	: out std_logic;  	-- MUX-A Sel
		MUXB_SEL           	: out std_logic;  	-- MUX-B Sel
		IS_ZERO				: in std_logic;
		ALU_OP				: out aluOp;		-- FUNC field

		-- Controlled by PIPE_EX_MEM_EN
		--ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
		--EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero

		-- MEM Control Signals
		-- . DRAM control interface
		DRAM_ISSUE			: out std_logic;
		DRAM_READNOTWRITE	: out std_logic;
		DRAM_READY			: in std_logic;

		--LMD_LATCH_EN       : out std_logic;	-- LMD Register Latch Enable
		JUMP_EN            : out std_logic;		-- JUMP Enable Signal for PC input MUX
		PC_LATCH_EN        : out std_logic;		-- Program Counte Latch Enable

		-- WB Control signals
		WB_MUX_SEL         : out std_logic;		-- Write Back MUX Sel
		RF_WE              : out std_logic		-- Register File Write Enable

	);  
end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

	type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
	signal cw_mem : mem_array := (
		RR_CW, 				-- 0x00	R type: IS IT CORRECT?
		NOP_CW,				-- 0x01
		not_implemented,	-- 0x02	J
		not_implemented, 	-- 0x03	JAL 
		not_implemented, 	-- 0x04	BEQZ
		not_implemented, 	-- 0x05	BNEZ
		not_implemented, 	-- 0x06
		not_implemented,	-- 0x07
		RI_CW, 				-- 0x08	ADDI
		not_implemented,	-- 0x09	ADDUI
		RI_CW,				-- 0x0A	SUBI
		not_implemented,	-- 0x0B	SUBUI
		RI_CW,				-- 0x0C	ANDI
		RI_CW,				-- 0x0D	ORI
		RI_CW,				-- 0x0E	XORI
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
		not_implemented,	-- 0x3A	SLTUI
		not_implemented,	-- 0x3B	SGTUI
		not_implemented,	-- 0x3C	
		not_implemented,	-- 0x3D	SGEUI
		not_implemented,	-- 0x3E
		not_implemented		-- 0x3F
	);	
	
	signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
	signal IR_func : std_logic_vector(FUNC_SIZE downto 0);   -- Func part of IR when Rtype
	signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem

	-- control word is shifted to the correct stage
	signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
	signal cw2 : std_logic_vector(CW_SIZE - 1 - 4 downto 0); -- second stage
	signal cw3 : std_logic_vector(CW_SIZE - 1 - 6 downto 0); -- third stage
	signal cw4 : std_logic_vector(CW_SIZE - 1 - 9 downto 0); -- fourth stage

	signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
	signal aluOpcode1: aluOp := NOP;
	signal aluOpcode2: aluOp := NOP;

	signal pipe_enable_i, pipe_clear_i, stall : std_logic;
	
begin  -- dlx_cu_rtl

	IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
	IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

	cw <= cw_mem(conv_integer(IR_opcode));
	
	-- PIPELINE ENABLE SIGNAL
	-- For now, all the pipeline register will remain ACTIVE
	-- and a new instruction will be fetched every clk
	stall <= '0';
	
	pipe_clear_i	<= '1';			-- For now, no branch instruction is created
	pipe_enable_i 	<= not stall;
	PC_LATCH_EN		<= not stall;
	
	PIPE_IF_ID_EN		<= pipe_enable_i;
	
	RF_EN				<= cw1(CW_SIZE-1);
	RF_RS1_EN			<= cw1(CW_SIZE-2);
	RF_RS2_EN			<= cw1(CW_SIZE-3);
	IMM_ISOFF			<= cw1(CW_SIZE-4);
	
	PIPE_ID_EX_EN		<= pipe_enable_i;
	
	MUXA_SEL			<= cw2(CW_SIZE-5);
	MUXB_SEL			<= cw2(CW_SIZE-6);
	
	PIPE_EX_MEM_EN		<= pipe_enable_i;
	
	DRAM_ISSUE			<= cw3(CW_SIZE-7);
	DRAM_READNOTWRITE	<= cw3(CW_SIZE-8);
	JUMP_EN				<= cw3(CW_SIZE-9);
	
	PIPE_MEM_WB_EN		<= pipe_enable_i;
	
	WB_MUX_SEL			<= cw4(CW_SIZE-10);
	RF_WE				<= cw4(CW_SIZE-11);

	-- process to pipeline control words
	CW_PIPE: process (Clk, Rst)
	begin  -- process Clk
		if Rst = '0' then                   -- asynchronous reset (active low)
			cw1 <= (others => '0');
			cw2 <= (others => '0');
			cw3 <= (others => '0');
			cw4 <= (others => '0');
			--cw5 <= (others => '0');
			aluOpcode1 <= NOP;
			aluOpcode2 <= NOP;
			aluOpcode3 <= NOP;
		elsif Clk'event and Clk = '1' then  -- rising clock edge
			cw1 <= cw;
			cw2 <= cw1(CW_SIZE - 1 - 4 downto 0);
			cw3 <= cw2(CW_SIZE - 1 - 6 downto 0);
			cw4 <= cw3(CW_SIZE - 1 - 9 downto 0);

			aluOpcode1 <= aluOpcode_i;
			aluOpcode2 <= aluOpcode1;
		
		end if;
	end process CW_PIPE;

	ALU_OPCODE <= aluOpcode2;

	-- purpose: Generation of ALU OpCode
	-- type   : combinational
	-- inputs : IR_i
	-- outputs: aluOpcode
	ALU_OP_CODE_P : process (IR_opcode, IR_func)
	begin  -- process ALU_OP_CODE_P
		case IR_opcode is
			-- case of R type requires analysis of FUNC
			when RR_OP =>
				case IR_func is
					when ADD_FUNC 	=> aluOpcode_i <= ADD; 
					when AND_FUNC 	=> aluOpcode_i <= AND_O; 
					when OR_FUNC	=> aluOpcode_i <= OR_O; 
					when SGE_FUNC	=> aluOpcode_i <= SGE;
					when SLE_FUNC	=> aluOpcode_i <= SLE; 
					when SLL_FUNC	=> aluOpcode_i <= SLL_O;
					when SNE_FUNC	=> aluOpcode_i <= SNE; 
					when SRL_FUNC	=> aluOpcode_i <= SRL_O;
					when SUB_FUNC	=> aluOpcode_i <= SUB; 
					when XOR_FUNC	=> aluOpcode_i <= XOR_O;
					when ADDU_FUNC	=> aluOpcode_i <= ADDU;	-- for now 
					when MULT_FUNC	=> aluOpcode_i <= MULT;	-- for now
					when SEQ_FUNC	=> aluOpcode_i <= SEQ; 
					when SGEU_FUNC	=> aluOpcode_i <= SGEU;
					when SGT_FUNC	=> aluOpcode_i <= SGT; 
					when SGTU_FUNC	=> aluOpcode_i <= SGTU;
					when SLT_FUNC	=> aluOpcode_i <= SLT;
					when SLTU_FUNC	=> aluOpcode_i <= SLTU; 
					when SRA_FUNC	=> aluOpcode_i <= SRA_O;
					when SUBU_FUNC	=> aluOpcode_i <= SUBU; 
					when others		=> aluOpcode_i <= NOP;
				end case;
			when J_OP		=> aluOpcode_i <= NOP; -- j
			when JAL_OP		=> aluOpcode_i <= NOP; -- jal
			when BEQZ_OP	=> aluOpcode_i <= NOP;
			when BNEZ_OP	=> aluOpcode_i <= NOP;
			when ADDI_OP	=> aluOpcode_i <= ADD;
			when SUBI_OP	=> aluOpcode_i <= SUB;
			when ANDI_OP	=> aluOpcode_i <= AND_O;
			when ORI_OP		=> aluOpcode_i <= OR_O;
			when XORI_OP	=> aluOpcode_i <= XOR_O;
			when SLLI_OP	=> aluOpcode_i <= SLL_O;
			when NOP_OP		=> aluOpcode_i <= NOP;
			when SRLI_OP	=> aluOpcode_i <= SRL_O;
			when SNEI_OP	=> aluOpcode_i <= SNEI;
			when SLEI_OP	=> aluOpcode_i <= SLEI;
			when SGEI_OP	=> aluOpcode_i <= SGEI;
			when LW_OP		=> aluOpcode_i <= ADD;
			when SW_OP		=> aluOpcode_i <= ADD;
			when ADDUI_OP	=> aluOpcode_i <= NOP; -- TO BE VERIFIED
			when JALR_OP	=> aluOpcode_i <= NOP; 
			when JR_OP		=> aluOpcode_i <= NOP; 
			when LBU_OP		=> aluOpcode_i <= NOP; 
			when LHI_OP		=> aluOpcode_i <= NOP; 
			when LHU_OP		=> aluOpcode_i <= NOP; 
			when SB_OP		=> aluOpcode_i <= NOP; 
			when SEQI_OP	=> aluOpcode_i <= NOP;
			when SGEUI_OP	=> aluOpcode_i <= SGEU;
			when SGTUI_OP	=> aluOpcode_i <= SGTU;
			when SLTI_OP	=> aluOpcode_i <= SLT;
			when SLTUI_OP	=> aluOpcode_i <= SLTU;
			when SRAI_OP	=> aluOpcode_i <= SRA_O;
			when SUBUI_OP	=> aluOpcode_i <= SUBU; 			
			when others => aluOpcode_i <= NOP;
		end case;
	end process ALU_OP_CODE_P;


end dlx_cu_hw;
