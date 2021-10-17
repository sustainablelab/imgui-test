I create this Git repository to test IMGUI:

```bash
$ cd ~/gitrepos
$ mkdir imgui-test
$ cd imgui-test
$ git init
```

I add IMGUI as a Git Submodule:

```bash
$ cd ~/gitrepos/imgui-test
$ git submodule add https://github.com/ocornut/imgui.git
```

Test gcc. Create `bob.c`:

```c
int main(void){}
```

Generate disassembly:

```bash
$ gcc -S bob.c 
```

Open `bob.s`:

```asm
	.file	"bob.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
    ...
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (Rev5, Built by MSYS2 project) 10.3.0"
```

I create a Makefile similar to the IMGUI examples Makefile, but I
can simplify it a lot because I don't need to generalize for all
frameworks and all operating systems.

Start the Makefile with this simple recipe to find out what
compiler is invoked by variable `CXX`:

```make
.PHONY:
what-compiler: 
	@echo $(CXX)
```

- `echo` prints recipe and its result to stdout
- `@echo` prints only the result (recipe is silenced)

Find out what the compiler is:

```bash
$ make
g++
```
