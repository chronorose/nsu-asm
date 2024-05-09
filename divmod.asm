.include "macro.asm"
.eqv MUL_MAX 214748363

mul10:
	li t1, MUL_MAX
	bgt a0, t1, mul10_overflow
	slli t0, a0, 3
	add t0, t0, a0
	add t0, t0, a0
	mv a0, t0
	ret
mul10_overflow:
	error "overflow registered"

# int div10(int x);
div10:
	push ra
	push s0
	push s1
	push s2
	mv s0, a0 # start
	call div10_rec
	mv s1, a0 # result of division
	li s2, 4
check_loop:
	mv a0, s1
	call mul10
	bge s0, a0, div10_cont
	addi s1, s1, -1
	addi s2, s2, -1
	bgez s2, check_loop
div10_cont:
	mv a0, s1
	pop s2
	pop s1
	pop s0
	pop ra
	ret

div10_rec:
	push ra
	push s0
	addi t0, a0, -10
	bltz t0, div10_rec_base
	srli s0, a0, 4
	srli a0, a0, 3
	call div10_rec
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

isqrt: # int isqrt(int value)
	li t0, 30
	li t1, 0
isqrt_loop:
	bltz t0, isqrt_end
	li t2, 0xFF
	sll t2, t2, t0
	and t3, a0, t2
	slli t1, t1, 1
	slli t4, t1, 1
	addi t4, t4, 1
	sll t4, t4, t0
	bgt t4, t3, isqrt_loop_cont
	addi t1, t1, 1
	sub a0, a0, t4
isqrt_loop_cont:
	addi t0, t0, -2
	j isqrt_loop
isqrt_end:
	mv a0, t1
	ret
