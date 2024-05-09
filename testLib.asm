.include "macro.asm"

.data
counter_passed: .word 0
counter_failed: .word 0
current_func: .word 0

.text
.macro FUNC %func %label
.text
fn_start:
	li t6, 0
	sw t6, counter_failed, t5
	sw t6, counter_passed, t5
	la t6, %func
	sw t6, current_func, t5
	print_str "Testing function "
	print_str %label
	print_str "...\n"
.end_macro

.macro DONE
	print_str "Passed: "
	lw t6, counter_passed
	swap t6, a0
	syscall 1
	swap t6, a0
	print_str ", failed: "
	lw t6, counter_failed
	swap t6, a0
	syscall 1
	swap t6, a0
	newline
.end_macro
