;comments start with a ";"

section .data
	text db "hello world",10

section .text
	;start is going to be globally available to the entire program
	global _start

;_start is now a label
_start:
	; sys_write(1, text, 14)
	mov rax, 1
	mov rdi, 1
	mov rsi, text
	mov rdx, 14
	syscall

	;sys_exit(0)
	mov rax, 60
	mov rdi, 0
	syscall

