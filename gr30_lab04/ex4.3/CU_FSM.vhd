-- HARDWIRED CONTROL UNIT --
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity CU_FSM is
  port (
    -- FIRST PIPE STAGE OUTPUTS
    EN1    : out std_logic;  -- enables the register file and the pipeline registers
    RF1    : out std_logic;  -- enables the read port 1 of the register file
    RF2    : out std_logic;  -- enables the read port 2 of the register file
    WF1    : out std_logic;  -- enables the write port of the register file
    -- SECOND PIPE STAGE OUTPUTS
    EN2    : out std_logic;             -- enables the pipe registers
    S1     : out std_logic;  -- input selection of the first multiplexer
    S2     : out std_logic;  -- input selection of the second multiplexer
    ALU1   : out std_logic;             -- alu control bit
    ALU2   : out std_logic;             -- alu control bit
    -- THIRD PIPE STAGE OUTPUTS
    EN3    : out std_logic;  -- enables the memory and the pipeline registers
    RM     : out std_logic;             -- enables the read-out of the memory
    WM     : out std_logic;             -- enables the write-in of the memory
    S3     : out std_logic;             -- input selection of the multiplexer
    -- INPUTS
    OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
    Clk    : in  std_logic;
    Rst    : in  std_logic);            -- Active Low
end CU_FSM;

architecture BEHAVIOR of CU_FSM is

  type State_type is (reset_state, stage1_state, stage2_state, stage3_state);
  signal current_state, next_state : State_type;

  signal stage1_control: std_logic_vector(2 downto 0); -- control signals associated to the first stage (EN1 | RF1 | RF2 )
  signal stage2_control: std_logic_vector(4 downto 0); -- control signals associated to the second stage ( EN2 | S1 | S2 | ALU1 | ALU2 )
  signal stage3_control: std_logic_vector(4 downto 0); -- control signals associated to the third stage ( EN3 | RM | WM | S3 | WF1)

begin
  
  -- Control word bits order (MSB downto LSB)
  -- EN1 | RF1 | RF2 | EN2 | S1 | S2 | ALU1 | ALU2 | EN3 | RM | WM | S3 | WF1

------------------ NEXT STATE GENERATION NETWORK ----------------------------------

  FSM_next_state_gen : process (current_state, RST)
  begin

    -- Synchronous reset
    if(RST = '0') then next_state <= reset_state;

    else
      
      case current_state is

        when reset_state => next_state <= stage1_state;
                            
        when stage1_state => next_state <= stage2_state;

        when stage2_state => next_state <= stage3_state;

        when stage3_state => next_state <= stage1_state;

        when others => next_state <= reset_state;

      end case;
    end if;
  end process;
  

  ----------------------------- STATE UPDATING ----------------------------------
  FSM_State_transition : process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      current_state <= next_state;
    end if;
  end process;

