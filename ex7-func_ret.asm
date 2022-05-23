; This example shows how a function call is performed in assembly.
; The instruction is called "call".
; It first pushes the instruction pointer (for the next inst) onto the stack;
; Then, it jumps to the location we specified.
;
; Hence, "call" will allow the program to jump to somewhere else in the program
; and then jump back to where we came from.

; In the following example, the function does one thing - sets the exit status
; of the program, and prints something.

global _start

section .data
	string1 db "Inside func", 0x0a
	len equ $-string1

section .text
_start:
	call func	; perform function call
	mov eax, 1	; sys_exit()
	int 0x80

func:
	; print string1
	mov rax, 1
	mov rdi, 1
	mov rsi, string1
	mov rdx, len
	syscall

	; set exit status to 42
	mov ebx, 42

	; func returns
	;pop rax	; "call" pushes the next instruction pointer onto the
			; stack. So now we are popping it into eax register
	;jmp rax	; Then, we jump to the "next instruction".
	ret
