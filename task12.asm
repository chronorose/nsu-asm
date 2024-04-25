j main
.include "str_lib.asm"
.include "file_io.asm"
.text

main:
	lw a0, 0(a1)
	call fopen # fd
	mv s0, a0
	call fload #char* file
	call count_lines
	syscall 1
        exit 0

count_lines: # int count_lines(char*)
	push ra
	push s0
	li s0, 0
cl_loop:
	li a1, '\n'
	call strchr
	beqz a0, cl_end
	addi s0, s0, 1
	addi a0, a0, 1
	j cl_loop
cl_end:
	mv a0, s0
	pop s0
	pop ra
	ret
