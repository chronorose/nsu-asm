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
