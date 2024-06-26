strchr: # char* strchr(char* str, char ch)
	beqz a0, strchr_nfound
strchr_loop:
	lb t0, 0(a0)
	beqz t0, strchr_nfound
	beq t0, a1, strchr_found
	addi a0, a0, 1
	j strchr_loop
strchr_nfound:
	li a0, 0
	ret
strchr_found:
	ret

count_char: # int count_char(char* buf, char ch)
	push ra
	push s0
	push s1
	li s0, 0
	mv s1, a1
cc_loop:
	mv a1, s1
	call strchr
	beqz a0, cc_end
	addi s0, s0, 1
	addi a0, a0, 1
	j cc_loop
cc_end:
	mv a0, s0
	pop s1
	pop s0
	pop ra
	ret

split:  # char** split(char* buf, char ch)
	push ra
	push s0
	push s1
	push s2
	push s3
	
	mv s0, a0
	mv s1, a1
	call count_char
	mv s3, a0
	slli a0, a0, 2
	syscall 9
	mv s2, a0
	mv a0, s0
	mv s0, s2
	sw a0, 0(s0)
	addi s0, s0, 4
split_loop:
	mv a1, s1
	call strchr
	beqz a0, split_end
	sb zero, 0(a0)
	addi a0, a0, 1
	sw a0, 0(s0)
	addi s0, s0, 4
	j split_loop
split_end:
	mv a0, s2
	mv a1, s3
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret

strstr: #char* strstr(const char* str, const char* to_find
	push s0
	push s1
	
	mv s0, a0
	mv s1, a1
strstr_loop:
	lb t0, 0(a0)
	lb t1, 0(a1)
	beqz t1, found
	beqz t0, not_found
	bne t0, t1, strstr_ne
	addi a0, a0, 1
	addi a1, a1, 1
	j strstr_loop
strstr_ne:
	mv a1, s1
	addi s0, s0, 1
	mv a0, s0
	j strstr_loop
found:
	mv a0, s0
	j strstr_end
not_found:
	li a0, 0
strstr_end:
	pop s1
	pop s0
	ret
	
# version of strstr that forcefully lowercases everything trying to search for substring
strstr_lc: #char* strstr(const char* str, const char* to_find
	push s0
	push s1
	
	mv s0, a0
	mv s1, a1
strstr_lc_loop:
	lb t0, 0(a0)
	lb t1, 0(a1)
	beqz t1, lc_found
	beqz t0, lc_not_found
	j strstr_lowercase
strstr_lc_loop_cont:	
	bne t0, t1, strstr_lc_ne
	addi a0, a0, 1
	addi a1, a1, 1
	j strstr_lc_loop
strstr_lc_ne:
	mv a1, s1
	addi s0, s0, 1
	mv a0, s0
	j strstr_lc_loop
lc_found:
	mv a0, s0
	j strstr_lc_end
lc_not_found:
	li a0, 0
strstr_lc_end:
	pop s1
	pop s0
	ret

strstr_lowercase:
	xori t2, t0, 64
	xori t3, t1, 64
	beqz t2, ss_lc_skip_first
	beqz t3, ss_lc_skip_second
	addi t2, t2, -26
	addi t3, t3, -26
	blez t2, ss_lc_first
	blez t3, ss_lc_second
	j ss_lc_end
ss_lc_skip_first:
	beqz t3, ss_lc_end
	addi t3, t3, -26
	blez t3, ss_lc_second
	j ss_lc_end
ss_lc_skip_second:
	addi t2, t2, -26
	bgtz t2, ss_lc_end
	addi t0, t0, 32
	j ss_lc_end
ss_lc_first:
	addi t0, t0, 32	
	blez t3, ss_lc_second
	j ss_lc_end
ss_lc_second:
	addi t1, t1, 32
ss_lc_end:
	j strstr_lc_loop_cont
	
strspn: # size_t strspn(const char* str1, const char str2)
	li t2, 0
	mv t3, a1
strspn_loop:
	lb t0, 0(a0)
	beqz t0, strspn_end
strspn_loop_cont:
	lb t1, 0(a1)
	beqz t1, strspn_end
	beq t0, t1, strspn_found
	addi a1, a1, 1
	j strspn_loop_cont
strspn_found:
	addi a0, a0, 1
	addi t2, t2, 1
	mv a1, t3
	j strspn_loop
strspn_end:
	mv a0, t2
	ret

strcspn: # size_t strspn(const char* str1, const char str2)
	li t2, 0
	mv t3, a1
strcspn_loop:
	lb t0, 0(a0)
	beqz t0, strcspn_end
strcspn_loop_cont:
	lb t1, 0(a1)
	beqz t1, strcspn_nfound
	beq t1, t0, strcspn_end
	addi a1, a1, 1
	j strcspn_loop_cont
strcspn_nfound:
	addi t2, t2, 1
	addi a0, a0, 1
	mv a1, t3
	j strcspn_loop
strcspn_end:
	mv a0, t2
	ret

strlen: # size_t strlen(const char* str)
	li t0, 0
	beqz a0, strlen_end
strlen_loop:
	lb t1, 0(a0)
	beqz t1, strlen_end
	addi t0, t0, 1
	addi a0, a0, 1
	j strlen_loop
strlen_end:
	mv a0, t0
	ret

splitv:  # char** splitv(char* buf, char ch) version of the split that also has amount of symbols in string in the next pointer to it
	push ra
	push s0
	push s1
	push s2
	push s3
	push s4
	mv s0, a0
	mv s1, a1
	call count_char
	mv s3, a0
	slli a0, a0, 3
	syscall 9
	mv s2, a0
	mv a0, s0
	mv s0, s2
	sw a0, 0(s0)
	mv s4, a0
	addi s4, s4, -1
	addi s0, s0, 4
splitv_loop:
	mv a1, s1
	call strchr
	beqz a0, splitv_end
	sb zero, 0(a0)
	sub t0, a0, s4
	addi t0, t0, -1
	sw t0, 0(s0)
	addi s0, s0, 4
	mv s4, a0
	addi a0, a0, 1
	sw a0, 0(s0)
	addi s0, s0, 4
	j splitv_loop
splitv_end:
	mv a0, s2
	mv a1, s3
	pop s4
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret