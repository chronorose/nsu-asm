.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro swap %r1 %r2
	xor %r1, %r1, %r2
	xor %r2, %r1, %r2
	xor %r1, %r1, %r2
.end_macro

.macro printStr
	syscall 4
.end_macro

.macro printInt
	syscall 1
.end_macro
	
.macro readch
	syscall 12
.end_macro

.macro push %register
	addi sp, sp, -4
	sw %register, 0(sp)
.end_macro

.macro println %string
.data 
str: .asciz %string
.text
	newline
	push a0
	la a0, str
	syscall 4
	pop a0
.end_macro

.macro pop %register
	lw %register, 0(sp)
	addi sp, sp, 4
.end_macro

.macro error %s
.data
str: .asciz %s
.text
	newline
	la a0, str
	syscall 4
	exit 1
.end_macro

.macro newline
	push a0
	li a0, 10
	printch
	pop a0
.end_macro

.macro println
	newline
	printch
.end_macro

.macro exit %n
	li a0, %n
	syscall 93
.end_macro

.macro printch
	syscall 11
.end_macro
