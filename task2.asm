.text

.macro syscall %n
	li a7, %n
	ecall
.end_macro

 .macro readch
 	syscall 12
 .end_macro
 
  .macro printch
  	syscall 11
  .end_macro 
  
  .macro newline
  	mv s0, a0
  	li a0, 10
  	printch
  	mv a0, s0
  .end_macro
  
  .macro println
  	newline
  	printch
  .end_macro
  
  .macro exit %n
  	li a0, %n
  	syscall 93
  .end_macro

main:
	readch
	li t0, '\n'
	beq t0, a0, exit
	addi a0, a0, 1
	println
	j main
	
	
exit:
	exit 0
