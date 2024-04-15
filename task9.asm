j main
.include "div.asm"

main:
	call test
	exit 0
	
test:
	push ra
	li a0, -7
	li a1, 2
	call test_sdiv
	li a0, -7
	li a1, 2
	call test_udiv
	pop ra
	ret
	

test_sdiv:
	push ra
	push s0
	call sdiv
	mv s0, a1
	newline
	call print_dec
	mv a0, s0
	newline
	call print_dec
	pop s0
	pop ra
	ret

test_udiv:
	push ra
	push s0
	call udiv
	mv s0, a1
	newline
	call print_dec
	mv a0, s0
	newline
	call print_dec
	pop s0
	pop ra
	ret