j main
.include "dec_io.asm"
.eqv MAX_INT 2147483647
.eqv MIN_INT -2147483648

main:
	call read_dec
	mv s0, a0
	call read_dec
	mv s1, a0
	call parse_sign_op
	mv a3, a0
	mv a0, s0
	mv a1, s1
	call operation
	call print_dec
	exit 0

operation:
	beqz a3, op_plus
	li t0, MIN_INT
	add t0, t0, a1
	blt a0, t0, overflow
	sub a0, a0, a1
	ret

op_plus:
	li t0, MAX_INT
	sub t0, t0, a0
	bgt a1, t0, overflow
	li t0, MIN_INT
	add a0, a0, a1
	mv s0, a0
	push ra
	mv a0, a1
	call print_dec
	pop ra
	mv a0, s0
	ret
	
overflow:
	error "overflow"
	

parse_sign_op:
	readch
	li t0, '-'
	beq t0, a0, parse_minus
	li t0, '+'
	beq t0, a0, parse_plus
	error "wrong sign input"

parse_minus:
	li a0, 1
	ret
parse_plus:
	li a0, 0
	ret
