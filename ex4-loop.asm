; This example shows a simple loop in assembly.
; ebx is init to be 1, doubled in each loop, a total of 4 loops.
; Hence, exit status should be 16 in this case.

; $ nasm -f elf64 ex4-loop.asm
; $ ld ex4-loop.asm
; $ echo $?   // should print 16



global _start

section .text
_start:
	mov eax, 1	; sys_exit syscall (only for "int 0x80", not "syscall")
	mov ebx, 1	; initially, set ebx to be 1
	mov ecx, 4	; number of iterations (loops)

label:
	add ebx, ebx	; ebx += ebx
	dec ecx		; decrement ecx by 1 (initially set to 4)
	cmp ecx, 0	; compare ecx with 0
	jg label	; jump to "label" if ecx > 0

	int 0x80	; interrupt with syscall interrupt handler
