; In this example, we show the usage of altering the content of a string
; at runtime. In other words, we will be working with contiguous bytes.


global _start

section .data
	addr db "yellow",10	; define bytes "yellow"

section .text
_start:
	; alter the string @addr
	mov [addr], byte 'H'	; move byte 'H' to address at @addr
				; i.e. replace 'y' with 'H'
	mov [addr+5], byte '!'

	; eax: syscall ID
	; ebx, ecx, edx: params passed to syscall
	mov eax, 4	; sys_write() syscall
	mov ebx, 1	; write to stdout file descriptor
	mov ecx, addr	; set the bytes to be written
	mov edx, 7	; set the number of bytes to write
	int 0x80	; interrupt with syscall handler

	mov eax, 1	; sys_exit() syscall
	mov ebx, 0	; set exit status to be 0
	int 0x80	; syscall again
