# Compiling, assembling and linking

Given a .c file, we compile it (```gcc -S```) to obtain .asm/.s file, then 
assemble it to obtain the object file .o, finally link it to obtain the executable (elf).
ELF: executable and linkable format.

Resource:
+ [Compiling, assembling, and linking](https://www.youtube.com/watch?v=N2y6csonII4)




## Hello World example
```
#include <stdio.h>

int main() {
	int a = 0;
	int b = a + 5;
	printf("%d\n", b);
	return 0;
}
```
Note that the following analysis is based on GCC version 5.4.0. I wanted to 
find the corresponding information using GCC v9.4.0, but I failed to find it.

#### Compile (gcc -S test.c)
Compile it to assembly code (gcc -S). We can see that there is one line: 
```call printf``` (GCC v5.4.0). However, the actual assembly code of how 
```printf()``` works is not shown here. Where it is?

If we look at several lines below:
```
.def    printf; .scl    2;  .type  32; .endef
```
This line shows the relocation information, which means we need to look 
elsewhere for the printf() function, and the linker will use that information
later to connect us to that function.


#### Assemble (gcc -c test.c)
Assemble the code will give us an object file - test.o. If we ```cat``` it, we
cannot see to much of useful information since most are binaries, however, we
can still extract something to get a better understanding of how an object file
is formatted.

+ Object file header (```filename.c```: name of file, ```main```: telling us where program starts)
+ Text segment (.text)
	+ This segment is where our code will be, and how we are going to allocate the text segment.
+ Data segment (.data)
+ Relocation information & Symbol table (```printf```)
+ Debugging information

#### Linker (static)
This is the last step before generating an executable. After compiling, we have
1 or more object files. Those object files can be recombined by the linker. 
Besides the linker also connects the object files to libraries such as ```stdio```.
The linker finds all the data that is missing, and turns it into an executable
that we can run.

**How does the linker do that?** (see example below)

Suppose we have two object files f1 and f2. f1 contains main(), f2 contains a 
function foo(), which is called in main(). main() also calls printf() which is 
defined in C standard library. By merely looking at f1, the linker will notice
that both foo() and printf() are relocation records. The linker will resolve
references to undefined symbols.

Next, the linker will generate an executable file which contains the definition
of foo() and printf().

#### What about dynamic linking?
We do not cover it in this section, since the videos only talked about static linking
for simplicity; however, none of them explicitly said "this is static linking, not dynamic linking".

For more info about dynamic linking, I found another useful video, which is covered
in the next section.



## Notes from a series of videos
In the following sections, I would follow the videos uploaded by Prof. Chris Kanich.
I would post the link to each video in each section. The topic for each section is
exactly the same as the topic of the video - not only because some of the topics 
are quite attractive, but also because of the fact that professors are much better 
than me on summarizing things.

### Executable Linkers are basically just home theater setups
- [video](https://www.youtube.com/watch?v=eQ0KOT_J8Sk&list=PLhy9gU5W1fvUND_5mdpbNVHC1WCIaABbP&index=10)
- [article](https://medium.com/@mahmoudabdalghany/linking-on-linux-x86-64-machines-933a17419ceb)


> I like the beginning of this video, where he mentioned that nowadays most 
programmers build things on top of the existing ones, e.g. those libraries, and
compilers like gcc, llvm. I was one of them - I wrote C programs, then compile
them without understanding what was going on under the hood.

+ What does a linker do?
	+ A linker combines files, updates addresses of symbols.

+ What is a symbol?
	+ Symbols are the tool we use to transfer from "variable names (in source code, by programmer)" to "memory addresses (in machine instructions, understood by CPU)". In other words, symbols are equivalent to memory offsets.
	+ **Not all variables are going to be symbols.** For instance, a loop invariant is only going to be referenced within that loop, it is never needed to be referenced anywhere else. Therefore, the linker does not care about such kind of variables.

+ What creates symbols?
	+ **The compiler needs to create symbols**, as well as **relocation entries** for any symbol that needs to be resolved **before this program can run**. 

+ What does the linker do (again)?
	+ When the linker comes in, the linker is going to find all of those symbol locations, and rewrite them in a way that allows the program to execute.

Now, it is necessary for us to pause for a minute. What we have discussed on the 
linker so far does not distinguish the difference between static linking and 
dynamic linking. Dynamic linking is performed during runtime, while static linking
is done before the ELF file is generated.

+ What is the raw input for the linking process (to the linker, dynamic linking)?
	+ The relocatable object file (ELF files in Linux)

We can now take a look at how a relocatable object file (.o file) is organized.
Under the ELF header (yes, .o files also contain ELF header), there are a bunch
of sections. (For more detailed explaination, refer to the link to the [article](https://medium.com/@mahmoudabdalghany/linking-on-linux-x86-64-machines-933a17419ceb) by Mahmoud Abd Al-Ghany)

```
ELF header
Section header table // contains the offsets of each subsequent sections
.text     // all the code that we wrote (assembly)
.rodata   // data that is read-only, cannot be changed
.data     // data that is changable, e.g. global variables
.bss      // uninitialized data (for saving space)
.symtab   // symbol table
.rel.text // relocation entries in .text section
.rel.data // relocation entries in .data section
.debug    // debug symbols
.line     // line numbers
.strtab   // string table
```

+ ```.bss```
	+ This is where we put everything we know that will have value 0 when this program starts running.
	+ E.g. if we know we have a 4096-byte buffer filled with all zeros, then we do not need to put 4096 zeros in our executable on the disk; we just need to remember that when we created it in memory, we expand it out into zeros.
	+ This is where all of those symbols that we know start at zero live.
	+ Hence, it "better saves space".

+ Two pseudo-sections (special section types)
	+ ```COMMON``` (different from ```.bss```!): this is where we put anything that is uninitialized and global. Note that it does not mean initialized to zero, and it does not mean static variables.
	+ ```UNDEF```: this is where we put every single symbol that is referenced here but is not defined here. (like ```fprintf()``` and ```puts()```). Those symbols are eventually going to into one of our real symbol sections, i.e. ```.text```, ```.data``` sections.


+ ```.symtab```, ```.rel.text``` and ```.rel.data```
	+ The symbol table gives us the list of indices for all the symbols in this entire file.
	+ The relocatable text and data sections have a list of relocation entries, which can be regarded as TODOs that the compiler left for itself, saying that, "hey, when the linker links this program, the linker needs to go there, find the symbol and replace it at a memory address"
	+ In this way, the linker gets the locations within the "text" that need to be changed before the program gets linked into an executable, as well as the "data" where things need to get changed before the program can be run.

+ ```.debug```, ```.line```, ```.strtab```:
	+ These are the things that are useful for debugging the program and disassembling the program, but aren't useful when the program is normally running.
	+ ```.debug```: info about stack local variables and other generic things that make gcc able to do its job.
	+ ```.line```: maps individual assembly instructions from our text section onto individual lines of the source c file so that allows us to do things like "break on a line" as opposed to finding the exact offset in the address space of an individual instruction, and setting a breakpoint on that address.
	+ The string table has the mapping between the symbol table entries and the actual string variable name that the humans used to refer to. It contains the names of symbols in ```.symtab``` and ```.debug``` section and section names. Typically NULL-terminated strings.
	+ The debug information will tell us what line we are on, and what memory addresses correspond to what local variables.
	+ The **loader** will throw these information out if it is not actually running the program inside a debugger.


What has been covered:
+ Why do we have linkers?
+ What do linkers do?
	+ Symbol resolution
	+ Relocation
What's next?
+ How do we resolve?
+ How do we relocate?




### How do linkers resolve symbols?
+ What is a symbol?
	+ Anything with a global or module level name.
		+ Functions.
		+ Global variables.
		+ Static variables.
	+ A variable that the linker that needs to care about



Given an object file, it is an intermediate file that contains a bunch of assembly instructions that we wrote and references to the code that in other files (libraries, etc.). The references need to be incorporated into our program to make it runnable (in this case, ```fprintf()``` and ```puts()```). In other words, even if we let the preprocessor to open up ```stdio.h``` and jam it into this file, it is not going to have the definition of ```fprintf()``` or ```puts()```; instead, it is just going to have the definitions for the signatures of those functions, so we know how to call them; but it does not give us the body of those functions.

In order to get the body of the functions, we need to do "relocation"; but 
before we do relocation we need to do "symbol resolution" to figure out which 
```puts()``` or ```fprintf()``` do we want.

+ What is a symbol from programmer's point of view?
	+ Anything with a global-level or module-level name, which includes functions, global variables, and static variables are symbols.
	+ Why static variables are symbols?
		+ Static variables are not visible at all to anywhere else in the entire running program once it is been linked together, but we still need to keep trach of them as symbols because we are going to move them around and give them their own specific home and memory when we turn this into a runnable executable.


Let's take a look at an example: [static_example.c](./static_example.c).
Compile it with ```gcc -c static_example.c```, then read the symbol table within that file by
```
readelf -sW static_example.o
```
we can see there are 21 entries (gcc v9.4.0), in which it contains the symbols for```fprintf()```, ```puts()``` etc, but those are all UND (undefined). It also contains symbols for ```invocations```, ```message```, etc.

One column of the symbol table is named ```Bind```, which means binding.

+ Symbol bindings
	+ Global: symbols defined in current file: e.g. ```int not_defined here;```, ```char message[];```.
	+ Global (external): defined elsewhere, e.g. ```puts()```, ```fprintf()```, ```stderr```.
	+ Local (any variable declared as ```static```)


Two types of symbols:
+ Strong symbols: defined functions, initialized variables.

+ Weak symbols: uninitialized variables.

+ Rules for resolving symbols:
	+ Multiple strong symbols with the same name are not allowed.
	+ When there's a strong and weak, pick the strong symbol.
	+ When there are multiple weak symbols, just pick one (randomly).

Here let's take a look at an example, [weakmain.c](./weakmain.c) and [weaklibrary.c](./weaklibrary.c). When we compile main first, then the library, there will be a warning saying that
```
alignment 1 of symbol 'x' in weakmain.o is smaller than 4 in weaklibrary.o.
```

This is because in weakmain.c, x is defined as a character (alignment 1, byte-aligned) while in weaklibrary.c, x is defined as an integer (alignment 4, word-aligned).


The output is ```;)```, which is not ```ab``` as expected. Why? This is because at the beginning, x is a and y is b, but when we get to ```f()``` in main, it reaches weaklibrary.c where ```f()``` is defined, and such file initialized x as an integer, which takes up 4 bytes. Hence, that will overwrite not only x, but also y.

What is the take away? C is very low level, and C trusts programmers that they would not make mistakes when operating on memory. Hence, be careful!

How your linker gets confused:

+ The linker scans files in the order they appear on the command line. 
+ The linker keeps track of
	+ E: the set of relocatable object files that will be merged
	+ U: the set of unresolved symbols
	+ D: the set of symbols that have been defined in previous input files
+ Object files from archives are only added to E if they contain symbols from U.
	+ When they get added, the whole object file gets added.

See the following Makefile example:
```
(CCOPTS) = gcc -fno-pie -no-pie

main: main.c sum.o
	$(CCOPTS) -c main.c
	$(CCOPTS) -c sum.c
	$(CCOPTS) -o main main.o sum.o

sum.o: sum.c sum.h
	$(CCOPTS) -c sum.c

libsum.a: sum.o
	ar r libsum.a sum.o
	ranlib libsum.a

main_broken: libsum.a main.c
	$(CCOPTS) -L. -lsum main.c -o main

main_fixed: libsum.a main.c
	$(CCOPTS) main.c -L. -lsum -o main
```

The background of this Makefile is - in ```main.c```, it references a function
defined in ```sum.c```. In order to compile the main program, we can execute
the first rule, i.e. ```make main```, where we compile ```main.c```, then
```sum.c```, then finally turn ```main.o``` into an executable.

There is another way of doing that, by making ```sum``` into a library. Then,
compile main.c specifying the library to be linked while compiling. Here we 
compile the ```sum.c``` file into a library - ```libsum.a```, such 
library will be linked later when compiling the final executable ```main```.

There are two rules: ```main_broken``` and ```main_fixed```. The first one will 
generate an error while linking, while the latter one will not. The only 
difference between the two is the order of ```-L. -lsum``` and ```main.c```.

As the linker goes through each file (.o, .a), it will pick up references 
(symbols that need to be resolved),  When in later files the linker finds the
definition of the symbol that needs to be resolved, it will disambiguate them
one by one. However, **it only goes through once, and it does not remember 
anything if it is not a reference that needs to be resolved.**

Hence, for the rule ```main_broken```, it goes through the libsum first, but
since the symbol in main.c has not been recognized by the linker, the linker
will basically ignore all functions in libsum, which will result in an error
when it comes to main.c. 

That is why we need to go through main.c first, turn it into main.o, which has
```.rel.text``` section that contains the symbol of ```sum()``` defined in 
libsum. Next, the linker will go through the libsum and find the definition of
```sum()```, which will not generate an error.

What has been covered?
+ How do we resolve symbols?
	+ Depends on binding
	+ Depends on strong/weak
	+ Can easily mess up

+ What's next?
	+ Fix references to symbols
	+ Then we will have machine code with references to start executing code.

