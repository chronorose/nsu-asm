j main
.include "dec_io.asm"
main:
	call read_dec
	call print_dec
	exit 0