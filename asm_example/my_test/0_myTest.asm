; CUSTOM TEST for DLX
; Loads from the first word in memory the tests to be performed
; r31	Return register
; r30	Global result register
; r29	Option register				Each bit defines the test to do. 1 = do the test, 0 = do not
; r28	Test counter

lw 		r29, 0(r0)			; 0		The Option word is stored in Mem(0)

; Load the starting point of each test in memory
addi	r1, r0, RFTest		; 4
addi	r2, r0, ArithTest	; 8
addi	r3, r0, otherTests	; 12
add		r28, r28, r0		; 16
nop							; 20
sw		100(r0),r1			; 24
sw		102(r0),r2			; 28
sw		104(r0),r3			; 32

start:
beqz	r29, to_end			; 36	if no more test are requested, stop the program
andi	r27, r29, 1			; 40	Selects the first bit
lw		r26, 100(r28)		; 44	Load the PC value for the test
srli	r29, r29, 1			; 48
addi	r28, r28, 2			; 52 
nop							; 56
nop							; 60
beqz	r27, start			; 64		if zero, no test => next else continue
jr		r26					; 68		Jump to the desired test
nop							; 72 
nop							; 76
nop							; 80
nop							; 84

RFTest:
addi	r25, r0, 10			; 88
beqz 	r0, start			; 92

ArithTest:
addi	r25, r0, 11			; 96
beqz 	r0, start			; 100

otherTests:
addi	r25, r0, 12			; 104
beqz 	r0, start			; 108

to_end:
addi	r20, r0, 0xFFFF		; 112
nop							; 116
nop							; 120
nop							; 124	
nop							; 128
sw		0(r0), r20			; 132
end:						; 136
beqz	r0, end

