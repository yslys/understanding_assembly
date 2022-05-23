; This is the simplest assembly program with the exit status being 21.
;
; int 0x80:
; (This is a legacy way to invoke a syscall and should be avoided.)
; This is an interrupt, meaning the processor will transfer control to the
; interrupt handler specified by 0x80, which is the interrupt handler for
; syscalls. The syscall that it made is determined by eax register.
; The value 1 means we are making an exit syscall, which will signal the end of
; our program. The value stored in ebx register will be the exit status for the
; program.
;
; In this syscall, we are storing 1 to eax, the lower 32-bit of register rax.
; This is different than storing 1 to rax, which represents sys_write().



; To compile:
; $ nasm -f elf64 ex1.asm -o ex1.o
; $ ld ex1.o -o ex1
;
; To verify the result of the program:
; $ ./ex1
; $ echo $?        # to check the exit status of previous program

; Define the entry point of the assembly code
global _start

_start:
	mov eax, 1
	mov ebx, 42
	sub ebx, 21
	int 0x80 ; interrupt.
