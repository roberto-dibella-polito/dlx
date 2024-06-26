library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;

-- P4 Adder
-- Sparse tree and sum generator

entity P4 is
  generic(Nbit: integer := 32);
  port   (A             : in std_logic_vector(Nbit-1 downto 0);
          B             : in std_logic_vector(Nbit-1 downto 0);
          Cin           : in std_logic;
          Cout          : out std_logic;
          SUB_ADD_n     : in std_logic;              
          Sum           : out std_logic_vector(Nbit-1 downto 0));
  end P4;

  --SUB_ADD_n -> If 1, the adder performs a subtraction.
  --             It forces the carry-in to 1 in order to perform the 2's
  --             complement to the operands.

architecture STRUCTURE of P4 is

  component SPARSE_TREE
    generic( Nbit: integer := 512;
           Ncarry: integer := 4);
    port( A: in std_logic_vector(Nbit-1 downto 0);
          B: in std_logic_vector(Nbit-1 downto 0);
          Cin: in std_logic;
          Cout: out std_logic_vector(Nbit/4 downto 0) );
    end component;

  component CS_SUM
    generic( Nbit : integer := 8; N : integer := 4 );
    port (
      CN : in std_logic_vector((Nbit/N-1) downto 0);  --Carry N per time
      A : in std_logic_vector(Nbit-1 downto 0);      --Operand 1
      B : in std_logic_vector(Nbit-1 downto 0);      --Operand 2
      S : out std_logic_vector(Nbit-1 downto 0) );   --Sum
    end component;

  signal carries: std_logic_vector(Nbit/4 downto 0);
  signal internal_cin: std_logic; --Connected to the Sparse Tree and Sum
                                  --Generator carry-in


  signal B_xor: std_logic_vector(Nbit-1 downto 0); --Signal used to xor
                                                          --array to the input
                                                          --of the components

  begin

    -- Carry-in management
    -- internal_cin_x = 1 if (carry_in is 1) OR (sub_add_n is 1)

    internal_cin <= Cin or SUB_ADD_n;

    -- 1's complement of operands

    Complement: for i in 0 to Nbit-1 generate

      B_xor(i) <= B(i) xor SUB_ADD_n;

    end generate;
      
    SparseTree: SPARSE_TREE generic map (Nbit => Nbit)
      port map
      ( A => A,
        B => B_xor,
        Cin => internal_cin,
        Cout => carries );

    SumGen: CS_SUM generic map (Nbit => Nbit)
      port map
      ( CN => carries(Nbit/4-1 downto 0),
        A => A,
        B => B_xor,
        S => Sum );
        
    Cout <= carries(Nbit/4);
  end STRUCTURE;

    
    
  
