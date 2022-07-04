library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity CU_UP is
  port (
    -- FIRST PIPE STAGE OUTPUTS
    EN1    : out std_logic;               -- enables the register file and the pipeline registers
    RF1    : out std_logic;               -- enables the read port 1 of the register file
    RF2    : out std_logic;               -- enables the read port 2 of the register file
    WF1    : out std_logic;               -- enables the write port of the register file
    -- SECOND PIPE STAGE OUTPUTS
    EN2    : out std_logic;               -- enables the pipe registers
    S1     : out std_logic;               -- input selection of the first multiplexer
    S2     : out std_logic;               -- input selection of the second multiplexer
    ALU1   : out std_logic;               -- alu control bit
    ALU2   : out std_logic;               -- alu control bit
    -- THIRD PIPE STAGE OUTPUTS
    EN3    : out std_logic;               -- enables the memory and the pipeline registers
    RM     : out std_logic;               -- enables the read-out of the memory
    WM     : out std_logic;               -- enables the write-in of the memory
    S3     : out std_logic;               -- input selection of the multiplexer
    -- INPUTS
    OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);              
    Clk : in std_logic;
    Rst : in std_logic);                  -- Active Low
end CU_UP;

architecture STRUCTURE of CU_UP is
  
  type mem_array is array (integer range 0 to 63) of std_logic_vector(12 downto 0);
  
  -- MICROCODE MEMORY
  -- For each instruction there are three stages. For each stage there is a control word, in which the control signals belonging to that stage are set 
  -- on the basis of the OPCODE and the FUNC input to the CU, while the other control signals are set to zero. 
  -- The memory is organized in the following way:
  --  ___________
  -- |  OUT_NOP  | <- Address 0:  First stage output for NOP instruction
  -- |           | <- Address 1:  Second stage output for NOP
  -- |___________| <- Address 2:  Third stage output for NOP
  -- | OUT_SUBI1 | <- Address 3:  First stage output for SUBI1 instruction
  -- |           | <- Address 4:  Second stage output for SUBI1
  -- |___________| <- Address 5:  Third stage output for SUBI1
  -- | OUT_ANDI1 | <- Address 6:  First stage output for ANDI1     
  --
  -- ...And so on
  
  signal MEM: mem_array := (     OUT_NOP(12 downto 10)  & "0000000000", -- Address 0
                                "000" & OUT_NOP(9 downto 5) & "00000",
                                "00000000" & OUT_NOP(4 downto 0),
                                OUT_SUBI1(12 downto 10) & "0000000000", -- Address 3
                                "000" & OUT_SUBI1(9 downto 5) & "00000",
                                "00000000" & OUT_SUBI1(4 downto 0),
                                OUT_ANDI1(12 downto 10) & "0000000000", -- Address 6
                                "000" & OUT_ANDI1(9 downto 5) & "00000",
                                "00000000" & OUT_ANDI1(4 downto 0),
                                OUT_ORI1(12 downto 10)  & "0000000000",  -- Address 9
                                "000" & OUT_ORI1(9 downto 5) & "00000",
                                "00000000" & OUT_ORI1(4 downto 0),
                                OUT_ADDI2(12 downto 10)  & "0000000000", -- Address 12
                                "000" & OUT_ADDI2(9 downto 5) & "00000",
                                "00000000" & OUT_ADDI2(4 downto 0),
                                OUT_SUBI2(12 downto 10)  & "0000000000", -- Address 15
                                "000" & OUT_SUBI2(9 downto 5) & "00000",
                                "00000000" & OUT_SUBI2(4 downto 0),
                                OUT_ANDI2(12 downto 10)  & "0000000000", -- Address 18
                                "000" & OUT_ANDI2(9 downto 5) & "00000",
                                "00000000" & OUT_ANDI2(4 downto 0),
                                OUT_ORI2(12 downto 10)  & "0000000000",  -- Address 21
                                "000" & OUT_ORI2(9 downto 5) & "00000",
                                "00000000" & OUT_ORI2(4 downto 0),
                                OUT_MOV(12 downto 10)  & "0000000000",   -- Address 24
                                "000" & OUT_MOV(9 downto 5) & "00000",
                                "00000000" & OUT_MOV(4 downto 0),
                                OUT_S_REG1(12 downto 10)  & "0000000000",-- Address 27
                                "000" & OUT_S_REG1(9 downto 5) & "00000",
                                "00000000" & OUT_S_REG1(4 downto 0),
                                OUT_S_REG2(12 downto 10)  & "0000000000",-- Address 30
                                "000" & OUT_S_REG2(9 downto 5) & "00000",
                                "00000000" & OUT_S_REG2(4 downto 0),
                                OUT_S_MEM2(12 downto 10)  & "0000000000",-- Address 33 
                                "000" & OUT_S_MEM2(9 downto 5) & "00000",
                                "00000000" & OUT_S_MEM2(4 downto 0),
                                OUT_L_MEM1(12 downto 10)  & "0000000000",-- Address 36
                                "000" & OUT_L_MEM1(9 downto 5) & "00000",
                                "00000000" & OUT_L_MEM1(4 downto 0),
                                OUT_L_MEM2(12 downto 10)  & "0000000000",-- Address 39
                                "000" & OUT_L_MEM2(9 downto 5) & "00000",
                                "00000000" & OUT_L_MEM2(4 downto 0),
                                OUT_ADD(12 downto 10)  & "0000000000",   -- Address 42
                                "000" & OUT_ADD(9 downto 5) & "00000",
                                "00000000" & OUT_ADD(4 downto 0),
                                OUT_SUB(12 downto 10)  & "0000000000",   -- Address 45
                                "000" & OUT_SUB(9 downto 5)  & "00000",
                                "00000000" & OUT_SUB(4 downto 0),
                                OUT_AND(12 downto 10)  & "0000000000",   -- Address 48
                                "000" & OUT_AND(9 downto 5) & "00000",
                                "00000000" & OUT_AND(4 downto 0),
                                OUT_OR(12 downto 10)  & "0000000000",    -- Address 51
                                "000" & OUT_OR(9 downto 5) & "00000",
                                "00000000" & OUT_OR(4 downto 0),
                                OUT_ADDI1(12 downto 10) & "0000000000", -- Address 54
                                "000" & OUT_ADDI1(9 downto 5) & "00000",
                                "00000000" & OUT_ADDI1(4 downto 0),
                                others => "0000000000000");

  component ring_counter
    port( CLK,RESET : in std_logic;
          Q         : inout std_logic_vector(2 downto 0));
  end component;

  component mux2to1 
    generic (N : integer);
    port (IN0,IN1 : in std_logic_vector (N-1 downto 0); --input signals
          SEL: in std_logic; --select signal
          MUX_OUT : out std_logic_vector (N-1 downto 0));--N bits output
  end component;

  component reg_n
    GENERIC 	( N : INTEGER := 6 );
    PORT		( A : in std_logic_vector (N-1 downto 0);
                          Q : out std_logic_vector (N-1 downto 0);
                          CLK	: in Std_logic;
                          RST_n	: In std_logic );
  end component;

  signal ext_addr_sel : std_logic;  -- Selection of EXTERNAL address (OPCODE or FUNC)
  signal ext_addr : std_logic_vector(5 downto 0); --external address (OPCODE or FUNC) 
  signal mem_addr_incremented: std_logic_vector(5 downto 0); --external address should be incremented two times in order to access the cells associated to the second and third stage
  signal mem_addr_ff : std_logic_vector(5 downto 0); -- input of a register, that is used to synchronize the memory address 
   signal mem_addr : std_logic_vector(5 downto 0); -- memory_adddress (output of the register) 
  signal mem_out : std_logic_vector(12 downto 0);-- output of the memory (CONTROL WORD)
  signal ring_out: std_logic_vector(2 downto 0); -- output of the  ring counter, used to scan the three stages of each instruction
  
