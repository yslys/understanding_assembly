## Understanding Assembly

### Hello world
Check the file hello.s: it contains simple hello world assembly program. Note 
that such file can also be named as hello.asm. To compile such assembly code
to an ELF64 executable, need to run:

```
# nasm: an assembler and disassembler for the Intel x86 architecture
# -f: define the assembly program format (elf64)
# -o: output file name

nasm -f elf64 -o hello.o hello.s
```

Now we have an executable named hello.o. However, we cannot execute it yet. Why?
Because it is an object file - we need to link it using an linker to make it
an executable file. To link it, we use ```ld```.
```
# ld: linker
# -o: specifies the output executable filename

ld hello.o -o hello
```
Now, we have an executable named hello - try to execute it!


### Overview of Hello world
There are 3 sections in the x86_64 assembly.
+ ```.bss```: where data is allocated for future use.
	+ where you reserve some memory to use.
	+ E.g. reading user input.
+ ```.data```: where all the data is defined before compilation.
	+ where you define some memory to use.
+ ```.text```: where the actual code goes.

Next, there comes "label", which is used to label part of code.
+ Upon compilation, the compiler will calculate the location in which the label
will sit in memory.
+ Anytime the name of the label is used afterwards, that name is replaced by 
the location in memory by compiler.

The ```_start``` label:
+ This is essential for all programs.
+ When your program is compiled and later executed, ```_start``` is executed first.
+ If the linker cannot find ```_start```, it will throw an error.

The word ```global```:
+ It is used when you want the linker to be able to know the address of some label.
+ The object file (.o) generated will contain a link to every label declared ```global```.
+ We declare ```_start``` as ```global``` since it is required for the code to be properly linked.


In ```section .data```, we have: ```text db "hello world",10```.
+ ```text```: this is a name assigned to the address in memory that this data is located in. Whenever we sue "text" later in the code, when the code is compiled, the compiler will determine the actual location in memory of this data and replace all future instances of "text" with that memory address.
	+ In other words, ```text``` is just a label - the name of memory address, which will be replaced with an actual address when compiling.
+ ```db```: "define bytes" - meaning that we are going to define some raw bytes of data to insert into our code.
+ ```"hello world",10```: this is the bytes that we are defining. Each character in the string of text is a single byte. The ```10``` is a newline character, which denotes as ```\n```. Note that we cannot directly put ```\n``` here; hence, 10 is the only option.


Next, we will see some registers represented by assembly code. Registers are a 
part of the processor that temporarily holds memory. On 64-bit architectures, 
registers hold 64 bits. Since each register is 64 bits, what if we want to use only 32 bits, or 16 bits or even 8 bits?
+ rax: 64-bit
+ eax: (lower) 32-bit of rax
+ ax: (lower) 16-bit of rax
+ al: (lower) 8-bit of rax


Now that we have a basic understanding of the naming of the registers, we can
go to the ```_start``` label. It loads values into registers, then 
```syscall```. That means - it is executing a syscall.

How is a syscall executed?
- For now, the question we need to think about is - how to execute a syscall 
using only those available registers.

Before diving into the details, need to know what a syscall is:
- System call: a syscall is when a program requests a service from the kernel.
Each syscall has an ID associated with them. Syscall also takes arguments, 
which is a list of inputs.

Hence, in order to execute a syscall, we need to put the syscall ID, as well as
the arguments to some "specific" registers, as shown below:
+ rax: syscall ID
+ rdi: 1st argument
+ rsi: 2nd argument
+ rdx: 3rd argument
+ r10: 4th argument
+ r8: 5th argument
+ r9: 6th argument

Now, we can look back to the code:
+ ```mov rax, 1```: move the syscall ID - 1, to register rax.
+ ```mov rdi, 1```: move 1 to register rdi, i.e. the 1st argument.
+ ```mov rsi, text```: move ```text``` (it is actually the address of the defined bytes "hello world",0) to register rsi.
+ ```mov rdx, 14```: move 14 to register rdx, i.e. the 3rd argument.
+ ```syscall```: syscall can execute now.

Note that the syscall ID is 1, so let's take a loot at it:

Syscall ID 1: ```sys_write(#filedescriptor, $buffer, #count)```
+ ```#``` means the value is a number.
+ ```$``` means the value is a memory address.
+ ```filedescriptor```:
	+ 0: standard input
	+ 1: standard output
	+ 2: standard error
+ ```buffer```: location of the string to write.
+ ```count```: length of the string. 

The next syscall in the code has an ID of 60 - ```sys_exit```. It only takes in
one param - ```#errorcode```, which is the value that will be returned. If 
program exits with no failure, then simply return 0.

As you may have noticed - in assembly code, the address of the string is 
defined as ```text```. And we do not know what the actual address it 
corresponds to. So the question for now is - **when we would know what the value
of ```text``` is, at runtime, or as soon as linking finished?**

The answer is - ```text``` will be replaced with a memory address while 
compiling.


### Misc
When defining data in section ```.data```, we have seen the example of ```db```
which means defining a byte. What if we want to define 2, 4 bytes?
+ db is 1 byte 
```
name1 db "string"
name2 db 0xff
name3 db 100
```

+ dw is 2 bytes
```
name4 dw 0x1234
name5 dw 1000
```

+ dd is 4 bytes
```
name6 dd 0x12345678
name7 dd 100000
```







### Stack
Recall the memory layout of a process, the stack stays in the top of the whole
memory space. Hence, when we push something into the stack, it has the highest
address at first, then when we push more, the address decreases, until we reach
the limit.

Two important things to know:
- **```esp``` register holds the address of the top of the stack.**
- **```[esp]``` means the value stored at address esp.**

+ Push
	+ Decrease esp by 4 (32-bit) or 8 (64-bit).
	+ Write the value to address of value esp.
	+ E.g. for 32-bit assembly, ```push 357``` is equivalent to ```sub esp, 4```, then ```mov [esp], dword 357```. ```dword``` means we are telling nasm that we are moving a 4-byte value to the memory location specified by esp register.
	
+ Pop
	+ Move the value at address esp into another specified register
	+ Increase esp by 4 (32-bit) or 8 (64-bit)
	+ E.g. for 32-bit assembly, we pop the value to register eax: ```pop eax```. This is equivalent to ```mov eax, dword [esp]``` then ```add esp, 4```.








###


Here we have one source file - hello_world.c, very simple. In ```main()```, it calls ```foo1()```;
in ```foo1()```, it calls ```foo2()```; in ```foo2()```, it prints something.

### Somehting to know about gcc:
There are several frequently used flags passed to ```gcc```: (according to manpage)
- ```-S```: compile and stop after the stage of compilation.
- ```-E```: compile and stop after the preprocessing stage.

For instance, we can do the following:
- ```gcc -E hello_world.c > hello_world.i```: to generate the code after preprocessing.
- ```gcc -S hello_world.i```: this will generate a file ```hello_world.s```, the assembly code.

### Compile to obtain the assembly
```
```gcc -S hello_world.c```

Check the file ```hello_world.s```, we can see there are a few labels:

+ .file "hello_world.c"
+ .text
+ .section    .rodata
+ LC0: local constant

+ foo2
	+ LFB6: local function begin
	+ LFE6: local function end
+ foo1
	+ LFB7
	+ LFE7
+ main
        + .LFB8: local function begin marker
        + .LFE8: local function end marker




