j main
.include "file_io.asm"
.include "str_lib.asm"

.data
sorted: .asciz ".sorted"
slashn: .asciz "\n"
.text

main:
	lw a0, 0(a1)
	mv s3, a0
	call fopen
	mv s2, a0
	call fload
	li a1, '\n'
	call splitv
	mv s1, a1
	mv s0, a0
	#call print_arr
	li a2, 0
	addi a3, s1, -1
	li a4, 0
	mv a0, s0
	mv a1, s1
	call radix_sort
	mv s0, a0
	mv s1, a1
	mv a0, s3
	la a1, sorted
	call concatenate
	mv a2, a0
	mv a0, s0
	mv a1, s1
	call write_to_file
	exit 0

.macro char_at %reg %pos %arr
	addi t6, %reg, 4
	lw t6, 0(t6)
		
	ble t6, %pos, ca_ss

	add %arr, %arr, %pos
	lb t5, 0(%arr)
	j ca_end
ca_ss:
	li t5, -1
ca_end:
.end_macro
radix_sort: # char** radix_sort(char** strings, int stringcount, int low, int high, int d)
	#push s0
	#mv s0, a0
	bgt a2, a3, radix_return
	push ra
	push s0
	push s1
	push s2
	addi sp, sp, -1028
	mv t5, sp
	li t6, 257
zero_array:
	sw zero, 0(t5)
	addi t6, t6, -1
	addi t5, t5, 4
	bgez t6, zero_array
	
	mv t1, a2
	mv t0, a0
count:
	lw t2, 0(t0)
	char_at t0 a4 t2
	
	addi t5, t5, 2
	slli t5, t5, 2
	add t5, sp, t5
	lw t4, 0(t5)
	addi t4, t4, 1
	sw t4, 0(t5)
	addi t0, t0, 8
	addi t1, t1, 1
	ble t1, a3, count
	mv t0, sp
	addi t1, t0, 4
	li t2, 256
count2:
	lw t3, 0(t0)
	lw t4, 0(t1)
	add t4, t3, t4
	sw t4, 0(t1)
	addi t0, t0, 4
	addi t1, t1, 4
	addi t2, t2, -1
	bgtz t2, count2
	mv t0, sp # pointer for count array(don't lose)
	#mv t4, t0
	slli t1, a1, 2
	sub sp, sp, t1
	mv t1, a0
	mv t2, a2
temp:
	lw t3, 0(t1)
	char_at t1 a4 t3
	addi t5, t5, 1
	slli t5, t5, 2
	add t4, t0, t5 # count[c + 1]
	lw t5, 0(t4) # deref
	slli t5, t5, 2
	add t6, t5, sp
	lw t3, 0(t1)
	sw t3, 0(t6)
	lw t3, 0(t4)
	addi t3, t3, 1
	sw t3, 0(t4)
	
	addi t1, t1, 8
	addi t2, t2, 1
	ble t2, a3, temp
	mv t1, a2
	slli t1, t1, 3
	add t1, t1, a0
	
	mv t2, a2
copy_temp:
	sub t4, t2, a2
	slli t4, t4, 2
	add t4, sp, t4
	lw t4, 0(t4)
	#lw t5, 0(t1)
	
	sw t4, 0(t1)
	addi t1, t1, 8
	addi t2, t2, 1
	ble t2, a3, copy_temp
	slli t1, a1, 2
	add sp, sp, t1
	li s0, 0
	addi s2, a4, 1
	mv s1, a2
rec_cycle:
	slli t2, t0, 2
	add t2, sp, t2
	lw t4, 0(t2)
	add a2, s1, t4
	addi t2, t2, 4
	lw t4, 0(t2)
	add a3, s1, t4
	addi a3, a3, -1
	mv a4, s2
	call radix_sort
	addi s0, s0, 1
	li t3, 256
	blt s0, t3, rec_cycle
	addi sp, sp, 1028
	pop s2
	pop s1
	pop s0
	pop ra
	ret

radix_return:
	ret
	
print_arr:
	push s0
	mv s0, a0
	addi a1, a1, -1
pra_loop:
	lw a0, 0(s0)
	syscall 4
	print_str " | adress: "
	syscall 1
	li a0, ' '
	syscall 11
	addi s0, s0, 4
	lw a0, 0(s0)
	syscall 1
	newline
	addi s0, s0, 4
	addi, a1, a1, -1
	bgez a1, pra_loop
	pop s0
	ret

concatenate: # char* concatenate(char*, char*)
	push ra
	push s0
	push s1
	push s2
	li s2, 0
	mv s0, a0
	mv s1, a1
	call strlen
	add s2, a0, s2
	mv a0, s1
	call strlen
	add s2, a0, s2
	mv a0, s2
	addi a0, a0, 1
	syscall 9
	mv s2, a0
concfirst:
	lb t0, 0(s0)
	sb t0, 0(a0)
	addi s0, s0, 1
	addi a0, a0, 1
	bnez t0, concfirst
	addi a0, a0, -1
concsecond:
	lb t0, 0(s1)
	sb t0, 0(a0)
	addi s1, s1, 1
	addi a0, a0, 1
	bnez t0, concsecond
	addi a0, a0, 1
	li t0, '\0'
	sb t0, 0(a0)
	mv a0, s2
	pop s2
	pop s1
	pop s0
	pop ra
	ret

write_to_file: # void write_to_file(char**, int arr_len, char* path)
	push ra
	push s0
	push s1
	push s2
	mv s0, a0
	mv s1, a1
	mv a0, a2
	call fopen_write
	mv s2, a0
write_loop:
	lw a0, 0(s0)
	call strlen
	mv a2, a0
	mv a0, s2
	lw a1, 0(s0)
	syscall 64
	mv a0, s2
	li a2, 1
	la a1, slashn
	syscall 64
	addi s1, s1, -1
	addi s0, s0, 8
	bgtz s1, write_loop
	pop s2
	pop s1
	pop s0
	pop ra
	ret
	