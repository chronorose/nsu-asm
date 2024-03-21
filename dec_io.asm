.include "divmod.asm"

read_dec:
	push ra
	push s0
	push s1
	call parse_sign
	mv s0, a0
	mv s1, a1
read_dec_main:
	readch
	li t0, '\n'
	beq a0, t0, read_dec_end
	call parse_dec
	swap s0, a0
	call mul10
	add s0, s0, a0
	j read_dec_main
read_dec_end:
	mv a0, s0
	beqz s1, read_dec_endend
	neg a0, a0
read_dec_endend:
	pop s1
	pop s0
	pop ra
	ret

parse_sign:
	readch
	li t0, '-'
	beq a0, t0, sign_minus
	li a1, 0
	push ra
	call parse_dec
	pop ra
	ret
sign_minus:
	li a1, 1
	ret

print_dec:
	push ra
	push s0
	push s1
	li s0, 0
	mv s1, a0
	bgez a0, print_dec_prep
	li a0, '-'
	printch
	neg s1, s1
	mv a0, s1
print_dec_prep:
	call mod10
	push a0
	mv a0, s1
	call div10
	mv s1, a0
	addi s0, s0, 1
	bnez a0, print_dec_prep
print_dec_loop:
	pop a0
	addi a0, a0, 48
	printch
	addi s0, s0, -1
	bnez s0, print_dec_loop
print_dec_end:
	pop s1
	pop s0
	pop ra
	ret
	
parse_dec:
	andi a0, a0, 0xFF
	addi a0, a0, -58
	bltz a0, parse_dec_end
	error "wrong input"
parse_dec_end:
	addi a0, a0, 10
	ret
