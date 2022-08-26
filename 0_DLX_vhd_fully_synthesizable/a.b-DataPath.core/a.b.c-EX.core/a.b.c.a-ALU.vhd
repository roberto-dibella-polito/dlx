-- DLX
-- Execution stage
-- .MUXA,MUXB
-- .Zero Detector
-- .ALU

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;

entity DLX_ALU is
	generic(
		DATA_SIZE	: integer := 32;
	);
	port(
		PORT_A		: in std_logic_vector(DATA_SIZE-1 downto 0);
		PORT_B		: in std_logic_vector(DATA_SIZE-1 downto 0);
		ALU_OUT		: out std_logic_vector(DATA_SIZE-1 downto 0);
		DATA_MEM	: out std_logic_vector(DATA_SIZE-1 downto 0);
		RD_FWD_OUT	: out std_logic_vector(RD_SIZE-1 downto 0);
		BRANCH_T	: out std_logic
		
		ALU_OP		: in aluOp
	);
end DLX_EX;

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
	end component:
	
	signal sub_i, cout_i	: std_logic;
	signal adder_out		: std_logic_vector(DATA_SIZE-1 downto 0);
	signal and_out, or_out, sge_out, sle_out, sne_out	: std_logic_vector(DATA_SIZE-1 downto 0);
	
begin
	
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
	
	-- XOR_O : bitwise xor / OUT <= A xor B (unsigned)
	xor_out <= PORT_A xor PORT_B;	
	
	alu_p: process(PORT_A,PORT_B)
	begin
		-- SGE : greater or equal
		if( signed(PORT_A) >= signed(PORT_B) ) then
			sge_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sge_out <= (others='0');
		end if;
		
		-- SLE : greater or equal
		if( signed(PORT_A) <= signed(PORT_B) ) then
			sle_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sle_out <= (others='0');
		end if;
	
		-- SNE		: set if not equal		if( A != B ) OUT <= '1'		(signed)
		if( signed(PORT_A) /= signed(PORT_B) ) then 
			sne_out <= std_logic_vector(to_unsigned(1,DATA_SIZE));
		else
			sne_out <= (others=>'0');
		end if
		
		
	-- SLL_O 	: shift left logical	OUT <= A << B(4 downto 0) 	(unsigned)
	-- SRL_O	: shift right logical	OUT <= A >> B(4 downto 0)	(unsigned)
	
	
	-- ADDU		: Add unsigned			OUT <= A + B				(unsigned)
	-- MULT		: Integer mult			OUT <= A*B 					(signed)
	-- SEQ		: set if equal			if( A == B ) OUT <= '1'		(signed)
	-- SGEU		: great or equal uns	if( A >= B ) OUT <= '1'		(unsigned)
	-- SGT		: greater than			if( A > B )  OUT <= '1'		(signed)
	-- SGTU		: greater than uns		if( A > B )  OUT <= '1'		(unsigned)
	-- SLT		: less than				if( A < B )  OUT <= '1'		(signed)
	-- SLTU		: less than uns 		if( A < B )  OUT <= '1'		(unsigned)
	-- SRA_O	: shift right arith		OUT <= A(0)^B & (A >> B)_(B 
	-- SUBU		: sub unsigned			OUT <= A - B 				(unsigned)
	-- NOP 		: no operation			
	
	
	
	-- ALU Control Unit
	-- Translates the aluOp signal into a control signal
	-- for the adder
	alu_control: process(aluOp)
	begin

		case aluOp is
			when ADD =>
				sub_i 	<= '0';
				ALU_OUT	<= adder_out;
			
			-- SUB	: Signed subtraction / OUT <= A - B (signed)
			when SUB =>
				sub_i	<= '1';
				ALU_OUT	<= adder_out;
			
			when AND_O =>
				sub_i	<= '0';
				ALU_OUT	<= 
				
			when OR_O =>
				sub_i	<= '0';
				ALU_OUT	<= 
			
			when SGE =>
				sub_i	<= '0';
				ALU_OUT	<= 
	
end bhv;

