.eqv __TEST_FUNC "strchr"
.macro OK %pos %str %char
.data
str: .asciz %str
.text
	li a1, %char
	la a0, str
	mv t6, a0
	lw t5, current_func
	jalr t5
	beqz a0, ok_failed
	sub a0, a0, t6
	bnez a0, ok_failed
	j ok_passed
ok_failed:
	lw t6, counter_failed
	addi t6, t6, 1
	sw t6, counter_failed, t5
	print_str "Test failed: "
	print_str __TEST_FUNC
	print_str "(\""
	print_str %str
	print_str "\", '"
	print_char %char
	print_str "') results in "
	beqz a0, print_none
	print_str "OK("
	printInt
	print_str ")"
	j ok_continue
print_none:
	print_str "NONE"
ok_continue:
	print_str ", expected OK("
	print_int %pos
	print_str ")\n"
	j ok_exit
ok_passed:
	lw t0, counter_passed
	addi t0, t0, 1
	sw t0, counter_passed, t1
ok_exit:
.end_macro

.macro NONE %str %char
.data
str: .asciz %str
.text
	li a1, %char
	la a0, str
	lw t6, current_func 
	jalr t6
	beqz a0, none_passed
	la t6, str
	sub a0, a0, t6
	lw t6, counter_failed
	addi t6, t6, 1
	sw t6, counter_failed, t5
	print_str "Test failed: "
	print_str __TEST_FUNC
	print_str "(\""
	print_str %str
	print_str "\", '"
	print_char %char
	print_str "') results in OK("
	printInt
	print_str "), expected NONE\n"
	j none_exit
none_passed:
	lw t6, counter_passed
	addi t6, t6, 1
	sw t6, counter_passed, t5
none_exit:
.end_macro
