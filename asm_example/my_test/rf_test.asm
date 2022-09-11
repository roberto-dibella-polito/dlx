addi r1,r0,1
addi r2,r0,2
addi r3,r0,3
addi r4,r0,4
addi r5,r0,5
sw 0(r1),r1		# Mem(0+1 = 1 -> 0) = 1
sw 2(r2),r2		# Mem(2+2 = 4 -> 4) = 2
sw 4(r3),r3		# Mem(4+3 = 7 -> 6) = 3
sw 6(r4),r4		# Mem(6+4 = 10 -> 10) = 4
sw 8(r5),r5		# Mem(8+5 = 13 -> 12) = 5
addi r6,r0,6
addi r7,r0,7
addi r8,r0,8
addi r9,r0,9
addi r10,r0,10
sw 10(r6),r6	# Mem(10+6 = 16) = 6
sw 12(r7),r7	# Mem(12+7 = 19) = 7
sw 14(r8),r8	# Mem(14+8 = 22) = 8
sw 16(r9),r9	# Mem(16+9 = 25) = 9
sw 18(r10),r10	# Mem(18+10 = 28) = 10
addi r11,r0,11
addi r12,r0,12
addi r13,r0,13
addi r14,r0,14
addi r15,r0,15
sw 20(r11),r11	# Mem(20+11 = 31) = 11
sw 22(r12),r12	# Mem(22+12 = 34) = 12
sw 24(r13),r13	# Mem(24+13 = 37) = 13
sw 26(r14),r14	# Mem(26+14 = 40) = 14
sw 28(r15),r15	# Mem(28+15 = 43) = 15
addi r16,r0,16
addi r17,r0,17
addi r18,r0,18
addi r19,r0,19
addi r20,r0,20
sw 30(r16),r16	# Mem(30+16 = 46) = 16
sw 32(r17),r17	# Mem(32+17 = 49) = 17
sw 34(r18),r18	# Mem(34+18 = 52) = 18
sw 36(r19),r19	# Mem(36+19 = 55) = 19
sw 38(r20),r20	# Mem(38+20 = 58) = 20
addi r21,r0,21
addi r22,r0,22
addi r23,r0,23
addi r24,r0,24
addi r25,r0,25
sw 40(r21),r21	# Mem(40+21 = 61) = 21
sw 42(r22),r22	# Mem(42+22 = 64) = 22
sw 44(r23),r23	# Mem(44+23 = 67) = 23
sw 46(r24),r24	# Mem(46+24 = 70) = 24
sw 48(r25),r25	# Mem(48+25 = 73) = 25
addi r26,r0,26
addi r27,r0,27
addi r28,r0,28
addi r29,r0,29
addi r30,r0,30
sw 50(r26),r26	# Mem(50+26 = 76) = 26
addi r31,r0,31
sw 52(r27),r27	# Mem(52+27 = 79) = 27
sw 54(r28),r28	# Mem(54+28 = 82) = 28
sw 56(r29),r29	# Mem(56+29 = 85) = 29
sw 58(r30),r30	# Mem(58+30 = 88) = 30
sw 60(r31),r31	# Mem(60+31 = 91 -> 90) = 31
lw r6,76(r0)
lw r5,79(r0)	# r5 = Mem(79) = 27
lw r4,82(r0)
lw r3,85(r0)
lw r2,88(r0)
lw r1,91(r0)
lw r31,1(r0)
lw r30,4(r0)
lw r29,7(r0)
lw r28,10(r0)
lw r27,13(r0)
lw r26,16(r0)
lw r25,19(r0)
lw r24,22(r0)
lw r23,25(r0)
lw r22,28(r0)
lw r21,31(r0)
lw r20,34(r0)
lw r19,37(r0)
lw r18,40(r0)
lw r17,43(r0)
lw r16,46(r0)
lw r15,49(r0)
lw r14,52(r0)
lw r13,55(r0)
lw r12,58(r0)
lw r11,61(r0)
lw r10,64(r0)
lw r9,67(r0)
lw r8,70(r0)
lw r7,73(r0)
nop
nop
nop
nop
