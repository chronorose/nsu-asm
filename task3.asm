.text

.macro syscall %n
	li a7, %n
	ecall
.end_macro

.macro readch
	syscall 12
.end_macro

.macro newline
	mv t0, a0
	li a0, 10
	printch
	mv a0, t0
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
	li a0, 0
	call readnum
	mv s0, a0
	call readnum
	mv s1, a0
	readch
	li t0, '+'
	mv a1, s0
	mv a2, s1
	beq a0, t0, add
	li t0, '-'
	beq a0, t0, sub
	li t0, '&'
	beq a0, t0, and
	li t0, '|'
	beq a0, t0, or
	error "Wrong operator"

add:
	add a0, a1, a2
	call printnums
	j exit
sub:
	sub a0, a1, a2
	call printnums
	j exit
and:
	and a0, a1, a2
	call printnums
	j exit
or:
	or a0, a1, a2
	call printnums
	j exit

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
		
exit:
	exit 0

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
