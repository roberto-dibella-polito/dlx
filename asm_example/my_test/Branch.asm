xor r2, r2, r2		# r2 = 0
addi r1, r0, 10		# r1 = 10
nop
nop

ciclo:
lw r3, 0(r2)		# r3 = Mem(0) = 
addi r2, r2, 4		# r2 = 4
subi r1, r1, 1		# r1 = 9
nop
nop
srli r3, r3, 24
nop
nop
nop
nop
addi r3, r3, 10
nop
nop
nop
nop
sw 100(r2), r3
bnez r1, ciclo

addi r4, r0, 65535 
nop
nop
nop
nop
ori r5, r4, 100000
nop
nop
nop
nop
add r6, r4, r5
nop
nop
nop
nop

end:
beqz r0, end
