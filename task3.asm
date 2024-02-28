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

.macro println
	newline
	printch
.end_macro

.macro exit
	syscall 93
.end_macro

.macro printch
	syscall 11
.end_macro

main:
	li a0, 0
	call readnum
	mv s4, a0
	call readnum
	mv s5, a0
	readch
	li t0, '+'
	beq a0, t0, add
	li t0, '-'
	beq a0, t0, sub
	li t0, '&'
	beq a0, t0, and
	li t0, '|'
	beq a0, t0, or
	j exit

add:
	add a0, s4, s5
	call printnums
sub:
	sub a0, s4, s5
	call printnums
and:
	and a0, s4, s5
	call printnums
or:
	or a0, s4, s5
	call printnums
	
printnums:
	mv s0, a0
	mv s1, sp

printprepare:
	andi a0, s0, 0xF
	call to_number
	addi sp, sp, -1
	sb, a0, 0(sp)
	srli s0, s0, 4
	bgtz s0, printprepare
printLoop:
	lb a0, 0(sp)
	printch
	addi sp, sp, 1
	bne sp, s1, printLoop
	j exit
	
	

to_number:
	slti t0, a0, 10
	li t1, 0
	beq t0, t1, to_hex
	addi a0, a0, 48
	ret

to_hex:
	addi a0, a0, 55
	ret
		
exit:
	exit
	
readnum:
	li t0, '\n'
	li s1, 0	
readnumber:
	readch
	li t0, '\n'
	beq a0, t0, readnumber_return
	mv s3, ra
	call parsenum
	mv ra, s3
	slli, s1, s1, 4
	add s1, s1, a0
	j readnumber

readnumber_return:
	mv a0, s1
	ret

parsenum:
	andi t0, a0, 0xFF
	addi t0, t0, -48
	slti t0, t0, 10
	li t1, 1
	beq t0, t1, decimal
	addi t0, a0, -65
	slti t0, t0, 6
	beq t0, t1, hex
	j exit
	
decimal:
	addi a0, a0, -48
	ret

hex:
	addi a0, a0, -55
	ret