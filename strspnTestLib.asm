.eqv __TEST_FUNC "strspn"
.macro OK %pos %str %str2
.data
str: .asciz %str
str2: .asciz %str2
.text
	la a1, str2
	la a0, str
	mv t6, a0
	lw t5, current_func
	jalr t5
	li t5, %pos
	bne a0, t5, ok_failed
	j ok_passed
ok_failed:
	lw t6, counter_failed
	addi t6, t6, 1
	sw t6, counter_failed, t5
	print_str "Test failed: "
	print_str __TEST_FUNC
	print_str "(\""
	print_str %str
	print_str "\", \""
	print_str %str2
	print_str "\") results in "
	print_str "OK("
	printInt
	print_str ")"
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

