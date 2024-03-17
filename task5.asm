.text

.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro readch
	syscall 12
.end_macro

.macro push %register
	addi sp, sp, -4
	sw %register, 0(sp)
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
	push s0
	li s0, 0
	li t0, 32
	li t2, 0x1
mul_main:
	li t1, 32
	sub t1, t1, t0
	and t3, t2, a1
	beqz t3, mul_main_cont
	sll t3, a0, t1
	add s0, s0, t3
mul_main_cont:
	slli t2, t2, 1
	addi t0, t0, -1
	bnez t0, mul_main
mul_epilogue:
	mv a0, s0
	pop s0
	ret
	
# int readnum();
readnum:
	li t0, '\n'
	addi sp, sp, -8
	sw s0, 0(sp)
	sw ra, 4(sp)
	li s0, 0	
readnumber:
	readch
	li t0, '\n'
	beq a0, t0, readnumber_return
	call parsenum
	slli, s0, s0, 4
	add s0, s0, a0
	j readnumber

readnumber_return:
	mv a0, s0
	lw s0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8
	ret

# int parsenum(int a0);
parsenum:
	xori t0, a0, 0x30
	slti t0, t0, 10
	bnez t0, decimal
	xori t0, a0, 0x40
	addi t0, t0, -1
	sltiu t0, t0, 6
	bnez t0, hex
	andi t0, a0, 0xFF
	addi t0, t0, -97
	sltiu t0, t0, 6
	bnez t0, hexsmall
	error "Wrong input"
	
decimal:
	addi a0, a0, -48
	ret

hex:
	addi a0, a0, -55
	ret
hexsmall:
	addi a0, a0, -87
	ret
	
# void printnums(int a0);
printnums:
	addi sp, sp, -12
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	mv s1, a0
	mv s0, sp

printprepare:
	andi a0, s1, 0xF
	call to_number
	addi sp, sp, -4
	sw, a0, 0(sp)
	srli s1, s1, 4
	bgtz s1, printprepare
printLoop:
	lw a0, 0(sp)
	printch
	addi sp, sp, 4
	bne s0, sp, printLoop
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	addi sp, sp, 12
	ret
	
	

to_number:
	slti t0, a0, 10
	beqz t0, to_hex
	addi a0, a0, 48
	ret

to_hex:
	addi a0, a0, 55
	ret