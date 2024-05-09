j main

.include "file_io.asm"
.include "str_lib.asm"
.data
spacesymbols: .asciz " \t\r"
.text
main:
	call check_flags
	mv s0, a0
	mv s1, a1
	mv a0, a1
	call fopen
	mv a1, s0
	call wc
	mv a4, s0
	mv a5, s1
	call print_wc
	exit 0

print_wc: # void print_wc(int, int, int, int, int, char*)
	andi t0, a4, 2
	beqz t0, pw1
	swap a0, a1
	syscall 1
	li a0, ' '
	syscall 11
	mv a0, a1
pw1:
	andi t0, a4, 8
	beqz t0, pw2
	swap a0, a3
	syscall 1
	li a0, ' '
	syscall 11
	mv a0, a3
pw2:
	andi t0, a4, 1
	beqz t0, pw3
	syscall 1
	li a0, ' '
	syscall 11
pw3:
	andi t0, a4, 4
	beqz t0, pw_end
	mv a0, a2
	syscall 1
	li a0, ' '
	syscall 11
pw_end:
	ret

wc: # int, int, int, int wc(int fd, int flags)
	push ra
	push s0 # file descriptor
	push s1 # flags
	push s2 # result of c flag
	push s3 # result of l flag
	push s4 # result of L flag
	push s5 # result of w flag
	push s6 # loaded in file or splitted version of it
	push s7 # number of lines in array if we have to use split
	li s6, 0
	li s7, 0
	mv s0, a0
	mv s1, a1
	andi t0, s1, 1
	bnez t0, wc_cflag
wc_cont1:
	andi t0, s1, 2
	bnez t0, wc_lflag
wc_cont2:
	andi t0, s1, 4
	bnez t0, wc_Lflag
wc_cont3:
	andi t0, s1, 8
	bnez t0, wc_wflag
	j wc_end
wc_cflag:
	mv a0, s0
	call flen
	mv s2, a0 # number of bytes
	j wc_cont1
wc_lflag:
	mv a0, s0
	call fload
	mv s6, a0
	li a1, '\n'
	call count_char
	mv s3, a0
	j wc_cont2
wc_Lflag:
	bnez s6, wc_Lflag_cont
	mv a0, s0
	call fload
wc_Lflag_cont:
	li a1, '\n'
	call split
	mv s6, a0
	mv s5, a0 # treat s5 as scratch since it doesn't need to be initialized yet
	mv s0, a1 # we can also treat file descriptor register as scratch since we got everything we wanted from file
	li s4, 0
	mv s7, a1
wcLloop:
	lw a0, 0(s5)
	call strlen
	blt a0, s4, wcLloop_cont
	mv s4, a0
wcLloop_cont:
	addi s5, s5, 4
	addi s0, s0, -1
	bgtz s0, wcLloop
wcLend:
	li s5, 0
	j wc_cont3
wc_wflag:
	bnez s7, wflag_cont2
	bnez s6, wflag_cont1
	mv a0, s0
	call fload
wflag_cont1:
	li a1, '\n'
	call split
	mv s6, a0
	mv s7, a1
wflag_cont2:
	li s5, 0
wflag_loop1:
	lw s0, 0(s6)
wflag_loop2:
	mv a0, s0
	la a1, spacesymbols
	call strspn
	add s0, s0, a0
	lb a0, 0(s0)
	beqz a0, wflag_loop_cont
	addi s5, s5, 1
	mv a0, s0
	la a1, spacesymbols
	call strcspn
	add s0, s0, a0
	lb a0, 0(s0)
	bnez a0, wflag_loop2
wflag_loop_cont:
	addi s6, s6, 4
	addi s7, s7, -1
	bgtz s7, wflag_loop1
	j wc_end
wc_end:
	mv a0, s2
	mv a1, s3
	mv a2, s4
	mv a3, s5
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

check_flags: # int, char*, check_flags (int argc, char* argv[])
	push s0
	li s0, 0
	li t0, 1
	sub t0, a0, t0
	bltz t0, not_enough_args
	li t1, 0 # file_name
cf_loop:
	beqz a0, cf_end
	lw t0, 0(a1)
	li t3, '-'
	lb t4, 0(t0)
	beq t3, t4, read_flag
	mv t1, t0
continue_loop:
	addi a0, a0, -1
	addi a1, a1, 4
	j cf_loop
read_flag:
	lb t4, 1(t0)
	li t5, 'c'
	beq t4, t5, c_flag
	li t5, 'l'
	beq t4, t5, l_flag
	li t5, 'L'
	beq t4, t5, L_flag
	li t5, 'w'
	beq t4, t5, w_flag
	error "incorrect flag"
c_flag:
	ori s0, s0, 1 # if first bit is set then c flag is set
	j continue_loop
l_flag:
	ori s0, s0, 2 # if second bit is set then l flag is set
	j continue_loop
L_flag:
	ori s0, s0, 4 # if third bit is set then L flag is set
	j continue_loop
w_flag:
	ori s0, s0, 8 # if fourth bit is set then w flag is set
	j continue_loop 
cf_end:
	mv a0, s0
	mv a1, t1
	pop s0
	ret
not_enough_args:
	error "not enough arguments for the wc"
