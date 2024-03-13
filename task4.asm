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
	call read_num_prologue
	
# pair<int, int> read_num();
read_num_prologue:
	push ra
	push s0
	push s1
	push s2
	call parse_sign	
	andi s0, a0, 0xF
	srli s2, a0, 4
	mv s1, a1
	li t0, '\n'
read_num_main:
	readch
	beq t0, a0, read_num_epilogue
	call parse_num
	slli s2, s2, 4
	add s2, s2, a0
	addi s1, s1, -1
	bnez s1, read_num_main
read_num_epilogue:
	
	
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
	call parse_num
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
	mv a0, t0
	ret	