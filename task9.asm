j main
.include "dec_io.asm"

main:
	call read_dec
	mv s0, a0
	call read_dec
	mv s1, a0
	mv a1, s1
	mv a0, s0
	call sdiv
	call print_dec
	li a0, '\n'
	printch
	mv a0, a1
	call print_dec
	exit 0


udiv:
	beqz a1, zero_div
	push ra
	push s0
	li t4, 0
	li t0, 0
	beqz a0, udiv_end
	mv s0, a1
	call modulo
	swap s0, a0
	call modulo
	mv a1, a0
	mv a0, s0
	li t4, 0
	li t0, 0
	li t1, 1
	li t3, 32
	slli t1, t1, 31
udiv_loop:
	beqz t3, udiv_end
	addi t3, t3, -1
	and t2, t1, a0
	srli t1, t1, 1
	slli t0, t0, 1
	slli t4, t4, 1
	beqz t2, udiv_loop_cont
	addi t0, t0, 1
udiv_loop_cont:
	blt t0, a1, udiv_loop
	addi t4, t4, 1
	sub t0, t0, a1
	j udiv_loop
udiv_end:
	mv a0, t4
	mv a1, t0
	pop s0
	pop ra
	ret

sdiv:
	beqz a1, zero_div
	push ra
	push s0
	push s1
	li t4, 0
	li t0, 0
	beqz a0, sdiv_end
	mv s0, a1
	call modulo
	swap s0, a0
	mv s1, a1
	call modulo
	xor t5, s1, a1
	mv t6, s1
	mv a1, a0
	mv a0, s0
	li t4, 0
	li t0, 0
	li t1, 1
	li t3, 32
	slli t1, t1, 31
sdiv_loop:
	beqz t3, sdiv_end
	addi t3, t3, -1
	and t2, t1, a0
	srli t1, t1, 1
	slli t0, t0, 1
	slli t4, t4, 1
	beqz t2, sdiv_loop_cont
	addi t0, t0, 1
sdiv_loop_cont:
	blt t0, a1, sdiv_loop
	addi t4, t4, 1
	sub t0, t0, a1
	j sdiv_loop
sdiv_end:
	mv a0, t4
	mv a1, t0
	beqz t5, sdiv_rem_check
	neg a0, a0
sdiv_rem_check:
	beqz t6, sdiv_ep
	neg a1, a1
sdiv_ep:
	pop s1
	pop s0
	pop ra
	ret
		
zero_div:
	error "zero division"

modulo:
	li a1, 0
	bgez a0, modulo_end
	addi a1, a1, 1
	neg a0, a0
modulo_end:
	ret