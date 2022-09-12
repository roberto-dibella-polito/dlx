seq r25, r25, r25 ; r25 <= 1
sne r20, r25, r20 ; just to try 
myloop:
nop
nop
add r1, r1, r25   ; r1 <= 1
nop
nop
nop
nop
add r1, r25, r1   ; r1 <= 2
nop
nop
nop
nop
add r1, r1, r1    ; r1 <= 3
nop
nop
nop
nop
add r1, r1, r1    ; r1 <= 4
nop
nop
nop
nop
add r1, r1, r1    ; r1 <= 5
xor r20, r20, r25 ; toggle lsb of r20.
j  myloop   	  ; PC = PC + 4 - 11*4 = -40 (28 hexadecimal) = go to the beginning of the program. 
