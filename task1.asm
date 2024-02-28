.text
.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro readch
	syscall 12
.end_macro

.macro printch
	syscall 11
.end_macro

.macro exit %ecode
	li a0, %ecode
	syscall 93
.end_macro

.macro print %n
	li a0, %n
	printch
.end_macro
 

main:
	readch
	mv a1, a0
	print 10
	andi a0, a1, 0xff
	addi a0, a0, -48
	sltiu a0, a0, 10
	addi a0, a0, 48
	printch
	exit 0
