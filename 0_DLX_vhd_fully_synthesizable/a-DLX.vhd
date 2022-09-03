library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;
use work.DLX_ControlWords.all;

entity DLX is
	generic (
    	IR_SIZE		: integer := 32;       -- Instruction Register Size
    	PC_SIZE		: integer := 32;       -- Program Counter Size
		DATA_SIZE	: integer := 32
    );
	port (
		-- Inputs
		CLK						: in std_logic;		-- Clock
		RST						: in std_logic;		-- Reset:Active-High

		IRAM_ADDRESS			: out std_logic_vector(IR_SIZE - 1 downto 0);
		IRAM_ISSUE				: out std_logic;
		IRAM_READY				: in std_logic;
		IRAM_DATA				: in std_logic_vector(DATA_SIZE-1 downto 0);

		DRAM_ADDRESS			: out std_logic_vector(DATA_SIZE-1 downto 0);
		DRAM_ISSUE				: out std_logic;
		DRAM_READNOTWRITE		: out std_logic;
		DRAM_READY				: in std_logic;
		DRAM_DATA				: inout std_logic_vector(DATA_SIZE-1 downto 0)
	);
end DLX;

-- The provided architecture was modified to adapt to 
-- the our design choices.
-- The current version of our DLX does not support cache memories.

architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------

  -- Datapath
	component DLX_DP
		generic(
			ADDR_SIZE	: integer := 32;
			DATA_SIZE	: integer := 32	);
		port(
			CLK				: in std_logic;
			RST				: in std_logic;	-- Active HIGH
			
			-- Pipeline registers enable and clear signal
			PIPE_IF_ID_EN	: in std_logic;
			PIPE_ID_EX_EN	: in std_logic;
			PIPE_EX_MEM_EN	: in std_logic;
			PIPE_MEM_WB_EN	: in std_logic;
			
			PIPE_CLEAR_n	: in std_logic;
			
			-- Instruction Memory interface
			IRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
			IRAM_DATA		: in std_logic_vector(DATA_SIZE-1 downto 0);
			
			-- Instruction port, forwarded to CU
			INSTR			: out std_logic_vector(DATA_SIZE-1 downto 0);	
			
			-- ID control signals
			-- Windowed register file
			CALL			: in std_logic;
			RET				: in std_logic;
			SPILL			: out std_logic;
			FILL			: out std_logic;
			RF_EN			: in std_logic;
			RS1_EN			: in std_logic;
			RS2_EN			: in std_logic;
			
			IMM_ISOFF		: in std_logic;	
			
			-- EX control signals
			MUXA_SEL		: in std_logic;
			MUXB_SEL		: in std_logic;
			BRANCH_T		: out std_logic;
			ALU_OP			: in aluOp;
			MEM_IN_EN		: in std_logic;
			
			-- DRAM Data Interface
			DRAM_ADDRESS	: out std_logic_vector(ADDR_SIZE-1 downto 0);
			DRAM_DATA		: inout std_logic_vector(2*DATA_SIZE-1 downto 0);
			
			-- MEM control signals
			--LMD_LATCH_EN	: in std_logic;	-- LMD Register Latch Enable
			JUMP_EN			: in std_logic;	-- JUMP Enable Signal for PC input MUX
			PC_LATCH_EN		: in std_logic;	-- Pipelined version -> with no stalls, always active
			
			-- WB Control signals
			WB_MUX_SEL		: in std_logic;  -- Write Back MUX Sel
			RF_WE			: in std_logic  -- Register File Write Enable
		);
	end component;
  
  -- Control Unit
	component dlx_cu
		generic (
			MICROCODE_MEM_SIZE	: integer := 10;	-- Microcode Memory Size
			FUNC_SIZE			: integer := 11;	-- Func Field Size for R-Type Ops
			OP_CODE_SIZE		: integer := 6;		-- Op Code Size
			IR_SIZE				: integer := 32;	-- Instruction Register Size    
			CW_SIZE				: integer := 15
		);	-- Control Word Size

		port (
			Clk					: in  std_logic;	-- Clock
			Rst					: in  std_logic;	-- Reset:Active-High

			-- Instruction Register
			IR_IN				: in  std_logic_vector(IR_SIZE - 1 downto 0);
			
			-- IRAM control interface
			IRAM_ISSUE			: out std_logic;
			IRAM_READY			: in std_logic;

			-- Pipeline control signals (ID, EX, MEM)
			PIPE_IF_ID_EN		: out std_logic;
			PIPE_ID_EX_EN		: out std_logic;
			PIPE_EX_MEM_EN		: out std_logic;
			PIPE_MEM_WB_EN		: out std_logic;

			PIPE_CLEAR_n		: out std_logic;

			-- ID control signals
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
			MEM_IN_EN			: out std_logic;

			-- MEM Control Signals
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
	end component;


	----------------------------------------------------------------
	-- Signals Declaration
	----------------------------------------------------------------

	-- Control Unit Bus signals
	signal instr_i			: std_logic_vector(DATA_SIZE-1 downto 0);
	signal pipe_if_id_en_i	: std_logic;
	signal pipe_id_ex_en_i	: std_logic;
	signal pipe_ex_mem_en_i	: std_logic;
	signal pipe_mem_wb_en_i	: std_logic;
	signal pipe_clear_n_i	: std_logic;
	signal rf_call_i		: std_logic;
	signal rf_ret_i			: std_logic;
	signal rf_spill_i		: std_logic;
	signal rf_fill_i		: std_logic;
	signal rf_en_i			: std_logic;
	signal rf_rs1_en_i		: std_logic;
	signal rf_rs2_en_i		: std_logic;
	signal imm_isoff_i		: std_logic;
	signal muxA_sel_i		: std_logic;
	signal muxB_sel_i		: std_logic;
	signal mem_in_en_i		: std_logic;
	signal is_zero_i		: std_logic;
	signal alu_op_i			: aluOp;
	signal dram_issue_i		: std_logic;
	signal dram_rd_wr_i		: std_logic;
	signal dram_ready_i		: std_logic;
	signal jump_en_i		: std_logic;
	signal pc_latch_en_i	: std_logic;
	signal wb_mux_sel_i		: std_logic;
	signal rf_we_i			: std_logic;
	signal iram_address_i	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal iram_data_i		: std_logic_vector(DATA_SIZE-1 downto 0);
	
	
begin  -- DLX

	CU_I: dlx_cu generic map(
		MICROCODE_MEM_SIZE	=> uC_MEM_SIZE,
		FUNC_SIZE			=> FUNC_SIZE,
		OP_CODE_SIZE		=> OP_SIZE,
		IR_SIZE				=> INSTR_SIZE,    
		CW_SIZE				=> CW_SIZE
	)
	port map(
		Clk					=> CLK,
		Rst					=> RST,
		IR_IN				=> instr_i,
		IRAM_ISSUE			=> IRAM_ISSUE,
		IRAM_READY			=> IRAM_READY,
		PIPE_IF_ID_EN		=> pipe_if_id_en_i,
		PIPE_ID_EX_EN		=> pipe_id_ex_en_i,
		PIPE_EX_MEM_EN		=> pipe_ex_mem_en_i,
		PIPE_MEM_WB_EN		=> pipe_mem_wb_en_i,
		PIPE_CLEAR_n		=> pipe_clear_n_i,
		RF_CALL				=> rf_call_i,
		RF_RET				=> rf_ret_i,
		RF_SPILL			=> rf_spill_i,
		RF_FILL				=> rf_fill_i,
		RF_EN				=> rf_en_i,
		RF_RS1_EN			=> rf_rs1_en_i,
		RF_RS2_EN			=> rf_rs2_en_i,
		IMM_ISOFF			=> imm_isoff_i,	
		MUXA_SEL           	=> muxA_sel_i,
		MUXB_SEL           	=> muxB_sel_i,
		MEM_IN_EN			=> mem_in_en_i,
		IS_ZERO				=> is_zero_i,
		ALU_OP				=> alu_op_i,
		DRAM_ISSUE			=> DRAM_ISSUE,
		DRAM_READNOTWRITE	=> DRAM_READNOTWRITE,
		DRAM_READY			=> DRAM_READY,
		JUMP_EN            	=> jump_en_i,
		PC_LATCH_EN        	=> pc_latch_en_i,
		WB_MUX_SEL         	=> wb_mux_sel_i,
		RF_WE              	=> rf_we_i
	);  
	
	dp: DLX_DP generic map(
		ADDR_SIZE	=> INSTR_SIZE,
		DATA_SIZE	=> DATA_SIZE
	)
	port map(
		CLK				=> CLK,
		RST				=> RST,
		PIPE_IF_ID_EN	=> pipe_if_id_en_i,
		PIPE_ID_EX_EN	=> pipe_id_ex_en_i,
		PIPE_EX_MEM_EN	=> pipe_ex_mem_en_i,
		PIPE_MEM_WB_EN	=> pipe_mem_wb_en_i,
		PIPE_CLEAR_n	=> pipe_clear_n_i,
		IRAM_ADDRESS	=> iram_address_i,
		IRAM_DATA		=> iram_data_i,
		INSTR			=> instr_i,
		CALL			=> rf_call_i,
		RET				=> rf_ret_i,
		SPILL			=> rf_spill_i,
		FILL			=> rf_fill_i,
		RF_EN			=> rf_en_i,
		RS1_EN			=> rf_rs1_en_i,
		RS2_EN			=> rf_rs2_en_i,
		IMM_ISOFF		=> imm_isoff_i,	
		MUXA_SEL		=> muxA_sel_i,
		MUXB_SEL		=> muxB_sel_i,
		MEM_IN_EN		=> mem_in_en_i,
 		BRANCH_T		=> is_zero_i,
		ALU_OP			=> alu_op_i,
		DRAM_ADDRESS	=> DRAM_ADDRESS,
		DRAM_DATA		=> DRAM_DATA,
		JUMP_EN			=> jump_en_i,
		PC_LATCH_EN		=> pc_latch_en_i,
		WB_MUX_SEL		=> wb_mux_sel_i,
		RF_WE			=> rf_we_i
	);

	IRAM_ADDRESS 	<= iram_address_i;
	iram_data_i		<= IRAM_DATA;

end dlx_rtl;
