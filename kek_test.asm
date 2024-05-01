j main

.data
kek: .word 0
.macro kek
.data
global: .asciz "kek"
.text
	la t0, global
	sw t0, kek, t1
.end_macro

.text
main:
	kek
	lw a0, kek
	
	li a7, 1
	ecall
	li a7, 93
	li a0, 0
	ecall

func:
	li a0, 10
	ret