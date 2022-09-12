seq r25, r25, r25 	# 0		r25 <= 1
nop					# 4	
nop					# 8
nop					# 12
nop					# 16
sne r20, r25, r20 	# 20	just to try 
addi r31, r25, 1	# 24

myloop:
add r1, r1, r25		# 28	r1 <= 1
add r1, r25, r1		; 		r1 <= 2
add r1, r1, r1		; 		r1 <= 3
add r1, r1, r1		; 		r1 <= 4
add r1, r1, r1		; 		r1 <= 5
xor r20, r20, r25	; toggle lsb of r20.
j  myloop			# 52 PC = PC + 4 - 11*4 = -40 (28 hexadecimal) = go to the beginning of the program. 
