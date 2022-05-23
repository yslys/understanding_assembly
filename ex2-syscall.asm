;
; len equ $ - msg:
; This is to determine the length of the string, and store in @len.
; To calculate the length, we subtract the location of the start of the string
; from the location after the string, i.e. addr(end) - addr(start)
;       $: this refers to the current address
;       msg: this refers to the starting address of the string @msg


; As we can see from this example, we can also put "global _start" here.
global _start

section .data
	msg db "Hello World", 0x0a ;define bytes for the string msg.
	len equ $ - msg


section .text
_start:
	; sys_write(1, msg, len)
	mov rax, 1
	mov rdi, 1
	mov rsi, msg
	mov rdx, len
	syscall

	mov rax, 60
	mov rdi, 0
	syscall
