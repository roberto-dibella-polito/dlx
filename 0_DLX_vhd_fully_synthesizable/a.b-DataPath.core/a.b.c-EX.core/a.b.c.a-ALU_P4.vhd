-- DLX
-- Execution stage
-- .MUXA,MUXB
-- .Zero Detector
-- -> ALU

-- VERSION using the Pentium 4 as ADDER component

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_ALU is
	generic(
		DATA_SIZE	: integer := 32
	);
	port(
		PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
		PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
		ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
		ALU_OP		: in aluOp
	);
end DLX_ALU;

architecture bhv of DLX_ALU is
	
	component P4
		generic(Nbit: integer := 32);
		port   (
			A			: in std_logic_vector(Nbit-1 downto 0);
			B			: in std_logic_vector(Nbit-1 downto 0);
			Cin			: in std_logic;
			Cout		: out std_logic;
			SUB_ADD_n	: in std_logic;              
			Sum			: out std_logic_vector(Nbit-1 downto 0));
	end component;
	
	component SHIFTER_GENERIC
		generic(N: integer);
		port(	
			A				: in std_logic_vector(N-1 downto 0);
			B				: in std_logic_vector(4 downto 0);
			LOGIC_ARITH		: in std_logic;	-- 1 = logic, 0 = arith
			LEFT_RIGHT		: in std_logic;	-- 1 = left, 0 = right
			SHIFT_ROTATE	: in std_logic;	-- 1 = shift, 0 = rotate
			OUTPUT			: out std_logic_vector(N-1 downto 0) 
		);
	end component;
	
	signal sub_i, cout_i, shift_arith_i, shift_dir_i	: std_logic;
	signal adder_out, shifter_out						: std_logic_vector(DATA_SIZE-1 downto 0);
	signal and_out, or_out, xor_out, sge_out, sle_out, sne_out, seq_out, sra_out,
		sgeu_out, sgt_out, sgtu_out, slt_out, sltu_out 	: std_logic_vector(DATA_SIZE-1 downto 0);
	signal x0	: std_logic_vector(DATA_SIZE-1 downto 0);
	
