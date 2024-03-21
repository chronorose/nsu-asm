# int readnum();
readnum:
	li t0, '\n'
	push s0
	push ra
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
	pop ra
	pop s0
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
	push s0
	push s1
	push ra
	mv s1, a0
	mv s0, sp

printprepare:
	andi a0, s1, 0xF
	call to_number
	push a0
	srli s1, s1, 4
	bgtz s1, printprepare
printLoop:
	pop a0
	printch
	bne s0, sp, printLoop
	pop ra
	pop s1
	pop s0
	ret

to_number:
	slti t0, a0, 10
	beqz t0, to_hex
	addi a0, a0, 48
	ret

to_hex:
	addi a0, a0, 55
	ret
