j main
.include "file_io.asm"


main:
	li t0, 1
	bne t0, a0, invalid_args
	println "name of the file: "
	lw a0, 0(a1)
	printStr
	call fopen
	mv s0, a0
	call flen
	println "size of the file: "
	printInt
	close s0
	exit 0
	
invalid_args:
	error "invalid number of arguments"