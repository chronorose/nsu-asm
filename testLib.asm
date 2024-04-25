# these tests are tailor made for strchr since you can't do variable amount of arguments in rars
.include "macro.asm"
.macro FUNC %func %label
.data
label: .asciz %label
#counter_passed: .word 0
#counter_failed: .word 0
testing_function: .asciz "Testing function "
dots: .asciz "...\n"
.text
fn_start:
	mv t6, a0
	la a0, testing_function
	syscall 4
	la a0, label
	syscall 4
	la a0, dots
	syscall 4
.end_macro

.macro OK %pos %str %char
.data
str: .asciz %str
.text
	li a1, %char
	la a0, str
	mv t6, a0
	call strchr
	beqz a0, ok_failed
	sub a0, a0, t6
	bnez a0, ok_failed
	j ok_passed
ok_failed:
#	la t0, counter_failed
#	lw t0, 0(t0)
#	addi t0, t0, 1
#	sw t0, counter_failed, t1
.data
failed: .asciz "Test failed\n"
.text
	la a0, failed
	syscall 4
	j ok_exit
ok_passed:
#	la t0, counter_passed
#	lw t0, 0(t0)
#	addi t0, t0, 1
#	sw t0, counter_passed, t1
ok_exit:
.end_macro

.macro NONE %str %char
.data
str: .asciz %str
	li a1, %char
	la a0, str
	call strchr
	beqz a0, none_passed
none_failed:
failed: .asciz "Test failed\n"
.text
	la a0, failed
	syscall 4
	j none_exit
none_passed:
none_exit:
.end_macro