j main
.include "file_io.asm"
.include "str_lib.asm"
.text

main:
	lw a0, 0(a1)
	call fopen # fd
	mv s0, a0
	call fload #char* str
	mv s1, a0 #char* str
	li a1, '\n'
	call split
	call cats_tail
        exit 0
	
cats_tail:
	push s0
	push s1
	mv s0, a0
	li s1, 0
ct_loop:
	blez a1, ct_end
	lw a0, (s0)
	syscall 4
	addi s0, s0, 4
	addi a1, a1, -1
	j ct_loop
ct_end:
	ret