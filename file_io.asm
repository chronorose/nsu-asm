.include "macro.asm"

.macro open
	syscall 1024
.end_macro

.macro close %fd
	mv t6, a0 #t6 is scratch register
	mv a0, %fd
	syscall 57
	mv a0, t6
.end_macro

fopen:
	li a1, 0
	open
	li t0, -1
	beq a0, t0, fopen_error
	ret
fopen_error:
	error "Error happened during opening of the file"
	
.macro lseek
	li t0, -1
	syscall 62
	beq t0, a0, lseek_error
.end_macro

flen:
	push s0
	mv s0, a0
	li a1, 0
	li a2, 2
	lseek
	swap s0, a0
	li a1, 0
	li a2, 0
	lseek
	mv a0, s0
	pop s0
	ret

lseek_error:
	error "error happened during lseek"

