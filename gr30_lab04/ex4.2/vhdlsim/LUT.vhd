library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;


--Look Up table: from OPCODE and FUNC to the corresponding CONTROL WORD (LUT_out)

entity LUT is
  port (

    OPCODE  : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    FUNC    : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
    LUT_OUT : out std_logic_vector(CONTROL_SIZE-1  downto 0));  --CONTROL WORD            

end LUT;

architecture BEHAVIOR of LUT is

begin

  LUT_proc : process(OPCODE, FUNC)

  begin
    if OPCODE = RTYPE then
      case FUNC is --Rtype instructions
        when RTYPE_ADD => LUT_OUT <= OUT_ADD;
        when RTYPE_SUB => LUT_OUT <= OUT_SUB;
        when RTYPE_AND => LUT_OUT <= OUT_AND;
        when RTYPE_OR  => LUT_OUT <= OUT_OR;
        when NOP => LUT_OUT <= OUT_NOP;
        when others    => LUT_OUT <= OUT_NOP;
      end case;
    else
      case OPCODE is --Itype instructions
        when ITYPE_ADDI1  => LUT_OUT <= OUT_ADDI1;
        when ITYPE_SUBI1  => LUT_OUT <= OUT_SUBI1;
        when ITYPE_ANDI1  => LUT_OUT <= OUT_ANDI1;
        when ITYPE_ORI1   => LUT_OUT <= OUT_ORI1;
        when ITYPE_ADDI2  => LUT_OUT <= OUT_ADDI2;
        when ITYPE_SUBI2  => LUT_OUT <= OUT_SUBI2;
        when ITYPE_ANDI2  => LUT_OUT <= OUT_ANDI2;
        when ITYPE_ORI2   => LUT_OUT <= OUT_ORI2;
        when ITYPE_MOV    => LUT_OUT <= OUT_MOV;
        when ITYPE_S_REG1 => LUT_OUT <= OUT_S_REG1;
        when ITYPE_S_REG2 => LUT_OUT <= OUT_S_REG2;
        when ITYPE_S_MEM2 => LUT_OUT <= OUT_S_MEM2;
        when ITYPE_L_MEM1 => LUT_OUT <= OUT_L_MEM1;
        when ITYPE_L_MEM2 => LUT_OUT <= OUT_L_MEM2;
        when others       => LUT_OUT <= OUT_NOP;
      end case;
    end if;

  end process LUT_proc;
  
  
end BEHAVIOR;
