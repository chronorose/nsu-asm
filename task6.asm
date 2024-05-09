j main
#.include "divmod.asm"
.include "dec_io.asm"

main:
	call read_dec
	mv s0, a0
	call mod10
	call print_dec
	mv a0, s0
	call div10
	newline
	call print_dec
	exit 0
