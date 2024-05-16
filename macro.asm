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

.macro print_label %arg
	mv t6, a0
	la a0, %arg
	syscall 4
	mv a0, t6
.end_macro

.macro print_str %arg
.data
arg: .asciz %arg
.text
	push a0
	la a0, arg
	syscall 4
	pop a0
.end_macro

.macro printInt
	syscall 1
.end_macro

.macro print_int_reg %reg
	swap %reg, a0
	#li a0, %int
	syscall 1
	swap a0, %reg
.end_macro

.macro print_int %int
	mv t6, a0
	li a0, %int
	syscall 1
	mv a0, t6
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
	mv t6, a0
	la a0, str
	syscall 4
	mv a0, t6
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

.macro print_char %char
	mv t6, a0
	li a0, %char
	syscall 11
	mv a0, t6
.end_macro

.macro printch
	syscall 11
.end_macro