begin
	
	x0 <= (others=>'0');
	
	adder: P4 generic map(Nbit => DATA_SIZE)
	port map(
		A			=> PORT_A,
		B			=> PORT_B,
		Cin			=> sub_i,
		Cout		=> cout_i,
		SUB_ADD_n	=> sub_i,             
		Sum			=> adder_out 
	);
	
	-- Execution modules
	and_out <= PORT_A and PORT_B;	-- AND_O
	or_out	<= PORT_A or PORT_B;	-- OR_O
	xor_out <= PORT_A xor PORT_B;	-- XOR_O
	
	alu_p: process(PORT_A,PORT_B)
	begin
		-- SGE		: greater or equal
		if( signed(PORT_A) >= signed(PORT_B) ) then
			sge_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sge_out <= (others=>'0');
		end if;
		
		-- SLE		: less or equal
		if( signed(PORT_A) <= signed(PORT_B) ) then
			sle_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sle_out <= (others=>'0');
		end if;
	
		-- SNE		: set if not equal		if( A != B ) OUT <= '1' 	(signed)
		if( signed(PORT_A) /= signed(PORT_B) ) then 
			sne_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sne_out <= (others=>'0');
		end if;
		
		-- SEQ 		: set if equal			if( A == B ) OUT <= '1' 	(signed)
		if( signed(PORT_A) = signed(PORT_B) ) then 
			seq_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			seq_out <= (others=>'0');
		end if;
		
		-- SGEU		: great or equal uns	if( A >= B ) OUT <= '1'		(unsigned)
		if( unsigned(PORT_A) = unsigned(PORT_B) ) then 
			sgeu_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sgeu_out <= (others=>'0');
		end if;
		
		-- SGT		: greater than			if( A > B )  OUT <= '1'		(signed)
		if( signed(PORT_A) > signed(PORT_B) ) then 
			sgt_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sgt_out <= (others=>'0');
		end if;
		
		-- SGTU		: greater than uns		if( A > B )  OUT <= '1'		(unsigned)
		if( unsigned(PORT_A) > unsigned(PORT_B) ) then 
			sgtu_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sgtu_out <= (others=>'0');
		end if;
		
		-- SLT		: less than				if( A < B )  OUT <= '1'		(signed)
		if( signed(PORT_A) < signed(PORT_B) ) then 
			slt_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			slt_out <= (others=>'0');
		end if;
		
		-- SLTU		: less than uns 		if( A < B )  OUT <= '1'		(unsigned)
		if( unsigned(PORT_A) > unsigned(PORT_B) ) then 
			sltu_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sltu_out <= (others=>'0');
		end if;
		
	end process alu_p;
	
	-- SLL_O 	: shift left logical	OUT <= A << B(4 downto 0) 	(unsigned)
	-- SRL_O	: shift right logical	OUT <= A >> B(4 downto 0)	(unsigned)
	-- SRA_O	: shift right arith		OUT <= A(0)^B & (A >> B)_(B 
	shifter: SHIFTER_GENERIC 
	generic map(N => DATA_SIZE)
	port map(	
		A				=> PORT_A,
		B				=> PORT_B(4 downto 0),
		LOGIC_ARITH		=> shift_arith_i,	-- 1 = logic, 0 = arith
		LEFT_RIGHT		=> shift_dir_i,		-- 1 = left, 0 = right
		SHIFT_ROTATE	=> '1',				-- 1 = shift, 0 = rotate
		OUTPUT			=> shifter_out 
	);
	
	
	-- ADDU		: Add unsigned			OUT <= A + B				(unsigned)
	-- MULT		: Integer mult			OUT <= A*B 					(signed)
	-- SUBU		: sub unsigned			OUT <= A - B 				(unsigned)
	-- NOP 		: no operation			
	
	
	-- ALU Control Unit
	-- Translates the aluOp signal into a control signal
	-- for the adder
	-- Outputs:	sub_i, shift_arith_i, shift_dir_i, shift_rotate_i
	
	sub_i			<= '1' when( ALU_OP = SUB or ALU_OP = SUBU ) else '0';
	shift_arith_i	<= '1' when( ALU_OP = SUBU ) else '0';
	shift_dir_i		<= '1' when( ALU_OP = SLL_O ) else '0';
	
	alu_control: process(ALU_OP, adder_out, and_out, or_out, sge_out, sle_out, shifter_out, 
					sne_out, xor_out, seq_out, sgeu_out, sgt_out, sgtu_out, slt_out, sltu_out,
					sra_out)
	begin
		case ALU_OP is
			when ADD	=> ALU_OUT	<= adder_out;
			when SUB	=> ALU_OUT	<= adder_out;
			when AND_O	=> ALU_OUT	<= and_out;
			when OR_O	=> ALU_OUT	<= or_out;
			when SGE	=> ALU_OUT	<= sge_out;	
			when SLE	=> ALU_OUT	<= sle_out;
			when SLL_O	=> ALU_OUT	<= shifter_out;
			when SNE	=> ALU_OUT	<= sne_out;
			when SRL_O	=> ALU_OUT	<= shifter_out;
			when XOR_O	=> ALU_OUT	<= xor_out;
			when ADDU	=> ALU_OUT	<= adder_out;
			--when MULT	=> ALU_OUT	<= mult_out;
			when SEQ	=> ALU_OUT	<= seq_out;
			when SGEU	=> ALU_OUT	<= sgeu_out;
			when SGT	=> ALU_OUT	<= sgt_out;
			when SGTU	=> ALU_OUT	<= sgtu_out;
			when SLT	=> ALU_OUT	<= slt_out;
			when SLTU	=> ALU_OUT	<= sltu_out;
			when SRA_O	=> ALU_OUT	<= sra_out;
			when SUBU	=> ALU_OUT	<= adder_out;
			when NOP	=> ALU_OUT	<= adder_out; 
			when others	=> ALU_OUT	<= adder_out;
		end case;
	end process alu_control;
end bhv;

