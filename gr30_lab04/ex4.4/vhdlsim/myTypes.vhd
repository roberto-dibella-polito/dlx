library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
	constant MEM_SIZE	  : integer :=  57;
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size
	constant CONTROL_SIZE : integer :=  13;												-- CONTROL output size

-- R-Type instruction -> FUNC field
    constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";    -- ADD RS1,RS2,RD3 			Memory Address 42
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";    -- SUB RS1,RS2,RD3			Memory Address 45
    constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110000"; 	-- AND RS1,RS2,RD3			Memory Address 48
    constant RTYPE_OR  : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110011"; 	-- OR RS1,RS2,RD3			Memory Address 51
    
    constant NOP       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";	--							Memory Address 0    

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111111";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field
    constant ITYPE_ADDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "110110";    -- ADDI1  RS1,RD2,INP1		Memory Address 54
    constant ITYPE_SUBI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";	 -- SUBI1  RS1,RD2,INP1		Memory Address 3
    constant ITYPE_ANDI1  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";    -- ANDI1  RS1,RD2,INP1		Memory Address 6
    constant ITYPE_ORI1   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001"; 	 -- ORI1   RS1,RD2,INP1		Memory Address 9
    constant ITYPE_ADDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";    -- ADDI2  RS1,RD2,INP2		Memory Address 12
    constant ITYPE_SUBI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";	 -- SUBI2  RS1,RD2,INP2		Memory Address 15
    constant ITYPE_ANDI2  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010010";    -- ANDI2  RS1,RD2,INP2		Memory Address 18
    constant ITYPE_ORI2   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101";	 -- ORI2   RS1,RD2,INP2		Memory Address 21
    constant ITYPE_MOV    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";    -- MOV	   RS1,RD2			Memory Address 24
    constant ITYPE_S_REG1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011"; 	 -- S_REG1 RD2,INP1			Memory Address 27
    constant ITYPE_S_REG2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011110";    -- S_REG2 RD2,INP2			Memory Address 30
    constant ITYPE_S_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001"; 	 -- S_MEM2 RD1,RS2,INP2		Memory Address 33
    constant ITYPE_L_MEM1 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";    -- L_MEM1 RS1,RD2,INP1		Memory Address 36
	constant ITYPE_L_MEM2 : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100111";    -- L_MEM2 RS1,RD2,INP2		Memory Address 39
   
-- LUT Output
	constant OUT_ADD 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1111010010001"; --ADD output (CONTROL WORD)
    constant OUT_SUB	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1111010110001"; --SUB output
    constant OUT_AND      : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1111011010001"; --AND output
	constant OUT_OR 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1111011110001"; --OR output
	constant OUT_NOP 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "0000000000000"; --NOP output
	constant OUT_ADDI1 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1011110010001"; --ADDI1 output
	constant OUT_SUBI1 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1011110110001"; --SUBI1 output
	constant OUT_ANDI1 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1011111010001"; --ANDI1 output
	constant OUT_ORI1 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1011111110001"; --ORI1 output
	constant OUT_ADDI2 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101000010001"; --ADDI2 output
	constant OUT_SUBI2 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101000110001"; --SUBI2 output
	constant OUT_ANDI2 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101001010001"; --ANDI2 output
	constant OUT_ORI2 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101001110001"; --ORI2 output
	constant OUT_MOV 	  : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101000010001"; --MOV output
	constant OUT_S_REG1   : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1001100010001"; --S_REG1 output
	constant OUT_S_REG2   : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1001100010001"; --S_REG2 output
	constant OUT_S_MEM2   : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1111000010100"; --S_MEM2 output
	constant OUT_L_MEM1   : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1011110011011"; --L_MEM1 output
	constant OUT_L_MEM2   : std_logic_vector(CONTROL_SIZE - 1 downto 0) :=  "1101000011011"; --L_MEM2 output

	



-- Change the values of the instructions coding as you want, depending also on the type of control unit choosen

end myTypes;

