j main
.include "common.asm"

main:
	call readnum
	call mod10
	call printnums
	exit 0
	
mul10:
	slli t0, a0, 3
	add t0, t0, a0
	add t0, t0, a0
	mv a0, t0
	ret
	
# int div10(int x);
div10:
	push ra
	push s0
	push s1
	mv s0, a0 # start
	call div10_rec
	mv s1, a0 # result of division
	call mul10
	bge s0, a0, div10_cont
	addi s1, s1, -1
div10_cont:
	mv a0, s1
	pop s1
	pop s0
	pop ra
	ret

div10_rec:
	push ra
	push s0
	addi t0, a0, -10
	bltz t0, div10_rec_base
	srli s0, a0, 3
	srli a0, a0, 2
	call div10
	sub a0, s0, a0
	pop s0
	pop ra
	ret
		
div10_rec_base:
	li a0, 0
	pop s0
	pop ra
	ret

mod10:
	push ra
	push s0
	mv s0, a0
	call div10
	call mul10
	sub a0, s0, a0
	pop s0
	pop ra
	ret