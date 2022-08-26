library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

-- Sparse Tree carry generator, 4 bits
-- Nbit -> Power of 2 only

entity SPARSE_TREE is
  generic( Nbit: integer := 512;
           Ncarry: integer := 4);
  port( A: in std_logic_vector(Nbit-1 downto 0);
        B: in std_logic_vector(Nbit-1 downto 0);
        Cin: in std_logic;
        Cout: out std_logic_vector(Nbit/4 downto 0) );
end SPARSE_TREE;

-- OUTPUTS:
-- C0, C4, C8, C12, C16...

architecture STRUCTURE of SPARSE_TREE is

  component PG_NET
      port( A:  in std_logic;
            B:  in std_logic;
            p:  out std_logic;
            g: out std_logic );
  end component;
  
  component G_BLOCK 
    port( p,g,c_in: in  std_logic;
          c_out:    out std_logic );
  end component;

  component PG_BLOCK
    port( p_in, p_prev, g_in, g_prev: in  std_logic;
          p_out, g_out:               out std_logic );
  end component;

  type SignalVector is array (Nbit downto 0) of std_logic_vector(Nbit downto 0);

  signal prop, gen : SignalVector;

begin

  -- PG network

  --Initial value:
  gen(0)(0) <= Cin;     --G(0:0)
  prop(0)(0) <= '0';    --P(0:0)

  
  PG_network: for i in 1 to Nbit generate

    --A(0),B(0) => G(1:1),P(1:1)
    --...
    
    PG_net_i: PG_NET port map
      ( A => A(i-1),
        B => B(i-1),
        p => prop(i)(i),
        g => gen (i)(i) );

  end generate;

  --First G_block: G(1:0)

  G10: G_BLOCK port map
    ( p     => prop(1)(1),      --P(1:1) = P1
      g     => gen(1)(1),       --G(1:1) = G1
      c_in  => gen(0)(0),       --G(0:0) = C_in
      c_out => gen(1)(0) );     --G(1:0)

  -- Rows generation: depending to the log2 of Nbit
  -- HOW TO IMPLEMENT IT: I suppose MAX 2^9 = 512 bits
  -- 1) Increasing exp
  -- 2) if Nbit/2^exp >= 1 => New line to generate
  
  Row_gen: for exp in 1 to 9 generate

    Cond_exp: if Nbit/(2**exp) >= 1 generate

      ----------------------- G BLOCKS GENERATION -------------------
      --First row, exp == row
      Cond_1: if exp = 1 generate

        --First G_block doesn't follow the next law
        G20: G_BLOCK port map
          ( p     => prop(2)(2),      --P(2:2) = P2
            g     => gen(2)(2),       --G(2:2) = G2
            c_in  => gen(1)(0),       --G(1:0) = C_in
            c_out => gen(2)(0) );     --G(2:0)

      end generate;

      
      --If i > 1, generalization of G blocks generation
      Cond_1_n: if exp /= 1 generate

        --For sure, I generate G(2**i:0)
        G_2exp_0: G_BLOCK port map
        ( p     => prop(2**exp)(2**(exp-1)+1),   
          g     => gen (2**exp)(2**(exp-1)+1),   
          c_in  => gen (2**(exp-1))(0),       
          c_out => gen (2**exp)(0) );     


        --Generation of intermediate blocks G(Ncarry:0)
        --EXAMPLE: (2^exp - 2*(exp-1))/4

        Cond_2n: if (2**exp-2**(exp-1))/Ncarry > 1 generate
          
          G_2n: for n in 1 to (2**exp - 2**(exp-1))/Ncarry-1 generate

            --From 2**exp
            G_2n_0: G_BLOCK port map
              ( p     => prop(2**exp-n*4)(2**(exp-1)+1),      
                g     => gen (2**exp-n*4)(2**(exp-1)+1),      
                c_in  => gen (2**(exp-1))(0),       
                c_out => gen (2**exp-n*4)(0) );     

          end generate;
        end generate;
      end generate;
    end generate;



    -------------------- PG BLOCKS GENERATION -----------------------

    --If exp <= 3 -> regularity

    Cond_exp_3: if exp <= 3 generate

      PG_gen_3: for i in 0 to Nbit/(2**exp)-2 generate
        
        PG_ij: PG_BLOCK port map
        ( p_in    => prop(2**(exp+1)+(2**exp)*i)(2**(exp+1)+(2**exp)*i-2**(exp-1)+1),
          g_in    => gen (2**(exp+1)+(2**exp)*i)(2**(exp+1)+(2**exp)*i-2**(exp-1)+1),
          p_prev  => prop(2**(exp+1)+(2**exp)*i-2**(exp-1))(2**(exp+1)+(2**exp)*i-2**exp+1),
          g_prev  => gen (2**(exp+1)+(2**exp)*i-2**(exp-1))(2**(exp+1)+(2**exp)*i-2**exp+1),
          p_out   => prop(2**(exp+1)+2**(exp)*i)(2**(exp+1)+(2**exp)*i-2**exp+1),
          g_out   => gen (2**(exp+1)+2**(exp)*i)(2**(exp+1)+(2**exp)*i-2**exp+1) );

      end generate;

    end generate;

    
    -- If exp > 3, 
    --Cond_exp_4: if ((exp > 3) and (2**exp /= Nbit)) generate
	 Cond_exp_4: if (exp > 3) generate

      -- How many PG I want to instantiate every time?
      Trees: for index in 0 to 2**exp/8-1 generate
    
        -- How many blocks of the same type index I want to generate?
        PG_ij: for pg_i in 0 to Nbit/2**exp-2 generate

          PG_ij: PG_BLOCK port map
            ( p_in    => prop(2**(exp+1)+(2**exp)*pg_i-4*index)(2**(exp+1)+(2**exp)*pg_i-2**(exp-1)+1),
              g_in    => gen (2**(exp+1)+(2**exp)*pg_i-4*index)(2**(exp+1)+(2**exp)*pg_i-2**(exp-1)+1),
              p_prev  => prop(2**(exp+1)+(2**exp)*pg_i-2**(exp-1))(2**(exp+1)+(2**exp)*pg_i-2**exp+1),
              g_prev  => gen (2**(exp+1)+(2**exp)*pg_i-2**(exp-1))(2**(exp+1)+(2**exp)*pg_i-2**exp+1),
              p_out   => prop(2**(exp+1)+(2**exp)*pg_i-4*index)(2**(exp+1)+(2**exp)*pg_i-2**exp+1),
              g_out   => gen (2**(exp+1)+(2**exp)*pg_i-4*index)(2**(exp+1)+(2**exp)*pg_i-2**exp+1) );

        end generate;

      end generate;
    end generate;
  end generate;

  --OUTPUT

  Output: for i in 0 to Nbit/Ncarry generate

    Cout(i) <= gen(i*Ncarry)(0);

  end generate;
  
  
end STRUCTURE;
