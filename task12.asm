j main
.include "file_io.asm"
.include "str_lib.asm"
.text

main:
	lw a0, 0(a1)
	call fopen # fd
	mv s0, a0
	call fload #char* file
	li a1, '\n'
	call count_char
	syscall 1
        exit 0