----------------------------- OUTPUT GENERATION ----------------------------------  
  FSM_outputs : process(current_state,opcode,func)
  begin

    --Default values
    
    stage1_control <= "000"; --EN1 <= '0'; RF1 <= '0'; RF2 <= '0'; 
    stage2_control <= "00000"; --EN2 <= '0'; S1 <= '0'; S2 <= '0'; ALU1 <= '0'; ALU2 <= '0'; 
    stage3_control <= "00000"; --EN3 <= '0'; RM <= '0'; WM <= '0'; S3 <= '0'; WF1<= '0';
    

    case(current_state) is
      
      when stage1_state => 

    if OPCODE = RTYPE then
      case FUNC is --Rtype instructions
        when RTYPE_ADD => stage1_control <= OUT_ADD(12 downto 10);
        when RTYPE_SUB => stage1_control <= OUT_SUB(12 downto 10);
        when RTYPE_AND => stage1_control <= OUT_AND(12 downto 10);
        when RTYPE_OR  => stage1_control <= OUT_OR(12 downto 10);
        when NOP 	   => stage1_control <= OUT_NOP(12 downto 10);
        when others    => stage1_control <= OUT_NOP(12 downto 10);
      end case;
    else
      case OPCODE is --Itype instructions
        when ITYPE_ADDI1  => stage1_control <= OUT_ADDI1(12 downto 10);
        when ITYPE_SUBI1  => stage1_control <= OUT_SUBI1(12 downto 10);
        when ITYPE_ANDI1  => stage1_control <= OUT_ANDI1(12 downto 10);
        when ITYPE_ORI1   => stage1_control <= OUT_ORI1(12 downto 10);
        when ITYPE_ADDI2  => stage1_control <= OUT_ADDI2(12 downto 10);
        when ITYPE_SUBI2  => stage1_control <= OUT_SUBI2(12 downto 10);
        when ITYPE_ANDI2  => stage1_control <= OUT_ANDI2(12 downto 10);
        when ITYPE_ORI2   => stage1_control <= OUT_ORI2(12 downto 10);
        when ITYPE_MOV    => stage1_control <= OUT_MOV(12 downto 10);
        when ITYPE_S_REG1 => stage1_control <= OUT_S_REG1(12 downto 10);
        when ITYPE_S_REG2 => stage1_control <= OUT_S_REG2(12 downto 10);
        when ITYPE_S_MEM2 => stage1_control <= OUT_S_MEM2(12 downto 10);
        when ITYPE_L_MEM1 => stage1_control <= OUT_L_MEM1(12 downto 10);
        when ITYPE_L_MEM2 => stage1_control <= OUT_L_MEM2(12 downto 10);
        when others       => stage1_control <= OUT_NOP(12 downto 10);
      end case;
    end if;

    when stage2_state =>
    
    if OPCODE = RTYPE then
      case FUNC is --Rtype instructions
        when RTYPE_ADD => stage2_control <= OUT_ADD(9 downto 5);
        when RTYPE_SUB => stage2_control <= OUT_SUB(9 downto 5);
        when RTYPE_AND => stage2_control <= OUT_AND(9 downto 5);
        when RTYPE_OR  => stage2_control <= OUT_OR(9 downto 5);
        when NOP 	   => stage2_control <= OUT_NOP(9 downto 5);
        when others    => stage2_control <= OUT_NOP(9 downto 5);
      end case;
    else
      case OPCODE is --Itype instructions
        when ITYPE_ADDI1  => stage2_control <= OUT_ADDI1(9 downto 5);
        when ITYPE_SUBI1  => stage2_control <= OUT_SUBI1(9 downto 5);
        when ITYPE_ANDI1  => stage2_control <= OUT_ANDI1(9 downto 5);
        when ITYPE_ORI1   => stage2_control <= OUT_ORI1(9 downto 5);
        when ITYPE_ADDI2  => stage2_control <= OUT_ADDI2(9 downto 5);
        when ITYPE_SUBI2  => stage2_control <= OUT_SUBI2(9 downto 5);
        when ITYPE_ANDI2  => stage2_control <= OUT_ANDI2(9 downto 5);
        when ITYPE_ORI2   => stage2_control <= OUT_ORI2(9 downto 5);
        when ITYPE_MOV    => stage2_control <= OUT_MOV(9 downto 5);
        when ITYPE_S_REG1 => stage2_control <= OUT_S_REG1(9 downto 5);
        when ITYPE_S_REG2 => stage2_control <= OUT_S_REG2(9 downto 5);
        when ITYPE_S_MEM2 => stage2_control <= OUT_S_MEM2(9 downto 5);
        when ITYPE_L_MEM1 => stage2_control <= OUT_L_MEM1(9 downto 5);
        when ITYPE_L_MEM2 => stage2_control <= OUT_L_MEM2(9 downto 5);
        when others       => stage2_control <= OUT_NOP(9 downto 5);
      end case;
    end if;

    when stage3_state =>

    if OPCODE = RTYPE then
      case FUNC is --Rtype instructions
        when RTYPE_ADD => stage3_control <= OUT_ADD(4 downto 0);
        when RTYPE_SUB => stage3_control <= OUT_SUB(4 downto 0);
        when RTYPE_AND => stage3_control <= OUT_AND(4 downto 0);
        when RTYPE_OR  => stage3_control <= OUT_OR(4 downto 0);
        when NOP 	   => stage3_control <= OUT_NOP(4 downto 0);
        when others    => stage3_control <= OUT_NOP(4 downto 0);
      end case;
    else
      case OPCODE is --Itype instructions
        when ITYPE_ADDI1  => stage3_control <= OUT_ADDI1(4 downto 0);
        when ITYPE_SUBI1  => stage3_control <= OUT_SUBI1(4 downto 0);
        when ITYPE_ANDI1  => stage3_control <= OUT_ANDI1(4 downto 0);
        when ITYPE_ORI1   => stage3_control <= OUT_ORI1(4 downto 0);
        when ITYPE_ADDI2  => stage3_control <= OUT_ADDI2(4 downto 0);
        when ITYPE_SUBI2  => stage3_control <= OUT_SUBI2(4 downto 0);
        when ITYPE_ANDI2  => stage3_control <= OUT_ANDI2(4 downto 0);
        when ITYPE_ORI2   => stage3_control <= OUT_ORI2(4 downto 0);
        when ITYPE_MOV    => stage3_control <= OUT_MOV(4 downto 0);
        when ITYPE_S_REG1 => stage3_control <= OUT_S_REG1(4 downto 0);
        when ITYPE_S_REG2 => stage3_control <= OUT_S_REG2(4 downto 0);
        when ITYPE_S_MEM2 => stage3_control <= OUT_S_MEM2(4 downto 0);
        when ITYPE_L_MEM1 => stage3_control <= OUT_L_MEM1(4 downto 0);
        when ITYPE_L_MEM2 => stage3_control <= OUT_L_MEM2(4 downto 0);
        when others       => stage3_control <= OUT_NOP(4 downto 0);
      end case;
    end if;

    when others =>
    stage1_control <= "000"; --EN1 <= '0'; RF1 <= '0'; RF2 <= '0'; 
    stage2_control <= "00000"; --EN2 <= '0'; S1 <= '0'; S2 <= '0'; ALU1 <= '0'; ALU2 <= '0'; 
    stage3_control <= "00000"; --EN3 <= '0'; RM <= '0'; WM <= '0'; S3 <= '0'; WF1<= '0';
    
  end case;
end process;


EN1   <= stage1_control(2) ; 
RF1   <= stage1_control(1) ; 
RF2   <= stage1_control(0) ; 
EN2   <= stage2_control(4) ; 
S1    <= stage2_control(3) ; 
S2    <= stage2_control(2) ; 
ALU1  <= stage2_control(1) ; 
ALU2  <= stage2_control(0) ; 
EN3   <= stage3_control(4) ; 
RM    <= stage3_control(3) ; 
WM    <= stage3_control(2) ; 
S3    <= stage3_control(1) ; 
WF1   <= stage3_control(0) ;

end BEHAVIOR;



