; This example shows the usage of jmp

; $ nasm -f elf64 ex3-jmp.asm
; $ ld ex3-jmp.o
; $ echo $?   // this should print the exit status: 42

global _start

section .text
_start:
	mov eax, 1	; sys_exit() syscall
	mov ebx, 42	; exit status is 42
	jmp skip	; jump to "skip" label
	mov ebx, 13	; this will not be executed
skip:
	int 0x80
