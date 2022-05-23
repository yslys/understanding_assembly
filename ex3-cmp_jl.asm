; This example shows the usage of cmp and jl
; Similarly, we can do 
; je: jump if equal
; jne: jump if not equal
; jg, jge, jl, jle


; $ nasm -f elf64 ex3-cmp-jl.asm
; $ ld ex3-cmp-jl.o
; $ echo $?   // this should print the exit status: 42

global _start

section .text
_start:
	mov eax, 1	; sys_exit() syscall
	mov ebx, 42	; exit status is 42
	mov ecx, 99	; set ecx to 99
	cmp ecx, 100	; compare ecx to 100
	jl skip		; jump to "skip" label if cmp returns "less than"
	mov ebx, 13	; this will not be executed
skip:
	int 0x80
