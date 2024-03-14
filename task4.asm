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
	call read_num_prologue
	#call write_bcd
	mv s0, a0
	call read_num_prologue
	# call dbg
	mv a1, a0
	mv a0, s0
	call addition
	call write_bcd
	exit 0

operation_prologue:
	#push s0
	#push s1
	#mv s0, a0 # first number
	#mv s1, a1 # second number
	call addition
	ret

addition:
	push s0
	push s1
	push s2
	push ra
	mv s0, a0
	mv s1, a1
	mv s3, zero
	andi a0, s0, 0xF
	srli s0, s0, 4
	andi a1, s1, 0xF
	srli s1, s1, 4
	slt a2, s0, s1
	call addition_sign
	mv s2, a0 # sign
	add s0, s0, s1
	mv s1, zero
	mv t4, s0
	li t0, 7
correct_prep:
	andi t1, t4, 0xF
	srli t4, t4, 4
	addi t1, t1, -9
	blez t1, correct_continue2
correction:
	li t2, 0x6
	li t3, 7
	sub t3, t3, t0
	beqz t3, correct_continue
sdvig:
	slli t2, t2, 4
	addi t3, t3, -1
	bnez t3, sdvig
correct_continue:
	add s1, s1, t2
correct_continue2:
	addi t0, t0, -1
	bnez t0, correct_prep
# s1 - correction. s0 - result. s2 sign
addition_continue:
	add s0, s0, s1
	li t0, 0xF
	slli, t0, t0, 28
	and t0, t0, s0
	bnez t0, overflow
	slli, s0, s0, 4
	add s0, s0, s2
	mv a0, s0
	pop ra
	pop s2
	pop s1
	pop s0
	ret
	# li t0, 0xF
	# slli t0, t0, 28
	# andi t0, t0, s0
	# bnez t0, addition_overflow

overflow:
	error "Overflow detected"

#int addition_sign(int, int, int)
addition_sign:
	beqz a2, add_first_sign
add_second_sign:
	mv a0, a1
add_first_sign:
	ret

# void write_bcd(int arg);
write_bcd:
	newline
	push s0
	push s1
	mv s0, a0
	srli s0, s0, 4
	andi s1, a0, 0xF
	addi a0, s1, -0xB
	li s1, 0
	beqz a0, bcd_write_minus
write_bcd_prep_loop:
	andi a0, s0, 0xF
	push a0
	srli s0, s0, 4
	addi s1, s1, 1
	bnez s0, write_bcd_prep_loop
write_bcd_body:
	pop a0
	addi a0, a0, 48
	printch
	addi s1, s1, -1
	bnez s1, write_bcd_body
write_bcd_epilogue:
	pop s1
	pop s0
	ret
	

bcd_write_minus:
	li a0, '-'
	printch
	j write_bcd_prep_loop
	
# int read_num();
read_num_prologue:
	push ra
	push s0
	push s1
	push s2
	push s3
	newline
	call parse_sign	
	andi s0, a0, 0xF # s0 - sign
	srli s2, a0, 4 # s2 - total number
	mv s1, a1 # s1 - loop number
	li s3, '\n'
read_num_main:
	readch
	beq s3, a0, read_num_epilogue
	call parse_num
	slli s2, s2, 4
	add s2, s2, a0
	addi s1, s1, -1
	bnez s1, read_num_main
read_num_epilogue:
	slli a0, s2, 4
	add a0, a0, s0
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret

dbg:
	li t0, 8
	push s0
	mv s0, a0
	newline
dbg_body:
	andi t1, s0, 0xF
	srli, s0, s0, 4
	mv a0, t1
	addi a0, a0, 48
	printch
	addi t0, t0, -1
	bnez t0, dbg_body
dbg_epilogue:
	pop s0
	ret
	
# pair<int, int> parse_sign();
# check for sign at the start of input.
# returns start of the number with either signs or signs and also max number of loops for number
parse_sign:
	li a1, 7
	readch
	li t0, '-'
	beq t0, a0, parse_sign_minus
	li t0, '+'
	beq t0, a0, parse_sign_plus 
	push ra
	push a1
	call parse_num
	pop a1
	pop ra
	slli a0, a0, 4
	addi a0, a0, 0xA
	addi a1, a1, -1
	ret
	

parse_sign_minus:
	li a0, 0xB
	ret

parse_sign_plus:
	li a0, 0xA
	ret

# int parse_num(int)
parse_num:
	xori t0, a0, 0x30
	slti t0, t0, 10
	bnez t0, parse_num_epilogue
	error "wrong input"
parse_num_epilogue:
	addi a0, a0, -48
	ret	
