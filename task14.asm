j main
.include "file_io.asm"
.include "str_lib.asm"

.text
main:
	call check_flags
	mv s0, a0
	mv s1, a1
	mv a0, a2
	
	call fopen # fd
	call fload
	mv s3, a0 #char* str
	li a1, '\n'
	call split
	mv a2, s1 # string
	mv a3, s0 # flags
	call grep
	mv a2, s0 # flags
	call write_matched
	exit 0


	
write_matched: # void write_matched(char** matched, int amount, int flags)
	push s0
	li t0, 2
	and t0, t0, a2
	bnez t0, wm_cflag
	li t0, 1
	and t0, t0, a2
	mv s0, a0
	li t1, 1
wm_loop:
	beqz a1, wm_end
	beqz t0, wm_loop_cont
	mv a0, t1
	syscall 1
	print_str ":"
	addi t1, t1, 1
wm_loop_cont:
	lw a0, 0(s0)
	syscall 4
	newline
	addi s0, s0, 4
	addi a1, a1, -1
	j wm_loop
wm_cflag:
	mv a0, a1
	syscall 1 
wm_end:
	pop s0
	ret

grep: # char**, int grep(char** arr, int size, char* string, int flags)
	push ra
	push s0
	push s1
	push s2
	push s3
	push s4
	push s5
	push s6
	push s7
	li s7, 8
	and s7, s7, a3
	beqz s7, default_strstr
	la s7, strstr_lc
	j prologue_cont
default_strstr:
	la s7, strstr
prologue_cont:
	li s5, 0 # count of matched lines
	li s3, 4
	and s3, s3, a3 # invert flag
	mv s0, a0 # initial array
	mv s1, a1 # size of array
	mv s2, a2 # string
	slli a0, a1, 2
	syscall 9
	mv s4, a0 # array of matched strings
	mv s6, s4
grep_loop:
	beqz s1, grep_end
	lw a0, 0(s0)
	mv a1, s2
	jalr s7
	beqz a0, grep_nf
	bnez s3, grep_cont_loop
	addi s5, s5, 1
	lw a0, 0(s0)
	sw a0, 0(s4)
	addi s4, s4, 4
grep_cont_loop:
	addi s0, s0, 4
	addi s1, s1, -1
	j grep_loop
grep_nf:
	beqz s3, grep_cont_loop
	addi s5, s5, 1
	lw a0, 0(s0)
	sw a0, 0(s4)
	addi s4, s4, 4
	j grep_cont_loop
grep_end:
	mv a0, s6
	mv a1, s5
	pop s7
	pop s6
	pop s5
	pop s4
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret
	

check_flags: # int, char*, char* check_flags (int argc, char* argv[])
	push s0
	li s0, 0
	li t0, 2
	sub t0, a0, t0
	bltz t0, not_enough_args
	li t1, 0 # string to match
	li t2, 0 # file name
cf_loop:
	beqz a0, cf_end
	lw t0, 0(a1)
	li t3, '-'
	lb t4, 0(t0)
	beq t3, t4, read_flag
not_flag:
	beqz t1, set_string
	mv t2, t0
	j continue_loop
set_string:
	mv t1, t0
continue_loop:
	addi a0, a0, -1
	addi a1, a1, 4
	j cf_loop
read_flag:
	lb t4, 1(t0)
	li t5, 'n'
	beq t4, t5, n_flag
	li t5, 'c'
	beq t4, t5, c_flag
	li t5, 'v'
	beq t4, t5, v_flag
	li t5, 'i'
	beq t4, t5, i_flag
	error "incorrect flag"
n_flag:
	ori s0, s0, 1 # if first bit is set then n flag is set
	j continue_loop
c_flag:
	ori s0, s0, 2 # if second bit is set then c flag is set
	j continue_loop
v_flag:
	ori s0, s0, 4 # if third bit is set then v flag is set
	j continue_loop
i_flag:
	ori s0, s0, 8 # if fourth bit is set then i flag is set
	j continue_loop 
cf_end:
	mv a0, s0
	mv a1, t1
	mv a2, t2
	pop s0
	ret
not_enough_args:
	error "not enough arguments for the grepp"
