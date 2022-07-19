-- MANDATORY INSTRUCTIONS
-- ALU instruction -> OPCODE = 0x00
constant ALU_O	: std_logic_vector(FUNC_SIZE-1 downto 0) := "000000";
constant ADD_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100000";
constant AND_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100100";
constant OR_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100101";
constant SGE_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101101";
constant SLE_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101100";
constant SLL_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "000100";
constant SNE_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101001";
constant SRL_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "000110";
constant SUB_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100010";
constant XOR_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100110";
-- General instructions
constant J_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "000010";
constant JAL_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "000011";
constant BEQZ_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "000100";
constant BNEZ_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "000101";
constant ADDI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001000";
constant SUBI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001010";
constant ANDI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001100";
constant ORI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001101";
constant XORI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001110";
constant SLLI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010100";
constant NOP_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010101";
constant SRLI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010110";
constant SNEI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011001";
constant SLEI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011100";
constant SGEI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011101";
constant LW_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "100011";
constant SW_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "101011";
-- OPTIONAL INSTRUCTIONS
-- ALU instruction -> OPCODE = 0x00
constant ADDU_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100001";
constant MULT_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "001110";
constant SEQ_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101000";
constant SGEU_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "111101";
constant SGT_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101011";
constant SGTU_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "111011";
constant SLT_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "101010";
constant SLTU_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "111010";
constant SRA_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "000111";
constant SUBU_FUNC	: std_logic_vector(FUNC_SIZE-1 downto 0) := "100011";
-- General instructions
constant ADDUI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001001";
constant JALR_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010011";
constant JR_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010010";
constant LB_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "100000";
constant LBU_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "100100";
constant LHI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001111";
constant LHU_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "100101";
constant SB_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "101000";
constant SEQI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011000";
constant SGEUI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "111101";
constant SGTI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011011";
constant SGTUI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "111011";
constant SLTI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "011010";
constant SLTUI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "111010";
constant SRAI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "010111";
constant SUBUI_OP	: std_logic_vector(OP_SIZE-1 downto 0) := "001011";


type aluOp is ( 
ADD,
AND,
OR,
SGE,
SLE,
SLL,
SNE,
SRL,
SUB,
XOR,
ADDU,
MULT,
SEQ,
SGEU,
SGT,
SGTU,
SLT,
SLTU,
SRA,
SUBU,
