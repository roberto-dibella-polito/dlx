seq r25, r25, r25	# 0		r25 <= 1
nop					# 4
nop					# 8
nop					# 12
nop					# 16
sne r20, r25, r20 	# 20	just to try 
myloop:
add r1, r1, r25		# 24	r1 <= 1, 17 , 145
nop					# 28
nop					# 32
nop					# 36
nop					# 40
add r1, r25, r1   	# 44	r1 <= 2, 18 , 146
nop					# 48
nop					# 52
nop					# 56
nop					# 60
add r1, r1, r1    	# 64	r1 <= 4, 36 , 292
nop					# 68
nop					# 72
nop					# 76
nop					# 80
add r1, r1, r1    	# 84	r1 <= 8, 72 , 584
nop					# 88
nop					# 92
nop					# 96
nop					# 100
add r1, r1, r1    	# 104	r1 <= 16,144, 1168
xor r20, r20, r25 	# 108	toggle lsb of r20.
nop					# 112
nop					# 116
jal myloop   	  	# 120	PC = PC + 4 - 11*4 = -40 (28 hexadecimal) = go to the beginning of the program. 
