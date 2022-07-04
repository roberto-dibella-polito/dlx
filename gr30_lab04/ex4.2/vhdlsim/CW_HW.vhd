-- HARDWIRED CONTROL UNIT --
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity CU_HW is
  port (
    -- FIRST PIPE STAGE OUTPUTS
    EN1    : out std_logic;  -- enables the register file and the pipeline registers
    RF1    : out std_logic;  -- enables the read port 1 of the register file
    RF2    : out std_logic;  -- enables the read port 2 of the register file
    WF1    : out std_logic;  -- enables the write port of the register file
    -- SECOND PIPE STAGE OUTPUTS
    EN2    : out std_logic;  -- enables the pipe registers
    S1     : out std_logic;  -- input selection of the first multiplexer
    S2     : out std_logic;  -- input selection of the second multiplexer
    ALU1   : out std_logic;  -- alu control bit
    ALU2   : out std_logic;  -- alu control bit
    -- THIRD PIPE STAGE OUTPUTS
    EN3    : out std_logic;  -- enables the memory and the pipeline registers
    RM     : out std_logic;  -- enables the read-out of the memory
    WM     : out std_logic;  -- enables the write-in of the memory
    S3     : out std_logic;  -- input selection of the multiplexer
    -- INPUTS
    OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
    Clk    : in  std_logic;
    Rst    : in  std_logic);            -- Active Low
end CU_HW;

architecture BEHAVIOR of CU_HW is

  component reg_n
    generic (N : integer := 8);
    port (A   : in     std_logic_vector (N-1 downto 0);
          Q   : buffer std_logic_vector (N-1 downto 0);
          CLK : in     std_logic;
          RST : in     std_logic);
  end component;

  component LUT
    port (
      OPCODE  : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
      FUNC    : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
      LUT_OUT : out std_logic_vector(CONTROL_SIZE-1 downto 0));              

  end component;


  signal LUT_out : std_logic_vector(CONTROL_SIZE -1 downto 0);  --LUT output (CONTROL WORD)

-- BITS ORDER (MSB downto LSB)
  -- EN1 | RF1 | RF2 | EN2 | S1 | S2 | ALU1 | ALU2 | EN3 | RM | WM | S3 | WF1


  signal REG1_out : std_logic_vector(9 downto 0);
  signal REG2_out : std_logic_vector(4 downto 0);



begin

  -- Instantiation of the LUT
  LookUpTable : LUT port map (
    OPCODE  => OPCODE,
    FUNC    => FUNC,
    LUT_OUT => LUT_out);


-- The control signals that belong to the second stage of the pipe, must be activated a clock cycle after those of the first stage. 
-- So we use a register to delay them (Reg1). In addition, the control signals that belong to the third stage of the pipe, must be activated a clock cycle after those of the second stage.
-- Then the third stage control signals, which pass through Reg1, are further delayed by a second register (Reg2).

--Reg1 instantiation

  Reg1 : reg_n generic map (N => 10) port map (
    A                         => LUT_out(9 downto 0),
    Q                         => REG1_out,
    CLK                       => Clk,
    RST                       => Rst);

--Reg2 instantiation

  Reg2 : reg_n generic map (N => 5) port map (
    A                         => REG1_out(4 downto 0),
    Q                         => REG2_out,
    CLK                       => Clk,
    RST                       => Rst);


  -- Control word bits order (MSB downto LSB)
  -- EN1 | RF1 | RF2 | EN2 | S1 | S2 | ALU1 | ALU2 | EN3 | RM | WM | S3 | WF1


  EN1  <= LUT_out(12);
  RF1  <= LUT_out(11);
  RF2  <= LUT_out(10);
  EN2  <= REG1_out(9);
  S1   <= REG1_out(8);
  S2   <= REG1_out(7);
  ALU1 <= REG1_out(6);
  ALU2 <= REG1_out(5);
  EN3  <= REG2_out(4);
  RM   <= REG2_out(3);
  WM   <= REG2_out(2);
  S3   <= REG2_out(1);
  WF1  <= REG2_out(0);
  
  
end BEHAVIOR;



