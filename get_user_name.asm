;comments start with a ";"


; This program first prints a string "What is your name?", then waiting for
; user's input. Once user types in his/her name, this program will then print
; "Hello, " followed by the name of the user.
;
; Inside _start, there are four sub-routines:
;     _printText1: print "What is your name?"
;     _getName: wait for user to input the name
;     _printText2: print "Hello, "
;     _printName: print the name of the user
;
; To compile this assembly code to object file:
;     $ nasm -f elf64 get_user_name.asm -o get_user_name.o
; To link the object file into an executable:
;     $ ld get_user_name.o -o get_user_name


section .data
	text1 db "What is your name?",10 ;len of this string: 18+1
	text2 db "Hello, "

section .bss
	; resb: reserve bytes
	; We reserve 16 bytes of space to use
	; We can reference such 16 bytes using @name.
	name resb 16

section .text
	;start is going to be globally available to the entire program
	global _start

;_start is now a label
_start:
	call _printText1
	call _getName
	call _printText2
	call _printName

	;sys_exit(0)
	mov rax, 60
	mov rdi, 0
	syscall

; first, start with reading from stdin
_getName:
	; sys_read(0, name, 16)
	mov rax, 0
	mov rdi, 0
	mov rsi, name
	mov rdx, 16
	syscall
	ret


; Let's continue with the three simple print to stdout routines
_printText1:
	; sys_write(1, text1, 18)
	mov rax, 1
	mov rdi, 1
	mov rsi, text1
	mov rdx, 19
	syscall
	ret

_printText2:
	; sys_write(1, text2, 7)
	mov rax, 1
	mov rdi, 1
	mov rsi, text2
	mov rdx, 7
	syscall
	ret

_printName:
	; sys_write(1, name, )
	mov rax, 1
	mov rdi, 1
	mov rsi, name
	mov rdx, 16 ; we've reserved 16 bytes to store the name of user (.bss)
	syscall
	ret

