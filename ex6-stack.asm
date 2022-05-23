; This program shows the usage of stack.
; We first allocate 4 bytes on the stack, then write to it one by one.

; This program was originally written for 32-bit system, which used registers
; like esp, eax, ebx, ecx, etc.. However, those will lead to segmentation fault
; Especially after we subtracted esp by 4, and move one byte to esp points to.
; That is where we will incur segmentation fault.
; Therefore, I used rsp instead, and used syscall version targeting 64-bit.
; Hence, no more "int 0x80"; instead, we directly use "syscall".


global _start

section .text
_start:
	sub rsp, 4		; allocate 4 bytes on the stack
	mov [rsp], byte 'H'	; move 'H' to address esp
	mov [rsp+1], byte 'e'
	mov [rsp+2], byte 'y'
	mov [rsp+3], byte 10

	; sys_write()
	mov rax, 1		; sys_write()
	mov rdi, 1		; print to stdout
	mov rsi, rsp		; pointer to the bytes to write
	mov rdx, 4		; number of bytes to write
	syscall			; do syscall

	; sys_exit()
	mov rax, 60		; sys_exit()
	mov rdi, 0		; exit status is 0
	syscall
