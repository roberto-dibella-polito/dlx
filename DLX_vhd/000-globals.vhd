library ieee;
use ieee.std_logic_1164.all;

package myTypes is

	-- TYPES INSTRUCTION FORMAY
	
	--			| 31-26  | 25-21 | 20-16 | 15-0      |
	--			--------------------------------------
	-- I-TYPE	| opcode | rs1   | rd    | immediate |
	
	--			| 31-26  | 25-21 | 20-16 | 15-11 | 10-0 |
	--			-----------------------------------------
	-- R-TYPE	| opcode | rs1   | rs2   | rd    | func |

	--			| 31-26  | 25 - 0 |
	--			-------------------
	-- J-TYPE	| opcode | offset |

	constant OP_SIZE	: integer := 6;
	constant FUNC_SIZE	: integer := 11;
	constant IMM_SIZE	: integer := 16;
	constant OFFSET_SIZE: integer := 26;
	constant RX_SIZE	: integer := 5;


	type aluOp is (
		NOP, ADDS, LLS, LRS --- to be completed
			);

end myTypes;

