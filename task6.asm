j main
.include "macro.asm"
.include "divmod.asm"
.include "hex_io.asm"

main:
	call readnum
	mv s0, a0
	call mod10
	call printnums
	mv a0, s0
	call div10
	newline
	call printnums
	exit 0