begin

  -- ADDRESS SELECTOR
  -- OPCODE and FUNC values into "myTypes" files are changed in order to use them to
  -- directly access the first cell memory of each command
  -- IF OPCODE = RTYPE ("111111") => RTYPE FUNCTION identified by FUNC

  ext_addr_sel <= '1' when (OPCODE = RTYPE) else '0';

  Ext_mux: mux2to1 generic map ( N => 6 ) port map
    ( IN0 => OPCODE,
      IN1 => FUNC(5 downto 0),
      SEL => ext_addr_sel,
      MUX_OUT => ext_addr );

  

  -- INCREMENTER
  -- In order to access the cells associated to the second and the third stage,
  -- the address selected from outside should be incremented two times.

  mem_addr_incremented <= std_logic_vector(unsigned(mem_addr) + 1);

  -- MEMORY ADDRESS SELECTOR
  Mem_mux: mux2to1 generic map ( N => 6 ) port map
    ( IN0 => mem_addr_incremented,
      IN1 => ext_addr,
      SEL => ring_out(2),
      MUX_OUT => mem_addr_ff );


 --Register used to synchronize the memory address 
 --When the RST signal is equal to 0 (reset active low) the content of this register is set to "000000" (which is the adddress corrresponding to the NOP instruction, as defined in
 --the file "mytypes.vhd"). This means that when RST is active a NOP is performed.
  Reg: reg_n generic map ( N => 6 ) port map
    ( A => mem_addr_ff,
      Q => mem_addr,
      CLK => Clk,
      RST_n => Rst );

  
  -- 3-bit RING COUNTER
  -- Only one bit is set to 1 and always shifts.
  -- At each clock cycle:
  -- RESET:     Q = "100"
  --            Q = "001"
  --            Q = "010"
  --            Q = "100"
  --            ...and so on.
  -- Used to select between external address or incremented address.
  

  Ring: ring_counter port map
    ( CLK => Clk,
      RESET => Rst,
      Q => ring_out );

  

  -- MEMORY OUTPUT
  mem_out <= MEM(to_integer(unsigned(mem_addr)));  

  --OUTPUT CONNECTION

 -- Control word bits order (MSB downto LSB)
  -- EN1 | RF1 | RF2 | EN2 | S1 | S2 | ALU1 | ALU2 | EN3 | RM | WM | S3 | WF1

  EN1   <= mem_out(12) ; 
  RF1   <= mem_out(11) ; 
  RF2   <= mem_out(10) ; 
  EN2   <= mem_out(9) ; 
  S1    <= mem_out(8) ; 
  S2    <= mem_out(7) ; 
  ALU1  <= mem_out(6) ; 
  ALU2  <= mem_out(5) ; 
  EN3   <= mem_out(4) ; 
  RM    <= mem_out(3) ; 
  WM    <= mem_out(2) ; 
  S3    <= mem_out(1) ; 
  WF1   <= mem_out(0) ;
    
end STRUCTURE;
  


  
