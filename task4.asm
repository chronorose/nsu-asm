j main
.include "macro.asm"

main:
	call read_num_prologue
	#call write_bcd
	mv s0, a0
	call read_num_prologue
	# call dbg
	mv a1, a0
	mv a0, s0
	call operation_prologue
	call write_bcd
	exit 0

operation_prologue:
	push s0
	push s1
	push s2
	push ra
	mv s0, a0 # first number
	mv s1, a1 # second number
	call get_sign
	andi a1, s0, 0xF
	andi a2, s1, 0xF
	srli s0, s0, 4
	srli s1, s1, 4
	slt a4, s0, s1
	call get_op
	beqz a3, operation
	mv s2, s0  # TODO: redo swap with xors
	mv s0, s1
	mv s1, s2
operation:
	mv s2, a1 # sign in the end
	mv t0, a0
	mv a0, s0
	mv a1, s1
	beqz t0, addition_branch
	call subtraction
	addi a0, a0, 0xA
	add a0, a0, s2
operation_epilogue:
	pop ra
	pop s2
	pop s1
	pop s0
	ret
	
addition_branch:
	call addition
	j operation_epilogue

get_op:
	li a3, 0
	beqz a0, plus_branch
minus_branch:
	xor t0, a1, a2
	beqz t0, minus_equal
minus_diff:
	xori t0, a1, 0xA
	li a0, 0
	li a1, 0
	beqz t0, get_op_epilogue
	li a0, 1
	li a1, 1
	bnez t0, get_op_epilogue
minus_equal:
	xori t0, a1, 0xA
	beqz t0, dep
	li a3, 1
	bnez t0, dep
plus_branch:
	xor t0, a1, a2
	beqz t0, plus_equal
plus_diff:
	xori t0, a1, 0xA
	beqz t0, dep
	li a3, 1
	bnez t0, dep
plus_equal:
	xori t0, a1, 0xA
	li a0, 0
	li a1, 0
	beqz t0, get_op_epilogue
	li a0, 0
	li a1, 1
	bnez t0, get_op_epilogue
dep:
	li a0, 1
	mv a1, a4 
	beqz a3, get_op_epilogue
	beqz a1, swap2
swap1:
	li a1, 0
swap2:
	li a1, 1
	bnez a3, get_op_epilogue
get_op_epilogue:
	ret

get_sign:
	readch
	xori t1, a0, 0x2B # check for +
	beqz t1, ret_plus 
	xori t2, a0, 0x2D # check for -
	beqz t2, ret_minus
	error "Wrong operator"
ret_plus:
	li a0, 0
	ret
ret_minus:
	li a0, 1
	ret

addition:
	add a0, a0, a1
	mv a1, zero
	mv t4, a0
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
	add a1, a1, t2
correct_continue2:
	addi t0, t0, -1
	bnez t0, correct_prep
# s1 - correction. s0 - result. s2 sign
addition_continue:
	add a0, a0, a1
	li t0, 0xF
	slli, t0, t0, 28
	and t0, t0, a0
	bnez t0, overflow
	slli, a0, a0, 4
	ret

overflow:
	error "Overflow detected"

#int subtraction(int, int)	
subtraction:
	push s0
	push s1
	li s0, 0
	li s1, 0
	li a4, 0
	li t2, 7
subtraction_main:
	andi t0, a0, 0xF
	andi t1, a1, 0xF
	slt t4, t0, t1
	beqz t4, subtraction_main_cont
	li a3, 0
	li t5, 0xF
subtraction_take:
	slli t5, t5, 4
	addi a3, a3, 1
	and t6, t5, a0
	beqz t6, subtraction_take
	li t5, 4
	mul a4, a3, t5
	addi a3, a3, 7
	sub a3, a3, t2
	mul a3, a3, t5
	li t5, 0x1
	sll t5, t5, a4
	sub a0, a0, t5
	li t5, 0x6
	sll t5, t5, a3
	add s0, s0, t5
	addi t0, t0, 10
subtraction_main_cont:
	sub t0, t0, t1
	li t1, 7
	sub t1, t1, t2
	li a3, 4
	mul t1, t1, a3
	sll t0, t0, t1
	add s1, s1, t0
	addi t2, t2, -1
	srli a0, a0, 4
	srli a1, a1, 4
	bnez t2, subtraction_main
subtraction_epilogue:
	sub a0, s1, s0
	slli a0, a0, 4
	pop s1
	pop s0
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
