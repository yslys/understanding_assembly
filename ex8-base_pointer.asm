; Modifying the stack requires you to be careful. There is a common technique
; for preserving the stack - a register known as a base pointer.
; The base pointer is usually set to stack pointer at the START of the function.
; Function params & local vars are accesses by adding or subtracting a constant
; offset from the base pointer.

;;;;;;
; PROBLEM:
; What if a function calls another function?
; By storing the stack pointer value into the base pointer register, if inside
; such function, we are calling another function, then using the same technique
; will OVERWRITE the base pointer. That is NOT what we want.
;
; SOLUTION:
; Check the assembly code "ex8-push_ebp.asm" for solution.
;;;;;;


;;;;;;
; While writing this code, I realized one important thing.
; "What does it mean when we allocate something on the stack/heap"
; This is simply modifying the stack pointer (rsp), i.e. subtracting the size
; of the allocated space. That corresponds to brk() function right? We are just
; modifying the top of the stack/heap.
;;;;;;


; In the following example, the function does one thing - sets the exit status
; of the program, and prints "Hi".

; Use "$ echo $?" to check the exit status of the program

global _start

section .text
_start:
	call func	; perform function call
	mov eax, 1	; sys_exit()
	int 0x80

func:
	; first, store stack pointer value to our base pointer
	mov rbp, rsp		; move rsp to rbp (base pointer)

	; allocate 3 bytes in the stack, and fill in some bytes
	sub rsp, 3		; then we can safely modify rsp
	mov [rsp], byte 'H'
	mov [rsp+1], byte 'i'
	mov [rsp+2], byte 0x0a

	; print what's on top of stack (the 3 bytes we just allocated)
	mov rax, 1
	mov rdi, 1
	mov rsi, rsp
	mov rdx, 3
	syscall

	; set exit status to 42
	mov ebx, 42

	; restore esp, i.e. de-allocate memory we have allocated on stack
	mov rsp, rbp
	ret		; return

