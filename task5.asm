j main
.include "macro.asm"
.include "hex_io.asm"
.text
main:
	call readnum
	mv s0, a0
	call readnum
	mv s1, a0
	mv a0, s0
	mv a1, s1
	call multiplication
	call printnums
	exit 0

multiplication:
	li t4, 0
	li t0, 32
	li t2, 0x1
mul_main:
	li t1, 32
	sub t1, t1, t0
	and t3, t2, a1
	beqz t3, mul_main_cont
	sll t3, a0, t1
	add t4, t4, t3
mul_main_cont:
	slli t2, t2, 1
	addi t0, t0, -1
	bnez t0, mul_main
mul_epilogue:
	mv a0, t4
	ret
